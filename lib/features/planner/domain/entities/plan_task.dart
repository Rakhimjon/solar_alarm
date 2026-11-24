class PlanTask {
  final String id;
  final String title;
  final int targetMinutes;
  final int completedMinutes;
  final bool isCompleted;
  final DateTime createdAt;
  final String? category;

  const PlanTask({
    required this.id,
    required this.title,
    this.targetMinutes = 25,
    this.completedMinutes = 0,
    this.isCompleted = false,
    required this.createdAt,
    this.category,
  });

  PlanTask copyWith({
    String? id,
    String? title,
    int? targetMinutes,
    int? completedMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    String? category,
  }) {
    return PlanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
