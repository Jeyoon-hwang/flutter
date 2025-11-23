import 'dart:ui';
import '../models/drawing_stroke.dart';

/// Stroke smoothing utilities for better pen experience
/// Implements multiple smoothing algorithms for natural writing feel
class StrokeSmoother {
  /// Apply smoothing to a list of points based on smoothing factor
  /// smoothing: 0.0 (no smoothing) to 1.0 (maximum smoothing)
  static List<DrawingPoint> smoothPoints(
    List<DrawingPoint> points,
    double smoothing,
  ) {
    if (points.length < 3 || smoothing <= 0.0) {
      return points;
    }

    // Choose smoothing algorithm based on smoothing level
    if (smoothing < 0.5) {
      // Low smoothing: Simple weighted average (fast, subtle)
      return _weightedAverageSmoothing(points, smoothing);
    } else {
      // High smoothing: Catmull-Rom spline (smooth, natural curves)
      return _catmullRomSmoothing(points, smoothing);
    }
  }

  /// Simple weighted average smoothing - fast and subtle
  /// Good for ballpoint and pencil (smoothing < 0.5)
  static List<DrawingPoint> _weightedAverageSmoothing(
    List<DrawingPoint> points,
    double smoothing,
  ) {
    final smoothed = <DrawingPoint>[];

    // Keep first point
    smoothed.add(points.first);

    // Smooth middle points
    for (int i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final next = points[i + 1];

      // Weighted average: more smoothing = more weight on neighbors
      final weight = smoothing * 0.5; // Max 0.25 contribution from each neighbor

      final smoothedOffset = Offset(
        curr.offset.dx * (1.0 - 2 * weight) +
        prev.offset.dx * weight +
        next.offset.dx * weight,
        curr.offset.dy * (1.0 - 2 * weight) +
        prev.offset.dy * weight +
        next.offset.dy * weight,
      );

      final smoothedPressure = curr.pressure * (1.0 - 2 * weight) +
                                prev.pressure * weight +
                                next.pressure * weight;

      smoothed.add(DrawingPoint(
        offset: smoothedOffset,
        pressure: smoothedPressure.clamp(0.0, 1.0),
        deviceType: curr.deviceType,
        tiltX: curr.tiltX,
        tiltY: curr.tiltY,
      ));
    }

    // Keep last point
    smoothed.add(points.last);

    return smoothed;
  }

  /// Catmull-Rom spline smoothing - creates smooth curves
  /// Good for brush, fountain pen, and calligraphy (smoothing >= 0.5)
  static List<DrawingPoint> _catmullRomSmoothing(
    List<DrawingPoint> points,
    double smoothing,
  ) {
    if (points.length < 4) {
      return _weightedAverageSmoothing(points, smoothing);
    }

    final smoothed = <DrawingPoint>[];

    // Keep first point
    smoothed.add(points.first);

    // Generate interpolated points using Catmull-Rom spline
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

      // Number of interpolation steps (more smoothing = more steps)
      final steps = (smoothing * 4).toInt() + 1;

      for (int j = 0; j < steps; j++) {
        final t = j / steps;
        final offset = _catmullRomInterpolate(
          p0.offset,
          p1.offset,
          p2.offset,
          p3.offset,
          t,
        );

        final pressure = _catmullRomInterpolateScalar(
          p0.pressure,
          p1.pressure,
          p2.pressure,
          p3.pressure,
          t,
        );

        smoothed.add(DrawingPoint(
          offset: offset,
          pressure: pressure.clamp(0.0, 1.0),
          deviceType: p1.deviceType,
          tiltX: p1.tiltX,
          tiltY: p1.tiltY,
        ));
      }
    }

    // Keep last point
    smoothed.add(points.last);

    return smoothed;
  }

  /// Catmull-Rom spline interpolation for 2D points
  static Offset _catmullRomInterpolate(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;

    final x = 0.5 * (
      (2 * p1.dx) +
      (-p0.dx + p2.dx) * t +
      (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
      (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3
    );

    final y = 0.5 * (
      (2 * p1.dy) +
      (-p0.dy + p2.dy) * t +
      (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
      (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3
    );

    return Offset(x, y);
  }

  /// Catmull-Rom interpolation for scalar values (like pressure)
  static double _catmullRomInterpolateScalar(
    double p0,
    double p1,
    double p2,
    double p3,
    double t,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;

    return 0.5 * (
      (2 * p1) +
      (-p0 + p2) * t +
      (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
      (-p0 + 3 * p1 - 3 * p2 + p3) * t3
    );
  }

  /// Reduce jitter by removing points that are too close together
  /// Improves performance and reduces micro-jitter from input
  static List<DrawingPoint> removeJitter(
    List<DrawingPoint> points, {
    double minDistance = 1.0,
  }) {
    if (points.length < 2) return points;

    final filtered = <DrawingPoint>[points.first];

    for (int i = 1; i < points.length; i++) {
      final lastPoint = filtered.last;
      final currentPoint = points[i];

      final distance = (currentPoint.offset - lastPoint.offset).distance;

      if (distance >= minDistance) {
        filtered.add(currentPoint);
      }
    }

    // Always keep the last point for accurate endpoint
    if (filtered.last != points.last) {
      filtered.add(points.last);
    }

    return filtered;
  }

  /// Apply velocity-based width adjustment
  /// Fast strokes become thinner, slow strokes become thicker
  static List<DrawingPoint> applyVelocityAdjustment(
    List<DrawingPoint> points, {
    double velocityFactor = 0.3,
  }) {
    if (points.length < 2 || velocityFactor <= 0) return points;

    final adjusted = <DrawingPoint>[];

    for (int i = 0; i < points.length; i++) {
      double velocityAdjustment = 1.0;

      if (i > 0) {
        final distance = (points[i].offset - points[i - 1].offset).distance;
        // Normalize velocity (assuming ~60 FPS, typical touch speed)
        final normalizedVelocity = (distance / 10.0).clamp(0.0, 2.0);

        // Fast = thinner (velocity > 1), slow = thicker (velocity < 1)
        velocityAdjustment = 1.0 - (normalizedVelocity - 1.0) * velocityFactor;
        velocityAdjustment = velocityAdjustment.clamp(0.5, 1.5);
      }

      // Adjust pressure based on velocity
      final adjustedPressure = (points[i].pressure * velocityAdjustment).clamp(0.0, 1.0);

      adjusted.add(DrawingPoint(
        offset: points[i].offset,
        pressure: adjustedPressure,
        deviceType: points[i].deviceType,
        tiltX: points[i].tiltX,
        tiltY: points[i].tiltY,
      ));
    }

    return adjusted;
  }
}
