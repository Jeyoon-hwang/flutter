import 'package:flutter/material.dart';

/// Planner templates inspired by 모트모트 (Motemote)
/// Focus on 10-minute interval time blocks for detailed scheduling
enum PlannerTemplateType {
  motemote10min,    // 모트모트 스타일: 10분 단위
  hourly,           // 시간 단위
  dailyList,        // 리스트 형식
  weeklyOverview,   // 주간 개요
  customGrid,       // 커스텀 그리드
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

  static const motemote = PlannerTemplate(
    type: PlannerTemplateType.motemote10min,
    name: '모트모트 스타일',
    description: '10분 단위 시간표 (6:00~24:00)',
    accentColor: Color(0xFFF8B4D9), // 모트모트 핑크
  );

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
    motemote,
    hourly,
    dailyList,
    weeklyOverview,
  ];
}

/// Time block for 모트모트 style planner
class TimeBlock {
  final int hour;
  final int minute; // 0, 10, 20, 30, 40, 50
  final String? task;
  final String? subject;
  final Color? color;

  TimeBlock({
    required this.hour,
    required this.minute,
    this.task,
    this.subject,
    this.color,
  });

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool get isEmpty => task == null || task!.isEmpty;

  TimeBlock copyWith({
    String? task,
    String? subject,
    Color? color,
  }) {
    return TimeBlock(
      hour: hour,
      minute: minute,
      task: task ?? this.task,
      subject: subject ?? this.subject,
      color: color ?? this.color,
    );
  }
}

/// Motemote-style daily planner (6:00 ~ 24:00, 10분 단위)
class MotemoteDailyPlanner {
  final DateTime date;
  final Map<String, TimeBlock> blocks; // key: "HH:mm"

  MotemoteDailyPlanner({
    required this.date,
    Map<String, TimeBlock>? blocks,
  }) : blocks = blocks ?? _generateEmptyBlocks();

  static Map<String, TimeBlock> _generateEmptyBlocks() {
    final blocks = <String, TimeBlock>{};

    // 6:00 ~ 24:00, 10분 간격
    for (int hour = 6; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 10) {
        final block = TimeBlock(hour: hour, minute: minute);
        blocks[block.timeString] = block;
      }
    }

    return blocks;
  }

  /// Get all time blocks sorted by time
  List<TimeBlock> get sortedBlocks {
    final list = blocks.values.toList();
    list.sort((a, b) {
      if (a.hour != b.hour) return a.hour.compareTo(b.hour);
      return a.minute.compareTo(b.minute);
    });
    return list;
  }

  /// Get filled blocks (with tasks)
  List<TimeBlock> get filledBlocks => sortedBlocks.where((b) => !b.isEmpty).toList();

  /// Calculate total planned time
  Duration get totalPlannedTime => Duration(minutes: filledBlocks.length * 10);

  /// Get time blocks grouped by hour
  Map<int, List<TimeBlock>> get blocksByHour {
    final grouped = <int, List<TimeBlock>>{};
    for (final block in sortedBlocks) {
      grouped.putIfAbsent(block.hour, () => []).add(block);
    }
    return grouped;
  }
}

/// Beautiful study report for 공스타그램 (Gong-stagram)
/// Creates aesthetically pleasing images for social media sharing
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
  minimal,      // 미니멀 (무지 스타일)
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

/// Custom font presets (손글씨 감성)
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

  static const handwriting1 = CustomFontPreset(
    name: '손글씨체 1',
    fontFamily: 'NanumPenScript',
    description: '나눔 손글씨',
    isHandwriting: true,
  );

  static const handwriting2 = CustomFontPreset(
    name: '손글씨체 2',
    fontFamily: 'EastSeaDokdo',
    description: '동해바다 손글씨',
    isHandwriting: true,
  );

  static const minimal = CustomFontPreset(
    name: '미니멀',
    fontFamily: 'NotoSansKR',
    description: 'Noto Sans KR (깔끔)',
  );

  static List<CustomFontPreset> get all => [
    defaultFont,
    handwriting1,
    handwriting2,
    minimal,
  ];
}
