import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/advanced_pen.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import '../utils/device_helper.dart';
import 'pen_customizer.dart';

/// Advanced pen bar with customization support
/// "Gong-stagram" aesthetic: minimal, beautiful, functional
/// Responsive design for TV and large screens
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
        final scaleFactor = DeviceHelper.getScaleFactor(context);
        final isLargeScreen = DeviceHelper.isLargeScreen(context);

        return AnimatedContainer(
          duration: provider.performanceSettings.enableAnimations
              ? AppTheme.animationNormal
              : Duration.zero,
          curve: AppTheme.animationCurve,
          padding: EdgeInsets.symmetric(
            horizontal: provider.focusMode ? 0 : AppTheme.spaceMd * scaleFactor,
            vertical: AppTheme.spaceSm * scaleFactor,
          ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppTheme.darkSurface.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg * scaleFactor),
            boxShadow: provider.performanceSettings.enableShadows
                ? AppTheme.shadowMd(isDarkMode)
                : null,
            border: Border.all(
              color: isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.5 * scaleFactor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Advanced pens - show more on large screens
              ...advancedPens.take(isLargeScreen ? 8 : 5).map((pen) => _buildPenButton(
                    context,
                    provider,
                    pen,
                    isSelected: pen.id == _selectedPenId,
                    isDarkMode: isDarkMode,
                    scaleFactor: scaleFactor,
                  )),

              // Divider
              Container(
                width: 1.5 * scaleFactor,
                height: 32 * scaleFactor,
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spaceSm * scaleFactor),
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
                scaleFactor: scaleFactor,
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
                scaleFactor: scaleFactor,
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
                scaleFactor: scaleFactor,
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
                scaleFactor: scaleFactor,
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
    double scaleFactor = 1.0,
  }) {
    final touchTargetSize = DeviceHelper.getTouchTargetSize(context);

    return Tooltip(
      message: '${pen.name}\n${pen.getTypeName()}',
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPenId = pen.id);
          provider.selectAdvancedPen(pen.id);
          HapticFeedback.lightImpact();
          if (provider.performanceSettings.enableAnimations) {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
          }
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showPenCustomizer(context, provider, pen);
        },
        child: provider.performanceSettings.enableAnimations
            ? ScaleTransition(
                scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                child: _buildPenButtonContent(pen, isSelected, scaleFactor, touchTargetSize),
              )
            : _buildPenButtonContent(pen, isSelected, scaleFactor, touchTargetSize),
      ),
    );
  }

  Widget _buildPenButtonContent(AdvancedPen pen, bool isSelected, double scaleFactor, double touchTargetSize) {
    return AnimatedContainer(
      duration: AppTheme.animationFast,
      curve: AppTheme.animationCurve,
      margin: EdgeInsets.symmetric(horizontal: 4 * scaleFactor),
      padding: EdgeInsets.all(8 * scaleFactor),
      constraints: BoxConstraints(minWidth: touchTargetSize, minHeight: touchTargetSize),
      decoration: BoxDecoration(
        color: isSelected
            ? pen.color.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm * scaleFactor),
        border: isSelected
            ? Border.all(color: pen.color, width: 2 * scaleFactor)
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
                  color: pen.color.withValues(alpha: 0.5),
                  size: 28 * scaleFactor,
                ),
              Icon(
                pen.getIcon(),
                color: pen.color,
                size: 24 * scaleFactor,
              ),
            ],
          ),
          SizedBox(height: 2 * scaleFactor),
          // Width indicator with gradient for rainbow
          Container(
            width: pen.width.clamp(2.0, 16.0) * scaleFactor,
            height: 3 * scaleFactor,
            decoration: BoxDecoration(
              gradient: pen.gradientColors != null
                  ? LinearGradient(colors: pen.gradientColors!)
                  : null,
              color: pen.gradientColors == null
                  ? pen.color.withValues(alpha: pen.opacity)
                  : null,
              borderRadius: BorderRadius.circular(2 * scaleFactor),
            ),
          ),
        ],
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
    double scaleFactor = 1.0,
  }) {
    final touchTargetSize = DeviceHelper.getTouchTargetSize(context);

    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: AppTheme.animationFast,
          curve: AppTheme.animationCurve,
          margin: EdgeInsets.symmetric(horizontal: 4 * scaleFactor),
          padding: EdgeInsets.all(8 * scaleFactor),
          constraints: BoxConstraints(minWidth: touchTargetSize, minHeight: touchTargetSize),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm * scaleFactor),
            border: isSelected
                ? Border.all(color: AppTheme.primary, width: 2 * scaleFactor)
                : null,
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? (isDarkMode ? AppTheme.darkText : AppTheme.lightText)
                : (isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary),
            size: 24 * scaleFactor,
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
              padding: EdgeInsets.all(AppTheme.spaceLg * DeviceHelper.getScaleFactor(context)),
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
                            minimumSize: Size.fromHeight(DeviceHelper.getTouchTargetSize(context)),
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
                          style: AppTheme.primaryButton.copyWith(
                            minimumSize: MaterialStateProperty.all(
                              Size.fromHeight(DeviceHelper.getTouchTargetSize(context)),
                            ),
                          ),
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
    final scaleFactor = DeviceHelper.getScaleFactor(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppTheme.spaceLg * scaleFactor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '펜 라이브러리',
              style: AppTheme.heading2(provider.isDarkMode),
            ),
            SizedBox(height: AppTheme.spaceMd * scaleFactor),
            Text(
              '추가할 펜 종류를 선택하세요',
              style: AppTheme.bodyMedium(provider.isDarkMode),
            ),
            SizedBox(height: AppTheme.spaceLg * scaleFactor),
            Wrap(
              spacing: AppTheme.spaceMd * scaleFactor,
              runSpacing: AppTheme.spaceMd * scaleFactor,
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
                    width: 100 * scaleFactor,
                    padding: EdgeInsets.all(AppTheme.spaceMd * scaleFactor),
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? AppTheme.darkSurface
                          : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd * scaleFactor),
                      border: Border.all(
                        color: provider.isDarkMode
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(testPen.getIcon(), size: 32 * scaleFactor),
                        SizedBox(height: 8 * scaleFactor),
                        Text(
                          testPen.getTypeName(),
                          style: TextStyle(fontSize: 12 * DeviceHelper.getFontScale(context)),
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
