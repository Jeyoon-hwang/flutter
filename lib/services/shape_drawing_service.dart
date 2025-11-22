import 'dart:math';
import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

enum ShapeType2D {
  circle, rectangle, square, triangle, line, arrow, pentagon, hexagon, star,
  // Middle school geometry shapes
  parallelogram, rhombus, trapezoid, ellipse, sector, arc,
  rightAngle, tangent, chord, heptagon, octagon, nonagon, decagon
}
enum ShapeType3D { cube, cylinder, pyramid, sphere, cone, prism }

class ShapeDrawingService {
  // 2D Shape generators
  List<DrawingPoint> drawCircle(Offset center, double radius) {
    final points = <DrawingPoint>[];
    for (int i = 0; i <= 360; i += 2) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }
    return points;
  }

  List<DrawingPoint> drawRectangle(Offset topLeft, double width, double height) {
    return [
      DrawingPoint(offset: topLeft, pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + width, topLeft.dy), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + width, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: topLeft, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawSquare(Offset topLeft, double size) {
    return drawRectangle(topLeft, size, size);
  }

  List<DrawingPoint> drawTriangle(
    Offset center,
    double size,
    {double angle1 = 60, double angle2 = 60, double angle3 = 60}
  ) {
    // For equilateral triangle by default
    // User can adjust angles
    final height = size * sqrt(3) / 2;

    final p1 = Offset(center.dx, center.dy - height * 2 / 3);
    final p2 = Offset(center.dx - size / 2, center.dy + height / 3);
    final p3 = Offset(center.dx + size / 2, center.dy + height / 3);

    return [
      DrawingPoint(offset: p1, pressure: 0.5),
      DrawingPoint(offset: p2, pressure: 0.5),
      DrawingPoint(offset: p3, pressure: 0.5),
      DrawingPoint(offset: p1, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawIsoscelesTriangle(Offset center, double base, double height) {
    final p1 = Offset(center.dx, center.dy - height / 2);
    final p2 = Offset(center.dx - base / 2, center.dy + height / 2);
    final p3 = Offset(center.dx + base / 2, center.dy + height / 2);

    return [
      DrawingPoint(offset: p1, pressure: 0.5),
      DrawingPoint(offset: p2, pressure: 0.5),
      DrawingPoint(offset: p3, pressure: 0.5),
      DrawingPoint(offset: p1, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawRightTriangle(Offset topLeft, double width, double height) {
    return [
      DrawingPoint(offset: topLeft, pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + width, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: topLeft, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawLine(Offset start, Offset end) {
    return [
      DrawingPoint(offset: start, pressure: 0.5),
      DrawingPoint(offset: end, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawArrow(Offset start, Offset end, {double headSize = 20}) {
    final points = <DrawingPoint>[];

    // Arrow shaft
    points.add(DrawingPoint(offset: start, pressure: 0.5));
    points.add(DrawingPoint(offset: end, pressure: 0.5));

    // Arrow head
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowAngle = pi / 6; // 30 degrees

    final head1 = Offset(
      end.dx - headSize * cos(angle - arrowAngle),
      end.dy - headSize * sin(angle - arrowAngle),
    );
    final head2 = Offset(
      end.dx - headSize * cos(angle + arrowAngle),
      end.dy - headSize * sin(angle + arrowAngle),
    );

    points.add(DrawingPoint(offset: head1, pressure: 0.5));
    points.add(DrawingPoint(offset: end, pressure: 0.5));
    points.add(DrawingPoint(offset: head2, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawPentagon(Offset center, double radius) {
    return _drawRegularPolygon(center, radius, 5);
  }

  List<DrawingPoint> drawHexagon(Offset center, double radius) {
    return _drawRegularPolygon(center, radius, 6);
  }

  List<DrawingPoint> drawStar(Offset center, double outerRadius, {int points = 5}) {
    final List<DrawingPoint> starPoints = [];
    final innerRadius = outerRadius * 0.4;
    final angleStep = pi / points;

    for (int i = 0; i < points * 2; i++) {
      final angle = i * angleStep - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      starPoints.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }
    starPoints.add(starPoints.first); // Close the shape
    return starPoints;
  }

  // 3D Shape generators (isometric projection)
  List<DrawingPoint> drawCube(Offset center, double size) {
    final points = <DrawingPoint>[];
    final angle = pi / 6; // 30 degrees for isometric
    final dx = size * cos(angle);
    final dy = size * sin(angle);

    // Front face
    final frontBottomLeft = Offset(center.dx - dx, center.dy + dy);
    final frontBottomRight = Offset(center.dx + dx, center.dy + dy);
    final frontTopRight = Offset(center.dx + dx, center.dy + dy - size);
    final frontTopLeft = Offset(center.dx - dx, center.dy + dy - size);

    // Back face
    final backBottomLeft = Offset(frontBottomLeft.dx, frontBottomLeft.dy - dy * 2);
    final backBottomRight = Offset(frontBottomRight.dx, frontBottomRight.dy - dy * 2);
    final backTopRight = Offset(frontTopRight.dx, frontTopRight.dy - dy * 2);
    final backTopLeft = Offset(frontTopLeft.dx, frontTopLeft.dy - dy * 2);

    // Draw front face
    points.add(DrawingPoint(offset: frontBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: frontTopRight, pressure: 0.5));
    points.add(DrawingPoint(offset: frontTopLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomLeft, pressure: 0.5));

    // Draw back face
    points.add(DrawingPoint(offset: backBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backTopRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backTopLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomLeft, pressure: 0.5));

    // Connect corresponding vertices
    points.add(DrawingPoint(offset: frontBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backTopRight, pressure: 0.5));
    points.add(DrawingPoint(offset: frontTopRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backTopRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backTopLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: frontTopLeft, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawCylinder(Offset center, double radius, double height) {
    final points = <DrawingPoint>[];

    // Top ellipse (isometric view)
    for (int i = 0; i <= 360; i += 5) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy - height / 2 + radius * 0.3 * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Connect to bottom
    points.add(DrawingPoint(
      offset: Offset(center.dx + radius, center.dy + height / 2),
      pressure: 0.5,
    ));

    // Bottom ellipse
    for (int i = 0; i <= 180; i += 5) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + height / 2 + radius * 0.3 * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Left edge
    points.add(DrawingPoint(
      offset: Offset(center.dx - radius, center.dy - height / 2),
      pressure: 0.5,
    ));

    return points;
  }

  List<DrawingPoint> drawPyramid(Offset center, double baseSize, double height) {
    final points = <DrawingPoint>[];
    final halfBase = baseSize / 2;

    // Base (square)
    final baseY = center.dy + height / 3;
    final base1 = Offset(center.dx - halfBase, baseY);
    final base2 = Offset(center.dx + halfBase, baseY);
    final base3 = Offset(center.dx + halfBase * 0.5, baseY + halfBase);
    final base4 = Offset(center.dx - halfBase * 0.5, baseY + halfBase);

    // Apex
    final apex = Offset(center.dx, center.dy - height * 2 / 3);

    // Draw base
    points.add(DrawingPoint(offset: base1, pressure: 0.5));
    points.add(DrawingPoint(offset: base2, pressure: 0.5));
    points.add(DrawingPoint(offset: base3, pressure: 0.5));
    points.add(DrawingPoint(offset: base4, pressure: 0.5));
    points.add(DrawingPoint(offset: base1, pressure: 0.5));

    // Draw edges to apex
    points.add(DrawingPoint(offset: apex, pressure: 0.5));
    points.add(DrawingPoint(offset: base2, pressure: 0.5));
    points.add(DrawingPoint(offset: apex, pressure: 0.5));
    points.add(DrawingPoint(offset: base3, pressure: 0.5));
    points.add(DrawingPoint(offset: apex, pressure: 0.5));
    points.add(DrawingPoint(offset: base4, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawSphere(Offset center, double radius) {
    final points = <DrawingPoint>[];

    // Main circle
    for (int i = 0; i <= 360; i += 2) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Horizontal ellipse (equator)
    for (int i = 0; i <= 360; i += 5) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * 0.3 * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Vertical ellipse
    for (int i = 0; i <= 360; i += 5) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * 0.3 * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    return points;
  }

  List<DrawingPoint> drawCone(Offset center, double baseRadius, double height) {
    final points = <DrawingPoint>[];

    // Base ellipse (bottom)
    for (int i = 0; i <= 180; i += 5) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + baseRadius * cos(angle),
          center.dy + height / 2 + baseRadius * 0.3 * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Left edge to apex
    final apex = Offset(center.dx, center.dy - height / 2);
    points.add(DrawingPoint(offset: apex, pressure: 0.5));

    // Back part of base (dashed or lighter)
    for (int i = 180; i <= 360; i += 5) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + baseRadius * cos(angle),
          center.dy + height / 2 + baseRadius * 0.3 * sin(angle),
        ),
        pressure: 0.3, // Lighter for back side
      ));
    }

    // Right edge to apex
    points.add(DrawingPoint(offset: apex, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawPrism(Offset center, double size, double height) {
    final points = <DrawingPoint>[];

    // Similar to cube but with triangular base
    final baseHalfWidth = size / 2;
    final baseHeight = size * sqrt(3) / 2;

    // Front triangle
    final frontTop = Offset(center.dx, center.dy - baseHeight / 2);
    final frontBottomLeft = Offset(center.dx - baseHalfWidth, center.dy + baseHeight / 2);
    final frontBottomRight = Offset(center.dx + baseHalfWidth, center.dy + baseHeight / 2);

    // Back triangle (offset for depth)
    final depthOffset = height * 0.3;
    final backTop = Offset(frontTop.dx - depthOffset, frontTop.dy - depthOffset);
    final backBottomLeft = Offset(frontBottomLeft.dx - depthOffset, frontBottomLeft.dy - depthOffset);
    final backBottomRight = Offset(frontBottomRight.dx - depthOffset, frontBottomRight.dy - depthOffset);

    // Draw front triangle
    points.add(DrawingPoint(offset: frontTop, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: frontTop, pressure: 0.5));

    // Draw back triangle
    points.add(DrawingPoint(offset: backTop, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: backTop, pressure: 0.5));

    // Connect corresponding vertices
    points.add(DrawingPoint(offset: frontTop, pressure: 0.5));
    points.add(DrawingPoint(offset: backTop, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomRight, pressure: 0.5));
    points.add(DrawingPoint(offset: backBottomLeft, pressure: 0.5));
    points.add(DrawingPoint(offset: frontBottomLeft, pressure: 0.5));

    return points;
  }

  // Middle school geometry shapes
  List<DrawingPoint> drawParallelogram(Offset topLeft, double width, double height, {double skew = 30}) {
    final skewOffset = height * tan(skew * pi / 180);
    return [
      DrawingPoint(offset: topLeft, pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + width, topLeft.dy), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + width - skewOffset, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx - skewOffset, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: topLeft, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawRhombus(Offset center, double size) {
    final halfSize = size / 2;
    return [
      DrawingPoint(offset: Offset(center.dx, center.dy - halfSize), pressure: 0.5),
      DrawingPoint(offset: Offset(center.dx + halfSize, center.dy), pressure: 0.5),
      DrawingPoint(offset: Offset(center.dx, center.dy + halfSize), pressure: 0.5),
      DrawingPoint(offset: Offset(center.dx - halfSize, center.dy), pressure: 0.5),
      DrawingPoint(offset: Offset(center.dx, center.dy - halfSize), pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawTrapezoid(Offset topLeft, double topWidth, double bottomWidth, double height) {
    final widthDiff = (bottomWidth - topWidth) / 2;
    return [
      DrawingPoint(offset: topLeft, pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + topWidth, topLeft.dy), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx + topWidth + widthDiff, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: Offset(topLeft.dx - widthDiff, topLeft.dy + height), pressure: 0.5),
      DrawingPoint(offset: topLeft, pressure: 0.5),
    ];
  }

  List<DrawingPoint> drawEllipse(Offset center, double radiusX, double radiusY) {
    final points = <DrawingPoint>[];
    for (int i = 0; i <= 360; i += 2) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radiusX * cos(angle),
          center.dy + radiusY * sin(angle),
        ),
        pressure: 0.5,
      ));
    }
    return points;
  }

  List<DrawingPoint> drawSector(Offset center, double radius, {double startAngle = 0, double sweepAngle = 90}) {
    final points = <DrawingPoint>[];

    // Add center point
    points.add(DrawingPoint(offset: center, pressure: 0.5));

    // Draw arc
    final startRad = startAngle * pi / 180;

    for (double i = 0; i <= sweepAngle; i += 2) {
      final angle = startRad + (i * pi / 180);
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Back to center
    points.add(DrawingPoint(offset: center, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawArc(Offset center, double radius, {double startAngle = 0, double sweepAngle = 120}) {
    final points = <DrawingPoint>[];
    final startRad = startAngle * pi / 180;

    for (double i = 0; i <= sweepAngle; i += 2) {
      final angle = startRad + (i * pi / 180);
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    return points;
  }

  List<DrawingPoint> drawRightAngle(Offset vertex, double size, {double rotation = 0}) {
    final points = <DrawingPoint>[];
    final rotRad = rotation * pi / 180;

    // Right angle symbol (small square at vertex)
    final squareSize = size * 0.2;

    final p1 = Offset(
      vertex.dx + squareSize * cos(rotRad),
      vertex.dy + squareSize * sin(rotRad),
    );
    final p2 = Offset(
      vertex.dx + squareSize * cos(rotRad) + squareSize * cos(rotRad + pi / 2),
      vertex.dy + squareSize * sin(rotRad) + squareSize * sin(rotRad + pi / 2),
    );
    final p3 = Offset(
      vertex.dx + squareSize * cos(rotRad + pi / 2),
      vertex.dy + squareSize * sin(rotRad + pi / 2),
    );

    points.add(DrawingPoint(offset: p1, pressure: 0.5));
    points.add(DrawingPoint(offset: p2, pressure: 0.5));
    points.add(DrawingPoint(offset: p3, pressure: 0.5));

    // Add the two arms of the angle
    final arm1End = Offset(
      vertex.dx + size * cos(rotRad),
      vertex.dy + size * sin(rotRad),
    );
    final arm2End = Offset(
      vertex.dx + size * cos(rotRad + pi / 2),
      vertex.dy + size * sin(rotRad + pi / 2),
    );

    points.add(DrawingPoint(offset: arm1End, pressure: 0.5));
    points.add(DrawingPoint(offset: vertex, pressure: 0.5));
    points.add(DrawingPoint(offset: arm2End, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawTangent(Offset circleCenter, double radius, Offset touchPoint) {
    final points = <DrawingPoint>[];

    // Draw circle
    for (int i = 0; i <= 360; i += 3) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          circleCenter.dx + radius * cos(angle),
          circleCenter.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Draw tangent line (perpendicular to radius at touch point)
    final angleToTouch = atan2(touchPoint.dy - circleCenter.dy, touchPoint.dx - circleCenter.dx);
    final perpAngle = angleToTouch + pi / 2;

    final tangentLength = radius * 2;
    final tangentStart = Offset(
      touchPoint.dx - tangentLength / 2 * cos(perpAngle),
      touchPoint.dy - tangentLength / 2 * sin(perpAngle),
    );
    final tangentEnd = Offset(
      touchPoint.dx + tangentLength / 2 * cos(perpAngle),
      touchPoint.dy + tangentLength / 2 * sin(perpAngle),
    );

    points.add(DrawingPoint(offset: tangentStart, pressure: 0.5));
    points.add(DrawingPoint(offset: tangentEnd, pressure: 0.5));

    // Draw radius to touch point
    points.add(DrawingPoint(offset: circleCenter, pressure: 0.5));
    points.add(DrawingPoint(offset: touchPoint, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawChord(Offset center, double radius, {double startAngle = 30, double endAngle = 150}) {
    final points = <DrawingPoint>[];

    // Draw circle
    for (int i = 0; i <= 360; i += 3) {
      final angle = i * pi / 180;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    // Draw chord
    final startRad = startAngle * pi / 180;
    final endRad = endAngle * pi / 180;

    final startPoint = Offset(
      center.dx + radius * cos(startRad),
      center.dy + radius * sin(startRad),
    );
    final endPoint = Offset(
      center.dx + radius * cos(endRad),
      center.dy + radius * sin(endRad),
    );

    points.add(DrawingPoint(offset: startPoint, pressure: 0.5));
    points.add(DrawingPoint(offset: endPoint, pressure: 0.5));

    return points;
  }

  List<DrawingPoint> drawHeptagon(Offset center, double radius) {
    return _drawRegularPolygon(center, radius, 7);
  }

  List<DrawingPoint> drawOctagon(Offset center, double radius) {
    return _drawRegularPolygon(center, radius, 8);
  }

  List<DrawingPoint> drawNonagon(Offset center, double radius) {
    return _drawRegularPolygon(center, radius, 9);
  }

  List<DrawingPoint> drawDecagon(Offset center, double radius) {
    return _drawRegularPolygon(center, radius, 10);
  }

  // Helper method for regular polygons
  List<DrawingPoint> _drawRegularPolygon(Offset center, double radius, int sides) {
    final points = <DrawingPoint>[];
    final angleStep = (2 * pi) / sides;

    for (int i = 0; i <= sides; i++) {
      final angle = i * angleStep - pi / 2;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        pressure: 0.5,
      ));
    }

    return points;
  }
}
