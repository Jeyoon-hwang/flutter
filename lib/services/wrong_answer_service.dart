import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/wrong_answer.dart';
import '../models/note.dart';

/// Service for managing wrong answer clipping and collections
class WrongAnswerService extends ChangeNotifier {
  // All wrong answer collections
  final List<WrongAnswerCollection> _collections = [];

  // Current active collection
  WrongAnswerCollection? _currentCollection;

  // Auto-detected subject (from note title or last used)
  String _lastUsedSubject = '수학';

  // Getters
  List<WrongAnswerCollection> get collections => List.unmodifiable(_collections);
  WrongAnswerCollection? get currentCollection => _currentCollection;
  String get lastUsedSubject => _lastUsedSubject;

  /// Get or create default collection
  WrongAnswerCollection get defaultCollection {
    if (_collections.isEmpty) {
      final collection = WrongAnswerCollection(
        id: 'default_${DateTime.now().millisecondsSinceEpoch}',
        name: '나의 오답노트',
        description: '모든 오답 문제',
        createdAt: DateTime.now(),
      );
      _collections.add(collection);
      _currentCollection = collection;
    }
    return _currentCollection ?? _collections.first;
  }

  /// Set current collection
  void setCurrentCollection(String collectionId) {
    final collection = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => defaultCollection,
    );
    _currentCollection = collection;
    notifyListeners();
  }

  /// Create new wrong answer collection
  WrongAnswerCollection createCollection({
    required String name,
    String? description,
  }) {
    final collection = WrongAnswerCollection(
      id: 'collection_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    _collections.add(collection);
    _currentCollection = collection;
    notifyListeners();

    print('✅ Created wrong answer collection: $name');
    return collection;
  }

  /// Clip wrong answer from selection
  /// This is the core function called when user completes clipping
  Future<WrongAnswer> clipWrongAnswer({
    required ui.Image screenshot,
    required Rect selectionBounds,
    required String sourceNoteId,
    int? sourcePage,
    required String subject,
    String? chapter,
    DifficultyLevel difficulty = DifficultyLevel.medium,
  }) async {
    try {
      // Save screenshot to file
      final imagePath = await _saveScreenshot(screenshot);

      // Create wrong answer object
      final wrongAnswer = WrongAnswer(
        id: 'wa_${DateTime.now().millisecondsSinceEpoch}',
        problemImagePath: imagePath,
        originalBounds: selectionBounds,
        sourceNoteId: sourceNoteId,
        sourcePage: sourcePage,
        subject: subject,
        chapter: chapter,
        difficulty: difficulty,
        clippedAt: DateTime.now(),
      );

      // Add to current collection
      final collection = defaultCollection;
      final updatedWrongAnswers = [...collection.wrongAnswers, wrongAnswer];

      final collectionIndex = _collections.indexWhere((c) => c.id == collection.id);
      if (collectionIndex != -1) {
        _collections[collectionIndex] = collection.copyWith(
          wrongAnswers: updatedWrongAnswers,
        );
      }

      // Update last used subject
      _lastUsedSubject = subject;

      notifyListeners();

      print('✅ Clipped wrong answer: $subject${chapter != null ? " - $chapter" : ""}');
      print('   Image saved: $imagePath');
      print('   Total wrong answers: ${updatedWrongAnswers.length}');

      return wrongAnswer;
    } catch (e) {
      print('❌ Error clipping wrong answer: $e');
      rethrow;
    }
  }

  /// Save screenshot image to file
  Future<String> _saveScreenshot(ui.Image image) async {
    try {
      // Convert image to PNG bytes
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final wrongAnswersDir = Directory('${directory.path}/wrong_answers');

      // Create directory if it doesn't exist
      if (!await wrongAnswersDir.exists()) {
        await wrongAnswersDir.create(recursive: true);
      }

      // Save file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'wa_$timestamp.png';
      final file = File('${wrongAnswersDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      print('❌ Error saving screenshot: $e');
      rethrow;
    }
  }

  /// Mark wrong answer as mastered
  void markAsMastered(String wrongAnswerId) {
    for (int i = 0; i < _collections.length; i++) {
      final collection = _collections[i];
      final waIndex = collection.wrongAnswers.indexWhere((wa) => wa.id == wrongAnswerId);

      if (waIndex != -1) {
        final updatedWrongAnswer = collection.wrongAnswers[waIndex].copyWith(
          isMastered: true,
          lastReviewedAt: DateTime.now(),
          reviewCount: collection.wrongAnswers[waIndex].reviewCount + 1,
        );

        final updatedWrongAnswers = [...collection.wrongAnswers];
        updatedWrongAnswers[waIndex] = updatedWrongAnswer;

        _collections[i] = collection.copyWith(wrongAnswers: updatedWrongAnswers);
        notifyListeners();

        print('✅ Marked as mastered: ${updatedWrongAnswer.title}');
        break;
      }
    }
  }

  /// Record a review session
  void recordReview(String wrongAnswerId) {
    for (int i = 0; i < _collections.length; i++) {
      final collection = _collections[i];
      final waIndex = collection.wrongAnswers.indexWhere((wa) => wa.id == wrongAnswerId);

      if (waIndex != -1) {
        final updatedWrongAnswer = collection.wrongAnswers[waIndex].copyWith(
          lastReviewedAt: DateTime.now(),
          reviewCount: collection.wrongAnswers[waIndex].reviewCount + 1,
        );

        final updatedWrongAnswers = [...collection.wrongAnswers];
        updatedWrongAnswers[waIndex] = updatedWrongAnswer;

        _collections[i] = collection.copyWith(wrongAnswers: updatedWrongAnswers);
        notifyListeners();

        print('✅ Recorded review: ${updatedWrongAnswer.title}');
        break;
      }
    }
  }

  /// Delete wrong answer
  void deleteWrongAnswer(String wrongAnswerId) {
    for (int i = 0; i < _collections.length; i++) {
      final collection = _collections[i];
      final waIndex = collection.wrongAnswers.indexWhere((wa) => wa.id == wrongAnswerId);

      if (waIndex != -1) {
        // Delete image file
        final wrongAnswer = collection.wrongAnswers[waIndex];
        _deleteImageFile(wrongAnswer.problemImagePath);

        // Remove from collection
        final updatedWrongAnswers = [...collection.wrongAnswers];
        updatedWrongAnswers.removeAt(waIndex);

        _collections[i] = collection.copyWith(wrongAnswers: updatedWrongAnswers);
        notifyListeners();

        print('✅ Deleted wrong answer: ${wrongAnswer.title}');
        break;
      }
    }
  }

  /// Delete image file
  Future<void> _deleteImageFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print('✅ Deleted image file: $path');
      }
    } catch (e) {
      print('❌ Error deleting image file: $e');
    }
  }

  /// Get all wrong answers across all collections
  List<WrongAnswer> get allWrongAnswers {
    return _collections.expand((c) => c.wrongAnswers).toList();
  }

  /// Get wrong answers by subject
  List<WrongAnswer> getWrongAnswersBySubject(String subject) {
    return allWrongAnswers.where((wa) => wa.subject == subject).toList();
  }

  /// Get wrong answers that need review
  List<WrongAnswer> get needsReview {
    return allWrongAnswers.where((wa) {
      if (wa.isMastered) return false;
      if (wa.lastReviewedAt == null) return true;

      final daysSinceReview = DateTime.now().difference(wa.lastReviewedAt!).inDays;
      return daysSinceReview >= 3;
    }).toList();
  }

  /// Get subjects used in wrong answers
  List<String> get usedSubjects {
    final subjects = <String>{};
    for (final wa in allWrongAnswers) {
      subjects.add(wa.subject);
    }
    return subjects.toList()..sort();
  }

  /// Get statistics
  Map<String, dynamic> get statistics {
    final total = allWrongAnswers.length;
    final mastered = allWrongAnswers.where((wa) => wa.isMastered).length;
    final needsReviewCount = needsReview.length;

    return {
      'total': total,
      'mastered': mastered,
      'remaining': total - mastered,
      'needsReview': needsReviewCount,
      'masteryPercentage': total > 0 ? (mastered / total) * 100 : 0.0,
    };
  }

  /// Auto-detect subject from note title
  String detectSubjectFromNote(Note note) {
    final title = note.title.toLowerCase();

    // Common subjects in Korean
    final subjectKeywords = {
      '수학': ['수학', 'math', '미적분', '기하', '확률'],
      '영어': ['영어', 'english', '독해', '문법'],
      '국어': ['국어', 'korean', '문학', '비문학'],
      '과학': ['과학', 'science', '물리', '화학', '생물', '지구과학'],
      '사회': ['사회', 'social', '역사', '지리', '윤리', '경제'],
    };

    for (final entry in subjectKeywords.entries) {
      for (final keyword in entry.value) {
        if (title.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // Default to last used subject
    return _lastUsedSubject;
  }
}
