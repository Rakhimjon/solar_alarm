import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/solar_time_item.dart';

abstract class PrayerTimesRemoteDataSource {
  Future<DaySolarCycle?> fetchDayCycle({
    required DateTime date,
    required double lat,
    required double lng,
  });
}

class PrayerTimesRemoteDataSourceImpl implements PrayerTimesRemoteDataSource {
  final SharedPreferences prefs;
  final HttpClient _client;

  PrayerTimesRemoteDataSourceImpl({
    required this.prefs,
    HttpClient? client,
  }) : _client = client ?? (HttpClient()..connectionTimeout = const Duration(seconds: 4));

  @override
  Future<DaySolarCycle?> fetchDayCycle({
    required DateTime date,
    required double lat,
    required double lng,
  }) async {
    final cacheKey = 'prayer_times_${date.year}_${date.month}_${date.day}';

    // 1. Try islomapi.uz (O'zbekiston rasmiy taqvimi)
    try {
      final cycle = await _fetchFromIslomApi(date);
      if (cycle != null) {
        _cacheTimes(cacheKey, cycle);
        return cycle;
      }
    } catch (_) {}

    // 2. Try Aladhan API as reliable backup
    try {
      final cycle = await _fetchFromAladhan(date, lat, lng);
      if (cycle != null) {
        _cacheTimes(cacheKey, cycle);
        return cycle;
      }
    } catch (_) {}

    // 3. Fallback to cached times if available
    final cached = _getCachedTimes(cacheKey, date);
    if (cached != null) {
      return cached;
    }

    return null;
  }

  Future<DaySolarCycle?> _fetchFromIslomApi(DateTime date) async {
    final url = Uri.parse('https://islomapi.uz/api/present/day?region=Toshkent');
    final jsonMap = await _getJson(url);
    if (jsonMap == null || !jsonMap.containsKey('times')) return null;

    final times = jsonMap['times'] as Map<String, dynamic>;
    return _buildCycleFromStrings(
      date: date,
      fajrStr: times['tong_saharlik'] as String?,
      sunriseStr: times['quyosh'] as String?,
      dhuhrStr: times['peshin'] as String?,
      asrStr: times['asr'] as String?,
      maghribStr: times['shom_iftor'] as String?,
      ishaStr: times['hufton'] as String?,
    );
  }

  Future<DaySolarCycle?> _fetchFromAladhan(DateTime date, double lat, double lng) async {
    final formattedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity/$formattedDate?city=Tashkent&country=Uzbekistan&method=3',
    );
    final jsonMap = await _getJson(url);
    if (jsonMap == null || !jsonMap.containsKey('data')) return null;

    final data = jsonMap['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>?;
    if (timings == null) return null;

    return _buildCycleFromStrings(
      date: date,
      fajrStr: timings['Fajr'] as String?,
      sunriseStr: timings['Sunrise'] as String?,
      dhuhrStr: timings['Dhuhr'] as String?,
      asrStr: timings['Asr'] as String?,
      maghribStr: timings['Maghrib'] as String?,
      ishaStr: timings['Isha'] as String?,
    );
  }

  Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    try {
      final request = await _client.getUrl(uri).timeout(const Duration(seconds: 4));
      request.headers.set('User-Agent', 'SolarAlarmApp/1.0');
      request.followRedirects = true;
      request.maxRedirects = 5;

      final response = await request.close().timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  DaySolarCycle? _buildCycleFromStrings({
    required DateTime date,
    required String? fajrStr,
    required String? sunriseStr,
    required String? dhuhrStr,
    required String? asrStr,
    required String? maghribStr,
    required String? ishaStr,
  }) {
    if (fajrStr == null ||
        sunriseStr == null ||
        dhuhrStr == null ||
        asrStr == null ||
        maghribStr == null ||
        ishaStr == null) {
      return null;
    }

    DateTime parseTime(String str) {
      final clean = str.split(' ').first; // remove any (EST) or timezone suffix
      final parts = clean.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, h, m);
    }

    final items = [
      SolarTimeItem(
        type: SolarEventType.fajr,
        title: SolarEventType.fajr.titleUz,
        time: parseTime(fajrStr),
        icon: SolarEventType.fajr.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.sunrise,
        title: SolarEventType.sunrise.titleUz,
        time: parseTime(sunriseStr),
        icon: SolarEventType.sunrise.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.dhuhr,
        title: SolarEventType.dhuhr.titleUz,
        time: parseTime(dhuhrStr),
        icon: SolarEventType.dhuhr.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.asr,
        title: SolarEventType.asr.titleUz,
        time: parseTime(asrStr),
        icon: SolarEventType.asr.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.maghrib,
        title: SolarEventType.maghrib.titleUz,
        time: parseTime(maghribStr),
        icon: SolarEventType.maghrib.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.isha,
        title: SolarEventType.isha.titleUz,
        time: parseTime(ishaStr),
        icon: SolarEventType.isha.iconAsset,
      ),
    ];

    final now = DateTime.now();
    SolarTimeItem? next;
    for (final item in items) {
      if (item.time.isAfter(now)) {
        next = item;
        break;
      }
    }

    Duration? timeUntil;
    if (next != null) {
      timeUntil = next.time.difference(now);
    }

    final sunriseTime = items[1].time;
    final sunsetTime = items[4].time;
    double progress = 0.0;
    if (now.isAfter(sunriseTime) && now.isBefore(sunsetTime)) {
      final totalDaylight = sunsetTime.difference(sunriseTime).inSeconds;
      final elapsed = now.difference(sunriseTime).inSeconds;
      progress = (elapsed / totalDaylight).clamp(0.0, 1.0);
    } else if (now.isAfter(sunsetTime)) {
      progress = 1.0;
    }

    return DaySolarCycle(
      date: date,
      items: items,
      nextEvent: next,
      timeUntilNext: timeUntil,
      dayProgress: progress,
    );
  }

  void _cacheTimes(String key, DaySolarCycle cycle) {
    try {
      final map = {
        for (final item in cycle.items)
          item.type.name: '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
      };
      prefs.setString(key, jsonEncode(map));
    } catch (_) {}
  }

  DaySolarCycle? _getCachedTimes(String key, DateTime date) {
    try {
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;

      return _buildCycleFromStrings(
        date: date,
        fajrStr: map[SolarEventType.fajr.name] as String?,
        sunriseStr: map[SolarEventType.sunrise.name] as String?,
        dhuhrStr: map[SolarEventType.dhuhr.name] as String?,
        asrStr: map[SolarEventType.asr.name] as String?,
        maghribStr: map[SolarEventType.maghrib.name] as String?,
        ishaStr: map[SolarEventType.isha.name] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
