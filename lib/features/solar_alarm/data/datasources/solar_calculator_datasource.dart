import 'dart:math';
import '../../domain/entities/solar_types.dart';

class SolarCalculatorDataSource {
  static const double _deg2rad = pi / 180.0;
  static const double _rad2deg = 180.0 / pi;

  DateTime getSolarTime({
    required DateTime date,
    required double lat,
    required double lng,
    required SolarEvent event,
    int offsetMinutes = 0,
  }) {
    final dayOfYear = int.parse(
          DateTime(date.year, date.month, date.day)
              .difference(DateTime(date.year, 1, 1))
              .inDays
              .toString(),
        ) +
        1;

    final gamma = (2 * pi / 365) * (dayOfYear - 1);
    final eqtime = 229.18 *
        (0.000075 +
            0.001868 * cos(gamma) -
            0.032077 * sin(gamma) -
            0.014615 * cos(2 * gamma) -
            0.040849 * sin(2 * gamma));
    final decl = 0.006918 -
        0.399912 * cos(gamma) +
        0.070257 * sin(gamma) -
        0.006758 * cos(2 * gamma) +
        0.000907 * sin(2 * gamma) -
        0.002697 * cos(3 * gamma) +
        0.00148 * sin(3 * gamma);

    const zenith = 90.833 * _deg2rad;
    final latRad = lat * _deg2rad;
    final cosHa =
        (cos(zenith) / (cos(latRad) * cos(decl))) - (tan(latRad) * tan(decl));

    final ha = acos(cosHa.clamp(-1.0, 1.0)) * _rad2deg;
    final minutesUtc = (event == SolarEvent.sunrise)
        ? 720 - 4 * (lng + ha) - eqtime
        : 720 - 4 * (lng - ha) - eqtime;

    final offset = date.timeZoneOffset.inMinutes;
    final totalMinutes = (minutesUtc + offset).round() + offsetMinutes;

    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime getNextAlarmTime({
    required double lat,
    required double lng,
    required SolarEvent event,
    int offsetMinutes = 0,
  }) {
    final now = DateTime.now();
    final todayTime = getSolarTime(
      date: now,
      lat: lat,
      lng: lng,
      event: event,
      offsetMinutes: offsetMinutes,
    );

    if (todayTime.isAfter(now)) {
      return todayTime;
    }

    final tomorrow = now.add(const Duration(days: 1));
    return getSolarTime(
      date: tomorrow,
      lat: lat,
      lng: lng,
      event: event,
      offsetMinutes: offsetMinutes,
    );
  }
}
