import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/templates.dart';
import '../models/study_timer.dart';

/// Gongstagram report image generator
/// Creates beautiful study report images for social media sharing
/// Inspired by 모트모트 aesthetic and 투두메이트 sharing culture
class GongstagramGenerator {
  /// Generate a beautiful study report image
  static Future<ui.Image> generateReportImage({
    required GongstagramReport report,
    required Size size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw based on style
    switch (report.style) {
      case ReportStyle.minimal:
        _drawMinimalStyle(canvas, size, report);
        break;
      case ReportStyle.pastel:
        _drawPastelStyle(canvas, size, report);
        break;
      case ReportStyle.dark:
        _drawDarkStyle(canvas, size, report);
        break;
      case ReportStyle.gradient:
        _drawGradientStyle(canvas, size, report);
        break;
      case ReportStyle.cute:
        _drawCuteStyle(canvas, size, report);
        break;
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  /// Minimal style
  static void _drawMinimalStyle(Canvas canvas, Size size, GongstagramReport report) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFFFFFAF0); // Ivory
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Title area
    final titlePaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.15),
      titlePaint,
    );

    // Date
    final dateText = '${report.date.month}.${report.date.day}';
    _drawText(
      canvas,
      dateText,
      Offset(size.width * 0.05, size.height * 0.05),
      const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: Color(0xFF333333),
      ),
    );

    // Total study time (large display)
    _drawText(
      canvas,
      report.formattedTotalTime,
      Offset(size.width * 0.5, size.height * 0.3),
      const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Color(0xFF667EEA),
        letterSpacing: -2,
      ),
      textAlign: TextAlign.center,
    );

    // Achievement rate
    final achievementText = '${report.achievementRate.toStringAsFixed(0)}% 달성';
    _drawText(
      canvas,
      achievementText,
      Offset(size.width * 0.5, size.height * 0.45),
      const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Color(0xFF666666),
      ),
      textAlign: TextAlign.center,
    );

    // Subject breakdown
    double yOffset = size.height * 0.55;
    for (final entry in report.topSubjects) {
      final subjectText = entry.key;
      final timeText = _formatDuration(entry.value);

      // Subject name
      _drawText(
        canvas,
        subjectText,
        Offset(size.width * 0.1, yOffset),
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      );

      // Time bar
      final barWidth = (entry.value.inMinutes / report.totalStudyTime.inMinutes) * (size.width * 0.5);
      final barPaint = Paint()
        ..color = const Color(0xFF667EEA).withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.1, yOffset + 30, barWidth, 8),
          const Radius.circular(4),
        ),
        barPaint,
      );

      // Time text
      _drawText(
        canvas,
        timeText,
        Offset(size.width * 0.7, yOffset),
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF667EEA),
        ),
      );

      yOffset += 60;
    }

    // Motivational message
    _drawText(
      canvas,
      report.motivationalMessage,
      Offset(size.width * 0.5, size.height * 0.9),
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF999999),
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );

    // Streak indicator
    if (report.studyStreak > 0) {
      _drawText(
        canvas,
        '🔥 ${report.studyStreak}일 연속',
        Offset(size.width * 0.85, size.height * 0.05),
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFF6B35),
        ),
      );
    }
  }

  /// Pastel style
  static void _drawPastelStyle(Canvas canvas, Size size, GongstagramReport report) {
    // Gradient background
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(size.width, size.height),
      [
        const Color(0xFFFFF0F5), // Pastel pink
        const Color(0xFFE6F3FF), // Pastel blue
      ],
    );

    final bgPaint = Paint()..shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Rest similar to minimal but with pastel colors...
    // (Implementation simplified for brevity)
  }

  /// Dark style
  static void _drawDarkStyle(Canvas canvas, Size size, GongstagramReport report) {
    // Dark background
    final bgPaint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Neon accents...
  }

  /// Gradient style
  static void _drawGradientStyle(Canvas canvas, Size size, GongstagramReport report) {
    // Vibrant gradient
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(size.width, size.height),
      [
        const Color(0xFF667EEA),
        const Color(0xFF764BA2),
      ],
    );

    final bgPaint = Paint()..shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  /// Cute style
  static void _drawCuteStyle(Canvas canvas, Size size, GongstagramReport report) {
    // Soft colors with decorative elements
    final bgPaint = Paint()..color = const Color(0xFFFFF9E6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Add cute decorative elements (stars, hearts, etc.)
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign textAlign = TextAlign.left,
  }) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );

    textPainter.layout();

    // Center horizontally if center aligned
    final x = textAlign == TextAlign.center
        ? position.dx - textPainter.width / 2
        : position.dx;

    textPainter.paint(canvas, Offset(x, position.dy));
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Save image to gallery and get shareable path
  static Future<String?> saveAndShare(ui.Image image) async {
    // Convert to bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    // TODO: Implement save to gallery using gal package
    // This would be connected to the existing gallery save functionality

    return null; // Return file path for sharing
  }
}

