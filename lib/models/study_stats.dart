/// Study statistics model for tracking learning progress
class StudyStats {
  final DateTime date;
  final Duration studyDuration; // 순공 시간
  final int problemsSolved; // 푼 문제 수
  final int correctAnswers; // 정답 수
  final Map<String, Duration> subjectDurations; // 과목별 학습 시간
  final List<String> completedTasks; // 완료한 작업들

  StudyStats({
    required this.date,
    required this.studyDuration,
    this.problemsSolved = 0,
    this.correctAnswers = 0,
    Map<String, Duration>? subjectDurations,
    List<String>? completedTasks,
  })  : subjectDurations = subjectDurations ?? {},
        completedTasks = completedTasks ?? [];

  /// Calculate accuracy rate
  double get accuracyRate {
    if (problemsSolved == 0) return 0.0;
    return (correctAnswers / problemsSolved) * 100;
  }

  /// Format duration as "Xh Ym"
  String get formattedDuration {
    final hours = studyDuration.inHours;
    final minutes = studyDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'studyDuration': studyDuration.inSeconds,
      'problemsSolved': problemsSolved,
      'correctAnswers': correctAnswers,
      'subjectDurations': subjectDurations.map(
        (key, value) => MapEntry(key, value.inSeconds),
      ),
      'completedTasks': completedTasks,
    };
  }

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    return StudyStats(
      date: DateTime.parse(json['date'] as String),
      studyDuration: Duration(seconds: json['studyDuration'] as int),
      problemsSolved: json['problemsSolved'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      subjectDurations: (json['subjectDurations'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Duration(seconds: value as int)),
          ) ??
          {},
      completedTasks: (json['completedTasks'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  StudyStats copyWith({
    DateTime? date,
    Duration? studyDuration,
    int? problemsSolved,
    int? correctAnswers,
    Map<String, Duration>? subjectDurations,
    List<String>? completedTasks,
  }) {
    return StudyStats(
      date: date ?? this.date,
      studyDuration: studyDuration ?? this.studyDuration,
      problemsSolved: problemsSolved ?? this.problemsSolved,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      subjectDurations: subjectDurations ?? this.subjectDurations,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}

/// Weekly study goal
class WeeklyGoal {
  final Duration targetDuration; // 목표 학습 시간
  final int targetProblems; // 목표 문제 수
  final DateTime weekStart;

  WeeklyGoal({
    required this.targetDuration,
    required this.targetProblems,
    required this.weekStart,
  });

  DateTime get weekEnd => weekStart.add(const Duration(days: 7));

  Map<String, dynamic> toJson() {
    return {
      'targetDuration': targetDuration.inSeconds,
      'targetProblems': targetProblems,
      'weekStart': weekStart.toIso8601String(),
    };
  }

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      targetDuration: Duration(seconds: json['targetDuration'] as int),
      targetProblems: json['targetProblems'] as int,
      weekStart: DateTime.parse(json['weekStart'] as String),
    );
  }
}

/// Study statistics manager
class StudyStatsManager {
  final List<StudyStats> _dailyStats = [];
  WeeklyGoal? _currentWeeklyGoal;

  // Current session tracking
  DateTime? _sessionStartTime;
  String? _currentSubject;
  final Map<String, Duration> _sessionSubjectDurations = {};

  List<StudyStats> get dailyStats => List.unmodifiable(_dailyStats);
  WeeklyGoal? get currentWeeklyGoal => _currentWeeklyGoal;

  /// Start a study session
  void startSession({String? subject}) {
    _sessionStartTime = DateTime.now();
    _currentSubject = subject;
  }

  /// End current session and record duration
  void endSession() {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!);

    if (_currentSubject != null) {
      _sessionSubjectDurations[_currentSubject!] =
          (_sessionSubjectDurations[_currentSubject!] ?? Duration.zero) + duration;
    }

    _sessionStartTime = null;
    _currentSubject = null;
  }

  /// Get today's stats
  StudyStats getTodayStats() {
    final today = DateTime.now();
    final todayStats = _dailyStats.firstWhere(
      (stat) =>
          stat.date.year == today.year &&
          stat.date.month == today.month &&
          stat.date.day == today.day,
      orElse: () => StudyStats(
        date: today,
        studyDuration: Duration.zero,
      ),
    );

    // Add current session duration if active
    if (_sessionStartTime != null) {
      final currentDuration = DateTime.now().difference(_sessionStartTime!);
      return todayStats.copyWith(
        studyDuration: todayStats.studyDuration + currentDuration,
      );
    }

    return todayStats;
  }

  /// Get week's stats
  List<StudyStats> getWeekStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return _dailyStats.where((stat) {
      return stat.date.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate weekly goal achievement percentage
  double getWeeklyGoalAchievement() {
    if (_currentWeeklyGoal == null) return 0.0;

    final weekStats = getWeekStats();
    final totalDuration = weekStats.fold<Duration>(
      Duration.zero,
      (sum, stat) => sum + stat.studyDuration,
    );

    return (totalDuration.inSeconds / _currentWeeklyGoal!.targetDuration.inSeconds) * 100;
  }

  /// Get consecutive study days (streak)
  int getStudyStreak() {
    if (_dailyStats.isEmpty) return 0;

    final sortedStats = List<StudyStats>.from(_dailyStats)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var stat in sortedStats) {
      final statDate = DateTime(stat.date.year, stat.date.month, stat.date.day);
      final compareDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (statDate == compareDate || statDate == compareDate.subtract(const Duration(days: 1))) {
        if (stat.studyDuration.inMinutes >= 30) {
          // 최소 30분 학습해야 streak 카운트
          streak++;
          checkDate = stat.date.subtract(const Duration(days: 1));
        }
      } else {
        break;
      }
    }

    return streak;
  }

  /// Add study stats for a day
  void addDailyStats(StudyStats stats) {
    final index = _dailyStats.indexWhere((s) =>
        s.date.year == stats.date.year &&
        s.date.month == stats.date.month &&
        s.date.day == stats.date.day);

    if (index != -1) {
      _dailyStats[index] = stats;
    } else {
      _dailyStats.add(stats);
    }
  }

  /// Set weekly goal
  void setWeeklyGoal(WeeklyGoal goal) {
    _currentWeeklyGoal = goal;
  }

  /// Record completed task
  void recordCompletedTask(String taskId) {
    final today = getTodayStats();
    final updatedTasks = List<String>.from(today.completedTasks)..add(taskId);
    addDailyStats(today.copyWith(completedTasks: updatedTasks));
  }

  /// Record problem solved
  void recordProblemSolved(bool isCorrect) {
    final today = getTodayStats();
    addDailyStats(today.copyWith(
      problemsSolved: today.problemsSolved + 1,
      correctAnswers: today.correctAnswers + (isCorrect ? 1 : 0),
    ));
  }
}
