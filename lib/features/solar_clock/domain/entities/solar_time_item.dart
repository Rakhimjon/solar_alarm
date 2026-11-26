enum SolarEventType { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension SolarEventTypeX on SolarEventType {
  String get titleUz {
    switch (this) {
      case SolarEventType.fajr:
        return 'Bomdod';
      case SolarEventType.sunrise:
        return 'Quyosh chiqishi';
      case SolarEventType.dhuhr:
        return 'Peshin';
      case SolarEventType.asr:
        return 'Asr';
      case SolarEventType.maghrib:
        return 'Shom';
      case SolarEventType.isha:
        return 'Xufton';
    }
  }

  String get iconAsset {
    switch (this) {
      case SolarEventType.fajr:
        return '🌅';
      case SolarEventType.sunrise:
        return '☀️';
      case SolarEventType.dhuhr:
        return '☀️';
      case SolarEventType.asr:
        return '🌤️';
      case SolarEventType.maghrib:
        return '🌇';
      case SolarEventType.isha:
        return '🌙';
    }
  }
}

class SolarTimeItem {
  final SolarEventType type;
  final String title;
  final DateTime time;
  final String icon;
  final bool isUpcoming;

  const SolarTimeItem({
    required this.type,
    required this.title,
    required this.time,
    required this.icon,
    this.isUpcoming = false,
  });
}

class DaySolarCycle {
  final DateTime date;
  final List<SolarTimeItem> items;
  final SolarTimeItem? nextEvent;
  final Duration? timeUntilNext;
  final double dayProgress; // 0.0 to 1.0 (sun position)

  const DaySolarCycle({
    required this.date,
    required this.items,
    this.nextEvent,
    this.timeUntilNext,
    this.dayProgress = 0.0,
  });
}
