import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/responsive_util.dart';
import './ocr_result_dialog.dart';
import './template_picker.dart';

class FloatingToolbar extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;

  const FloatingToolbar({Key? key, required this.repaintBoundaryKey}) : super(key: key);

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
    final buttonSize = isTablet ? 56.0 : 48.0;
    final smallButtonSize = isTablet ? 48.0 : 40.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final smallIconSize = isTablet ? 24.0 : 20.0;
    final spacing = isTablet ? 12.0 : 8.0;
    final padding = isTablet ? 20.0 : 16.0;
    final verticalPadding = isTablet ? 16.0 : 12.0;
    final colorButtonSize = isTablet ? 48.0 : 40.0;

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Hide in focus mode
        if (provider.focusMode) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: isTablet ? 40 : 30,
          left: isTablet ? 30 : 20,
          right: isTablet ? 30 : 20,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 36 : 30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: verticalPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: provider.isDarkMode
                          ? [
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.5),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.white.withOpacity(0.5),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: provider.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tool buttons (only show if enabled in settings)
                        if (provider.settings.showPenTool) ...[
                          _ModernToolButton(
                            icon: Icons.edit,
                            isActive: provider.mode == DrawingMode.pen,
                            onTap: () => provider.setMode(DrawingMode.pen),
                            isDarkMode: provider.isDarkMode,
                            size: buttonSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(width: spacing),
                        ],
                        if (provider.settings.showEraserTool) ...[
                          _ModernToolButton(
                            icon: Icons.auto_fix_high_outlined,
                            isActive: provider.mode == DrawingMode.eraser,
                            onTap: () => provider.setMode(DrawingMode.eraser),
                            isDarkMode: provider.isDarkMode,
                            size: buttonSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(width: spacing),
                        ],
                        if (provider.settings.showSelectTool) ...[
                          _ModernToolButton(
                            icon: Icons.select_all,
                            isActive: provider.mode == DrawingMode.select,
                            onTap: () => provider.setMode(DrawingMode.select),
                            isDarkMode: provider.isDarkMode,
                            size: buttonSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(width: spacing),
                        ],
                        // Wrong Answer Clip tool (가위 아이콘)
                        _ModernToolButton(
                          icon: Icons.content_cut,
                          isActive: provider.mode == DrawingMode.wrongAnswerClip,
                          onTap: () => provider.setMode(DrawingMode.wrongAnswerClip),
                          isDarkMode: provider.isDarkMode,
                          size: buttonSize,
                          iconSize: iconSize,
                        ),
                        SizedBox(width: spacing),
                        if (provider.settings.showShapeTool) ...[
                          _ModernToolButton(
                            icon: Icons.category_outlined,
                            isActive: provider.mode == DrawingMode.shape,
                            onTap: () => provider.setMode(DrawingMode.shape),
                            isDarkMode: provider.isDarkMode,
                            size: buttonSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(width: spacing),
                        ],
                        if (provider.settings.showTextTool) ...[
                          _ModernToolButton(
                            icon: Icons.text_fields,
                            isActive: provider.mode == DrawingMode.text,
                            onTap: () => provider.setMode(DrawingMode.text),
                            isDarkMode: provider.isDarkMode,
                            size: buttonSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(width: spacing),
                        ],

                        // Auto-shape toggle (only show when pen mode)
                        if (provider.mode == DrawingMode.pen) ...[
                          SizedBox(width: spacing),
                          _ModernToolButton(
                            icon: Icons.auto_awesome,
                            isActive: provider.autoShapeEnabled,
                            onTap: () => provider.toggleAutoShape(),
                            isDarkMode: provider.isDarkMode,
                            size: smallButtonSize,
                            iconSize: smallIconSize,
                          ),
                        ],

                        // Divider
                        if (provider.selectionRect != null || provider.mode == DrawingMode.pen) ...[
                          SizedBox(width: spacing * 1.5),
                          Container(
                            width: 1,
                            height: isTablet ? 36 : 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.2),
                                        Colors.black.withOpacity(0),
                                      ],
                              ),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),
                        ],

                        // Shape conversion & OCR buttons (only show when selection exists)
                        if (provider.selectionRect != null) ...[
                          _ModernActionButton(
                            icon: Icons.auto_fix_high,
                            label: '도형',
                            onTap: () => provider.convertSelectionToShapes(),
                            color: const Color(0xFF5E5CE6),
                            isDarkMode: provider.isDarkMode,
                            isLoading: false,
                            isTablet: isTablet,
                          ),
                          SizedBox(width: spacing),
                          _ModernActionButton(
                            icon: Icons.text_snippet,
                            label: '텍스트',
                            onTap: () => _recognizeText(context, provider),
                            color: const Color(0xFF34C759),
                            isDarkMode: provider.isDarkMode,
                            isLoading: provider.isProcessingOCR,
                            isTablet: isTablet,
                          ),
                          SizedBox(width: spacing),
                          _ModernActionButton(
                            icon: Icons.functions,
                            label: '수식',
                            onTap: () => _recognizeMath(context, provider),
                            color: const Color(0xFF007AFF),
                            isDarkMode: provider.isDarkMode,
                            isLoading: provider.isProcessingOCR,
                            isTablet: isTablet,
                          ),
                          SizedBox(width: spacing),
                          _ModernActionButton(
                            icon: Icons.auto_awesome,
                            label: 'LaTeX',
                            onTap: () => _convertToLatex(context, provider),
                            color: const Color(0xFFFF9500),
                            isDarkMode: provider.isDarkMode,
                            isLoading: provider.isProcessingOCR,
                            isTablet: isTablet,
                          ),
                        ],

                        // Recent colors (only show when pen mode and has recent colors)
                        if (provider.mode == DrawingMode.pen &&
                            provider.selectionRect == null &&
                            provider.recentColors.isNotEmpty) ...[
                          // Divider before recent colors
                          Container(
                            width: 1,
                            height: isTablet ? 36 : 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.2),
                                        Colors.black.withOpacity(0),
                                      ],
                              ),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),

                          // Recent colors label
                          Text(
                            '최근',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              fontWeight: FontWeight.w600,
                              color: provider.isDarkMode
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(width: spacing),

                          ...provider.recentColors.map((color) => Padding(
                                padding: EdgeInsets.only(right: spacing),
                                child: _ModernColorButton(
                                  color: color,
                                  isSelected: provider.currentColor == color,
                                  onTap: () => provider.setColor(color),
                                  isDarkMode: provider.isDarkMode,
                                  size: colorButtonSize * 0.9, // Slightly smaller
                                ),
                              )),

                          // Divider after recent colors
                          Container(
                            width: 1,
                            height: isTablet ? 36 : 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.2),
                                        Colors.black.withOpacity(0),
                                      ],
                              ),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),
                        ],

                        // Color palette (only show when pen mode)
                        if (provider.mode == DrawingMode.pen && provider.selectionRect == null) ...[
                          ...presetColors.map((color) => Padding(
                                padding: EdgeInsets.only(right: spacing),
                                child: _ModernColorButton(
                                  color: color,
                                  isSelected: provider.currentColor == color,
                                  onTap: () => provider.setColor(color),
                                  isDarkMode: provider.isDarkMode,
                                  size: colorButtonSize,
                                ),
                              )),
                        ],

                        // Template picker button (show for all modes except select with rect)
                        if (provider.selectionRect == null) ...[
                          // Divider before template picker
                          Container(
                            width: 1,
                            height: isTablet ? 36 : 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0),
                                      ]
                                    : [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.2),
                                        Colors.black.withOpacity(0),
                                      ],
                              ),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),
                          const TemplatePickerButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _recognizeText(BuildContext context, DrawingProvider provider) async {
    final result = await provider.recognizeSelection(repaintBoundaryKey);
    if (result != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => OCRResultDialog(
          text: result['text'],
          isMath: false,
          latex: '',
        ),
      );
      provider.clearSelection();
    }
  }

  Future<void> _recognizeMath(BuildContext context, DrawingProvider provider) async {
    final result = await provider.recognizeSelection(repaintBoundaryKey);
    if (result != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => OCRResultDialog(
          text: result['text'],
          isMath: result['isMath'],
          latex: result['latex'],
        ),
      );
      provider.clearSelection();
    }
  }

  Future<void> _convertToLatex(BuildContext context, DrawingProvider provider) async {
    await provider.convertSelectionToLatex(repaintBoundaryKey);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '손글씨가 LaTeX로 변환되었습니다',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF34C759),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }
}

class _ModernToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;
  final double size;
  final double iconSize;

  const _ModernToolButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive
              ? null
              : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isActive
              ? Colors.white
              : (isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7)),
        ),
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDarkMode;
  final bool isLoading;
  final bool isTablet;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.isDarkMode,
    required this.isLoading,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isTablet ? 16.0 : 14.0;
    final verticalPadding = isTablet ? 12.0 : 10.0;
    final iconSize = isTablet ? 20.0 : 18.0;
    final fontSize = isTablet ? 14.0 : 13.0;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: iconSize),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;
  final double size;

  const _ModernColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isSelected
            ? Icon(Icons.check, color: Colors.white, size: size * 0.5)
            : null,
      ),
    );
  }
}
