import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../providers/drawing_provider.dart';
import '../models/drawing_stroke.dart';
import '../models/text_object.dart';
import '../models/note.dart';
import '../models/page_layout.dart';
import '../widgets/text_input_dialog.dart';
import '../services/template_renderer.dart';
import '../services/hybrid_input_detector.dart';
import '../widgets/wrong_answer_clip_dialog.dart';

/// Intelligently inverts colors for dark mode (text version)
Color _invertColorForText(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final invertedLightness = 1.0 - hslColor.lightness;
  final adjustedLightness = invertedLightness < 0.6
      ? 0.6 + (invertedLightness * 0.4)
      : invertedLightness;
  final adjustedSaturation = hslColor.saturation > 0.8
      ? hslColor.saturation * 0.85
      : hslColor.saturation;
  return hslColor
      .withLightness(adjustedLightness)
      .withSaturation(adjustedSaturation)
      .toColor();
}

class DrawingCanvas extends StatefulWidget {
  final GlobalKey repaintBoundaryKey;

  const DrawingCanvas({Key? key, required this.repaintBoundaryKey})
      : super(key: key);

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  Offset? _twoFingerStartPosition;
  int _pointerCount = 0;
  HybridInputDetector? _hybridDetector;
  bool _clipDialogShown = false;
  DateTime? _twoFingerTapTime;
  static const Duration _twoFingerTapTimeout = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Initialize hybrid input detector with repaint boundary key
        _hybridDetector ??= provider.getHybridInputDetector(widget.repaintBoundaryKey);

