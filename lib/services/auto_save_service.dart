import 'dart:async';
import 'package:flutter/foundation.dart';

/// Auto-save service to prevent work loss
/// Saves notes automatically at regular intervals and on important events
class AutoSaveService {
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  DateTime? _lastSaveTime;
  int _strokeCountSinceLastSave = 0;

  // Callbacks
  Future<void> Function()? onAutoSave;
  VoidCallback? onSaveSuccess;
  void Function(dynamic error)? onSaveError;

  // Auto-save settings
  Duration autoSaveInterval = const Duration(seconds: 30); // 30초마다 자동 저장
  int strokeThresholdForSave = 10; // 10획 그리면 저장
  bool enableAutoSave = true;

  /// Start auto-save timer
  void startAutoSave() {
    if (!enableAutoSave) return;

    // Cancel existing timer
    _autoSaveTimer?.cancel();

    // Start new timer
    _autoSaveTimer = Timer.periodic(autoSaveInterval, (timer) async {
      if (_hasUnsavedChanges) {
        await _performAutoSave();
      }
    });

    debugPrint('✅ Auto-save started (interval: ${autoSaveInterval.inSeconds}s)');
  }

  /// Stop auto-save timer
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    debugPrint('🛑 Auto-save stopped');
  }

  /// Mark that changes have been made
  void markUnsavedChanges({bool isStroke = false}) {
    _hasUnsavedChanges = true;

    if (isStroke) {
      _strokeCountSinceLastSave++;

      // Save immediately if stroke threshold reached
      if (_strokeCountSinceLastSave >= strokeThresholdForSave) {
        _performAutoSave();
      }
    }
  }

  /// Mark that all changes have been saved
  void markAsSaved() {
    _hasUnsavedChanges = false;
    _strokeCountSinceLastSave = 0;
    _lastSaveTime = DateTime.now();
  }

  /// Perform auto-save
  Future<void> _performAutoSave() async {
    if (onAutoSave == null) return;

    try {
      debugPrint('💾 Auto-saving... (${_strokeCountSinceLastSave} new strokes)');
      await onAutoSave!();

      markAsSaved();
      onSaveSuccess?.call();

      debugPrint('✅ Auto-save successful');
    } catch (e) {
      debugPrint('❌ Auto-save failed: $e');
      onSaveError?.call(e);
    }
  }

  /// Save immediately (manual trigger)
  Future<void> saveNow() async {
    await _performAutoSave();
  }

  /// Get time since last save
  Duration? get timeSinceLastSave {
    if (_lastSaveTime == null) return null;
    return DateTime.now().difference(_lastSaveTime!);
  }

  /// Check if has unsaved changes
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  /// Get number of unsaved strokes
  int get unsavedStrokeCount => _strokeCountSinceLastSave;

  /// Dispose and cleanup
  void dispose() {
    stopAutoSave();
  }
}
