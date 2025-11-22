import 'dart:math';
import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

enum ShapeType { none, line, circle, rectangle, triangle, arrow }

class RecognizedShape {
  final ShapeType type;
  final List<Offset> points;
  final double confidence;

  RecognizedShape({
    required this.type,
    required this.points,
    required this.confidence,
  });
}

class ShapeRecognitionService {
  static const double minConfidence = 0.7;
  static const double circleThreshold = 0.15;
  static const double lineThreshold = 0.1;
  
  RecognizedShape? recognizeShape(List<DrawingPoint> points) {
    if (points.length < 3) return null;

    final offsets = points.map((p) => p.offset).toList();

    // Try to recognize different shapes
    final circle = _recognizeCircle(offsets);
    if (circle != null && circle.confidence > minConfidence) {
      return circle;
    }

    final line = _recognizeLine(offsets);
    if (line != null && line.confidence > minConfidence) {
      return line;
    }

    final rectangle = _recognizeRectangle(offsets);
    if (rectangle != null && rectangle.confidence > minConfidence) {
      return rectangle;
    }

    final triangle = _recognizeTriangle(offsets);
    if (triangle != null && triangle.confidence > minConfidence) {
      return triangle;
    }

    final arrow = _recognizeArrow(offsets);
    if (arrow != null && arrow.confidence > minConfidence) {
      return arrow;
    }

    return null;
  }

  RecognizedShape? _recognizeCircle(List<Offset> points) {
    if (points.length < 10) return null;

    // Calculate center point
    double sumX = 0, sumY = 0;
    for (var point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }
    final center = Offset(sumX / points.length, sumY / points.length);

    // Calculate average radius
    double sumRadius = 0;
    for (var point in points) {
      sumRadius += (point - center).distance;
    }
    final avgRadius = sumRadius / points.length;

    // Calculate variance from average radius
    double variance = 0;
    for (var point in points) {
      final diff = (point - center).distance - avgRadius;
      variance += diff * diff;
    }
    variance /= points.length;
    final stdDev = sqrt(variance);

    // Check if it's circular enough
    final circularity = 1 - (stdDev / avgRadius);
    
    if (circularity > (1 - circleThreshold) && avgRadius > 20) {
      // Generate perfect circle points
      final circlePoints = <Offset>[];
      for (int i = 0; i < 360; i += 5) {
        final angle = i * pi / 180;
        circlePoints.add(Offset(
          center.dx + avgRadius * cos(angle),
          center.dy + avgRadius * sin(angle),
        ));
      }

      return RecognizedShape(
        type: ShapeType.circle,
        points: circlePoints,
        confidence: circularity,
      );
    }

    return null;
  }

  RecognizedShape? _recognizeLine(List<Offset> points) {
    if (points.length < 5) return null;

    final first = points.first;
    final last = points.last;
    final lineLength = (last - first).distance;

    if (lineLength < 30) return null;

    // Calculate perpendicular distance from each point to the line
    double totalDistance = 0;
    for (var point in points) {
      final distance = _perpendicularDistance(point, first, last);
      totalDistance += distance;
    }
    final avgDistance = totalDistance / points.length;

    // Check if points are close to a straight line
    final straightness = 1 - (avgDistance / lineLength);

    if (straightness > (1 - lineThreshold)) {
      return RecognizedShape(
        type: ShapeType.line,
        points: [first, last],
        confidence: straightness,
      );
    }

    return null;
  }

  RecognizedShape? _recognizeRectangle(List<Offset> points) {
    if (points.length < 20) return null;

    // Simplify the stroke using Douglas-Peucker algorithm
    final simplified = _douglasPeucker(points, 10.0);

    if (simplified.length >= 4 && simplified.length <= 6) {
      // Check if it forms a closed shape
      if ((simplified.first - simplified.last).distance > 50) {
        return null;
      }

      // Get 4 corner points
      List<Offset> corners;
      if (simplified.length == 5) {
        // Perfect - 4 corners + closing point
        corners = simplified.sublist(0, 4);
      } else {
        // Find 4 most significant corners
        corners = _findCorners(simplified, 4);
      }

      if (corners.length == 4) {
        // Check if angles are close to 90 degrees
        final angles = _calculateAngles(corners);
        final avgAngle = angles.reduce((a, b) => a + b) / angles.length;
        final angleVariance = angles.map((a) => (a - avgAngle).abs()).reduce((a, b) => a + b) / angles.length;

        if (angleVariance < 30) { // Allow some tolerance
          // Create perfect rectangle
          final rect = _createRectangle(corners);
          
          return RecognizedShape(
            type: ShapeType.rectangle,
            points: rect,
            confidence: 1 - (angleVariance / 90),
          );
        }
      }
    }

    return null;
  }

