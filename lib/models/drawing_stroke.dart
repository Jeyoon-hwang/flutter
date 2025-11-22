import 'dart:ui';

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

  DrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    this.opacity = 1.0,
    this.isEraser = false,
  });
}
