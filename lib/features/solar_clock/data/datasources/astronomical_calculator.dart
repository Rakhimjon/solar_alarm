import 'dart:math';

import '../../domain/entities/solar_time_item.dart';

class AstronomicalCalculator {
  static const double _deg2rad = pi / 180.0;
  static const double _rad2deg = 180.0 / pi;

  /// Calculates astronomical solar and prayer times for given date and coordinates.
  DaySolarCycle calculateCycle({
    required DateTime date,
    required double lat,
    required double lng,
  }) {
    final julianDay = _julianDate(date.year, date.month, date.day);
    final d = julianDay - 2451545.0;

    // Mean anomaly of the Sun
    final g = (357.529 + 0.98560028 * d) % 360.0;
    final gRad = g * _deg2rad;

    // Mean longitude of the Sun
    final q = (280.459 + 0.98564736 * d) % 360.0;

    // Geocentric apparent ecliptic longitude
    final l = (q + 1.915 * sin(gRad) + 0.020 * sin(2 * gRad)) % 360.0;
    final lRad = l * _deg2rad;

    // Mean obliquity of the ecliptic
    final e = 23.439 - 0.00000036 * d;
    final eRad = e * _deg2rad;

    // Sun Right Ascension and Declination
    final sinDecl = sin(eRad) * sin(lRad);
    final decl = asin(sinDecl);

    final y = cos(eRad) * sin(lRad);
    final x = cos(lRad);
    var ra = atan2(y, x) * _rad2deg;
    ra = (ra / 15.0) % 24.0;

    // Equation of time in hours
    final eqt = (q / 15.0) - ra;

    // Solar noon (in local time)
    final timezoneOffsetHours = date.timeZoneOffset.inMinutes / 60.0;
    final noonHours = 12.0 + timezoneOffsetHours - (lng / 15.0) - eqt;

    final latRad = lat * _deg2rad;

    // Helper to calculate time offset from noon based on sun altitude angle
    double? getHourAngle(double sunAltitude) {
      final altRad = sunAltitude * _deg2rad;
      final cosH =
          (sin(altRad) - sin(latRad) * sin(decl)) / (cos(latRad) * cos(decl));
      if (cosH > 1.0 || cosH < -1.0) return null;
      return acos(cosH) * _rad2deg / 15.0;
    }

    // Fajr (18° below horizon)
    final fajrHa = getHourAngle(-18.0) ?? 6.0;
    final fajrHours = noonHours - fajrHa;

    // Sunrise (-0.833° horizon crossing)
    final sunriseHa = getHourAngle(-0.833) ?? 6.0;
    final sunriseHours = noonHours - sunriseHa;

    // Dhuhr (solar noon)
    final dhuhrHours = noonHours;

    // Asr (Shafi'i shadow factor = 1.0)
    final asrAlt = atan(1.0 / (1.0 + tan((latRad - decl).abs()))) * _rad2deg;
    final asrHa = getHourAngle(asrAlt) ?? 3.0;
    final asrHours = noonHours + asrHa;

    // Maghrib (sunset: -0.833°)
    final maghribHours = noonHours + sunriseHa;

    // Isha (17° below horizon)
    final ishaHa = getHourAngle(-17.0) ?? 6.0;
    final ishaHours = noonHours + ishaHa;

    DateTime toDateTime(double decimalHours) {
      var totalMinutes = (decimalHours * 60).round();
      final dayShift = totalMinutes ~/ 1440;
      totalMinutes = totalMinutes % 1440;
      if (totalMinutes < 0) totalMinutes += 1440;
      final h = totalMinutes ~/ 60;
      final m = totalMinutes % 60;
      return DateTime(date.year, date.month, date.day + dayShift, h, m);
    }

    final now = DateTime.now();
    final items = [
      SolarTimeItem(
        type: SolarEventType.fajr,
        title: SolarEventType.fajr.titleUz,
        time: toDateTime(fajrHours),
        icon: SolarEventType.fajr.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.sunrise,
        title: SolarEventType.sunrise.titleUz,
        time: toDateTime(sunriseHours),
        icon: SolarEventType.sunrise.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.dhuhr,
        title: SolarEventType.dhuhr.titleUz,
        time: toDateTime(dhuhrHours),
        icon: SolarEventType.dhuhr.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.asr,
        title: SolarEventType.asr.titleUz,
        time: toDateTime(asrHours),
        icon: SolarEventType.asr.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.maghrib,
        title: SolarEventType.maghrib.titleUz,
        time: toDateTime(maghribHours),
        icon: SolarEventType.maghrib.iconAsset,
      ),
      SolarTimeItem(
        type: SolarEventType.isha,
        title: SolarEventType.isha.titleUz,
        time: toDateTime(ishaHours),
        icon: SolarEventType.isha.iconAsset,
      ),
    ];

    // Find next event
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
    } else {
      // Tomorrow Fajr
      final tomorrowCycle = calculateCycle(
        date: date.add(const Duration(days: 1)),
        lat: lat,
        lng: lng,
      );
      next = tomorrowCycle.items.first;
      timeUntil = next.time.difference(now);
    }

    // Day progress (from sunrise to sunset or whole 24h)
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

  double _julianDate(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }
}
