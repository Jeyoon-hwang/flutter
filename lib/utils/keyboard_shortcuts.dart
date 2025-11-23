import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/drawing_provider.dart';

/// Keyboard shortcuts handler for better UX
/// Inspired by tldraw/fldraw best practices
class KeyboardShortcuts {
  /// Register keyboard shortcuts for drawing provider
  static Map<LogicalKeySet, Intent> getShortcuts() {
    return {
      // Tool selection shortcuts
      LogicalKeySet(LogicalKeyboardKey.keyV): const SelectToolIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyP): const PenToolIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyE): const EraserToolIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyR): const RectangleToolIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyT): const TextToolIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyS): const ShapeToolIntent(),

      // Undo/Redo
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
          const UndoIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
          const RedoIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ):
          const RedoIntent(),

      // View controls
      LogicalKeySet(LogicalKeyboardKey.digit0, LogicalKeyboardKey.control):
          const ResetZoomIntent(),
      LogicalKeySet(LogicalKeyboardKey.equal, LogicalKeyboardKey.control):
          const ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.minus, LogicalKeyboardKey.control):
          const ZoomOutIntent(),

      // Focus mode
      LogicalKeySet(LogicalKeyboardKey.keyF): const ToggleFocusModeIntent(),

      // Delete
      LogicalKeySet(LogicalKeyboardKey.delete): const DeleteSelectionIntent(),
      LogicalKeySet(LogicalKeyboardKey.backspace): const DeleteSelectionIntent(),

      // Select all
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
          const SelectAllIntent(),

      // Help
      LogicalKeySet(LogicalKeyboardKey.slash, LogicalKeyboardKey.shift):
          const ShowHelpIntent(),
    };
  }

  /// Get action map for shortcuts
  static Map<Type, Action<Intent>> getActions(
    DrawingProvider provider, {
    VoidCallback? onShowHelp,
  }) {
    return {
      SelectToolIntent: CallbackAction<SelectToolIntent>(
        onInvoke: (_) => provider.setMode(DrawingMode.select),
      ),
      PenToolIntent: CallbackAction<PenToolIntent>(
        onInvoke: (_) => provider.setMode(DrawingMode.pen),
      ),
      EraserToolIntent: CallbackAction<EraserToolIntent>(
        onInvoke: (_) => provider.setMode(DrawingMode.eraser),
      ),
      RectangleToolIntent: CallbackAction<RectangleToolIntent>(
        onInvoke: (_) {
          provider.setMode(DrawingMode.shape);
          // Set rectangle as selected shape
          return null;
        },
      ),
      TextToolIntent: CallbackAction<TextToolIntent>(
        onInvoke: (_) => provider.setMode(DrawingMode.text),
      ),
      ShapeToolIntent: CallbackAction<ShapeToolIntent>(
        onInvoke: (_) => provider.setMode(DrawingMode.shape),
      ),
      UndoIntent: CallbackAction<UndoIntent>(
        onInvoke: (_) => provider.canUndo ? provider.undo() : null,
      ),
      RedoIntent: CallbackAction<RedoIntent>(
        onInvoke: (_) => provider.canRedo ? provider.redo() : null,
      ),
      ResetZoomIntent: CallbackAction<ResetZoomIntent>(
        onInvoke: (_) => provider.resetZoom(),
      ),
      ZoomInIntent: CallbackAction<ZoomInIntent>(
        onInvoke: (_) => provider.zoomIn(),
      ),
      ZoomOutIntent: CallbackAction<ZoomOutIntent>(
        onInvoke: (_) => provider.zoomOut(),
      ),
      ToggleFocusModeIntent: CallbackAction<ToggleFocusModeIntent>(
        onInvoke: (_) => provider.toggleFocusMode(),
      ),
      DeleteSelectionIntent: CallbackAction<DeleteSelectionIntent>(
        onInvoke: (_) => provider.deleteSelection(),
      ),
      SelectAllIntent: CallbackAction<SelectAllIntent>(
        onInvoke: (_) => provider.selectAll(),
      ),
      ShowHelpIntent: CallbackAction<ShowHelpIntent>(
        onInvoke: (_) {
          onShowHelp?.call();
          return null;
        },
      ),
    };
  }

  /// Get keyboard shortcut hints for UI
  static Map<String, String> getShortcutHints() {
    return {
      'Select': 'V',
      'Pen': 'P',
      'Eraser': 'E',
      'Rectangle': 'R',
      'Text': 'T',
      'Shape': 'S',
      'Undo': 'Ctrl+Z',
      'Redo': 'Ctrl+Y',
      'Focus Mode': 'F',
      'Zoom In': 'Ctrl++',
      'Zoom Out': 'Ctrl+-',
      'Reset Zoom': 'Ctrl+0',
      'Delete': 'Del',
      'Select All': 'Ctrl+A',
    };
  }
}

// Intent classes
class SelectToolIntent extends Intent {
  const SelectToolIntent();
}

class PenToolIntent extends Intent {
  const PenToolIntent();
}

class EraserToolIntent extends Intent {
  const EraserToolIntent();
}

class RectangleToolIntent extends Intent {
  const RectangleToolIntent();
}

class TextToolIntent extends Intent {
  const TextToolIntent();
}

class ShapeToolIntent extends Intent {
  const ShapeToolIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class ResetZoomIntent extends Intent {
  const ResetZoomIntent();
}

class ZoomInIntent extends Intent {
  const ZoomInIntent();
}

class ZoomOutIntent extends Intent {
  const ZoomOutIntent();
}

class ToggleFocusModeIntent extends Intent {
  const ToggleFocusModeIntent();
}

class DeleteSelectionIntent extends Intent {
  const DeleteSelectionIntent();
}

class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

class ShowHelpIntent extends Intent {
  const ShowHelpIntent();
}
