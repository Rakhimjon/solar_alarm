class Habit {
  final String id;
  final String name;
  final String emoji;
  final int colorValue; // ARGB32
  final List<int> weekdays; // bo'sh = har kuni; 1=Dush ... 7=Yaksh
  final DateTime createdAt;
  final Set<String> completedDates; // 'yyyy-MM-dd'

  const Habit({
    required this.id,
    required this.name,
    this.emoji = '⭐',
    this.colorValue = 0xFFF59E0B,
    this.weekdays = const [],
    required this.createdAt,
    this.completedDates = const {},
  });

  bool get isEveryDay => weekdays.isEmpty;

  bool isScheduledOn(DateTime day) =>
      isEveryDay || weekdays.contains(day.weekday);

  bool isDoneOn(DateTime day) => completedDates.contains(_dateKey(day));

  String get scheduleText {
    if (isEveryDay || weekdays.length == 7) return 'Har kuni';
    const names = {
      1: 'Du',
      2: 'Se',
      3: 'Chor',
      4: 'Pay',
      5: 'Jum',
      6: 'Shan',
      7: 'Yak',
    };
    return weekdays.map((d) => names[d] ?? '').join(', ');
  }

  /// Joriy streak. Tugamagan kun streakni buzmaydi: bugun rejalashtirilgan
  /// lekin hali bajarilmagan bo'lsa, kechagi kundan hisoblash boshlanadi.
  int currentStreak([DateTime? reference]) {
    final today = _dateOnly(reference ?? DateTime.now());
    var cursor = today;
    if (isScheduledOn(cursor) && !isDoneOn(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    final start = _dateOnly(createdAt);
    while (!cursor.isBefore(start)) {
      if (!isScheduledOn(cursor)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (isDoneOn(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Tarixdagi eng uzun streak (yaratilgan kundan bugungacha).
  int bestStreak([DateTime? reference]) {
    final today = _dateOnly(reference ?? DateTime.now());
    var cursor = _dateOnly(createdAt);
    var best = 0;
    var current = 0;

    while (!cursor.isAfter(today)) {
      if (isScheduledOn(cursor)) {
        if (isDoneOn(cursor)) {
          current++;
          if (current > best) best = current;
        } else {
          current = 0;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return best;
  }

  int get totalCompletions => completedDates.length;

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorValue,
    List<int>? weekdays,
    DateTime? createdAt,
    Set<String>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      weekdays: weekdays ?? this.weekdays,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
        'weekdays': weekdays,
        'createdAt': createdAt.toIso8601String(),
        'completedDates': completedDates.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '⭐',
        colorValue: json['colorValue'] as int? ?? 0xFFF59E0B,
        weekdays: (json['weekdays'] as List<dynamic>? ?? const [])
            .map((e) => e as int)
            .toList(),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
        completedDates: ((json['completedDates'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toSet(),
      );

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
