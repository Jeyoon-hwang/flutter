import 'package:flutter/material.dart';

/// Represents a to-do item in the planner
/// Can be linked to specific note pages
class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;
  DateTime? dueDate;
  Priority priority;

  // Hyperlink to note
  String? linkedNoteId;
  int? linkedPageNumber;
  String? linkedNoteName; // Cache for display

  // Timer integration
  Duration studyTime; // Total time spent on this task
  DateTime? timerStartedAt; // When timer started
  bool isTimerRunning;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.priority = Priority.medium,
    this.linkedNoteId,
    this.linkedPageNumber,
    this.linkedNoteName,
    this.studyTime = Duration.zero,
    this.timerStartedAt,
    this.isTimerRunning = false,
  });

  /// Get display text with linked note info
  String get displayText {
    if (linkedNoteName != null && linkedPageNumber != null) {
      return '$title ($linkedNoteName p.$linkedPageNumber)';
    } else if (linkedNoteName != null) {
      return '$title ($linkedNoteName)';
    }
    return title;
  }

  /// Get formatted study time
  String get formattedStudyTime {
    final hours = studyTime.inHours;
    final minutes = studyTime.inMinutes.remainder(60);
    final seconds = studyTime.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  /// Get current elapsed time (if timer is running)
  Duration get currentElapsed {
    if (!isTimerRunning || timerStartedAt == null) {
      return studyTime;
    }

    final elapsed = DateTime.now().difference(timerStartedAt!);
    return studyTime + elapsed;
  }

  /// Get priority color
  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFFF3B30); // Red
      case Priority.medium:
        return const Color(0xFFFF9500); // Orange
      case Priority.low:
        return const Color(0xFF34C759); // Green
    }
  }

  /// Get priority icon
  IconData get priorityIcon {
    switch (priority) {
      case Priority.high:
        return Icons.priority_high;
      case Priority.medium:
        return Icons.remove;
      case Priority.low:
        return Icons.arrow_downward;
    }
  }

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    Priority? priority,
    String? linkedNoteId,
    int? linkedPageNumber,
    String? linkedNoteName,
    Duration? studyTime,
    DateTime? timerStartedAt,
    bool? isTimerRunning,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      linkedPageNumber: linkedPageNumber ?? this.linkedPageNumber,
      linkedNoteName: linkedNoteName ?? this.linkedNoteName,
      studyTime: studyTime ?? this.studyTime,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
    );
  }
}

enum Priority {
  high,   // 높음 - 빨간색
  medium, // 보통 - 주황색
  low,    // 낮음 - 초록색
}

/// Manages planner and to-do items
class PlannerManager extends ChangeNotifier {
  final List<TodoItem> _todos = [];
  TodoItem? _activeTimerTodo; // Currently running timer

  List<TodoItem> get todos => List.unmodifiable(_todos);
  TodoItem? get activeTimerTodo => _activeTimerTodo;

  /// Get today's todos
  List<TodoItem> get todayTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _todos.where((todo) {
      if (todo.dueDate == null) return false;
      final dueDay = DateTime(
        todo.dueDate!.year,
        todo.dueDate!.month,
        todo.dueDate!.day,
      );
      return dueDay == today;
    }).toList();
  }

  /// Get incomplete todos
  List<TodoItem> get incompleteTodos {
    return _todos.where((todo) => !todo.isCompleted).toList();
  }

  /// Get completed todos
  List<TodoItem> get completedTodos {
    return _todos.where((todo) => todo.isCompleted).toList();
  }

  /// Create new todo
  TodoItem createTodo({
    required String title,
    DateTime? dueDate,
    Priority priority = Priority.medium,
    String? linkedNoteId,
    int? linkedPageNumber,
    String? linkedNoteName,
  }) {
    final todo = TodoItem(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      linkedNoteId: linkedNoteId,
      linkedPageNumber: linkedPageNumber,
      linkedNoteName: linkedNoteName,
    );

    _todos.insert(0, todo);
    notifyListeners();

    print('✅ Created todo: $title');
    if (linkedNoteName != null) {
      print('   Linked to: $linkedNoteName${linkedPageNumber != null ? " p.$linkedPageNumber" : ""}');
    }

    return todo;
  }

  /// Toggle todo completion
  void toggleComplete(String todoId) {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    final isCompleting = !_todos[index].isCompleted;

    _todos[index] = _todos[index].copyWith(
      isCompleted: isCompleting,
      completedAt: isCompleting ? DateTime.now() : null,
    );

    // Stop timer if completing
    if (isCompleting && _todos[index].isTimerRunning) {
      stopTimer(todoId);
    }

    notifyListeners();
    print(isCompleting ? '✅ Completed todo' : '⚪ Uncompleted todo');
  }

  /// Start timer for todo (Pomodoro integration)
  void startTimer(String todoId) {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    // Stop any other running timer
    if (_activeTimerTodo != null && _activeTimerTodo!.id != todoId) {
      stopTimer(_activeTimerTodo!.id);
    }

    _todos[index] = _todos[index].copyWith(
      timerStartedAt: DateTime.now(),
      isTimerRunning: true,
    );

    _activeTimerTodo = _todos[index];
    notifyListeners();

    print('▶️ Started timer for: ${_todos[index].title}');
  }

  /// Stop timer for todo
  void stopTimer(String todoId) {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    if (!_todos[index].isTimerRunning) return;

    // Calculate elapsed time
    final elapsed = DateTime.now().difference(_todos[index].timerStartedAt!);
    final newTotalTime = _todos[index].studyTime + elapsed;

    _todos[index] = _todos[index].copyWith(
      studyTime: newTotalTime,
      timerStartedAt: null,
      isTimerRunning: false,
    );

    if (_activeTimerTodo?.id == todoId) {
      _activeTimerTodo = null;
    }

    notifyListeners();

    print('⏸️ Stopped timer: ${_todos[index].formattedStudyTime}');
  }

  /// Delete todo
  void deleteTodo(String todoId) {
    // Stop timer if running
    final todo = _todos.firstWhere((t) => t.id == todoId, orElse: () => _todos.first);
    if (todo.isTimerRunning) {
      stopTimer(todoId);
    }

    _todos.removeWhere((t) => t.id == todoId);
    notifyListeners();

    print('✅ Deleted todo');
  }

  /// Update todo
  void updateTodo(String todoId, {
    String? title,
    DateTime? dueDate,
    Priority? priority,
  }) {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    _todos[index] = _todos[index].copyWith(
      title: title,
      dueDate: dueDate,
      priority: priority,
    );

    notifyListeners();
  }

  /// Get todo by ID
  TodoItem? getTodo(String todoId) {
    try {
      return _todos.firstWhere((t) => t.id == todoId);
    } catch (e) {
      return null;
    }
  }

  /// Get todos linked to a specific note
  List<TodoItem> getTodosForNote(String noteId) {
    return _todos.where((t) => t.linkedNoteId == noteId).toList();
  }

  /// Get statistics
  Map<String, dynamic> get statistics {
    final total = _todos.length;
    final completed = completedTodos.length;
    final totalStudyTime = _todos.fold<Duration>(
      Duration.zero,
      (sum, todo) => sum + todo.studyTime,
    );

    return {
      'total': total,
      'completed': completed,
      'incomplete': total - completed,
      'completionRate': total > 0 ? (completed / total) * 100 : 0.0,
      'totalStudyTime': totalStudyTime,
    };
  }
}
