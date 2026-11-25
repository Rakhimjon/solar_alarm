import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_alarm/core/services/alarm_local_datasource.dart';
import 'package:solar_alarm/features/solar_clock/data/datasources/astronomical_calculator.dart';
import 'package:solar_alarm/features/solar_clock/data/datasources/prayer_times_remote_datasource.dart';
import 'package:solar_alarm/features/solar_clock/data/repositories/solar_clock_repository_impl.dart';
import 'package:solar_alarm/features/solar_clock/domain/entities/solar_time_item.dart';

class FakeRemoteDataSource implements PrayerTimesRemoteDataSource {
  DaySolarCycle? mockCycle;

  @override
  Future<DaySolarCycle?> fetchDayCycle({
    required DateTime date,
    required double lat,
    required double lng,
    String region = 'Toshkent',
  }) async {
    return mockCycle;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SolarClockRepositoryImpl returns remote cycle when available, falls back to calculator when null', () async {
    SharedPreferences.setMockInitialValues({});
    final calculator = AstronomicalCalculator();
    final fakeRemote = FakeRemoteDataSource();
    final alarmDataSource = AlarmLocalDataSource();

    final repo = SolarClockRepositoryImpl(
      calculator: calculator,
      remoteDataSource: fakeRemote,
      alarmDataSource: alarmDataSource,
    );

    // 1. When remote is null, falls back to astronomical calculation
    final fallbackCycle = await repo.getDayCycle(
      date: DateTime(2026, 11, 24),
      lat: 41.311,
      lng: 69.240,
    );
    expect(fallbackCycle.items.length, 6);
    expect(fallbackCycle.items.first.type, SolarEventType.fajr);

    // 2. When remote returns cycle, repository uses remote cycle
    fakeRemote.mockCycle = DaySolarCycle(
      date: DateTime(2026, 11, 24),
      items: [
        SolarTimeItem(
          type: SolarEventType.fajr,
          title: 'Bomdod',
          time: DateTime(2026, 11, 24, 5, 45),
          icon: '🌅',
        ),
      ],
    );

    final remoteCycle = await repo.getDayCycle(
      date: DateTime(2026, 11, 24),
      lat: 41.311,
      lng: 69.240,
    );
    expect(remoteCycle.items.first.time.hour, 5);
    expect(remoteCycle.items.first.time.minute, 45);
  });
}
