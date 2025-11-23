import 'dart:ui';
import 'advanced_pen.dart';

/// Represents input device type for drawing
enum InputDeviceType {
  touch,      // 손가락 터치
  stylus,     // S펜, Apple Pencil 등
  mouse,      // 마우스
  unknown,    // 알 수 없음
}

class DrawingPoint {
  final Offset offset;
  final double pressure;
  final InputDeviceType deviceType;
  final double? tiltX;  // 펜 기울기 X (라디안)
  final double? tiltY;  // 펜 기울기 Y (라디안)

  DrawingPoint({
    required this.offset,
    this.pressure = 0.5,
    this.deviceType = InputDeviceType.touch,
    this.tiltX,
    this.tiltY,
  });

  /// Create from PointerEvent
  factory DrawingPoint.fromPointer({
    required Offset offset,
    required double pressure,
    required PointerDeviceKind kind,
    double? tiltX,
    double? tiltY,
  }) {
    InputDeviceType deviceType;
    switch (kind) {
      case PointerDeviceKind.stylus:
        deviceType = InputDeviceType.stylus;
        break;
      case PointerDeviceKind.touch:
        deviceType = InputDeviceType.touch;
        break;
      case PointerDeviceKind.mouse:
        deviceType = InputDeviceType.mouse;
        break;
      default:
        deviceType = InputDeviceType.unknown;
    }

    return DrawingPoint(
      offset: offset,
      pressure: pressure,
      deviceType: deviceType,
      tiltX: tiltX,
      tiltY: tiltY,
    );
  }

  bool get isStylusInput => deviceType == InputDeviceType.stylus;
}

class DrawingStroke {
  final List<DrawingPoint> points;
  final Color color;
  final double width;
  final double opacity;
  final bool isEraser;

  // Advanced pen properties
  final PenType? penType;
  final List<Color>? gradientColors;
  final bool enableGlow;
  final double? glitterDensity;
  final double smoothing;
  final double tapering;
  final double pressureSensitivity; // 0.0 (no pressure) to 1.0 (max pressure)

  DrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    this.opacity = 1.0,
    this.isEraser = false,
    this.penType,
    this.gradientColors,
    this.enableGlow = false,
    this.glitterDensity,
    this.smoothing = 0.0,
    this.tapering = 0.0,
    this.pressureSensitivity = 0.7,
  });
}
