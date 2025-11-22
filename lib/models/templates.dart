import 'package:flutter/material.dart';

/// Simple planner templates
enum PlannerTemplateType {
  hourly,           // 시간 단위
  dailyList,        // 리스트 형식
  weeklyOverview,   // 주간 개요
}

class PlannerTemplate {
  final PlannerTemplateType type;
  final String name;
  final String description;
  final Color accentColor;

  const PlannerTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.accentColor,
  });

  static const hourly = PlannerTemplate(
    type: PlannerTemplateType.hourly,
    name: '시간 단위',
    description: '1시간 단위 시간표',
    accentColor: Color(0xFF667EEA),
  );

  static const dailyList = PlannerTemplate(
    type: PlannerTemplateType.dailyList,
    name: '할 일 리스트',
    description: '체크박스 기반 리스트',
    accentColor: Color(0xFF34C759),
  );

  static const weeklyOverview = PlannerTemplate(
    type: PlannerTemplateType.weeklyOverview,
    name: '주간 플래너',
    description: '7일 한눈에 보기',
    accentColor: Color(0xFFFF9500),
  );

  static List<PlannerTemplate> get all => [
    hourly,
    dailyList,
    weeklyOverview,
  ];
}

// 10분 단위 플래너 제거됨 (모트모트 제외)

/// Study report for 공스타그램 (Gong-stagram)
/// Creates beautiful images for social media sharing
class GongstagramReport {
  final DateTime date;
  final Duration totalStudyTime;
  final Map<String, Duration> subjectTimes;
  final int tasksCompleted;
  final int totalTasks;
  final int studyStreak;
  final String? motivationalQuote;
  final ReportStyle style;

  GongstagramReport({
    required this.date,
    required this.totalStudyTime,
    required this.subjectTimes,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.studyStreak,
    this.motivationalQuote,
    this.style = ReportStyle.minimal,
  });

  double get achievementRate => totalTasks > 0 ? (tasksCompleted / totalTasks * 100) : 0;

  String get formattedTotalTime {
    final hours = totalStudyTime.inHours;
    final minutes = totalStudyTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  List<MapEntry<String, Duration>> get topSubjects {
    final entries = subjectTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).toList();
  }

  /// Get emoji based on achievement rate
  String get achievementEmoji {
    if (achievementRate >= 100) return '🔥';
    if (achievementRate >= 80) return '⭐';
    if (achievementRate >= 60) return '👍';
    if (achievementRate >= 40) return '💪';
    return '📝';
  }

  /// Get motivational message
  String get motivationalMessage {
    if (motivationalQuote != null) return motivationalQuote!;

    if (achievementRate >= 100) return '완벽한 하루! 대단해요 🎉';
    if (achievementRate >= 80) return '정말 잘했어요! 👏';
    if (achievementRate >= 60) return '좋은 페이스예요! 💪';
    if (achievementRate >= 40) return '꾸준히 해나가요! 📚';
    return '시작이 중요해요! 🌱';
  }
}

enum ReportStyle {
  minimal,      // 미니멀
  pastel,       // 파스텔
  dark,         // 다크 모드
  gradient,     // 그라데이션
  cute,         // 귀여운 스타일
}

/// Weekly study summary for motivation
class WeeklyStudySummary {
  final DateTime weekStart;
  final List<DailySummaryData> dailySummaries;

  WeeklyStudySummary({
    required this.weekStart,
    required this.dailySummaries,
  });

  Duration get totalWeekStudyTime {
    return dailySummaries.fold(
      Duration.zero,
      (sum, day) => sum + day.studyTime,
    );
  }

  int get totalTasksCompleted {
    return dailySummaries.fold(
      0,
      (sum, day) => sum + day.tasksCompleted,
    );
  }

  double get averageDailyHours => totalWeekStudyTime.inMinutes / (7 * 60);

  DailySummaryData? get bestDay {
    if (dailySummaries.isEmpty) return null;
    return dailySummaries.reduce(
      (a, b) => a.studyTime > b.studyTime ? a : b,
    );
  }

  /// Get study days count (days with study time > 0)
  int get studyDaysCount {
    return dailySummaries.where((d) => d.studyTime.inMinutes > 0).length;
  }

  bool get isPerfectWeek => studyDaysCount == 7;
}

class DailySummaryData {
  final DateTime date;
  final Duration studyTime;
  final int tasksCompleted;
  final int totalTasks;

  DailySummaryData({
    required this.date,
    required this.studyTime,
    required this.tasksCompleted,
    required this.totalTasks,
  });

  String get weekdayShort {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  double get achievementRate => totalTasks > 0 ? (tasksCompleted / totalTasks * 100) : 0;
}

/// Custom font presets
class CustomFontPreset {
  final String name;
  final String? fontFamily;
  final String description;
  final bool isHandwriting;

  const CustomFontPreset({
    required this.name,
    this.fontFamily,
    required this.description,
    this.isHandwriting = false,
  });

  static const defaultFont = CustomFontPreset(
    name: '기본 폰트',
    fontFamily: null,
    description: 'SF Pro / Roboto',
  );

  static const minimal = CustomFontPreset(
    name: '미니멀',
    fontFamily: 'NotoSansKR',
    description: 'Noto Sans KR (깔끔)',
  );

  static List<CustomFontPreset> get all => [
    defaultFont,
    minimal,
  ];
}