/// Weekly report generator
class WeeklyReportGenerator {
  static Future<ui.Image> generateWeeklyReport({
    required WeeklyStudySummary summary,
    required Size size,
    ReportStyle style = ReportStyle.minimal,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    _drawWeeklyReport(canvas, size, summary, style);

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  static void _drawWeeklyReport(
    Canvas canvas,
    Size size,
    WeeklyStudySummary summary,
    ReportStyle style,
  ) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFFFFFAF0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Title
    GongstagramGenerator._drawText(
      canvas,
      '주간 공부 리포트',
      Offset(size.width * 0.05, size.height * 0.05),
      const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );

    // Week period
    final weekStart = summary.weekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    final periodText = '${weekStart.month}.${weekStart.day} - ${weekEnd.month}.${weekEnd.day}';

    GongstagramGenerator._drawText(
      canvas,
      periodText,
      Offset(size.width * 0.05, size.height * 0.1),
      const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color(0xFF666666),
      ),
    );

    // Total study time
    final totalHours = summary.totalWeekStudyTime.inHours;
    final totalMinutes = summary.totalWeekStudyTime.inMinutes.remainder(60);

    GongstagramGenerator._drawText(
      canvas,
      '${totalHours}시간 ${totalMinutes}분',
      Offset(size.width * 0.5, size.height * 0.25),
      const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: Color(0xFF667EEA),
      ),
      textAlign: TextAlign.center,
    );

    // Bar chart - daily breakdown
    _drawDailyBarChart(canvas, size, summary);

    // Stats
    final statsY = size.height * 0.75;

    GongstagramGenerator._drawText(
      canvas,
      '평균: ${summary.averageDailyHours.toStringAsFixed(1)}시간/일',
      Offset(size.width * 0.1, statsY),
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF666666),
      ),
    );

    GongstagramGenerator._drawText(
      canvas,
      '공부일: ${summary.studyDaysCount}/7일',
      Offset(size.width * 0.1, statsY + 30),
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF666666),
      ),
    );

    // Perfect week badge
    if (summary.isPerfectWeek) {
      GongstagramGenerator._drawText(
        canvas,
        '🏆 완벽한 주!',
        Offset(size.width * 0.7, statsY),
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700),
        ),
      );
    }
  }

  static void _drawDailyBarChart(Canvas canvas, Size size, WeeklyStudySummary summary) {
    final chartY = size.height * 0.4;
    final chartHeight = size.height * 0.25;
    final barWidth = size.width * 0.1;
    final barSpacing = size.width * 0.02;

    final maxHours = summary.dailySummaries
        .map((d) => d.studyTime.inMinutes)
        .reduce((a, b) => a > b ? a : b)
        / 60;

    for (int i = 0; i < summary.dailySummaries.length; i++) {
      final day = summary.dailySummaries[i];
      final hours = day.studyTime.inMinutes / 60;

      final barHeight = maxHours > 0 ? (hours / maxHours) * chartHeight : 0;

      final x = size.width * 0.05 + i * (barWidth + barSpacing);

      // Bar
      final barPaint = Paint()
        ..color = const Color(0xFF667EEA).withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartY + chartHeight - barHeight, barWidth, barHeight),
          const Radius.circular(4),
        ),
        barPaint,
      );

      // Weekday label
      GongstagramGenerator._drawText(
        canvas,
        day.weekdayShort,
        Offset(x + barWidth / 2, chartY + chartHeight + 10),
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF666666),
        ),
        textAlign: TextAlign.center,
      );

      // Hours label
      if (hours > 0) {
        GongstagramGenerator._drawText(
          canvas,
          '${hours.toStringAsFixed(1)}h',
          Offset(x + barWidth / 2, chartY + chartHeight - barHeight - 15),
          const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF667EEA),
          ),
          textAlign: TextAlign.center,
        );
      }
    }
  }
}
