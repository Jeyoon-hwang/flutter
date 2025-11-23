import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/responsive_util.dart';
import '../models/advanced_pen.dart';
import './ocr_result_dialog.dart';
import './template_picker.dart';
import './pen_customizer.dart';

class FloatingToolbar extends StatefulWidget {
  final GlobalKey repaintBoundaryKey;

  const FloatingToolbar({Key? key, required this.repaintBoundaryKey}) : super(key: key);

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar> {
  String? _selectedPenId;

  static const List<Color> presetColors = [
    Colors.black,
    Color(0xFF424242),
    Color(0xFFFF3B30),
    Color(0xFFFF2D55),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF30D158),
    Color(0xFF007AFF),
    Color(0xFF0A84FF),
    Color(0xFF5E5CE6),
    Color(0xFFAF52DE),
    Color(0xFFBF5AF2),
    Color(0xFF8E8E93),
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final advancedPens = provider.advancedPens;

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            Colors.black.withValues(alpha: 0.95),
                            Colors.black.withValues(alpha: 0.98),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.98),
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Advanced Pens Section
                          ...advancedPens.take(isTablet ? 6 : 4).map((pen) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildPenButton(
                                  context,
                                  provider,
                                  pen,
                                  isSelected: pen.id == _selectedPenId,
                                  isDarkMode: isDarkMode,
                                ),
                              )),

                          // Add Pen Button
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToolButton(
                              context,
                              icon: Icons.add_circle_outline,
                              label: '펜 추가',
                              isActive: false,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _showPenCustomizer(context, provider);
                              },
                              isDarkMode: isDarkMode,
                            ),
                          ),

                          // Divider
                          Container(
                            width: 2,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0.1),
                                        Colors.white.withValues(alpha: 0.05),
                                      ]
                                    : [
                                        Colors.black.withValues(alpha: 0.1),
                                        Colors.black.withValues(alpha: 0.05),
                                      ],
                              ),
                            ),
                          ),

                          // Tools Section
                          if (provider.settings.showEraserTool) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildToolButton(
                                context,
                                icon: Icons.auto_fix_high,
                                label: '지우개',
                                isActive: provider.mode == DrawingMode.eraser,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  provider.setMode(DrawingMode.eraser);
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],

                          // Clear All (only in eraser mode)
                          if (provider.mode == DrawingMode.eraser) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildToolButton(
                                context,
                                icon: Icons.delete_sweep,
                                label: '전체 지우기',
                                isActive: false,
                                onTap: () {
                                  _showClearAllDialog(context, provider);
                                },
                                isDarkMode: isDarkMode,
                                color: Colors.red,
                              ),
                            ),
                          ],

                          if (provider.settings.showSelectTool) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildToolButton(
                                context,
                                icon: Icons.select_all,
                                label: '선택',
                                isActive: provider.mode == DrawingMode.select,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  provider.setMode(DrawingMode.select);
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],

                          // Wrong Answer Clip
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToolButton(
                              context,
                              icon: Icons.content_cut,
                              label: '오답',
                              isActive: provider.mode == DrawingMode.wrongAnswerClip,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                provider.setMode(DrawingMode.wrongAnswerClip);
                              },
                              isDarkMode: isDarkMode,
                            ),
                          ),

                          if (provider.settings.showShapeTool) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildToolButton(
                                context,
                                icon: Icons.category_outlined,
                                label: '도형',
                                isActive: provider.mode == DrawingMode.shape,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  provider.setMode(DrawingMode.shape);
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],

                          if (provider.settings.showTextTool) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildToolButton(
                                context,
                                icon: Icons.text_fields,
                                label: '텍스트',
                                isActive: provider.mode == DrawingMode.text,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  provider.setMode(DrawingMode.text);
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],

                          // Divider
                          Container(
                            width: 2,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0.1),
                                        Colors.white.withValues(alpha: 0.05),
                                      ]
                                    : [
                                        Colors.black.withValues(alpha: 0.1),
                                        Colors.black.withValues(alpha: 0.05),
                                      ],
                              ),
                            ),
                          ),

                          // Undo/Redo
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToolButton(
                              context,
                              icon: Icons.undo,
                              label: 'Undo',
                              isActive: false,
                              onTap: provider.canUndo
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      provider.undo();
                                    }
                                  : null,
                              isDarkMode: isDarkMode,
                              isEnabled: provider.canUndo,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToolButton(
                              context,
                              icon: Icons.redo,
                              label: 'Redo',
                              isActive: false,
                              onTap: provider.canRedo
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      provider.redo();
                                    }
                                  : null,
                              isDarkMode: isDarkMode,
                              isEnabled: provider.canRedo,
                            ),
                          ),

                          // OCR Tool
                          if (provider.settings.showOcrTool) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildToolButton(
                                context,
                                icon: Icons.text_rotation_none,
                                label: 'OCR',
                                isActive: provider.mode == DrawingMode.ocr,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  provider.setMode(DrawingMode.ocr);
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],

                          // Template Tool
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildToolButton(
                              context,
                              icon: Icons.grid_on,
                              label: '템플릿',
                              isActive: false,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _showTemplatePicker(context, provider);
                              },
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPenButton(
    BuildContext context,
    DrawingProvider provider,
    AdvancedPen pen,
    {required bool isSelected, required bool isDarkMode}
  ) {
    return Tooltip(
      message: '${pen.name}\n탭: 선택 | 길게 누르기: 편집',
      preferBelow: false,
      verticalOffset: 10,
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedPenId = pen.id;
          });
          provider.setAdvancedPen(pen);
          provider.setMode(DrawingMode.pen);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showPenCustomizer(context, provider, pen: pen);
        },
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withValues(alpha: 0.2)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF667EEA)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pen preview
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: pen.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            // Pen name
            Text(
              pen.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
    required bool isDarkMode,
    bool isEnabled = true,
    Color? color,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      verticalOffset: 10,
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.3,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? (color ?? const Color(0xFF667EEA)).withValues(alpha: 0.2)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? (color ?? const Color(0xFF667EEA))
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1)),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: color ??
                    (isActive
                        ? const Color(0xFF667EEA)
                        : (isDarkMode ? Colors.white : Colors.black87)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: color ??
                      (isDarkMode ? Colors.white70 : Colors.black54),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void _showPenCustomizer(BuildContext context, DrawingProvider provider, {AdvancedPen? pen}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PenCustomizer(
        pen: pen,
        onSave: (newPen) {
          if (pen == null) {
            provider.addAdvancedPen(newPen);
          } else {
            provider.updateAdvancedPen(newPen);
          }
          setState(() {
            _selectedPenId = newPen.id;
          });
        },
        onDelete: pen != null
            ? () {
                provider.deleteAdvancedPen(pen.id);
                if (_selectedPenId == pen.id) {
                  setState(() {
                    _selectedPenId = null;
                  });
                }
              }
            : null,
      ),
    );
  }

  void _showTemplatePicker(BuildContext context, DrawingProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TemplatePicker(
        onTemplateSelected: (template) {
          provider.setTemplate(template);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, DrawingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_sweep,
                color: Color(0xFFFF3B30),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('전체 지우기'),
          ],
        ),
        content: const Text('모든 내용을 지우시겠습니까?\n이 작업은 실행 취소할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearCanvas();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              elevation: 0,
            ),
            child: const Text(
              '전체 지우기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
