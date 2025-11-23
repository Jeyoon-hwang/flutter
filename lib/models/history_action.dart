import 'package:flutter/material.dart';

/// Type of history action for granular undo/redo
enum HistoryActionType {
  addStroke,       // 획 추가
  removeStroke,    // 획 삭제
  addText,         // 텍스트 추가
  removeText,      // 텍스트 삭제
  moveText,        // 텍스트 이동
  updateText,      // 텍스트 수정
  addLayer,        // 레이어 추가
  removeLayer,     // 레이어 삭제
  reorderLayers,   // 레이어 순서 변경
  toggleLayerVisibility,  // 레이어 표시/숨김
  toggleLayerLock, // 레이어 잠금/해제
  clear,           // 전체 지우기
}

/// Represents a single undoable/redoable action
class HistoryAction {
  final HistoryActionType type;
  final String? layerId;
  final dynamic data; // Can be DrawingStroke, TextObject, Layer, etc.
  final dynamic previousData; // For updates and moves
  final DateTime timestamp;
  final String description;
  final int? index; // For position-specific operations

  HistoryAction({
    required this.type,
    this.layerId,
    required this.data,
    this.previousData,
    required this.description,
    this.index,
  }) : timestamp = DateTime.now();

  /// Get user-friendly Korean description
  String get koreanDescription {
    switch (type) {
      case HistoryActionType.addStroke:
        return '획 추가';
      case HistoryActionType.removeStroke:
        return '획 삭제';
      case HistoryActionType.addText:
        return '텍스트 추가';
      case HistoryActionType.removeText:
        return '텍스트 삭제';
      case HistoryActionType.moveText:
        return '텍스트 이동';
      case HistoryActionType.updateText:
        return '텍스트 수정';
      case HistoryActionType.addLayer:
        return '레이어 추가';
      case HistoryActionType.removeLayer:
        return '레이어 삭제';
      case HistoryActionType.reorderLayers:
        return '레이어 순서 변경';
      case HistoryActionType.toggleLayerVisibility:
        return '레이어 표시 변경';
      case HistoryActionType.toggleLayerLock:
        return '레이어 잠금 변경';
      case HistoryActionType.clear:
        return '전체 지우기';
    }
  }

  /// Get icon for the action
  IconData get icon {
    switch (type) {
      case HistoryActionType.addStroke:
        return Icons.gesture;
      case HistoryActionType.removeStroke:
        return Icons.remove_circle_outline;
      case HistoryActionType.addText:
        return Icons.text_fields;
      case HistoryActionType.removeText:
        return Icons.text_fields_outlined;
      case HistoryActionType.moveText:
        return Icons.open_with;
      case HistoryActionType.updateText:
        return Icons.edit;
      case HistoryActionType.addLayer:
        return Icons.layers;
      case HistoryActionType.removeLayer:
        return Icons.layers_clear;
      case HistoryActionType.reorderLayers:
        return Icons.reorder;
      case HistoryActionType.toggleLayerVisibility:
        return Icons.visibility;
      case HistoryActionType.toggleLayerLock:
        return Icons.lock;
      case HistoryActionType.clear:
        return Icons.delete_sweep;
    }
  }
}

/// Manages history for undo/redo with granular control
class HistoryManager extends ChangeNotifier {
  final List<HistoryAction> _history = [];
  int _currentIndex = -1;
  final int _maxHistory = 500; // Massive history for professional use (500 actions!)

  /// Get all history actions (for debugging or advanced UI)
  List<HistoryAction> get history => List.unmodifiable(_history);

  /// Current position in history
  int get currentIndex => _currentIndex;

  /// Can undo?
  bool get canUndo => _currentIndex >= 0;

  /// Can redo?
  bool get canRedo => _currentIndex < _history.length - 1;

  /// Get the action that would be undone
  HistoryAction? get nextUndoAction {
    if (canUndo) {
      return _history[_currentIndex];
    }
    return null;
  }

  /// Get the action that would be redone
  HistoryAction? get nextRedoAction {
    if (canRedo) {
      return _history[_currentIndex + 1];
    }
    return null;
  }

  /// Record a new action
  void recordAction(HistoryAction action) {
    // Remove any actions after current index (lost redo)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Add new action
    _history.add(action);
    _currentIndex++;

    // Limit history size
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
      _currentIndex--;
    }

    notifyListeners();
  }

  /// Undo the last action and return it
  HistoryAction? undo() {
    if (!canUndo) return null;

    final action = _history[_currentIndex];
    _currentIndex--;
    notifyListeners();

    return action;
  }

  /// Redo the next action and return it
  HistoryAction? redo() {
    if (!canRedo) return null;

    _currentIndex++;
    final action = _history[_currentIndex];
    notifyListeners();

    return action;
  }

  /// Clear all history
  void clear() {
    _history.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  /// Get recent actions (for UI display)
  List<HistoryAction> getRecentActions({int count = 10}) {
    final startIndex = (_currentIndex - count + 1).clamp(0, _history.length);
    final endIndex = (_currentIndex + 1).clamp(0, _history.length);

    if (startIndex >= endIndex) return [];

    return _history.sublist(startIndex, endIndex);
  }
}
