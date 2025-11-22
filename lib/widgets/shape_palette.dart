import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../services/shape_drawing_service.dart';

class ShapePalette extends StatefulWidget {
  const ShapePalette({Key? key}) : super(key: key);

  @override
  State<ShapePalette> createState() => _ShapePaletteState();
}

class _ShapePaletteState extends State<ShapePalette> {
  bool _show3D = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Hide in focus mode
        if (provider.focusMode) {
          return const SizedBox.shrink();
        }

        if (!provider.isShapeMode) return const SizedBox.shrink();

        return Positioned(
          left: 20,
          top: 80,
          child: Container(
            width: 280,
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: provider.isDarkMode
                  ? Colors.black.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
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
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '도형 선택',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _TabButton(
                            label: '2D',
                            isActive: !_show3D,
                            onTap: () => setState(() => _show3D = false),
                          ),
                          const SizedBox(width: 8),
                          _TabButton(
                            label: '3D',
                            isActive: _show3D,
                            onTap: () => setState(() => _show3D = true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Shape grid
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        if (!_show3D) ..._build2DShapes(provider),
                        if (_show3D) ..._build3DShapes(provider),

                        // Triangle angle controls (only for triangles in 2D mode)
                        if (!_show3D && provider.selectedShape2D == ShapeType2D.triangle) ...[
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),
                          _AngleControl(
                            label: '각도 1',
                            value: provider.triangleAngle1,
                            onChanged: (value) {
                              provider.setTriangleAngles(
                                value,
                                provider.triangleAngle2,
                                provider.triangleAngle3,
                              );
                            },
                            isDarkMode: provider.isDarkMode,
                          ),
                          const SizedBox(height: 8),
                          _AngleControl(
                            label: '각도 2',
                            value: provider.triangleAngle2,
                            onChanged: (value) {
                              provider.setTriangleAngles(
                                provider.triangleAngle1,
                                value,
                                provider.triangleAngle3,
                              );
                            },
                            isDarkMode: provider.isDarkMode,
                          ),
                          const SizedBox(height: 8),
                          _AngleControl(
                            label: '각도 3',
                            value: provider.triangleAngle3,
                            onChanged: (value) {
                              provider.setTriangleAngles(
                                provider.triangleAngle1,
                                provider.triangleAngle2,
                                value,
                              );
                            },
                            isDarkMode: provider.isDarkMode,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _build2DShapes(DrawingProvider provider) {
    final shapes = [
      // Basic shapes
      ShapeInfo(ShapeType2D.circle, '●', '원'),
      ShapeInfo(ShapeType2D.ellipse, '◯', '타원'),
      ShapeInfo(ShapeType2D.square, '■', '정사각형'),
      ShapeInfo(ShapeType2D.rectangle, '▭', '직사각형'),
      ShapeInfo(ShapeType2D.triangle, '▲', '삼각형'),
      ShapeInfo(ShapeType2D.line, '─', '선'),
      ShapeInfo(ShapeType2D.arrow, '→', '화살표'),

      // Quadrilaterals
      ShapeInfo(ShapeType2D.parallelogram, '▱', '평행사변형'),
      ShapeInfo(ShapeType2D.rhombus, '◇', '마름모'),
      ShapeInfo(ShapeType2D.trapezoid, '⏢', '사다리꼴'),

      // Regular polygons
      ShapeInfo(ShapeType2D.pentagon, '⬟', '오각형'),
      ShapeInfo(ShapeType2D.hexagon, '⬡', '육각형'),
      ShapeInfo(ShapeType2D.heptagon, '⭘', '칠각형'),
      ShapeInfo(ShapeType2D.octagon, '⯃', '팔각형'),
      ShapeInfo(ShapeType2D.nonagon, '◯', '구각형'),
      ShapeInfo(ShapeType2D.decagon, '◯', '십각형'),

      // Circle-related
      ShapeInfo(ShapeType2D.sector, '◔', '부채꼴'),
      ShapeInfo(ShapeType2D.arc, '◠', '호'),
      ShapeInfo(ShapeType2D.chord, '⌒', '현'),
      ShapeInfo(ShapeType2D.tangent, '⊥', '접선'),

      // Others
      ShapeInfo(ShapeType2D.star, '★', '별'),
      ShapeInfo(ShapeType2D.rightAngle, '∟', '직각'),
    ];

    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemCount: shapes.length,
        itemBuilder: (context, index) {
          final shape = shapes[index];
          final isSelected = provider.selectedShape2D == shape.type && provider.selectedShape3D == null;
          return _ShapeButton(
            icon: shape.icon,
            label: shape.label,
            isSelected: isSelected,
            onTap: () => provider.setShape2D(shape.type as ShapeType2D),
            isDarkMode: provider.isDarkMode,
          );
        },
      ),
    ];
  }

  List<Widget> _build3DShapes(DrawingProvider provider) {
    final shapes = [
      ShapeInfo3D(ShapeType3D.cube, '◻', '큐브'),
      ShapeInfo3D(ShapeType3D.cylinder, '◯', '실린더'),
      ShapeInfo3D(ShapeType3D.pyramid, '△', '피라미드'),
      ShapeInfo3D(ShapeType3D.sphere, '◉', '구'),
      ShapeInfo3D(ShapeType3D.cone, '◮', '원뿔'),
      ShapeInfo3D(ShapeType3D.prism, '▲', '프리즘'),
    ];

    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: shapes.length,
        itemBuilder: (context, index) {
          final shape = shapes[index];
          final isSelected = provider.selectedShape3D == shape.type;
          return _ShapeButton(
            icon: shape.icon,
            label: shape.label,
            isSelected: isSelected,
            onTap: () => provider.setShape3D(shape.type),
            isDarkMode: provider.isDarkMode,
          );
        },
      ),
    ];
  }
}

class ShapeInfo {
  final dynamic type;
  final String icon;
  final String label;

  ShapeInfo(this.type, this.icon, this.label);
}

class ShapeInfo3D {
  final ShapeType3D type;
  final String icon;
  final String label;

  ShapeInfo3D(this.type, this.icon, this.label);
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ShapeButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _ShapeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected
              ? null
              : (isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 32,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AngleControl extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isDarkMode;

  const _AngleControl({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(0)}°',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF667EEA),
            inactiveTrackColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            thumbColor: const Color(0xFF667EEA),
            overlayColor: const Color(0xFF667EEA).withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 10,
            max: 170,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
