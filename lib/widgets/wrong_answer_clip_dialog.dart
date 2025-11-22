import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/wrong_answer.dart';

/// Dialog shown after user selects wrong answer clipping area
/// Allows user to input subject, chapter, and difficulty
class WrongAnswerClipDialog extends StatefulWidget {
  final Rect selectionBounds;
  final GlobalKey repaintBoundaryKey;

  const WrongAnswerClipDialog({
    Key? key,
    required this.selectionBounds,
    required this.repaintBoundaryKey,
  }) : super(key: key);

  @override
  State<WrongAnswerClipDialog> createState() => _WrongAnswerClipDialogState();
}

class _WrongAnswerClipDialogState extends State<WrongAnswerClipDialog> {
  late TextEditingController _subjectController;
  late TextEditingController _chapterController;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  bool _isProcessing = false;

  // Common subjects for quick selection
  static const List<String> _commonSubjects = [
    '수학',
    '영어',
    '국어',
    '과학',
    '사회',
    '물리',
    '화학',
    '생물',
    '지구과학',
    '한국사',
  ];

  @override
  void initState() {
    super.initState();

    final provider = context.read<DrawingProvider>();

    // Auto-detect subject from note title
    String initialSubject = provider.wrongAnswerService.lastUsedSubject;
    if (provider.noteService.currentNote != null) {
      initialSubject = provider.wrongAnswerService
          .detectSubjectFromNote(provider.noteService.currentNote!);
    }

    _subjectController = TextEditingController(text: initialSubject);
    _chapterController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrawingProvider>();
    final isDarkMode = provider.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF9500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오답 클리핑',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '문제 정보를 입력하세요',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subject input
            Text(
              '과목 *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: '예: 수학 I, 영어 독해',
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Quick subject selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSubjects.map((subject) {
                final isSelected = _subjectController.text == subject;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _subjectController.text = subject;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFF667EEA),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Chapter input
            Text(
              '단원 (선택)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _chapterController,
              decoration: InputDecoration(
                hintText: '예: 지수함수, 수능 기출 2024',
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Difficulty selection
            Text(
              '난이도',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: DifficultyLevel.values.map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                String label;
                IconData icon;
                Color color;

                switch (difficulty) {
                  case DifficultyLevel.easy:
                    label = '쉬움';
                    icon = Icons.sentiment_satisfied;
                    color = const Color(0xFF34C759);
                    break;
                  case DifficultyLevel.medium:
                    label = '보통';
                    icon = Icons.sentiment_neutral;
                    color = const Color(0xFFFF9500);
                    break;
                  case DifficultyLevel.hard:
                    label = '어려움';
                    icon = Icons.sentiment_very_dissatisfied;
                    color = const Color(0xFFFF3B30);
                    break;
                }

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: difficulty != DifficultyLevel.hard ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDifficulty = difficulty;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.2)
                              : isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              icon,
                              color: isSelected
                                  ? color
                                  : isDarkMode
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.5),
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? color
                                    : isDarkMode
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : Colors.black.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.pop(context);
                            // Clear selection
                            provider.clearSelection();
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleClip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 6),
                              Text(
                                '오답노트로 보내기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClip() async {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('과목을 입력하세요')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = context.read<DrawingProvider>();

      // Capture screenshot of selected area
      final RenderRepaintBoundary boundary = widget.repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);

      // Create recorder to capture just selected area
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the selected portion
      canvas.drawImageRect(
        fullImage,
        widget.selectionBounds,
        Rect.fromLTWH(
          0,
          0,
          widget.selectionBounds.width,
          widget.selectionBounds.height,
        ),
        Paint(),
      );

      final picture = recorder.endRecording();
      final screenshot = await picture.toImage(
        widget.selectionBounds.width.toInt(),
        widget.selectionBounds.height.toInt(),
      );

      // Get current page number (1-indexed)
      final currentPage = provider.pageManager.currentPageIndex + 1;

      // Clip wrong answer
      final wrongAnswer = await provider.wrongAnswerService.clipWrongAnswer(
        screenshot: screenshot,
        selectionBounds: widget.selectionBounds,
        sourceNoteId: provider.noteService.currentNote?.id ?? 'unknown',
        sourcePage: currentPage,
        subject: subject,
        chapter: _chapterController.text.trim().isEmpty
            ? null
            : _chapterController.text.trim(),
        difficulty: _selectedDifficulty,
      );

      if (mounted) {
        // Clear selection
        provider.clearSelection();

        // Close dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '오답노트에 추가됨',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        wrongAnswer.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF34C759),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error clipping wrong answer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
