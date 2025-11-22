import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_pen.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';

/// Favorite pen bar for quick pen switching
/// Inspired by GoodNotes' minimal toolbar design
class FavoritePenBar extends StatelessWidget {
  const FavoritePenBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final favoritePens = provider.settings.favoritePens;
        final selectedPenId = provider.settings.selectedFavoritePenId;
        final isDarkMode = provider.isDarkMode;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
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
              // Favorite pens
              ...favoritePens.map((pen) => _buildPenButton(
                    context,
                    pen,
                    isSelected: pen.id == selectedPenId,
                    onTap: () => provider.selectFavoritePen(pen.id),
                    isDarkMode: isDarkMode,
                  )),

              // Divider
              Container(
                width: 1.5,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
                color: isDarkMode
                    ? AppTheme.darkBorder
                    : AppTheme.lightBorder,
              ),

              // Eraser
              _buildToolButton(
                context,
                icon: Icons.auto_fix_high,
                isSelected: provider.isEraser,
                onTap: () => provider.setMode(DrawingMode.eraser),
                isDarkMode: isDarkMode,
                tooltip: '지우개',
              ),

              // Undo
              _buildToolButton(
                context,
                icon: Icons.undo,
                isSelected: false,
                onTap: provider.canUndo ? () => provider.undo() : null,
                isDarkMode: isDarkMode,
                tooltip: '실행취소',
                isEnabled: provider.canUndo,
              ),

              // Redo
              _buildToolButton(
                context,
                icon: Icons.redo,
                isSelected: false,
                onTap: provider.canRedo ? () => provider.redo() : null,
                isDarkMode: isDarkMode,
                tooltip: '다시실행',
                isEnabled: provider.canRedo,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPenButton(
    BuildContext context,
    FavoritePen pen, {
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Tooltip(
      message: pen.name,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () {
          // Long press to customize this pen
          _showPenCustomizationDialog(context, pen);
        },
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
              Icon(
                pen.icon,
                color: pen.color,
                size: 24,
              ),
              const SizedBox(height: 2),
              // Width indicator
              Container(
                width: pen.width.clamp(2.0, 16.0),
                height: 3,
                decoration: BoxDecoration(
                  color: pen.color.withOpacity(pen.opacity),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
    required bool isDarkMode,
    required String tooltip,
    bool isEnabled = true,
  }) {
    return Tooltip(
      message: tooltip,
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
                : (isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showPenCustomizationDialog(BuildContext context, FavoritePen pen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pen.name} 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('펜 커스터마이징 기능은 곧 추가됩니다.'),
            const SizedBox(height: 16),
            Text('현재 설정:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('굵기: ${pen.width.toStringAsFixed(1)}mm'),
            Text('투명도: ${(pen.opacity * 100).toStringAsFixed(0)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
