enum FocusStatus { idle, running, paused, completed }

class FocusTimerState {
  final FocusStatus status;
  final int totalSeconds;
  final int remainingSeconds;
  final String? activeTaskId;
  final String? activeTaskTitle;
  final bool isDeepWorkEnabled;
  final bool isLocked;
  final String? warningMessage;

  const FocusTimerState({
    this.status = FocusStatus.idle,
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.activeTaskId,
    this.activeTaskTitle,
    this.isDeepWorkEnabled = true,
    this.isLocked = false,
    this.warningMessage,
  });

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  FocusTimerState copyWith({
    FocusStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    String? activeTaskId,
    String? activeTaskTitle,
    bool? isDeepWorkEnabled,
    bool? isLocked,
    String? warningMessage,
    bool clearWarning = false,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      activeTaskId: activeTaskId ?? this.activeTaskId,
      activeTaskTitle: activeTaskTitle ?? this.activeTaskTitle,
      isDeepWorkEnabled: isDeepWorkEnabled ?? this.isDeepWorkEnabled,
      isLocked: isLocked ?? this.isLocked,
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
    );
  }
}
