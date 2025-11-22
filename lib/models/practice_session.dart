import 'package:flutter/material.dart';
import 'layer.dart';

/// Represents a practice session (N회독)
/// Each session has its own layer for strokes
class PracticeSession {
  final String id;
  final int sessionNumber; // 1회독, 2회독, 3회독...
  final DateTime startedAt;
  DateTime? completedAt;
  final String layerId; // Link to the layer containing this session's strokes
  final Color sessionColor; // Unique color for this session

  // Statistics
  int totalStrokes;
  Duration practiceTime;
  String? notes; // User notes about this session

  PracticeSession({
    required this.id,
    required this.sessionNumber,
    required this.startedAt,
    this.completedAt,
    required this.layerId,
    required this.sessionColor,
    this.totalStrokes = 0,
    this.practiceTime = Duration.zero,
    this.notes,
  });

  /// Check if session is active (not completed)
  bool get isActive => completedAt == null;

  /// Get session title
  String get title => '$sessionNumber회독';

  /// Get session status
  String get status {
    if (completedAt != null) {
      return '완료 (${_formatDuration(practiceTime)})';
    }
    return '진행 중';
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    }
    return '${minutes}분';
  }

  /// Get time since started
  String get timeSinceStarted {
    final now = DateTime.now();
    final diff = now.difference(startedAt);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${(diff.inDays / 7).floor()}주 전';
  }

  PracticeSession copyWith({
    String? id,
    int? sessionNumber,
    DateTime? startedAt,
    DateTime? completedAt,
    String? layerId,
    Color? sessionColor,
    int? totalStrokes,
    Duration? practiceTime,
    String? notes,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      layerId: layerId ?? this.layerId,
      sessionColor: sessionColor ?? this.sessionColor,
      totalStrokes: totalStrokes ?? this.totalStrokes,
      practiceTime: practiceTime ?? this.practiceTime,
      notes: notes ?? this.notes,
    );
  }
}

/// Manages practice sessions for N-round repetition
class PracticeSessionManager extends ChangeNotifier {
  final Map<String, List<PracticeSession>> _sessionsByNote = {};
  final Map<String, String> _activeSessionByNote = {}; // noteId -> sessionId

  // Predefined colors for sessions (up to 5 sessions)
  static const List<Color> sessionColors = [
    Color(0xFFFF3B30), // Red - 1회독
    Color(0xFF007AFF), // Blue - 2회독
    Color(0xFF34C759), // Green - 3회독
    Color(0xFFFF9500), // Orange - 4회독
    Color(0xFF5E5CE6), // Purple - 5회독
  ];

  /// Get all sessions for a note
  List<PracticeSession> getSessions(String noteId) {
    return _sessionsByNote[noteId] ?? [];
  }

  /// Get active session for a note
  PracticeSession? getActiveSession(String noteId) {
    final sessionId = _activeSessionByNote[noteId];
    if (sessionId == null) return null;

    final sessions = _sessionsByNote[noteId] ?? [];
    return sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );
  }

  /// Get current session number
  int getCurrentSessionNumber(String noteId) {
    final sessions = getSessions(noteId);
    if (sessions.isEmpty) return 1;

    final activeSession = getActiveSession(noteId);
    if (activeSession != null) {
      return activeSession.sessionNumber;
    }

    return sessions.last.sessionNumber + 1;
  }

  /// Start new practice session
  PracticeSession startNewSession({
    required String noteId,
    required String layerId,
  }) {
    final sessions = _sessionsByNote[noteId] ?? [];
    final sessionNumber = sessions.isEmpty ? 1 : sessions.last.sessionNumber + 1;

    // Get color for this session (cycle if more than 5)
    final colorIndex = (sessionNumber - 1) % sessionColors.length;
    final sessionColor = sessionColors[colorIndex];

    final session = PracticeSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      sessionNumber: sessionNumber,
      startedAt: DateTime.now(),
      layerId: layerId,
      sessionColor: sessionColor,
    );

    // Add to sessions list
    if (!_sessionsByNote.containsKey(noteId)) {
      _sessionsByNote[noteId] = [];
    }
    _sessionsByNote[noteId]!.add(session);

    // Set as active session
    _activeSessionByNote[noteId] = session.id;

    notifyListeners();

    print('✅ Started ${session.title} with color ${session.sessionColor}');
    return session;
  }

  /// Complete current session
  void completeSession(String noteId, {Duration? practiceTime, int? totalStrokes}) {
    final sessionId = _activeSessionByNote[noteId];
    if (sessionId == null) return;

    final sessions = _sessionsByNote[noteId];
    if (sessions == null) return;

    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    sessions[sessionIndex] = sessions[sessionIndex].copyWith(
      completedAt: DateTime.now(),
      practiceTime: practiceTime,
      totalStrokes: totalStrokes,
    );

    // Remove from active sessions
    _activeSessionByNote.remove(noteId);

    notifyListeners();

    print('✅ Completed ${sessions[sessionIndex].title}');
  }

  /// Update session practice time
  void updatePracticeTime(String noteId, Duration duration) {
    final sessionId = _activeSessionByNote[noteId];
    if (sessionId == null) return;

    final sessions = _sessionsByNote[noteId];
    if (sessions == null) return;

    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    sessions[sessionIndex] = sessions[sessionIndex].copyWith(
      practiceTime: duration,
    );

    notifyListeners();
  }

  /// Update session stroke count
  void updateStrokeCount(String noteId, int count) {
    final sessionId = _activeSessionByNote[noteId];
    if (sessionId == null) return;

    final sessions = _sessionsByNote[noteId];
    if (sessions == null) return;

    final sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    sessions[sessionIndex] = sessions[sessionIndex].copyWith(
      totalStrokes: count,
    );

    notifyListeners();
  }

  /// Check if note has active practice session
  bool hasActiveSession(String noteId) {
    return _activeSessionByNote.containsKey(noteId);
  }

  /// Get comparison data for overlaying sessions
  Map<String, dynamic> getComparisonData(String noteId) {
    final sessions = getSessions(noteId);
    return {
      'totalSessions': sessions.length,
      'sessions': sessions,
      'canCompare': sessions.length >= 2,
    };
  }

  /// Delete session
  void deleteSession(String noteId, String sessionId) {
    final sessions = _sessionsByNote[noteId];
    if (sessions == null) return;

    sessions.removeWhere((s) => s.id == sessionId);

    if (_activeSessionByNote[noteId] == sessionId) {
      _activeSessionByNote.remove(noteId);
    }

    notifyListeners();
    print('✅ Deleted session');
  }

  /// Get statistics
  Map<String, dynamic> getStatistics(String noteId) {
    final sessions = getSessions(noteId);
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalTime': Duration.zero,
        'averageTime': Duration.zero,
        'totalStrokes': 0,
      };
    }

    final totalTime = sessions.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.practiceTime,
    );

    final totalStrokes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.totalStrokes,
    );

    return {
      'totalSessions': sessions.length,
      'totalTime': totalTime,
      'averageTime': Duration(
        microseconds: totalTime.inMicroseconds ~/ sessions.length,
      ),
      'totalStrokes': totalStrokes,
    };
  }
}

/// View mode for practice sessions
enum PracticeViewMode {
  current, // Show only current session
  overlay, // Overlay multiple sessions with different colors
  sideBySide, // Show sessions side by side (future)
}
