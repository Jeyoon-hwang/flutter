import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/note.dart';

/// Service for rendering note templates (lined, grid, dots, cornell, music)
class TemplateRenderer {
  /// Render template background on canvas
  static void renderTemplate(
    Canvas canvas,
    Size size,
    NoteTemplate template,
    Color backgroundColor,
    bool isDarkMode,
  ) {
    // Fill background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Template line color
    final lineColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    switch (template) {
      case NoteTemplate.blank:
        // Nothing to draw
        break;

      case NoteTemplate.lined:
        _renderLinedTemplate(canvas, size, lineColor);
        break;

      case NoteTemplate.grid:
        _renderGridTemplate(canvas, size, lineColor);
        break;

      case NoteTemplate.dots:
        _renderDotsTemplate(canvas, size, lineColor);
        break;

      case NoteTemplate.cornell:
        _renderCornellTemplate(canvas, size, lineColor, isDarkMode);
        break;

      case NoteTemplate.music:
        _renderMusicTemplate(canvas, size, lineColor);
        break;
    }
  }

  /// Lined paper template (horizontal lines)
  static void _renderLinedTemplate(Canvas canvas, Size size, Color lineColor) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const lineSpacing = 40.0; // Space between lines
    const marginLeft = 80.0; // Left margin line

    // Draw horizontal lines
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw left margin line
    final marginPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(marginLeft, 0),
      Offset(marginLeft, size.height),
      marginPaint,
    );
  }

  /// Grid template (horizontal and vertical lines)
  static void _renderGridTemplate(Canvas canvas, Size size, Color lineColor) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 40.0; // Size of each grid cell

    // Draw vertical lines
    for (double x = gridSize; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = gridSize; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw thicker lines every 5 cells
    final thickPaint = Paint()
      ..color = lineColor.withValues(alpha: 1.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (double x = gridSize * 5; x < size.width; x += gridSize * 5) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        thickPaint,
      );
    }

    for (double y = gridSize * 5; y < size.height; y += gridSize * 5) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        thickPaint,
      );
    }
  }

  /// Dots template (grid of dots)
  static void _renderDotsTemplate(Canvas canvas, Size size, Color lineColor) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    const dotSpacing = 30.0; // Space between dots
    const dotRadius = 1.5; // Radius of each dot

    // Draw dots
    for (double x = dotSpacing; x < size.width; x += dotSpacing) {
      for (double y = dotSpacing; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }

    // Draw slightly larger dots every 5 positions
    final largeDotPaint = Paint()
      ..color = lineColor.withValues(alpha: 1.5)
      ..style = PaintingStyle.fill;

    for (double x = dotSpacing * 5; x < size.width; x += dotSpacing * 5) {
      for (double y = dotSpacing * 5; y < size.height; y += dotSpacing * 5) {
        canvas.drawCircle(Offset(x, y), dotRadius * 1.5, largeDotPaint);
      }
    }
  }

  /// Cornell note-taking template
  static void _renderCornellTemplate(
    Canvas canvas,
    Size size,
    Color lineColor,
    bool isDarkMode,
  ) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final thickPaint = Paint()
      ..color = lineColor.withValues(alpha: 1.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const lineSpacing = 40.0;
    const cueColumnWidth = 250.0; // Left column for cues
    const summaryHeight = 150.0; // Bottom area for summary

    // Draw horizontal lines (for main notes area)
    for (double y = lineSpacing; y < size.height - summaryHeight; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical line separating cue column
    canvas.drawLine(
      const Offset(cueColumnWidth, 0),
      Offset(cueColumnWidth, size.height - summaryHeight),
      thickPaint,
    );

    // Draw horizontal line separating summary area
    canvas.drawLine(
      Offset(0, size.height - summaryHeight),
      Offset(size.width, size.height - summaryHeight),
      thickPaint,
    );

    // Add labels (using TextPainter)
    _drawLabel(
      canvas,
      'Cues',
      const Offset(20, 10),
      lineColor,
      isDarkMode,
    );
    _drawLabel(
      canvas,
      'Notes',
      Offset(cueColumnWidth + 20, 10),
      lineColor,
      isDarkMode,
    );
    _drawLabel(
      canvas,
      'Summary',
      Offset(20, size.height - summaryHeight + 10),
      lineColor,
      isDarkMode,
    );
  }

  /// Music staff template (5-line staves)
  static void _renderMusicTemplate(Canvas canvas, Size size, Color lineColor) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const linesPerStaff = 5;
    const lineSpacing = 12.0; // Space between lines in a staff
    const staffSpacing = 80.0; // Space between staves
    const staffHeight = lineSpacing * (linesPerStaff - 1);

    double currentY = 60.0; // Start position

    while (currentY + staffHeight < size.height - 40) {
      // Draw 5 lines for this staff
      for (int i = 0; i < linesPerStaff; i++) {
        final y = currentY + (i * lineSpacing);
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }

      // Draw bar line at the start
      final barPaint = Paint()
        ..color = lineColor.withValues(alpha: 1.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(40, currentY),
        Offset(40, currentY + staffHeight),
        barPaint,
      );

      currentY += staffHeight + staffSpacing;
    }
  }

  /// Helper method to draw text labels
  static void _drawLabel(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    bool isDarkMode,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  /// Get template name in Korean
  static String getTemplateName(NoteTemplate template) {
    switch (template) {
      case NoteTemplate.blank:
        return '백지';
      case NoteTemplate.lined:
        return '줄 노트';
      case NoteTemplate.grid:
        return '격자';
      case NoteTemplate.dots:
        return '점선';
      case NoteTemplate.cornell:
        return '코넬식';
      case NoteTemplate.music:
        return '오선지';
    }
  }

  /// Get template icon
  static IconData getTemplateIcon(NoteTemplate template) {
    switch (template) {
      case NoteTemplate.blank:
        return Icons.note;
      case NoteTemplate.lined:
        return Icons.subject;
      case NoteTemplate.grid:
        return Icons.grid_on;
      case NoteTemplate.dots:
        return Icons.scatter_plot;
      case NoteTemplate.cornell:
        return Icons.view_sidebar;
      case NoteTemplate.music:
        return Icons.music_note;
    }
  }
}
