import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/advanced_pen.dart';
import '../utils/responsive_util.dart';

/// Quick pen switcher for fast pen changes
/// Shows favorite pens in a compact horizontal bar
class PenQuickSwitcher extends StatefulWidget {
  const PenQuickSwitcher({Key? key}) : super(key: key);

  @override
  State<PenQuickSwitcher> createState() => _PenQuickSwitcherState();
}

class _PenQuickSwitcherState extends State<PenQuickSwitcher> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isTablet = ResponsiveUtil.isTablet(context);
        final isDarkMode = provider.isDarkMode;

        // Get favorite pens (first 6)
        final favoritePens = provider.advancedPens.take(6).toList();
        final currentPenId = provider.selectedAdvancedPenId;

        return Positioned(
          right: isTablet ? 20 : 16,
          top: isTablet ? 100 : 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: isTablet ? 56 : 48,
                      height: isTablet ? 56 : 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.black.withValues(alpha: 0.5),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isExpanded ? Icons.close : Icons.palette,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Pen list
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: isTablet ? 80 : 70,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [
                                    Colors.black.withValues(alpha: 0.9),
                                    Colors.black.withValues(alpha: 0.8),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.95),
                                    Colors.white.withValues(alpha: 0.9),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: favoritePens.length,
                          itemBuilder: (context, index) {
                            final pen = favoritePens[index];
                            final isSelected = pen.id == currentPenId;

                            return GestureDetector(
                              onTap: () {
                                provider.selectAdvancedPen(pen.id);
                                setState(() {
                                  _isExpanded = false; // Auto-close after selection
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF667EEA).withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: const Color(0xFF667EEA),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    // Color preview
                                    Container(
                                      width: isTablet ? 40 : 35,
                                      height: isTablet ? 40 : 35,
                                      decoration: BoxDecoration(
                                        color: pen.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.3)
                                              : Colors.black.withValues(alpha: 0.2),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: pen.color.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        pen.getIcon(),
                                        color: _getContrastColor(pen.color),
                                        size: isTablet ? 20 : 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Pen type indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : Colors.black.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getPenTypeShort(pen.type),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Get contrasting color for icon
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Get short pen type name
  String _getPenTypeShort(PenType type) {
    switch (type) {
      case PenType.ballpoint:
        return '볼펜';
      case PenType.fountain:
        return '만년필';
      case PenType.brush:
        return '붓';
      case PenType.marker:
        return '마커';
      case PenType.highlighter:
        return '형광';
      case PenType.pencil:
        return '연필';
      case PenType.calligraphy:
        return '캘리';
      case PenType.neon:
        return '네온';
      case PenType.rainbow:
        return '무지개';
      case PenType.glitter:
        return '반짝';
    }
  }
}
