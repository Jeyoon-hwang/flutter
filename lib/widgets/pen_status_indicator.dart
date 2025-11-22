import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/drawing_stroke.dart';

/// Displays current input device status (S-Pen, Apple Pencil, Touch, etc.)
class PenStatusIndicator extends StatelessWidget {
  const PenStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Only show if stylus has been detected
        if (!provider.isStylusDetected && provider.currentInputDevice == InputDeviceType.touch) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(provider.currentInputDevice),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(provider.currentInputDevice),
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                provider.inputDeviceName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(InputDeviceType deviceType) {
    switch (deviceType) {
      case InputDeviceType.stylus:
        return const Color(0xFF34C759); // Green for stylus
      case InputDeviceType.touch:
        return const Color(0xFF667EEA); // Blue for touch
      case InputDeviceType.mouse:
        return const Color(0xFFFF9500); // Orange for mouse
      case InputDeviceType.unknown:
        return const Color(0xFF8E8E93); // Gray for unknown
    }
  }

  IconData _getIcon(InputDeviceType deviceType) {
    switch (deviceType) {
      case InputDeviceType.stylus:
        return Icons.edit;
      case InputDeviceType.touch:
        return Icons.touch_app;
      case InputDeviceType.mouse:
        return Icons.mouse;
      case InputDeviceType.unknown:
        return Icons.help_outline;
    }
  }
}

/// Extended version with pressure display
class PenStatusDetailedIndicator extends StatelessWidget {
  final double? currentPressure;

  const PenStatusDetailedIndicator({
    Key? key,
    this.currentPressure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isStylusActive = provider.currentInputDevice == InputDeviceType.stylus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isStylusActive
                ? const Color(0xFF34C759).withValues(alpha: 0.9)
                : Colors.grey.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Device icon and name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isStylusActive ? Icons.edit : Icons.touch_app,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.inputDeviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Pressure indicator (only for stylus)
              if (isStylusActive && currentPressure != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '압력',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: currentPressure!.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(currentPressure! * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