        // Show text input dialog when text input position is set
        if (provider.textInputPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => const TextInputDialog(),
            );
          });
        }

        // Show wrong answer clip dialog when selection is complete in clip mode
        if (provider.isWrongAnswerClipMode &&
            provider.selectionRect != null &&
            !_clipDialogShown) {
          _clipDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => WrongAnswerClipDialog(
                selectionBounds: provider.selectionRect!,
                repaintBoundaryKey: widget.repaintBoundaryKey,
              ),
            ).then((_) {
              // Reset flag when dialog is closed
              setState(() {
                _clipDialogShown = false;
              });
            });
          });
        }

        // Reset clip dialog flag when mode changes or selection is cleared
        if (!provider.isWrongAnswerClipMode || provider.selectionRect == null) {
          _clipDialogShown = false;
        }

        return Stack(
          children: [
            Listener(
              onPointerDown: (event) {
                _pointerCount++;

                // Track two-finger gesture start position
                if (_pointerCount == 2) {
                  _twoFingerStartPosition = event.localPosition;
                  _twoFingerTapTime = DateTime.now();
                  return; // Don't start drawing with two fingers
                }

                // Only start drawing with one finger
                if (_pointerCount == 1) {
                  // Use hybrid input detector for automatic mode switching
                  _hybridDetector?.onPointerDown(event);

                  // Start drawing with device information
                  provider.startDrawing(
                    event.localPosition,
                    event.pressure,
                    deviceKind: event.kind,
                    tiltX: event.tilt,
                    tiltY: event.orientation,
                  );
                }
              },
              onPointerMove: (event) {
                // Handle two-finger swipe gesture
                if (_pointerCount == 2 && _twoFingerStartPosition != null) {
                  final delta = event.localPosition - _twoFingerStartPosition!;
                  final threshold = 50.0;

                  // Check if swipe distance exceeds threshold
                  if (delta.dx.abs() > threshold || delta.dy.abs() > threshold) {
                    // Determine primary direction
                    if (delta.dx.abs() > delta.dy.abs()) {
                      // Horizontal swipe
                      if (delta.dx > 0) {
                        // Right swipe: Select mode
                        provider.setMode(DrawingMode.select);
                      } else {
                        // Left swipe: Shape mode
                        provider.setMode(DrawingMode.shape);
                      }
                    } else {
                      // Vertical swipe
                      if (delta.dy < 0) {
                        // Up swipe: Pen mode
                        provider.setMode(DrawingMode.pen);
                      } else {
                        // Down swipe: Eraser mode
                        provider.setMode(DrawingMode.eraser);
                      }
                    }

                    // Reset to prevent multiple triggers
                    _twoFingerStartPosition = null;
                  }
                  return;
                }

                // Only update drawing with one finger
                if (_pointerCount == 1) {
                  provider.updateDrawing(
                    event.localPosition,
                    event.pressure,
                    deviceKind: event.kind,
                    tiltX: event.tilt,
                    tiltY: event.orientation,
                  );
                }
              },
              onPointerUp: (event) {
                // Check for two-finger tap (Undo gesture)
                if (_pointerCount == 2 && _twoFingerTapTime != null) {
                  final tapDuration = DateTime.now().difference(_twoFingerTapTime!);
                  if (tapDuration <= _twoFingerTapTimeout) {
                    // Two-finger tap detected! Trigger Undo
                    if (provider.canUndo) {
                      provider.undo();
                    }
                  }
                }

                _pointerCount--;

                if (_pointerCount < 0) _pointerCount = 0;

                // Notify hybrid detector
                _hybridDetector?.onPointerUp(event);

                // Reset two-finger tracking
                if (_pointerCount < 2) {
                  _twoFingerStartPosition = null;
                  _twoFingerTapTime = null;
                }

                // End drawing only if no fingers remain
                if (_pointerCount == 0) {
                  provider.endDrawing();
                }
              },
              onPointerCancel: (event) {
                _pointerCount--;
                if (_pointerCount < 0) _pointerCount = 0;
                _twoFingerStartPosition = null;
              },
              child: RepaintBoundary(
                key: widget.repaintBoundaryKey,
                child: CustomPaint(
                  painter: DrawingPainter(
                    strokes: provider.strokes,
                    currentStroke: provider.currentStroke,
                    currentColor: provider.currentColor,
                    lineWidth: provider.lineWidth,
                    opacity: provider.opacity,
                    isEraser: provider.isEraser,
                    isDarkMode: provider.isDarkMode,
                    shapePreview: provider.isShapeMode ? provider.getShapePreview() : [],
                    showGridLines: provider.settings.showGridLines,
                    noteTemplate: provider.noteService.currentNote?.template ?? NoteTemplate.blank,
                    backgroundColor: provider.noteService.currentNote?.backgroundColor ??
                        (provider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
                    pages: provider.pageManager.pages,
                    currentPageIndex: provider.pageManager.currentPageIndex,
                    enableGlowEffects: provider.performanceSettings.enableGlowEffects,
                    enableGlitterEffects: provider.performanceSettings.enableGlitterEffects,
                    enableShadows: provider.performanceSettings.enableShadows,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: provider.isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            // Text objects overlay
            ...provider.textObjects.map((textObj) => Positioned(
              left: textObj.position.dx,
              top: textObj.position.dy,
              child: GestureDetector(
                onTap: () => provider.selectTextObject(textObj),
                onPanUpdate: (details) {
                  provider.moveTextObject(
                    textObj.id,
                    textObj.position + details.delta,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: provider.selectedTextObject?.id == textObj.id
                        ? const Color(0xFF667EEA).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: provider.selectedTextObject?.id == textObj.id
                        ? Border.all(color: const Color(0xFF667EEA), width: 2)
                        : null,
                  ),
                  child: textObj.type == TextType.latex
                      ? Math.tex(
                          textObj.text,
                          textStyle: TextStyle(
                            fontSize: textObj.fontSize,
                            color: provider.isDarkMode
                                ? _invertColorForText(textObj.color)
                                : textObj.color,
                          ),
                        )
                      : Text(
                          textObj.text,
                          style: TextStyle(
                            fontSize: textObj.fontSize,
                            color: provider.isDarkMode
                                ? _invertColorForText(textObj.color)
                                : textObj.color,
                          ),
                        ),
                ),
              ),
            )),
            // Selection overlay
            if (provider.selectionRect != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: SelectionPainter(
                    selectionRect: provider.selectionRect!,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<DrawingPoint> currentStroke;
  final Color currentColor;
  final double lineWidth;
  final double opacity;
  final bool isEraser;
  final bool isDarkMode;
  final List<DrawingPoint> shapePreview;
  final bool showGridLines;
  final NoteTemplate noteTemplate;
  final Color backgroundColor;
  final List<NotePage> pages;
  final int currentPageIndex;
  final bool enableGlowEffects;
  final bool enableGlitterEffects;
  final bool enableShadows;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.currentColor,
    required this.lineWidth,
    required this.opacity,
    required this.isEraser,
    required this.isDarkMode,
    this.shapePreview = const [],
    this.showGridLines = false,
    this.noteTemplate = NoteTemplate.blank,
    required this.backgroundColor,
    this.pages = const [],
    this.currentPageIndex = 0,
    this.enableGlowEffects = true,
    this.enableGlitterEffects = true,
    this.enableShadows = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw page boundaries if we have pages
    if (pages.isNotEmpty) {
      _drawPageBoundaries(canvas, size);

      // Draw template on each page
      for (final page in pages) {
        canvas.save();
        canvas.translate(0, page.yOffset);

        TemplateRenderer.renderTemplate(
          canvas,
          page.dimensions,
          noteTemplate,
          backgroundColor,
          isDarkMode,
        );

        canvas.restore();
      }
    } else {
      // Fallback: draw template on entire canvas
      TemplateRenderer.renderTemplate(
        canvas,
        size,
        noteTemplate,
        backgroundColor,
        isDarkMode,
      );
    }

    // Draw grid lines if enabled (override template)
    if (showGridLines) {
      _drawGridLines(canvas, size);
    }

    // Draw completed strokes
    for (var stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke being drawn
    if (currentStroke.isNotEmpty) {
      final currentStrokeData = DrawingStroke(
        points: currentStroke,
        color: currentColor,
        width: lineWidth,
        opacity: opacity,
        isEraser: isEraser,
      );
      _drawStroke(canvas, currentStrokeData);
    }

    // Draw shape preview
    if (shapePreview.isNotEmpty) {
      final previewStroke = DrawingStroke(
        points: shapePreview,
        color: currentColor,
        width: lineWidth,
        opacity: opacity * 0.6, // Slightly transparent for preview
        isEraser: false,
      );
      _drawStroke(canvas, previewStroke);
    }
  }

  void _drawPageBoundaries(Canvas canvas, Size size) {
    final pagePaint = Paint()
      ..color = isDarkMode ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Only draw shadows if performance allows
    final shadowPaint = enableShadows
        ? (Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8))
        : null;

    final currentPageHighlightPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF667EEA).withOpacity(0.1)
          : const Color(0xFF667EEA).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      final bounds = page.bounds;

      // Draw page shadow (behind page) if enabled
      if (shadowPaint != null) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            bounds.shift(const Offset(4, 4)),
            const Radius.circular(8),
          ),
          shadowPaint,
        );
      }

      // Highlight current page
      if (i == currentPageIndex) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(bounds, const Radius.circular(8)),
          currentPageHighlightPaint,
        );
      }

      // Draw page boundary
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(8)),
        pagePaint,
      );

      // Draw page number
      _drawPageNumber(canvas, page, bounds);
    }
  }

  void _drawPageNumber(Canvas canvas, NotePage page, Rect bounds) {
    final textSpan = TextSpan(
      text: '${page.pageNumber}',
      style: TextStyle(
        color: isDarkMode ? Colors.white38 : Colors.black26,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Draw at bottom center of page
    final x = bounds.center.dx - textPainter.width / 2;
    final y = bounds.bottom - textPainter.height - 12;

    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw single point as a dot (for immediate feedback when user starts drawing)
    if (stroke.points.length == 1) {
      final point = stroke.points[0];
      final pressure = point.pressure;
      final dotRadius = stroke.isEraser
          ? stroke.width * 1.5
          : stroke.width * (0.5 + pressure * 0.5);

      paint.color = stroke.isEraser
          ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white)
          : (isDarkMode
              ? _invertColorIntelligently(stroke.color).withOpacity(stroke.opacity)
              : stroke.color.withOpacity(stroke.opacity));

      canvas.drawCircle(point.offset, dotRadius, paint);
      return;
    }

    // Apply glow effect if enabled (performance setting check)
    if (enableGlowEffects && stroke.enableGlow && !stroke.isEraser) {
      _drawGlowEffect(canvas, stroke);
    }

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final point1 = stroke.points[i];
      final point2 = stroke.points[i + 1];

      final pressure = (point1.pressure + point2.pressure) / 2;

      // Apply tapering (thinner at ends)
      double taperingFactor = 1.0;
      if (stroke.tapering > 0) {
        final progress = i / (stroke.points.length - 1);
        final distanceFromCenter = (progress - 0.5).abs() * 2;
        taperingFactor = 1.0 - (distanceFromCenter * stroke.tapering);
      }

      final adjustedWidth = stroke.isEraser
          ? stroke.width * 3
          : stroke.width * (0.5 + pressure) * taperingFactor;

      // Rainbow gradient effect
      if (stroke.gradientColors != null && stroke.gradientColors!.length > 1) {
        final progress = i / (stroke.points.length - 1);
        final colorIndex = (progress * (stroke.gradientColors!.length - 1)).floor();
        final nextColorIndex = (colorIndex + 1).clamp(0, stroke.gradientColors!.length - 1);
        final localProgress = (progress * (stroke.gradientColors!.length - 1)) - colorIndex;

        paint.color = Color.lerp(
          stroke.gradientColors![colorIndex],
          stroke.gradientColors![nextColorIndex],
          localProgress,
        )!.withOpacity(stroke.opacity);
      } else {
        paint.color = stroke.isEraser
            ? (isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white)
            : (isDarkMode
                ? _invertColorIntelligently(stroke.color).withOpacity(stroke.opacity)
                : stroke.color.withOpacity(stroke.opacity));
      }

      paint.strokeWidth = adjustedWidth;
      canvas.drawLine(point1.offset, point2.offset, paint);

      // Draw glitter particles (performance setting check)
      if (enableGlitterEffects && stroke.glitterDensity != null && stroke.glitterDensity! > 0 && !stroke.isEraser) {
        _drawGlitterParticles(canvas, point1.offset, point2.offset, stroke);
      }
    }
  }

  /// Draw glow effect around stroke
  void _drawGlowEffect(Canvas canvas, DrawingStroke stroke) {
    final glowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final point1 = stroke.points[i];
      final point2 = stroke.points[i + 1];

      final pressure = (point1.pressure + point2.pressure) / 2;
      final adjustedWidth = stroke.width * (0.5 + pressure) * 2; // Wider for glow

      glowPaint.color = (isDarkMode
              ? _invertColorIntelligently(stroke.color)
              : stroke.color)
          .withOpacity(stroke.opacity * 0.3);
      glowPaint.strokeWidth = adjustedWidth;

      canvas.drawLine(point1.offset, point2.offset, glowPaint);
    }
  }

  /// Draw glitter particles along stroke
  void _drawGlitterParticles(Canvas canvas, Offset start, Offset end, DrawingStroke stroke) {
    final particleCount = (stroke.glitterDensity! * 3).toInt();
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.8);

    for (int i = 0; i < particleCount; i++) {
      final t = i / particleCount;
      final position = Offset.lerp(start, end, t)!;

      // Add random offset for sparkle effect
      final random = (position.dx * position.dy * i).toInt() % 100;
      final offsetX = (random % 10 - 5) * 0.5;
      final offsetY = ((random ~/ 10) % 10 - 5) * 0.5;

      final particlePos = position + Offset(offsetX, offsetY);
      final size = 1.0 + (random % 3);

      canvas.drawCircle(particlePos, size, paint);
    }
  }

  /// Intelligently inverts colors for dark mode
  /// - Black → White
  /// - Dark colors → Light versions
  /// - Preserves hue, inverts lightness
  Color _invertColorIntelligently(Color color) {
    // Convert to HSL
    final hslColor = HSLColor.fromColor(color);

    // Invert lightness: dark becomes light, light becomes dark
    // We use a complementary lightness calculation
    final invertedLightness = 1.0 - hslColor.lightness;

    // Boost lightness to ensure visibility on dark background
    // Minimum lightness of 0.6 to keep colors bright
    final adjustedLightness = invertedLightness < 0.6 ? 0.6 + (invertedLightness * 0.4) : invertedLightness;

    // Slightly reduce saturation for very saturated colors to avoid eye strain
    final adjustedSaturation = hslColor.saturation > 0.8
        ? hslColor.saturation * 0.85
        : hslColor.saturation;

    return hslColor
        .withLightness(adjustedLightness)
        .withSaturation(adjustedSaturation)
        .toColor();
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSpacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.shapePreview != shapePreview ||
        oldDelegate.showGridLines != showGridLines ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

class SelectionPainter extends CustomPainter {
  final Rect selectionRect;

  SelectionPainter({required this.selectionRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw selection background
    final bgPaint = Paint()
      ..color = const Color(0xFF667EEA).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(selectionRect, bgPaint);

    // Draw selection border
    final borderPaint = Paint()
      ..color = const Color(0xFF667EEA)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Dashed border
    final path = Path()
      ..addRect(selectionRect);
    
    canvas.drawPath(_createDashedPath(path, 8, 4), borderPaint);

    // Draw corner handles
    final handlePaint = Paint()
      ..color = const Color(0xFF667EEA)
      ..style = PaintingStyle.fill;
    
    final handleSize = 8.0;
    final corners = [
      selectionRect.topLeft,
      selectionRect.topRight,
      selectionRect.bottomLeft,
      selectionRect.bottomRight,
    ];

    for (var corner in corners) {
      canvas.drawCircle(corner, handleSize, handlePaint);
      canvas.drawCircle(
        corner,
        handleSize,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  Path _createDashedPath(Path source, double dashLength, double dashSpace) {
    final Path dest = Path();
    for (PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(SelectionPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}
