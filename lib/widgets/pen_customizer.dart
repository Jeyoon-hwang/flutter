import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/advanced_pen.dart';
import '../utils/app_theme.dart';

/// Pen customizer widget for advanced pen configuration
/// "Gong-stagram" aesthetic: beautiful, intuitive pen customization
class PenCustomizer extends StatefulWidget {
  final AdvancedPen initialPen;
  final Function(AdvancedPen) onPenChanged;
  final bool isDarkMode;

  const PenCustomizer({
    Key? key,
    required this.initialPen,
    required this.onPenChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<PenCustomizer> createState() => _PenCustomizerState();
}

class _PenCustomizerState extends State<PenCustomizer> {
  late AdvancedPen _currentPen;

  @override
  void initState() {
    super.initState();
    _currentPen = widget.initialPen;
  }

  void _updatePen(AdvancedPen pen) {
    setState(() => _currentPen = pen);
    widget.onPenChanged(pen);
    HapticFeedback.lightImpact(); // 햅틱 피드백
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd(widget.isDarkMode),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with pen preview
          _buildHeader(),

          const SizedBox(height: AppTheme.spaceLg),

          // Pen type selector
          _buildPenTypeSelector(),

          const SizedBox(height: AppTheme.spaceLg),

          // Color picker
          _buildColorPicker(),

          const SizedBox(height: AppTheme.spaceLg),

          // Width slider
          _buildSlider(
            label: '굵기',
            value: _currentPen.width,
            min: 1.0,
            max: 30.0,
            divisions: 29,
            icon: Icons.line_weight,
            onChanged: (value) {
              _updatePen(_currentPen.copyWith(width: value));
            },
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // Opacity slider
          _buildSlider(
            label: '투명도',
            value: _currentPen.opacity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            icon: Icons.opacity,
            onChanged: (value) {
              _updatePen(_currentPen.copyWith(opacity: value));
            },
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Advanced settings (collapsible)
          _buildAdvancedSettings(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Pen icon
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _currentPen.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            _currentPen.getIcon(),
            color: _currentPen.color,
            size: 28,
          ),
        ),

        const SizedBox(width: AppTheme.spaceMd),

        // Pen info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentPen.name,
                style: AppTheme.heading3(widget.isDarkMode),
              ),
              const SizedBox(height: 4),
              Text(
                _currentPen.getTypeName(),
                style: AppTheme.bodySmall(widget.isDarkMode),
              ),
            ],
          ),
        ),

        // Live preview
        CustomPaint(
          size: const Size(80, 40),
          painter: _PenPreviewPainter(_currentPen),
        ),
      ],
    );
  }

  Widget _buildPenTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '펜 종류',
          style: AppTheme.bodyLarge(widget.isDarkMode).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Wrap(
          spacing: AppTheme.spaceSm,
          runSpacing: AppTheme.spaceSm,
          children: PenType.values.map((type) {
            final isSelected = _currentPen.type == type;
            final testPen = AdvancedPen.fromType(
              id: 'test',
              name: '',
              type: type,
              color: _currentPen.color,
              width: _currentPen.width,
            );

            return GestureDetector(
              onTap: () {
                _updatePen(testPen.copyWith(
                  id: _currentPen.id,
                  name: _currentPen.name,
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.2)
                      : (widget.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      testPen.getIcon(),
                      size: 20,
                      color: isSelected
                          ? AppTheme.primary
                          : (widget.isDarkMode
                              ? AppTheme.darkText
                              : AppTheme.lightText),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      testPen.getTypeName(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primary
                            : (widget.isDarkMode
                                ? AppTheme.darkText
                                : AppTheme.lightText),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '색상',
          style: AppTheme.bodyLarge(widget.isDarkMode).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            // Current color
            GestureDetector(
              onTap: () => _showFullColorPicker(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _currentPen.color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.lightBorder,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.colorize, color: Colors.white),
              ),
            ),

            const SizedBox(width: AppTheme.spaceMd),

            // Quick color presets
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.black,
                  const Color(0xFF007AFF),
                  const Color(0xFFFF3B30),
                  const Color(0xFF34C759),
                  const Color(0xFFFF9500),
                  const Color(0xFF5E5CE6),
                  const Color(0xFFFF6B9D),
                  const Color(0xFFFFCC00),
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      _updatePen(_currentPen.copyWith(color: color));
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _currentPen.color == color
                              ? AppTheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required IconData icon,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: widget.isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium(widget.isDarkMode).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: AppTheme.bodyMedium(widget.isDarkMode).copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return ExpansionTile(
      title: Text(
        '고급 설정',
        style: AppTheme.bodyLarge(widget.isDarkMode).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        // Pressure sensitivity
        _buildSlider(
          label: '압력 감도',
          value: _currentPen.pressureSensitivity,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          icon: Icons.touchpad,
          onChanged: (value) {
            _updatePen(_currentPen.copyWith(pressureSensitivity: value));
          },
        ),

        const SizedBox(height: AppTheme.spaceSm),

        // Smoothing
        _buildSlider(
          label: '스무딩',
          value: _currentPen.smoothing,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          icon: Icons.waves,
          onChanged: (value) {
            _updatePen(_currentPen.copyWith(smoothing: value));
          },
        ),

        const SizedBox(height: AppTheme.spaceSm),

        // Tapering
        _buildSlider(
          label: '테이퍼링 (끝 가늘게)',
          value: _currentPen.tapering,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          icon: Icons.arrow_right_alt,
          onChanged: (value) {
            _updatePen(_currentPen.copyWith(tapering: value));
          },
        ),

        const SizedBox(height: AppTheme.spaceMd),

        // Special effects toggles
        SwitchListTile(
          title: const Text('빛나는 효과 (네온)'),
          value: _currentPen.enableGlow,
          onChanged: (value) {
            _updatePen(_currentPen.copyWith(enableGlow: value));
          },
        ),

        SwitchListTile(
          title: const Text('그림자'),
          value: _currentPen.enableShadow,
          onChanged: (value) {
            _updatePen(_currentPen.copyWith(enableShadow: value));
          },
        ),
      ],
    );
  }

  void _showFullColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentPen.color,
            onColorChanged: (color) {
              _updatePen(_currentPen.copyWith(color: color));
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for pen preview
class _PenPreviewPainter extends CustomPainter {
  final AdvancedPen pen;

  _PenPreviewPainter(this.pen);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pen.color.withOpacity(pen.opacity)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = pen.width
      ..style = PaintingStyle.stroke;

    // Draw a sample stroke
    final path = Path();
    path.moveTo(10, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 - 10,
      size.width - 10,
      size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PenPreviewPainter oldDelegate) {
    return oldDelegate.pen != pen;
  }
}
