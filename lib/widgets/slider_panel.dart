import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';

class SliderPanel extends StatelessWidget {
  const SliderPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Hide in focus mode
        if (provider.focusMode) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 20,
          top: MediaQuery.of(context).size.height * 0.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
              color: provider.isDarkMode
                  ? Colors.black.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _SliderGroup(
                  icon: '📏',
                  value: provider.lineWidth,
                  min: 1,
                  max: 30,
                  onChanged: provider.setLineWidth,
                  displayValue: provider.lineWidth.toInt().toString(),
                  isDarkMode: provider.isDarkMode,
                ),
                const SizedBox(height: 25),
                _SliderGroup(
                  icon: '💧',
                  value: provider.opacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: provider.setOpacity,
                  displayValue: provider.opacity.toStringAsFixed(1),
                  isDarkMode: provider.isDarkMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliderGroup extends StatelessWidget {
  final String icon;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String displayValue;
  final bool isDarkMode;

  const _SliderGroup({
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.displayValue,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF764BA2),
                inactiveTrackColor: const Color(0xFF667EEA),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF667EEA).withValues(alpha: 0.3),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? const Color(0xFF8B9CFF)
                  : const Color(0xFF667EEA),
            ),
          ),
        ),
      ],
    );
  }
}