  RecognizedShape? _recognizeTriangle(List<Offset> points) {
    if (points.length < 15) return null;

    final simplified = _douglasPeucker(points, 10.0);

    if (simplified.length >= 3 && simplified.length <= 5) {
      if ((simplified.first - simplified.last).distance > 50) {
        return null;
      }

      List<Offset> corners;
      if (simplified.length == 4) {
        corners = simplified.sublist(0, 3);
      } else {
        corners = _findCorners(simplified, 3);
      }

      if (corners.length == 3) {
        // Check if it forms a reasonable triangle
        final side1 = (corners[1] - corners[0]).distance;
        final side2 = (corners[2] - corners[1]).distance;
        final side3 = (corners[0] - corners[2]).distance;

        // Triangle inequality
        if (side1 + side2 > side3 && side2 + side3 > side1 && side3 + side1 > side2) {
          return RecognizedShape(
            type: ShapeType.triangle,
            points: [...corners, corners[0]], // Close the triangle
            confidence: 0.85,
          );
        }
      }
    }

    return null;
  }

  RecognizedShape? _recognizeArrow(List<Offset> points) {
    if (points.length < 10) return null;

    // Check if last 30% of points form a V shape (arrowhead)
    final headStartIndex = (points.length * 0.7).toInt();
    final headPoints = points.sublist(headStartIndex);
    
    if (headPoints.length < 5) return null;

    // Check if main body is relatively straight
    final bodyPoints = points.sublist(0, headStartIndex);
    final bodyLine = _recognizeLine(bodyPoints);
    
    if (bodyLine != null && bodyLine.confidence > 0.8) {
      // Check if head diverges from body
      final bodyEnd = bodyPoints.last;
      final headEnd = points.last;
      final headMid = headPoints[headPoints.length ~/ 2];
      
      final angle1 = _calculateAngle(bodyEnd, headMid, headEnd);
      
      if (angle1 > 20 && angle1 < 60) {
        // Create arrow shape
        final arrowPoints = [
          bodyLine.points[0], // Arrow start
          bodyLine.points[1], // Arrow body end
          headEnd, // Arrowhead point
        ];

        return RecognizedShape(
          type: ShapeType.arrow,
          points: arrowPoints,
          confidence: 0.8,
        );
      }
    }

    return null;
  }

  // Helper methods
  double _perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final lineLength = (lineEnd - lineStart).distance;
    if (lineLength == 0) return (point - lineStart).distance;

    final t = max(0.0, min(1.0, 
      ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) + 
       (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) / 
       (lineLength * lineLength)
    ));

    final projection = Offset(
      lineStart.dx + t * (lineEnd.dx - lineStart.dx),
      lineStart.dy + t * (lineEnd.dy - lineStart.dy),
    );

    return (point - projection).distance;
  }

  List<Offset> _douglasPeucker(List<Offset> points, double epsilon) {
    if (points.length < 3) return points;

    double maxDistance = 0;
    int maxIndex = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], points.first, points.last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    if (maxDistance > epsilon) {
      final left = _douglasPeucker(points.sublist(0, maxIndex + 1), epsilon);
      final right = _douglasPeucker(points.sublist(maxIndex), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [points.first, points.last];
    }
  }

  List<Offset> _findCorners(List<Offset> points, int count) {
    if (points.length <= count) return points;
    
    // Simple corner detection - find points with maximum angle change
    final corners = <Offset>[points.first];
    
    // This is a simplified version - you might want to implement a more sophisticated algorithm
    final step = points.length ~/ count;
    for (int i = step; i < points.length; i += step) {
      if (corners.length < count) {
        corners.add(points[i]);
      }
    }
    
    return corners;
  }

  List<double> _calculateAngles(List<Offset> points) {
    final angles = <double>[];
    for (int i = 0; i < points.length; i++) {
      final prev = points[i];
      final curr = points[(i + 1) % points.length];
      final next = points[(i + 2) % points.length];
      
      angles.add(_calculateAngle(prev, curr, next));
    }
    return angles;
  }

  double _calculateAngle(Offset p1, Offset p2, Offset p3) {
    final v1 = p1 - p2;
    final v2 = p3 - p2;
    
    final dot = v1.dx * v2.dx + v1.dy * v2.dy;
    final det = v1.dx * v2.dy - v1.dy * v2.dx;
    
    final angle = atan2(det, dot) * 180 / pi;
    return angle.abs();
  }

  List<Offset> _createRectangle(List<Offset> corners) {
    // Sort corners to create a proper rectangle
    final sorted = List<Offset>.from(corners);
    sorted.sort((a, b) {
      if ((a.dy - b.dy).abs() < 10) {
        return a.dx.compareTo(b.dx);
      }
      return a.dy.compareTo(b.dy);
    });

    return [
      sorted[0], sorted[1], sorted[3], sorted[2], sorted[0]
    ];
  }
}
