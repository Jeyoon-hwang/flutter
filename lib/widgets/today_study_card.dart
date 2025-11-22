import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import 'common/animated_widgets.dart';

/// Today's study summary card
/// Shows quick stats: study time, notes created, goals completed
class TodayStudyCard extends StatelessWidget {
  const TodayStudyCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final stats = provider.studyStatsManager;
        final todayStats = stats.getTodayStats();

        return FadeInWidget(
          duration: const Duration(milliseconds: 400),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.9),
                  AppTheme.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '오늘의 공부',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceLg),

                // Stats grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.timer_outlined,
                        label: '공부 시간',
                        value: _formatDuration(todayStats.studyDuration),
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.edit_outlined,
                        label: '푼 문제',
                        value: '${todayStats.problemsSolved}개',
                        index: 1,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.check_circle_outline,
                        label: '완료 계획',
                        value: '${todayStats.completedTasks.length}개',
                        index: 2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceMd),

                // Motivation message
                ScaleInWidget(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getMotivationMessage(todayStats.studyDuration),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required int index,
  }) {
    return SlideInWidget(
      delay: Duration(milliseconds: 400 + (index * 100)),
      begin: const Offset(0, 0.3),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: 24,
          ),
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
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _getMotivationMessage(Duration studyTime) {
    final minutes = studyTime.inMinutes;

    if (minutes >= 240) {
      return '와! 4시간 이상 공부했어요! 정말 대단해요! 🔥';
    } else if (minutes >= 120) {
      return '2시간 돌파! 정말 열심히 하고 있어요! 💪';
    } else if (minutes >= 60) {
      return '1시간 달성! 계속 이 속도를 유지하세요! ⭐';
    } else if (minutes >= 30) {
      return '좋아요! 꾸준히 하는 게 중요해요! 👍';
    } else if (minutes > 0) {
      return '좋은 시작이에요! 계속 해봐요! 🌱';
    } else {
      return '오늘도 힘내요! 함께 공부해요! 📚';
    }
  }
}

/// Today's stats data model
class TodayStats {
  final Duration totalStudyTime;
  final int notesCreated;
  final int goalsCompleted;

  const TodayStats({
    this.totalStudyTime = Duration.zero,
    this.notesCreated = 0,
    this.goalsCompleted = 0,
  });
}

/// Extension for StudyStats to get today's data
extension TodayStatsExtension on dynamic {
  TodayStats getTodayStats() {
    // This would be implemented in the actual StudyStats class
    // For now, return default values
    return const TodayStats();
  }
}
