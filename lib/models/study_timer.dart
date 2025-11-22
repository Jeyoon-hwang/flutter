import 'package:flutter/material.dart';

/// Study timer for tracking pure study time (순공 시간)
/// Inspired by 열품타 (YPT) but integrated with our planner system
class StudyTimer {
  final String id;
  final String subject; // 과목
  final DateTime startTime;
  DateTime? endTime;
  Duration pausedDuration; // 일시정지 시간
  bool isActive;
  bool isPaused;

  StudyTimer({
    required this.id,
    required this.subject,
    required this.startTime,
    this.endTime,
    this.pausedDuration = Duration.zero,
    this.isActive = true,
    this.isPaused = false,
  });

  /// Get pure study time (순공 시간) excluding paused time
  Duration get pureStudyTime {
    if (endTime == null) {
      return DateTime.now().difference(startTime) - pausedDuration;
    }
    return endTime!.difference(startTime) - pausedDuration;
  }

  /// Format duration as "2h 35m"
  String get formattedTime {
    final duration = pureStudyTime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'pausedDuration': pausedDuration.inSeconds,
    'isActive': isActive,
    'isPaused': isPaused,
  };

  factory StudyTimer.fromJson(Map<String, dynamic> json) => StudyTimer(
    id: json['id'],
    subject: json['subject'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    pausedDuration: Duration(seconds: json['pausedDuration'] ?? 0),
    isActive: json['isActive'] ?? true,
    isPaused: json['isPaused'] ?? false,
  );
}

/// Subject-wise study statistics (과목별 통계)
class SubjectStats {
  final String subject;
  final Duration totalTime;
  final int sessionCount;
  final DateTime lastStudied;

  SubjectStats({
    required this.subject,
    required this.totalTime,
    required this.sessionCount,
    required this.lastStudied,
  });

  String get formattedTotalTime {
    final hours = totalTime.inHours;
    final minutes = totalTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  double get averageSessionMinutes => totalTime.inMinutes / sessionCount;
}

/// Daily study summary (하루 통계)
class DailyStudySummary {
  final DateTime date;
  final Duration totalStudyTime;
  final Map<String, Duration> subjectTimes; // 과목별 시간
  final int totalSessions;
  final Duration longestSession;

  DailyStudySummary({
    required this.date,
    required this.totalStudyTime,
    required this.subjectTimes,
    required this.totalSessions,
    required this.longestSession,
  });

  String get formattedTotalTime {
    final hours = totalStudyTime.inHours;
    final minutes = totalStudyTime.inMinutes.remainder(60);
    return '${hours}시간 ${minutes}분';
  }

  /// Get top 3 subjects by time
  List<MapEntry<String, Duration>> get topSubjects {
    final entries = subjectTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).toList();
  }
}

/// Study timer manager
class StudyTimerManager extends ChangeNotifier {
  StudyTimer? _activeTimer;
  final List<StudyTimer> _completedTimers = [];
  DateTime? _pauseStartTime;

  StudyTimer? get activeTimer => _activeTimer;
  bool get isTimerActive => _activeTimer != null && _activeTimer!.isActive;
  bool get isTimerPaused => _activeTimer?.isPaused ?? false;

  /// Start a new study session
  void startTimer(String subject) {
    // End current timer if exists
    if (_activeTimer != null) {
      endTimer();
    }

    _activeTimer = StudyTimer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Pause current timer
  void pauseTimer() {
    if (_activeTimer == null || _activeTimer!.isPaused) return;

    _activeTimer!.isPaused = true;
    _pauseStartTime = DateTime.now();
    notifyListeners();
  }

  /// Resume paused timer
  void resumeTimer() {
    if (_activeTimer == null || !_activeTimer!.isPaused) return;

    if (_pauseStartTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseStartTime!);
      _activeTimer!.pausedDuration += pauseDuration;
    }

    _activeTimer!.isPaused = false;
    _pauseStartTime = null;
    notifyListeners();
  }

  /// End current timer
  void endTimer() {
    if (_activeTimer == null) return;

    _activeTimer!.isActive = false;
    _activeTimer!.endTime = DateTime.now();

    // Save to completed
    _completedTimers.add(_activeTimer!);
    _activeTimer = null;
    _pauseStartTime = null;

    notifyListeners();
  }

