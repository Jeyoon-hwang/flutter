import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback service for enhanced tactile UX
/// Provides different levels of haptic feedback for various interactions
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;
  bool? _hasVibrator;

  /// Initialize and check if device has vibrator
  Future<void> initialize() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (e) {
      _hasVibrator = false;
    }
  }

  /// Enable/disable haptic feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Light haptic feedback for subtle interactions
  /// Use for: hover, focus, small UI changes
  Future<void> light() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Medium haptic feedback for normal interactions
  /// Use for: button taps, selections, toggles
  Future<void> medium() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Heavy haptic feedback for important interactions
  /// Use for: confirmations, deletions, important actions
  Future<void> heavy() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Success haptic pattern
  /// Use for: successful operations, achievements
  Future<void> success() async {
    if (!_isEnabled || _hasVibrator != true) return;

    try {
      await Vibration.vibrate(duration: 100, amplitude: 128);
      await Future.delayed(const Duration(milliseconds: 80));
      await Vibration.vibrate(duration: 50, amplitude: 255);
    } catch (e) {
      // Vibration not available, fallback to haptic
      await HapticFeedback.mediumImpact();
    }
  }

  /// Error haptic pattern
  /// Use for: errors, warnings, invalid actions
  Future<void> error() async {
    if (!_isEnabled || _hasVibrator != true) return;

    try {
      await Vibration.vibrate(duration: 200, amplitude: 255);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 200, amplitude: 255);
    } catch (e) {
      // Vibration not available, fallback to haptic
      await HapticFeedback.heavyImpact();
    }
  }

  /// Drawing/pen stroke haptic
  /// Use for: pen down, starting to draw
  Future<void> penDown() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Stylus detected haptic
  /// Use for: when S-Pen or Apple Pencil is detected
  Future<void> stylusDetected() async {
    if (!_isEnabled || _hasVibrator != true) return;

    try {
      await Vibration.vibrate(duration: 50, amplitude: 128);
    } catch (e) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Gesture completed haptic
  /// Use for: zoom, pan, gesture recognition
  Future<void> gestureComplete() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Selection changed haptic
  /// Use for: color picker, tool selection, option change
  Future<void> selectionChanged() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Button press haptic
  /// Use for: all button taps
  Future<void> buttonPress() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Toggle haptic
  /// Use for: switches, checkboxes
  Future<void> toggle() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available
    }
  }

  /// Notification haptic
  /// Use for: notifications, alerts
  Future<void> notification() async {
    if (!_isEnabled || _hasVibrator != true) return;

    try {
      await Vibration.vibrate(duration: 100, amplitude: 200);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 100, amplitude: 200);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 100, amplitude: 200);
    } catch (e) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Long press haptic
  /// Use for: long press actions
  Future<void> longPress() async {
    if (!_isEnabled) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback not available
    }
  }
}

/// Global haptic service instance
final hapticService = HapticService();
