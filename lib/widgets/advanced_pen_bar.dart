import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/advanced_pen.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import 'pen_customizer.dart';

/// Advanced pen bar with customization support
/// "Gong-stagram" aesthetic: minimal, beautiful, functional
class AdvancedPenBar extends StatefulWidget {
  const AdvancedPenBar({Key? key}) : super(key: key);

  @override
  State<AdvancedPenBar> createState() => _AdvancedPenBarState();
}

class _AdvancedPenBarState extends State<AdvancedPenBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _selectedPenId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final advancedPens = provider.advancedPens;
        final isDarkMode = provider.isDarkMode;

        return AnimatedContainer(
          duration: AppTheme.animationNormal,
          curve: AppTheme.animationCurve,
          padding: EdgeInsets.symmetric(
            horizontal: provider.focusMode ? 0 : AppTheme.spaceMd,
            vertical: AppTheme.spaceSm,
          ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppTheme.darkSurface.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowMd(isDarkMode),
            border: Border.all(
              color: isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Advanced pens
              ...advancedPens.take(5).map((pen) => _buildPenButton(
                    context,
                    provider,
                    pen,
                    isSelected: pen.id == _selectedPenId,
                    isDarkMode: isDarkMode,
                  )),

              // Divider
              Container(
                width: 1.5,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
                color: isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),

              // Tools
              _buildToolButton(
                context,
                provider,
                icon: Icons.auto_fix_high,
                label: '지우개',
                isSelected: provider.isEraser,
                onTap: () {
                  HapticFeedback.selectionClick();
                  provider.setMode(DrawingMode.eraser);
                },
                isDarkMode: isDarkMode,
              ),

              _buildToolButton(
                context,
                provider,
                icon: Icons.undo,
                label: 'Undo',
                isSelected: false,
                onTap: provider.canUndo
                    ? () {
                        HapticFeedback.mediumImpact();
                        provider.undo();
                      }
                    : null,
                isDarkMode: isDarkMode,
                isEnabled: provider.canUndo,
              ),

              _buildToolButton(
                context,
                provider,
                icon: Icons.redo,
                label: 'Redo',
                isSelected: false,
                onTap: provider.canRedo
                    ? () {
                        HapticFeedback.mediumImpact();
                        provider.redo();
                      }
                    : null,
                isDarkMode: isDarkMode,
                isEnabled: provider.canRedo,
              ),

              // Add pen button
              _buildToolButton(
                context,
                provider,
                icon: Icons.add_circle_outline,
                label: '펜 추가',
                isSelected: false,
                onTap: () => _showPenLibrary(context, provider),
                isDarkMode: isDarkMode,
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
    AdvancedPen pen, {
    required bool isSelected,
    required bool isDarkMode,
  }) {
    return Tooltip(
      message: '${pen.name}\n${pen.getTypeName()}',
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPenId = pen.id);
          provider.selectAdvancedPen(pen.id);
          HapticFeedback.lightImpact();
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showPenCustomizer(context, provider, pen);
        },
        child: ScaleTransition(
          scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: AnimatedContainer(
            duration: AppTheme.animationFast,
            curve: AppTheme.animationCurve,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? pen.color.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: isSelected
                  ? Border.all(color: pen.color, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pen icon with glow effect for neon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (pen.enableGlow)
                      Icon(
                        pen.getIcon(),
                        color: pen.color.withOpacity(0.5),
                        size: 28,
                      ),
                    Icon(
                      pen.getIcon(),
                      color: pen.color,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Width indicator with gradient for rainbow
                Container(
                  width: pen.width.clamp(2.0, 16.0),
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: pen.gradientColors != null
                        ? LinearGradient(colors: pen.gradientColors!)
                        : null,
                    color: pen.gradientColors == null
                        ? pen.color.withOpacity(pen.opacity)
                        : null,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    DrawingProvider provider, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    required bool isDarkMode,
    bool isEnabled = true,
  }) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: AppTheme.animationFast,
          curve: AppTheme.animationCurve,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: isSelected
                ? Border.all(color: AppTheme.primary, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? (isDarkMode ? AppTheme.darkText : AppTheme.lightText)
                : (isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary),
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showPenCustomizer(
    BuildContext context,
    DrawingProvider provider,
    AdvancedPen pen,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: provider.isDarkMode
                ? AppTheme.darkBackground
                : AppTheme.lightBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Text(
                    '펜 커스터마이징',
                    style: AppTheme.heading2(provider.isDarkMode),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Pen customizer
                  PenCustomizer(
                    initialPen: pen,
                    onPenChanged: (updatedPen) {
                      provider.updateAdvancedPen(pen.id, updatedPen);
                    },
                    isDarkMode: provider.isDarkMode,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.deleteAdvancedPen(pen.id);
                            Navigator.pop(context);
                            HapticFeedback.heavyImpact();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('삭제'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            HapticFeedback.selectionClick();
                          },
                          style: AppTheme.primaryButton,
                          child: const Text('완료'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPenLibrary(BuildContext context, DrawingProvider provider) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '펜 라이브러리',
              style: AppTheme.heading2(provider.isDarkMode),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              '추가할 펜 종류를 선택하세요',
              style: AppTheme.bodyMedium(provider.isDarkMode),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Wrap(
              spacing: AppTheme.spaceMd,
              runSpacing: AppTheme.spaceMd,
              children: PenType.values.map((type) {
                final testPen = AdvancedPen.fromType(
                  id: 'pen_${DateTime.now().millisecondsSinceEpoch}',
                  name: '나의 ${_getPenTypeName(type)}',
                  type: type,
                  color: Colors.black,
                );

                return GestureDetector(
                  onTap: () {
                    provider.addAdvancedPen(testPen);
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? AppTheme.darkSurface
                          : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: provider.isDarkMode
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(testPen.getIcon(), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          testPen.getTypeName(),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getPenTypeName(PenType type) {
    final testPen = AdvancedPen.fromType(
      id: 'test',
      name: '',
      type: type,
      color: Colors.black,
    );
    return testPen.getTypeName();
  }
}
