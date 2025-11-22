import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/study_timer.dart';
import '../utils/app_theme.dart';
import '../utils/device_helper.dart';
import 'dart:async';

/// Floating study timer widget (열품타 스타일)
/// Always visible, shows current study time
class StudyTimerWidget extends StatefulWidget {
  const StudyTimerWidget({Key? key}) : super(key: key);

  @override
  State<StudyTimerWidget> createState() => _StudyTimerWidgetState();
}

class _StudyTimerWidgetState extends State<StudyTimerWidget> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Update every second
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyTimerManager>(
      builder: (context, timerManager, child) {
        final scaleFactor = DeviceHelper.getScaleFactor(context);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        if (!timerManager.isTimerActive) {
          // Show start button
          return _buildStartButton(context, scaleFactor, isDarkMode);
        }

        // Show active timer
        return _buildActiveTimer(context, timerManager, scaleFactor, isDarkMode);
      },
    );
  }

  Widget _buildStartButton(BuildContext context, double scaleFactor, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showSubjectSelector(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 12 * scaleFactor,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(24 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 24 * scaleFactor,
            ),
            SizedBox(width: 8 * scaleFactor),
            Text(
              '공부 시작',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTimer(
    BuildContext context,
    StudyTimerManager timerManager,
    double scaleFactor,
    bool isDarkMode,
  ) {
    final timer = timerManager.activeTimer!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scaleFactor,
        vertical: 12 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24 * scaleFactor),
        border: Border.all(
          color: const Color(0xFF667EEA),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subject icon
          Container(
            padding: EdgeInsets.all(6 * scaleFactor),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book,
              color: const Color(0xFF667EEA),
              size: 20 * scaleFactor,
            ),
          ),

          SizedBox(width: 12 * scaleFactor),

          // Subject and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timer.subject,
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
                  fontSize: 14 * scaleFactor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                timer.formattedTime,
                style: TextStyle(
                  color: const Color(0xFF667EEA),
                  fontSize: 18 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  fontVariations: [const FontVariation('wght', 700)],
                ),
              ),
            ],
          ),

          SizedBox(width: 12 * scaleFactor),

          // Pause/Resume button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (timer.isPaused) {
                timerManager.resumeTimer();
              } else {
                timerManager.pauseTimer();
              }
            },
            child: Icon(
              timer.isPaused ? Icons.play_arrow : Icons.pause,
              color: const Color(0xFF667EEA),
              size: 24 * scaleFactor,
            ),
          ),

          SizedBox(width: 8 * scaleFactor),

          // Stop button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showEndTimerDialog(context, timerManager);
            },
            child: Icon(
              Icons.stop_circle_outlined,
              color: AppTheme.error,
              size: 24 * scaleFactor,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectSelector(BuildContext context) {
    final subjects = ['수학', '영어', '국어', '과학', '사회', '기타'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '과목 선택',
              style: AppTheme.heading2(Theme.of(context).brightness == Brightness.dark),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Wrap(
              spacing: AppTheme.spaceMd,
              runSpacing: AppTheme.spaceMd,
              children: subjects.map((subject) {
                return ElevatedButton(
                  onPressed: () {
                    final timerManager = Provider.of<StudyTimerManager>(
                      context,
                      listen: false,
                    );
                    timerManager.startTimer(subject);
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(subject),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndTimerDialog(BuildContext context, StudyTimerManager timerManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공부 종료'),
        content: Text(
          '${timerManager.activeTimer!.subject} 공부를 종료하시겠습니까?\n'
          '순공 시간: ${timerManager.activeTimer!.formattedTime}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              timerManager.endTimer();
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              _showCongratulationsSnackbar(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  void _showCongratulationsSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('수고하셨습니다! 🎉'),
        backgroundColor: Color(0xFF34C759),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Today's study time summary card
class TodayStudyCard extends StatelessWidget {
  const TodayStudyCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyTimerManager>(
      builder: (context, timerManager, child) {
        final totalTime = timerManager.getTodayTotalTime();
        final subjectTimes = timerManager.getTodaySubjectTimes();
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final scaleFactor = DeviceHelper.getScaleFactor(context);

        return Container(
          margin: EdgeInsets.all(AppTheme.spaceMd * scaleFactor),
          padding: EdgeInsets.all(AppTheme.spaceLg * scaleFactor),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF667EEA).withValues(alpha: 0.2),
                      const Color(0xFF764BA2).withValues(alpha: 0.2),
                    ]
                  : [
                      const Color(0xFF667EEA).withValues(alpha: 0.1),
                      const Color(0xFF764BA2).withValues(alpha: 0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg * scaleFactor),
            border: Border.all(
              color: const Color(0xFF667EEA).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: const Color(0xFF667EEA),
                    size: 24 * scaleFactor,
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Text(
                    '오늘의 순공 시간',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spaceMd * scaleFactor),

              // Total time
              Text(
                _formatDuration(totalTime),
                style: TextStyle(
                  fontSize: 36 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667EEA),
                  fontVariations: [const FontVariation('wght', 700)],
                ),
              ),

              if (subjectTimes.isNotEmpty) ...[
                SizedBox(height: AppTheme.spaceMd * scaleFactor),
                Divider(color: const Color(0xFF667EEA).withValues(alpha: 0.2)),
                SizedBox(height: AppTheme.spaceSm * scaleFactor),

                // Subject breakdown
                ...subjectTimes.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4 * scaleFactor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(entry.value),
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF667EEA),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    }
    return '${minutes}분';
  }
}