  /// Get today's total study time
  Duration getTodayTotalTime() {
    final today = DateTime.now();
    Duration total = Duration.zero;

    // Add completed timers from today
    for (final timer in _completedTimers) {
      if (_isSameDay(timer.startTime, today)) {
        total += timer.pureStudyTime;
      }
    }

    // Add active timer if exists
    if (_activeTimer != null && _isSameDay(_activeTimer!.startTime, today)) {
      total += _activeTimer!.pureStudyTime;
    }

    return total;
  }

  /// Get today's study time by subject
  Map<String, Duration> getTodaySubjectTimes() {
    final today = DateTime.now();
    final Map<String, Duration> subjectTimes = {};

    for (final timer in _completedTimers) {
      if (_isSameDay(timer.startTime, today)) {
        subjectTimes[timer.subject] =
          (subjectTimes[timer.subject] ?? Duration.zero) + timer.pureStudyTime;
      }
    }

    if (_activeTimer != null && _isSameDay(_activeTimer!.startTime, today)) {
      subjectTimes[_activeTimer!.subject] =
        (subjectTimes[_activeTimer!.subject] ?? Duration.zero) + _activeTimer!.pureStudyTime;
    }

    return subjectTimes;
  }

  /// Get daily summary for a specific date
  DailyStudySummary getDailySummary(DateTime date) {
    final timers = _completedTimers.where((t) => _isSameDay(t.startTime, date)).toList();

    Duration totalTime = Duration.zero;
    Map<String, Duration> subjectTimes = {};
    Duration longestSession = Duration.zero;

    for (final timer in timers) {
      totalTime += timer.pureStudyTime;
      subjectTimes[timer.subject] =
        (subjectTimes[timer.subject] ?? Duration.zero) + timer.pureStudyTime;

      if (timer.pureStudyTime > longestSession) {
        longestSession = timer.pureStudyTime;
      }
    }

    return DailyStudySummary(
      date: date,
      totalStudyTime: totalTime,
      subjectTimes: subjectTimes,
      totalSessions: timers.length,
      longestSession: longestSession,
    );
  }

  /// Get weekly summaries (last 7 days)
  List<DailyStudySummary> getWeeklySummaries() {
    final summaries = <DailyStudySummary>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      summaries.add(getDailySummary(date));
    }

    return summaries;
  }

  /// Get subject statistics
  List<SubjectStats> getSubjectStats() {
    final Map<String, List<StudyTimer>> subjectTimers = {};

    for (final timer in _completedTimers) {
      subjectTimers.putIfAbsent(timer.subject, () => []).add(timer);
    }

    return subjectTimers.entries.map((entry) {
      final timers = entry.value;
      final totalTime = timers.fold<Duration>(
        Duration.zero,
        (sum, timer) => sum + timer.pureStudyTime,
      );
      final lastStudied = timers.map((t) => t.startTime).reduce(
        (a, b) => a.isAfter(b) ? a : b,
      );

      return SubjectStats(
        subject: entry.key,
        totalTime: totalTime,
        sessionCount: timers.length,
        lastStudied: lastStudied,
      );
    }).toList()
      ..sort((a, b) => b.totalTime.compareTo(a.totalTime));
  }

  /// Get study streak (연속 공부 일수)
  int getStudyStreak() {
    if (_completedTimers.isEmpty) return 0;

    int streak = 0;
    DateTime currentDay = DateTime.now();

    while (true) {
      final hasStudied = _completedTimers.any((t) => _isSameDay(t.startTime, currentDay));

      if (!hasStudied) {
        // Check if today (allow 0 study for today)
        if (_isSameDay(currentDay, DateTime.now())) {
          currentDay = currentDay.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      streak++;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get current timer display time (for UI)
  String getCurrentTimerDisplay() {
    if (_activeTimer == null) return '0m';
    return _activeTimer!.formattedTime;
  }

  /// Clear all timers (for testing)
  void clearAll() {
    _activeTimer = null;
    _completedTimers.clear();
    _pauseStartTime = null;
    notifyListeners();
  }
}
