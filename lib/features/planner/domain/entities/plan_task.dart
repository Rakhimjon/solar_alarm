class PlanTask {
  final String id;
  final String title;
  final int targetMinutes;
  final int completedMinutes;
  final bool isCompleted;
  final bool useTimer;
  final DateTime createdAt;
  final String? category;

  const PlanTask({
    required this.id,
    required this.title,
    this.targetMinutes = 25,
    this.completedMinutes = 0,
    this.isCompleted = false,
    this.useTimer = true,
    required this.createdAt,
    this.category,
  });

  PlanTask copyWith({
    String? id,
    String? title,
    int? targetMinutes,
    int? completedMinutes,
    bool? isCompleted,
    bool? useTimer,
    DateTime? createdAt,
    String? category,
  }) {
    return PlanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      useTimer: useTimer ?? this.useTimer,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
