import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/wrong_answer.dart';
import '../utils/app_theme.dart';
import '../utils/page_routes.dart';
import 'canvas_screen.dart';

/// Wrong Answer Notes Screen
/// Displays all wrong answer clips collected by the user
class WrongAnswerScreen extends StatelessWidget {
  const WrongAnswerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final wrongAnswers = provider.wrongAnswerService.allWrongAnswers;

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          appBar: AppBar(
            title: const Text(
              '오답 노트',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [const Color(0xFFFF3B30), const Color(0xFFFF9500)],
                ),
              ),
            ),
          ),
          body: wrongAnswers.isEmpty
              ? _buildEmptyState(isDarkMode)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  itemCount: wrongAnswers.length,
                  itemBuilder: (context, index) {
                    final wrongAnswer = wrongAnswers[index];
                    return _buildWrongAnswerCard(
                      context,
                      provider,
                      wrongAnswer,
                      isDarkMode,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: isDarkMode ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            '아직 오답이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '필기 중 가위 아이콘(✂️)으로 오답을 캡처하세요',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWrongAnswerCard(
    BuildContext context,
    DrawingProvider provider,
    WrongAnswer wrongAnswer,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: AppTheme.containerDecoration(isDarkMode),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to the source note
            provider.switchToNote(wrongAnswer.sourceNoteId);
            context.pushSlideUp(const CanvasScreen());
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with subject and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Subject chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3B30), Color(0xFFFF9500)],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        wrongAnswer.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Date
                    Text(
                      _formatDate(wrongAnswer.clippedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceMd),

                // Title/Description
                Text(
                  wrongAnswer.title,
                  style: AppTheme.bodyLarge(isDarkMode).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),

                // Tags
                if (wrongAnswer.tags != null && wrongAnswer.tags!.isNotEmpty) ...[
                  Wrap(
                    spacing: AppTheme.spaceSm,
                    runSpacing: AppTheme.spaceSm,
                    children: wrongAnswer.tags!.split(',').map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF3B30),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                ],

                // Review count
                Row(
                  children: [
                    Icon(
                      Icons.replay,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '복습 ${wrongAnswer.reviewCount}회',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '오늘';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}
