class AlarmSoundOption {
  final String path;
  final String title;

  const AlarmSoundOption({required this.path, required this.title});

  static const List<AlarmSoundOption> all = [
    AlarmSoundOption(path: 'assets/loud_beep.wav', title: 'Baland Raqamli (2.8 kHz)'),
    AlarmSoundOption(path: 'assets/siren_alarm.wav', title: 'Harbiy Sirena'),
    AlarmSoundOption(path: 'assets/alarm.wav', title: 'Klassik Budilnik'),
    AlarmSoundOption(path: 'assets/gentle_chime.wav', title: 'Yumshoq Qo\'ng\'iroq'),
  ];
}

class AlarmItem {
  final int id;
  final int hour;
  final int minute;
  final String label;
  final bool isEnabled;
  final String soundPath;
  final String soundTitle;
  final List<int> repeatDays; // 1 = Dush ... 7 = Yaksh
  final bool vibrate;

  const AlarmItem({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = 'Budilnik',
    this.isEnabled = true,
    this.soundPath = 'assets/loud_beep.wav',
    this.soundTitle = 'Baland Raqamli (2.8 kHz)',
    this.repeatDays = const [],
    this.vibrate = true,
  });

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get repeatDaysText {
    if (repeatDays.isEmpty) return 'Bir martalik';
    if (repeatDays.length == 7) return 'Har kuni';
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5)) {
      return 'Dush - Juma';
    }
    const dayNames = {
      1: 'Du',
      2: 'Se',
      3: 'Chor',
      4: 'Pay',
      5: 'Jum',
      6: 'Shan',
      7: 'Yak',
    };
    return repeatDays.map((d) => dayNames[d] ?? '').join(', ');
  }

  DateTime get nextDateTime {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (repeatDays.isEmpty) {
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // Find next matching weekday
    for (int i = 0; i < 7; i++) {
      final candidate = scheduled.add(Duration(days: i));
      if (repeatDays.contains(candidate.weekday)) {
        if (candidate.isAfter(now)) {
          return candidate;
        }
      }
    }

    return scheduled.add(const Duration(days: 7));
  }

  AlarmItem copyWith({
    int? id,
    int? hour,
    int? minute,
    String? label,
    bool? isEnabled,
    String? soundPath,
    String? soundTitle,
    List<int>? repeatDays,
    bool? vibrate,
  }) {
    return AlarmItem(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      soundPath: soundPath ?? this.soundPath,
      soundTitle: soundTitle ?? this.soundTitle,
      repeatDays: repeatDays ?? this.repeatDays,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'isEnabled': isEnabled,
      'soundPath': soundPath,
      'soundTitle': soundTitle,
      'repeatDays': repeatDays,
      'vibrate': vibrate,
    };
  }

  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem(
      id: json['id'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: json['label'] as String? ?? 'Budilnik',
      isEnabled: json['isEnabled'] as bool? ?? true,
      soundPath: json['soundPath'] as String? ?? 'assets/loud_beep.wav',
      soundTitle: json['soundTitle'] as String? ?? 'Baland Raqamli (2.8 kHz)',
      repeatDays: (json['repeatDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }
}
