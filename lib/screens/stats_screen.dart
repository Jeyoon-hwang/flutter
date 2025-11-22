import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import '../models/study_stats.dart';
import 'dart:math' as math;

/// Statistics screen with beautiful data visualization
/// "Gong-stagram" aesthetic: clean charts, motivating metrics
class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final backgroundColor = provider.getBackgroundColor();

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '학습 통계',
              style: AppTheme.heading2(isDarkMode),
            ),
            iconTheme: IconThemeData(
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly overview card
                _buildWeeklyOverviewCard(provider, isDarkMode),

                const SizedBox(height: AppTheme.spaceLg),

                // Daily study time chart
                Text(
                  '이번 주 학습 시간',
                  style: AppTheme.heading3(isDarkMode),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildWeeklyBarChart(provider, isDarkMode),

                const SizedBox(height: AppTheme.spaceLg),

                // Subject breakdown
                Text(
                  '과목별 학습 시간',
                  style: AppTheme.heading3(isDarkMode),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildSubjectBreakdown(provider, isDarkMode),

                const SizedBox(height: AppTheme.spaceLg),

                // Achievement badges
                Text(
                  '달성 뱃지',
                  style: AppTheme.heading3(isDarkMode),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildAchievementBadges(provider, isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyOverviewCard(DrawingProvider provider, bool isDarkMode) {
    final statsManager = StudyStatsManager();
    final todayStats = statsManager.getTodayStats();
    final weeklyGoal = statsManager.getWeeklyGoalAchievement();
    final streak = statsManager.getStudyStreak();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd(isDarkMode),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                '오늘 순공',
                todayStats.formattedDuration,
                Icons.timer_outlined,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatColumn(
                '이번 주 달성',
                '${weeklyGoal.toStringAsFixed(0)}%',
                Icons.track_changes,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatColumn(
                '연속 학습',
                '$streak일',
                Icons.local_fire_department,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          // Weekly goal progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '주간 목표',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${weeklyGoal.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (weeklyGoal / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarChart(DrawingProvider provider, bool isDarkMode) {
    final statsManager = StudyStatsManager();
    final weekStats = statsManager.getWeekStats();

    // Sample data (replace with real data)
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final sampleData = [2.5, 3.2, 1.8, 4.1, 2.9, 3.5, 2.0]; // hours

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: AppTheme.containerDecoration(isDarkMode),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final value = sampleData[index];
          final maxValue = sampleData.reduce(math.max);
          final heightRatio = value / maxValue;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label
                  Text(
                    '${value.toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bar
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 120 * heightRatio,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primary.withOpacity(0.7),
                              AppTheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Weekday label
                  Text(
                    weekdays[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubjectBreakdown(DrawingProvider provider, bool isDarkMode) {
    // Sample data
    final subjects = {
      '수학': 8.5,
      '영어': 6.2,
      '국어': 5.0,
      '과학': 4.3,
      '사회': 2.0,
    };

    final total = subjects.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: AppTheme.containerDecoration(isDarkMode),
      child: Column(
        children: subjects.entries.map((entry) {
          final percentage = (entry.value / total) * 100;
          final color = _getSubjectColor(entry.key);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: AppTheme.bodyMedium(isDarkMode),
                        ),
                      ],
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(1)}h (${percentage.toStringAsFixed(0)}%)',
                      style: AppTheme.bodyMedium(isDarkMode).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementBadges(DrawingProvider provider, bool isDarkMode) {
    final badges = [
      _Badge(
        icon: Icons.local_fire_department,
        title: '7일 연속',
        description: '1주일 연속 학습',
        color: AppTheme.error,
        isUnlocked: true,
      ),
      _Badge(
        icon: Icons.timer,
        title: '100시간 돌파',
        description: '총 100시간 학습',
        color: AppTheme.primary,
        isUnlocked: true,
      ),
      _Badge(
        icon: Icons.stars,
        title: '완벽한 주',
        description: '주간 목표 100% 달성',
        color: AppTheme.warning,
        isUnlocked: false,
      ),
      _Badge(
        icon: Icons.emoji_events,
        title: '문제 정복자',
        description: '1000문제 풀이',
        color: AppTheme.success,
        isUnlocked: false,
      ),
    ];

    return Wrap(
      spacing: AppTheme.spaceMd,
      runSpacing: AppTheme.spaceMd,
      children: badges.map((badge) {
        return _buildBadgeCard(badge, isDarkMode);
      }).toList(),
    );
  }

  Widget _buildBadgeCard(_Badge badge, bool isDarkMode) {
    final isUnlocked = badge.isUnlocked;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: isUnlocked
            ? badge.color.withOpacity(0.1)
            : (isDarkMode
                ? AppTheme.darkSurface
                : AppTheme.lightSurface),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isUnlocked
              ? badge.color
              : (isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            badge.icon,
            size: 40,
            color: isUnlocked
                ? badge.color
                : (isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked
                  ? badge.color
                  : (isDarkMode
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isUnlocked)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '잠김',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final subjectColors = {
      '수학': const Color(0xFF007AFF),
      '영어': const Color(0xFF34C759),
      '국어': const Color(0xFFFF3B30),
      '과학': const Color(0xFF5E5CE6),
      '사회': const Color(0xFFFF9500),
    };
    return subjectColors[subject] ?? AppTheme.primary;
  }
}

class _Badge {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isUnlocked;

  _Badge({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isUnlocked,
  });
}
