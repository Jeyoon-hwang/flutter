import '../models/note.dart';

/// Filter options for note search
enum NoteSortBy {
  modifiedDate,  // 최근 수정일
  createdDate,   // 생성일
  title,         // 제목
  studyCount,    // 학습 횟수
}

enum SortOrder {
  ascending,
  descending,
}

/// Advanced note search and filter service
class NoteSearchService {
  /// Search and filter notes based on criteria
  static List<Note> searchNotes({
    required List<Note> notes,
    String? searchQuery,
    String? subject,
    String? category,
    List<String>? tags,
    bool? isFavorite,
    DateTime? startDate,
    DateTime? endDate,
    NoteSortBy sortBy = NoteSortBy.modifiedDate,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    var filtered = notes;

    // Search query filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((note) => note.matchesSearch(searchQuery)).toList();
    }

    // Subject filter
    if (subject != null && subject.isNotEmpty) {
      filtered = filtered.where((note) => note.subject == subject).toList();
    }

    // Category filter
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((note) => note.category == category).toList();
    }

    // Tags filter (note must have ALL specified tags)
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered.where((note) {
        return tags.every((tag) => note.tags.contains(tag));
      }).toList();
    }

    // Favorite filter
    if (isFavorite != null) {
      filtered = filtered.where((note) => note.isFavorite == isFavorite).toList();
    }

    // Date range filter
    if (startDate != null) {
      filtered = filtered.where((note) =>
        note.modifiedAt.isAfter(startDate) || note.modifiedAt.isAtSameMomentAs(startDate)
      ).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((note) =>
        note.modifiedAt.isBefore(endDate) || note.modifiedAt.isAtSameMomentAs(endDate)
      ).toList();
    }

    // Sort
    filtered = _sortNotes(filtered, sortBy, sortOrder);

    return filtered;
  }

  /// Get all unique subjects from notes
  static List<String> getSubjects(List<Note> notes) {
    final subjects = notes
        .map((note) => note.subject)
        .where((subject) => subject != null && subject.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
    subjects.sort();
    return subjects;
  }

  /// Get all unique categories from notes
  static List<String> getCategories(List<Note> notes) {
    final categories = notes
        .map((note) => note.category)
        .where((category) => category != null && category.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
    categories.sort();
    return categories;
  }

  /// Get all unique tags from notes
  static List<String> getAllTags(List<Note> notes) {
    final allTags = <String>{};
    for (final note in notes) {
      allTags.addAll(note.tags);
    }
    final tagList = allTags.toList();
    tagList.sort();
    return tagList;
  }

  /// Group notes by subject
  static Map<String, List<Note>> groupBySubject(List<Note> notes) {
    final grouped = <String, List<Note>>{};

    for (final note in notes) {
      final subject = note.subject ?? '미분류';
      grouped.putIfAbsent(subject, () => []).add(note);
    }

    return grouped;
  }

  /// Group notes by date (YYYY-MM-DD)
  static Map<String, List<Note>> groupByDate(List<Note> notes) {
    final grouped = <String, List<Note>>{};

    for (final note in notes) {
      final date = '${note.modifiedAt.year}-${note.modifiedAt.month.toString().padLeft(2, '0')}-${note.modifiedAt.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(date, () => []).add(note);
    }

    return grouped;
  }

  /// Group notes by month (YYYY-MM)
  static Map<String, List<Note>> groupByMonth(List<Note> notes) {
    final grouped = <String, List<Note>>{};

    for (final note in notes) {
      final month = '${note.modifiedAt.year}년 ${note.modifiedAt.month}월';
      grouped.putIfAbsent(month, () => []).add(note);
    }

    return grouped;
  }

  /// Get recently modified notes (last N days)
  static List<Note> getRecentNotes(List<Note> notes, {int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return notes
        .where((note) => note.modifiedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  /// Get favorite notes
  static List<Note> getFavorites(List<Note> notes) {
    return notes.where((note) => note.isFavorite).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  /// Get most studied notes (by study count)
  static List<Note> getMostStudied(List<Note> notes, {int limit = 10}) {
    final sorted = notes.toList()
      ..sort((a, b) => b.studyCount.compareTo(a.studyCount));
    return sorted.take(limit).toList();
  }

  /// Private: Sort notes
  static List<Note> _sortNotes(
    List<Note> notes,
    NoteSortBy sortBy,
    SortOrder order,
  ) {
    final sorted = notes.toList();

    switch (sortBy) {
      case NoteSortBy.modifiedDate:
        sorted.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
        break;
      case NoteSortBy.createdDate:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortBy.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NoteSortBy.studyCount:
        sorted.sort((a, b) => a.studyCount.compareTo(b.studyCount));
        break;
    }

    if (order == SortOrder.descending) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  /// Get study statistics for a subject
  static Map<String, dynamic> getSubjectStats(List<Note> notes, String subject) {
    final subjectNotes = notes.where((n) => n.subject == subject).toList();

    return {
      'totalNotes': subjectNotes.length,
      'totalStudyCount': subjectNotes.fold(0, (sum, note) => sum + note.studyCount),
      'favoriteCount': subjectNotes.where((n) => n.isFavorite).length,
      'recentNotes': getRecentNotes(subjectNotes, days: 7).length,
      'avgStudyCount': subjectNotes.isEmpty
          ? 0.0
          : subjectNotes.fold(0, (sum, note) => sum + note.studyCount) /
              subjectNotes.length,
    };
  }
}
