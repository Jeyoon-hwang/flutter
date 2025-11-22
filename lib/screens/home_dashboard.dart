import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import '../models/planner.dart';
import 'canvas_screen.dart';
import 'notes_list_screen.dart';

/// Home dashboard with planner-centric design
/// "Gong-stagram" aesthetic: minimal, clean, motivating
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final backgroundColor = provider.getBackgroundColor();

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and settings
                _buildHeader(context, provider, isDarkMode),

                // Study stats card (순공 시간, 목표 달성률)
                _buildStudyStatsCard(provider, isDarkMode),

                const SizedBox(height: AppTheme.spaceLg),

                // Today's planner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                  child: Text(
                    '오늘의 계획',
                    style: AppTheme.heading2(isDarkMode),
                  ),
                ),

                const SizedBox(height: AppTheme.spaceMd),

                // Planner items list
                Expanded(
                  child: _buildPlannerList(context, provider, isDarkMode),
                ),
              ],
            ),
          ),

          // Bottom navigation bar (minimal design)
          bottomNavigationBar: _buildBottomNav(context, isDarkMode),

          // FAB for quick note
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Create quick note and navigate to canvas
              provider.createQuickNote();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CanvasScreen()),
              );
            },
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.edit),
            label: const Text('빠른 메모'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DrawingProvider provider, bool isDarkMode) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${now.month}월 ${now.day}일 $weekday요일',
                style: AppTheme.bodySmall(isDarkMode),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 화이팅!',
                style: AppTheme.heading1(isDarkMode),
              ),
            ],
          ),
          // Settings button
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
            onPressed: () {
              // Navigate to settings
              _showThemeSelector(context, provider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStatsCard(DrawingProvider provider, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd(isDarkMode),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '오늘 순공',
              '2h 34m',
              Icons.timer_outlined,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '이번 주 목표',
              '67%',
              Icons.track_changes,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '연속 학습',
              '5일',
              Icons.local_fire_department,
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildPlannerList(BuildContext context, DrawingProvider provider, bool isDarkMode) {
    final plannerItems = provider.plannerManager.getTodayItems();

    if (plannerItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '오늘의 계획이 없습니다',
              style: AppTheme.heading3(isDarkMode),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 계획을 추가해보세요!',
              style: AppTheme.bodyMedium(isDarkMode).copyWith(
                color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      itemCount: plannerItems.length,
      itemBuilder: (context, index) {
        final item = plannerItems[index];
        return _buildPlannerCard(context, provider, item, isDarkMode);
      },
    );
  }

  Widget _buildPlannerCard(
    BuildContext context,
    DrawingProvider provider,
    PlannerItem item,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: AppTheme.containerDecoration(isDarkMode),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to linked note if exists
            if (item.linkedNoteId != null) {
              provider.switchToNote(item.linkedNoteId!);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CanvasScreen()),
              );
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    provider.plannerManager.toggleItemCompletion(item.id);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.isCompleted ? AppTheme.success : AppTheme.primary,
                        width: 2,
                      ),
                      color: item.isCompleted ? AppTheme.success : Colors.transparent,
                    ),
                    child: item.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),

                const SizedBox(width: AppTheme.spaceMd),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTheme.bodyLarge(isDarkMode).copyWith(
                          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                          color: item.isCompleted
                              ? (isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)
                              : null,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: AppTheme.bodySmall(isDarkMode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Subject tag
                if (item.subject != null)
                  AppWidgets.badge(
                    text: item.subject!,
                    color: _getSubjectColor(item.subject!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            // Navigate to notes list
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotesListScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '오늘의 계획',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: '노트 탐색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            activeIcon: Icon(Icons.error),
            label: '오답 노트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    // Map subjects to colors
    final subjectColors = {
      '수학': const Color(0xFF007AFF),
      '영어': const Color(0xFF34C759),
      '국어': const Color(0xFFFF3B30),
      '과학': const Color(0xFF5E5CE6),
      '사회': const Color(0xFFFF9500),
    };

    return subjectColors[subject] ?? AppTheme.primary;
  }

  void _showThemeSelector(BuildContext context, DrawingProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('테마 선택', style: AppTheme.heading2(provider.isDarkMode)),
            const SizedBox(height: AppTheme.spaceLg),
            Wrap(
              spacing: AppTheme.spaceMd,
              runSpacing: AppTheme.spaceMd,
              children: [
                _buildThemeOption(context, provider, AppThemeType.ivory, '아이보리', const Color(0xFFFFFAF0)),
                _buildThemeOption(context, provider, AppThemeType.pastelPink, '파스텔 핑크', const Color(0xFFFFF0F5)),
                _buildThemeOption(context, provider, AppThemeType.pastelBlue, '파스텔 블루', const Color(0xFFF0F8FF)),
                _buildThemeOption(context, provider, AppThemeType.pastelGreen, '파스텔 그린', const Color(0xFFF0FFF0)),
                _buildThemeOption(context, provider, AppThemeType.minimalist, '미니멀', Colors.white),
                _buildThemeOption(context, provider, AppThemeType.darkMode, '다크 모드', const Color(0xFF1E1E1E)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    DrawingProvider provider,
    AppThemeType themeType,
    String name,
    Color color,
  ) {
    final isSelected = provider.settings.themeType == themeType;

    return GestureDetector(
      onTap: () {
        provider.setThemeType(themeType);
        Navigator.pop(context);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: themeType == AppThemeType.darkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
