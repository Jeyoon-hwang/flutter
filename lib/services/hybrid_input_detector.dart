import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../providers/drawing_provider.dart';

/// Hybrid input detector for seamless pen/finger interaction
/// Implements "Fluidity" philosophy - no mode switching, just tool detection
class HybridInputDetector {
  final DrawingProvider provider;
  final GlobalKey repaintBoundaryKey;

  // Input state
  PointerDeviceKind? _lastInputDevice;

  // Double tap detection for OCR conversion
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  static const double _doubleTapDistance = 20.0;
  static const Duration _doubleTapTimeout = Duration(milliseconds: 300);

  HybridInputDetector(this.provider, this.repaintBoundaryKey);

  /// Handle pointer down event with automatic mode switching
  void onPointerDown(PointerDownEvent event) {
    final isPen = event.kind == PointerDeviceKind.stylus;
    final isFinger = event.kind == PointerDeviceKind.touch;

    _lastInputDevice = event.kind;

    // Pen detected: Switch to drawing mode automatically
    if (isPen) {
      _handlePenDown(event);
    }
    // Finger detected: Check for double tap (OCR conversion)
    else if (isFinger) {
      _handleFingerDown(event);
    }
  }

  /// Handle pointer up event
  void onPointerUp(PointerUpEvent event) {
    final isPen = event.kind == PointerDeviceKind.stylus;

    // Pen lifted: Stay in current mode (user might continue drawing)
    // We don't auto-revert because user might want to continue with pen
    if (isPen) {
      // Do nothing - keep drawing mode active
    }
  }

  /// Handle pen input - auto-switch to drawing
  void _handlePenDown(PointerDownEvent event) {
    // If not in pen mode, switch to it
    if (provider.mode != DrawingMode.pen) {
      provider.setMode(DrawingMode.pen);
    }

    // Start drawing
    provider.startDrawing(
      event.localPosition,
      event.pressure,
      isPen: true,
    );
  }

  /// Handle finger input - check for double tap or text input
  void _handleFingerDown(PointerDownEvent event) {
    final now = DateTime.now();
    final position = event.localPosition;

    // Check for double tap
    if (_lastTapTime != null && _lastTapPosition != null) {
      final timeSinceLastTap = now.difference(_lastTapTime!);
      final distance = (position - _lastTapPosition!).distance;

      if (timeSinceLastTap <= _doubleTapTimeout &&
          distance <= _doubleTapDistance) {
        // Double tap detected! Try OCR conversion
        _handleDoubleTap(position);

        // Reset double tap detection
        _lastTapTime = null;
        _lastTapPosition = null;
        return;
      }
    }

    // Record this tap for double tap detection
    _lastTapTime = now;
    _lastTapPosition = position;

    // Single finger tap: Check if user wants to draw or type
    // If in text mode, start text input
    if (provider.mode == DrawingMode.text) {
      provider.startDrawing(position, event.pressure, isPen: false);
    }
    // If in pen/eraser mode with palm rejection, ignore finger
    else if (provider.palmRejection &&
             (provider.mode == DrawingMode.pen ||
              provider.mode == DrawingMode.eraser)) {
      // Ignored by palm rejection
      return;
    }
    // Otherwise, allow finger drawing
    else {
      provider.startDrawing(position, event.pressure, isPen: false);
    }
  }

  /// Handle double tap for OCR conversion
  void _handleDoubleTap(Offset position) {
    // Check if there's a text object at this position
    final textObj = _findTextObjectAt(position);

    if (textObj != null) {
      // Double-tapped on existing text object - select it for editing
      print('Double tap on text object: ${textObj.id}');
      provider.selectTextObject(textObj);
    } else {
      // No text object found - try to convert handwriting strokes to text
      print('Double tap for OCR conversion at: $position');

      // Trigger layout-preserving OCR conversion
      // This will:
      // 1. Find strokes in the area around the tap
      // 2. Run OCR to recognize the handwriting
      // 3. Convert to text objects at the same position
      // 4. Remove the original strokes
      provider.convertStrokesToTextAtPosition(position, repaintBoundaryKey);
    }
  }

  /// Find text object at given position
  dynamic _findTextObjectAt(Offset position) {
    for (final textObj in provider.textObjects) {
      // Check if position is within text object bounds
      // Simple hit test with 20px padding
      final bounds = Rect.fromCenter(
        center: textObj.position,
        width: 100, // Approximate text width
        height: 30,  // Approximate text height
      );

      if (bounds.contains(position)) {
        return textObj;
      }
    }
    return null;
  }

  /// Get current input device type
  PointerDeviceKind? get lastInputDevice => _lastInputDevice;

  /// Check if last input was from pen
  bool get isPenActive => _lastInputDevice == PointerDeviceKind.stylus;

  /// Check if last input was from finger
  bool get isFingerActive => _lastInputDevice == PointerDeviceKind.touch;

  /// Reset input state
  void reset() {
    _lastInputDevice = null;
    _lastTapTime = null;
    _lastTapPosition = null;
  }
}

/// Extension to add hybrid input detection to DrawingProvider
extension HybridInputExtension on DrawingProvider {
  /// Get or create hybrid input detector
  /// Note: You must provide the repaintBoundaryKey for OCR functionality
  static final _detectors = <DrawingProvider, HybridInputDetector>{};

  HybridInputDetector getHybridInputDetector(GlobalKey repaintBoundaryKey) {
    // Always create new detector with the provided key
    // This ensures we always have the correct key reference
    _detectors[this] = HybridInputDetector(this, repaintBoundaryKey);
    return _detectors[this]!;
  }
}
