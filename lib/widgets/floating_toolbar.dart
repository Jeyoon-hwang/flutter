import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/responsive_util.dart';
import './ocr_result_dialog.dart';
import './template_picker.dart';

class FloatingToolbar extends StatefulWidget {
  final GlobalKey repaintBoundaryKey;

  const FloatingToolbar({Key? key, required this.repaintBoundaryKey}) : super(key: key);

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar> {
  Offset _position = const Offset(0, 0); // Will be calculated in build
  bool _showPenSettings = false;

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
    final defaultBottom = isTablet ? 40.0 : 30.0;

    // Initialize position on first build
    if (_position == const Offset(0, 0)) {
      _position = Offset(screenSize.width / 2, screenSize.height - defaultBottom - 50);
    }

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Hide in focus mode
        if (provider.focusMode) {
          return const SizedBox.shrink();
        }

        // Apply button size multiplier from settings
        final sizeMultiplier = provider.settings.buttonSize;
        final buttonSize = (isTablet ? 32.0 : 28.0) * sizeMultiplier;
        final smallButtonSize = (isTablet ? 28.0 : 24.0) * sizeMultiplier;
        final iconSize = (isTablet ? 18.0 : 16.0) * sizeMultiplier;
        final smallIconSize = (isTablet ? 16.0 : 14.0) * sizeMultiplier;
        final spacing = (isTablet ? 6.0 : 5.0) * sizeMultiplier;
        final padding = (isTablet ? 10.0 : 8.0) * sizeMultiplier;
        final verticalPadding = (isTablet ? 8.0 : 6.0) * sizeMultiplier;
        final colorButtonSize = (isTablet ? 28.0 : 24.0) * sizeMultiplier;

        return Stack(
          children: [
            // Main toolbar
            Positioned(
              left: _position.dx - (screenSize.width / 2),
              top: _position.dy,
              child: GestureDetector(
                onPanStart: (details) {},
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      (_position.dx + details.delta.dx).clamp(100.0, screenSize.width - 100),
                      (_position.dy + details.delta.dy).clamp(50.0, screenSize.height - 150),
                    );
                  });
                },
                onPanEnd: (details) {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
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
                              Colors.black.withValues(alpha: 0.7),
                              Colors.black.withValues(alpha: 0.5),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 0.5),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: provider.isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                            height: isTablet ? 20 : 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0),
                                      ]
                                    : [
                                        Colors.black.withValues(alpha: 0),
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0),
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
                            height: isTablet ? 20 : 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0),
                                      ]
                                    : [
                                        Colors.black.withValues(alpha: 0),
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0),
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
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black.withValues(alpha: 0.7),
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
                            height: isTablet ? 20 : 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0),
                                      ]
                                    : [
                                        Colors.black.withValues(alpha: 0),
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0),
                                      ],
                              ),
                            ),
                          ),
                          SizedBox(width: spacing * 1.5),
                        ],

                        // Favorite pens quick access
                        if (provider.mode == DrawingMode.pen && provider.selectionRect == null) ...[
                          // Favorite pens
                          ...provider.settings.favoritePens.take(5).map((favPen) => Padding(
                                padding: EdgeInsets.only(right: spacing),
                                child: _FavoritePenButton(
                                  pen: favPen,
                                  isSelected: provider.settings.selectedFavoritePenId == favPen.id,
                                  onTap: () => provider.selectFavoritePen(favPen.id),
                                  isDarkMode: provider.isDarkMode,
                                  size: smallButtonSize,
                                ),
                              )),

                          SizedBox(width: spacing),

                          // Pen settings button
                          _PenSettingsButton(
                            currentColor: provider.currentColor,
                            currentWidth: provider.lineWidth,
                            isDarkMode: provider.isDarkMode,
                            onPressed: () {
                              setState(() {
                                _showPenSettings = !_showPenSettings;
                              });
                            },
                            size: buttonSize,
                          ),
                        ],

                        // Template picker button (show for all modes except select with rect)
                        if (provider.selectionRect == null) ...[
                          // Divider before template picker
                          Container(
                            width: 1,
                            height: isTablet ? 20 : 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: provider.isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0),
                                      ]
                                    : [
                                        Colors.black.withValues(alpha: 0),
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0),
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

            // Pen settings panel (floating next to toolbar)
            if (_showPenSettings) ...[
              Positioned(
                // Horizontal positioning: left vs right
                left: _position.dx < screenSize.width / 2
                    ? _position.dx + (screenSize.width / 2) - 70  // On left → panel on right
                    : _position.dx - (screenSize.width / 2) - (isTablet ? 260 : 220) - 16,  // On right → panel on left
                // Vertical positioning: top vs bottom
                top: _position.dy < screenSize.height / 2
                    ? _position.dy + 50  // On top → panel below
                    : _position.dy - (isTablet ? 320 : 300),  // On bottom → panel above
                child: _buildPenSettingsPanel(provider, isTablet, sizeMultiplier),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _recognizeText(BuildContext context, DrawingProvider provider) async {
    final result = await provider.recognizeSelection(widget.repaintBoundaryKey);
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
    final result = await provider.recognizeSelection(widget.repaintBoundaryKey);
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
    await provider.convertSelectionToLatex(widget.repaintBoundaryKey);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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

  Widget _buildPenSettingsPanel(DrawingProvider provider, bool isTablet, double sizeMultiplier) {
    final isDarkMode = provider.isDarkMode;
    final panelWidth = isTablet ? 260.0 : 220.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: panelWidth,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.75),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '펜 설정',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPenSettings = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Color section
              Text(
                '색상',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),

              // Color palette (compact grid)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: presetColors.map((color) {
                  final isSelected = provider.currentColor == color;
                  return GestureDetector(
                    onTap: () {
                      provider.setColor(color);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF667EEA)
                              : (isDarkMode ? Colors.white24 : Colors.black12),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Thickness section
              Text(
                '굵기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),

              // Thickness slider (compact)
              Row(
                children: [
                  Icon(
                    Icons.line_weight,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Slider(
                      value: provider.lineWidth,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      activeColor: const Color(0xFF667EEA),
                      onChanged: (value) {
                        provider.setLineWidth(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${provider.lineWidth.round()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPenSettingsPopup(BuildContext context, DrawingProvider provider) {
    final isDarkMode = provider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '펜 설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Color section
            Text(
              '색상',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Color palette
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presetColors.map((color) {
                final isSelected = provider.currentColor == color;
                return GestureDetector(
                  onTap: () {
                    provider.setColor(color);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF667EEA)
                            : (isDarkMode ? Colors.white24 : Colors.black12),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Thickness section
            Text(
              '굵기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Thickness slider
            Row(
              children: [
                Icon(
                  Icons.line_weight,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: provider.lineWidth,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (value) {
                      provider.setLineWidth(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${provider.lineWidth.round()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Favorite pen button widget
class _FavoritePenButton extends StatelessWidget {
  final dynamic pen; // FavoritePen
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;
  final double size;

  const _FavoritePenButton({
    required this.pen,
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
          color: isSelected
              ? pen.color.withValues(alpha: 0.2)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? pen.color
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: pen.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              pen.icon,
              size: size * 0.4,
              color: isSelected
                  ? pen.color
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
            if (size > 45) ...[
              const SizedBox(height: 2),
              Container(
                width: size * 0.6,
                height: 2,
                decoration: BoxDecoration(
                  color: pen.color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Pen settings button widget
class _PenSettingsButton extends StatelessWidget {
  final Color currentColor;
  final double currentWidth;
  final bool isDarkMode;
  final VoidCallback onPressed;
  final double size;

  const _PenSettingsButton({
    required this.currentColor,
    required this.currentWidth,
    required this.isDarkMode,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Thickness indicator
            Icon(
              Icons.line_weight,
              size: 18,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              '${currentWidth.round()}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
          ],
        ),
      ),
    );
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
              : (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.4),
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
              : (isDarkMode ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7)),
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
              color.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
