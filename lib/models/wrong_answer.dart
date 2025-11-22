import 'package:flutter/material.dart';

/// Represents a clipped wrong answer problem
/// Each wrong answer has:
/// - Problem image (screenshot from PDF or textbook)
/// - Metadata (subject, chapter, difficulty)
/// - Solution space for writing explanation
/// - Attempt history for N-rounds review
class WrongAnswer {
  final String id;
  final String problemImagePath; // Path to clipped problem image
  final Rect originalBounds; // Original position in source note
  final String sourceNoteId; // Which note/PDF this came from
  final int? sourcePage; // Page number in source

  // Metadata
  String subject; // 예: "수학 I", "영어 독해"
  String? chapter; // 예: "지수함수", "수능 기출 2024"
  String? tags; // Additional tags
  DifficultyLevel difficulty;

  // Status tracking
  DateTime clippedAt;
  DateTime? lastReviewedAt;
  int reviewCount; // How many times reviewed
  bool isMastered; // Student marked as mastered

  // Solution note
  String? solutionNoteId; // Link to solution note page

  WrongAnswer({
    required this.id,
    required this.problemImagePath,
    required this.originalBounds,
    required this.sourceNoteId,
    this.sourcePage,
    required this.subject,
    this.chapter,
    this.tags,
    this.difficulty = DifficultyLevel.medium,
    required this.clippedAt,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.isMastered = false,
    this.solutionNoteId,
  });

  /// Get display title for this wrong answer
  String get title {
    final subjectPart = subject;
    final chapterPart = chapter != null ? ' - $chapter' : '';
    final pagePart = sourcePage != null ? ' (p.$sourcePage)' : '';
    return '$subjectPart$chapterPart$pagePart';
  }

  /// Get time since last review
  String get reviewStatus {
    if (lastReviewedAt == null) return '미복습';

    final now = DateTime.now();
    final diff = now.difference(lastReviewedAt!);

    if (diff.inDays == 0) return '오늘 복습';
    if (diff.inDays == 1) return '1일 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    return '${(diff.inDays / 30).floor()}개월 전';
  }

  /// Get difficulty color
  Color get difficultyColor {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return const Color(0xFF34C759); // Green
      case DifficultyLevel.medium:
        return const Color(0xFFFF9500); // Orange
      case DifficultyLevel.hard:
        return const Color(0xFFFF3B30); // Red
    }
  }

  /// Get difficulty icon
  IconData get difficultyIcon {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.sentiment_satisfied;
      case DifficultyLevel.medium:
        return Icons.sentiment_neutral;
      case DifficultyLevel.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  WrongAnswer copyWith({
    String? id,
    String? problemImagePath,
    Rect? originalBounds,
    String? sourceNoteId,
    int? sourcePage,
    String? subject,
    String? chapter,
    String? tags,
    DifficultyLevel? difficulty,
    DateTime? clippedAt,
    DateTime? lastReviewedAt,
    int? reviewCount,
    bool? isMastered,
    String? solutionNoteId,
  }) {
    return WrongAnswer(
      id: id ?? this.id,
      problemImagePath: problemImagePath ?? this.problemImagePath,
      originalBounds: originalBounds ?? this.originalBounds,
      sourceNoteId: sourceNoteId ?? this.sourceNoteId,
      sourcePage: sourcePage ?? this.sourcePage,
      subject: subject ?? this.subject,
      chapter: chapter ?? this.chapter,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      clippedAt: clippedAt ?? this.clippedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      isMastered: isMastered ?? this.isMastered,
      solutionNoteId: solutionNoteId ?? this.solutionNoteId,
    );
  }
}

enum DifficultyLevel {
  easy,   // 쉬움 - 단순 실수
  medium, // 보통 - 개념 부족
  hard,   // 어려움 - 심화 문제
}

/// Template for wrong answer note pages
/// Each page has two sections:
/// - Problem area (image)
/// - Solution area (lined paper for writing)
class WrongAnswerTemplate {
  static const double problemAreaHeight = 0.4; // 40% of page
  static const double solutionAreaHeight = 0.6; // 60% of page

  /// Get template name in Korean
  static String get templateName => '오답노트';

  /// Get template description
  static String get templateDescription => '문제 영역 + 해설 영역';

  /// Render wrong answer template background
  static void renderTemplate(
    Canvas canvas,
    Size size,
    Color backgroundColor,
    bool isDarkMode,
  ) {
    // Fill background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final dividerY = size.height * problemAreaHeight;
    final lineColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    // Draw divider line between problem and solution areas
    final dividerPaint = Paint()
      ..color = isDarkMode
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, dividerY),
      Offset(size.width, dividerY),
      dividerPaint,
    );

    // Draw "문제" label at top
    final problemLabelPainter = TextPainter(
      text: TextSpan(
        text: '문제',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.3),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    problemLabelPainter.layout();
    problemLabelPainter.paint(canvas, const Offset(20, 20));

    // Draw "해설" label at divider
    final solutionLabelPainter = TextPainter(
      text: TextSpan(
        text: '해설',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.3),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    solutionLabelPainter.layout();
    solutionLabelPainter.paint(canvas, Offset(20, dividerY + 10));

    // Draw lined paper in solution area
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const lineSpacing = 40.0;
    const marginLeft = 80.0;

    // Start lines below the "해설" label
    for (double y = dividerY + 50; y < size.height; y += lineSpacing) {
      // Vertical margin line (left side)
      canvas.drawLine(
        Offset(marginLeft, dividerY),
        Offset(marginLeft, size.height),
        linePaint,
      );

      // Horizontal lines
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }
}

/// Manages collection of wrong answers
class WrongAnswerCollection {
  final String id;
  final String name; // 예: "2024년 3월 모의고사"
  final String? description;
  final DateTime createdAt;
  final List<WrongAnswer> wrongAnswers;

  WrongAnswerCollection({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.wrongAnswers = const [],
  });

  /// Get statistics
  int get totalCount => wrongAnswers.length;
  int get masteredCount => wrongAnswers.where((wa) => wa.isMastered).length;
  int get remainingCount => totalCount - masteredCount;
  double get masteryPercentage =>
      totalCount > 0 ? (masteredCount / totalCount) * 100 : 0.0;

  /// Group by subject
  Map<String, List<WrongAnswer>> get groupedBySubject {
    final grouped = <String, List<WrongAnswer>>{};
    for (final wa in wrongAnswers) {
      if (!grouped.containsKey(wa.subject)) {
        grouped[wa.subject] = [];
      }
      grouped[wa.subject]!.add(wa);
    }
    return grouped;
  }

  /// Get wrong answers that need review (not reviewed recently)
  List<WrongAnswer> get needsReview {
    final now = DateTime.now();
    return wrongAnswers.where((wa) {
      if (wa.isMastered) return false;
      if (wa.lastReviewedAt == null) return true;

      // Need review if not reviewed in last 3 days
      final daysSinceReview = now.difference(wa.lastReviewedAt!).inDays;
      return daysSinceReview >= 3;
    }).toList();
  }

  WrongAnswerCollection copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<WrongAnswer>? wrongAnswers,
  }) {
    return WrongAnswerCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
    );
  }
}
