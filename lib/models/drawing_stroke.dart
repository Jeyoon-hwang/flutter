import 'dart:ui';
import 'advanced_pen.dart';

class DrawingPoint {
  final Offset offset;
  final double pressure;

  DrawingPoint({
    required this.offset,
    this.pressure = 0.5,
  });
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
  });
}
