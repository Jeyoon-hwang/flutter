import 'dart:ui';
import '../models/drawing_stroke.dart';

/// Performance optimizer for large notes
/// Provides culling and optimization techniques for smooth rendering
class PerformanceOptimizer {
  /// Cull strokes that are outside the viewport
  /// Only render strokes that are visible to improve performance
  static List<DrawingStroke> cullStrokesOutsideViewport(
    List<DrawingStroke> strokes,
    Rect viewport, {
    double padding = 100.0, // Extra padding for smooth scrolling
  }) {
    if (strokes.isEmpty) return strokes;

    final expandedViewport = viewport.inflate(padding);
    final visibleStrokes = <DrawingStroke>[];

    for (final stroke in strokes) {
      if (_strokeIntersectsRect(stroke, expandedViewport)) {
        visibleStrokes.add(stroke);
      }
    }

    return visibleStrokes;
  }

  /// Check if stroke intersects with viewport rectangle
  static bool _strokeIntersectsRect(DrawingStroke stroke, Rect rect) {
    if (stroke.points.isEmpty) return false;

    // Fast check: check bounding box first
    final bounds = _getStrokeBounds(stroke);
    if (!rect.overlaps(bounds)) return false;

    // Detailed check: check if any point is inside
    for (final point in stroke.points) {
      if (rect.contains(point.offset)) return true;
    }

    return false;
  }

  /// Get bounding box of a stroke
  static Rect _getStrokeBounds(DrawingStroke stroke) {
    if (stroke.points.isEmpty) return Rect.zero;

    double minX = stroke.points.first.offset.dx;
    double minY = stroke.points.first.offset.dy;
    double maxX = minX;
    double maxY = minY;

    for (final point in stroke.points) {
      if (point.offset.dx < minX) minX = point.offset.dx;
      if (point.offset.dy < minY) minY = point.offset.dy;
      if (point.offset.dx > maxX) maxX = point.offset.dx;
      if (point.offset.dy > maxY) maxY = point.offset.dy;
    }

    // Add stroke width padding
    final padding = stroke.width * 2;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  /// Simplify stroke by removing redundant points
  /// Uses Ramer-Douglas-Peucker algorithm
  static List<DrawingPoint> simplifyStroke(
    List<DrawingPoint> points,
    double epsilon,
  ) {
    if (points.length < 3) return points;

    return _ramerDouglasPeucker(points, epsilon);
  }

  /// Ramer-Douglas-Peucker algorithm for polyline simplification
  static List<DrawingPoint> _ramerDouglasPeucker(
    List<DrawingPoint> points,
    double epsilon,
  ) {
    if (points.length < 3) return points;

    // Find point with maximum distance
    double maxDistance = 0;
    int index = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(
        points[i].offset,
        points.first.offset,
        points.last.offset,
      );

      if (distance > maxDistance) {
        index = i;
        maxDistance = distance;
      }
    }

    // If max distance is greater than epsilon, recursively simplify
    if (maxDistance > epsilon) {
      // Recursive call
      final leftSegment = _ramerDouglasPeucker(
        points.sublist(0, index + 1),
        epsilon,
      );
      final rightSegment = _ramerDouglasPeucker(
        points.sublist(index),
        epsilon,
      );

      // Combine results (remove duplicate middle point)
      return [...leftSegment.sublist(0, leftSegment.length - 1), ...rightSegment];
    } else {
      // Return endpoints only
      return [points.first, points.last];
    }
  }

  /// Calculate perpendicular distance from point to line
  static double _perpendicularDistance(
    Offset point,
    Offset lineStart,
    Offset lineEnd,
  ) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    if (dx == 0 && dy == 0) {
      // Line start and end are the same point
      return (point - lineStart).distance;
    }

    // Calculate perpendicular distance using cross product
    final numerator = ((dy * (point.dx - lineStart.dx)) -
            (dx * (point.dy - lineStart.dy)))
        .abs();
    final denominator = (dx * dx + dy * dy).sqrt();

    return numerator / denominator;
  }

  /// Batch strokes into render groups for better performance
  /// Groups nearby strokes together to reduce draw calls
  static List<List<DrawingStroke>> batchStrokesForRendering(
    List<DrawingStroke> strokes, {
    int maxBatchSize = 100,
  }) {
    if (strokes.isEmpty) return [];

    final batches = <List<DrawingStroke>>[];
    List<DrawingStroke> currentBatch = [];

    for (final stroke in strokes) {
      currentBatch.add(stroke);

      if (currentBatch.length >= maxBatchSize) {
        batches.add(List.from(currentBatch));
        currentBatch.clear();
      }
    }

    // Add remaining strokes
    if (currentBatch.isNotEmpty) {
      batches.add(currentBatch);
    }

    return batches;
  }

  /// Calculate memory usage estimate for strokes
  /// Helps decide when to apply optimizations
  static int estimateStrokeMemoryUsage(List<DrawingStroke> strokes) {
    int totalBytes = 0;

    for (final stroke in strokes) {
      // Each DrawingPoint: ~40 bytes (2 doubles for offset, 1 for pressure, enum, 2 optional doubles)
      totalBytes += stroke.points.length * 40;

      // Stroke metadata: ~100 bytes
      totalBytes += 100;
    }

    return totalBytes;
  }

  /// Check if should apply performance optimizations
  static bool shouldOptimizePerformance(List<DrawingStroke> strokes) {
    // Apply optimizations if:
    // 1. More than 1000 strokes
    // 2. Memory usage > 5MB
    // 3. Total points > 50000

    if (strokes.length > 1000) return true;

    final memoryUsage = estimateStrokeMemoryUsage(strokes);
    if (memoryUsage > 5 * 1024 * 1024) return true; // 5MB

    int totalPoints = 0;
    for (final stroke in strokes) {
      totalPoints += stroke.points.length;
    }
    if (totalPoints > 50000) return true;

    return false;
  }

  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats(List<DrawingStroke> strokes) {
    int totalPoints = 0;
    int totalStrokes = strokes.length;

    for (final stroke in strokes) {
      totalPoints += stroke.points.length;
    }

    final memoryUsage = estimateStrokeMemoryUsage(strokes);
    final avgPointsPerStroke = totalStrokes > 0 ? totalPoints / totalStrokes : 0;

    return {
      'totalStrokes': totalStrokes,
      'totalPoints': totalPoints,
      'avgPointsPerStroke': avgPointsPerStroke.toStringAsFixed(1),
      'memoryUsageMB': (memoryUsage / (1024 * 1024)).toStringAsFixed(2),
      'shouldOptimize': shouldOptimizePerformance(strokes),
    };
  }
}
