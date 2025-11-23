import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import '../utils/page_routes.dart';
import '../utils/motivational_quotes.dart';
import '../models/planner.dart';
import '../models/app_settings.dart';
import '../models/note.dart';
import '../widgets/study_timer_widget.dart' hide TodayStudyCard;
import '../widgets/today_study_card.dart';
import '../services/haptic_service.dart';
import 'canvas_screen.dart';
import 'notes_list_screen.dart';
import 'stats_screen.dart';
import 'font_settings_screen.dart';
import 'gesture_guide_screen.dart';
import 'background_settings_screen.dart';
import 'settings_screen.dart';
import 'wrong_answer_screen.dart';

/// Home dashboard with planner-centric design
/// "Gong-stagram" aesthetic: minimal, clean, motivating
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool _performanceInitialized = false;

  // Get today's motivational quote
  Quote _getTodayQuote() {
    return MotivationalQuotes.getTimeBasedQuote();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Auto-detect performance settings once
    if (!_performanceInitialized) {
      final provider = Provider.of<DrawingProvider>(context, listen: false);
      provider.autoDetectPerformanceSettings(context);
      _performanceInitialized = true;

      // Show gesture guide on first launch
      _checkAndShowGestureGuide();
    }
  }

  Future<void> _checkAndShowGestureGuide() async {
    final shouldShow = await GestureGuideScreen.shouldShow();
    if (shouldShow && mounted) {
      // Small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).push(
          PageRoutes.fade(const GestureGuideScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final backgroundColor = provider.getBackgroundColor();

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date and settings
                    _buildHeader(context, provider, isDarkMode),

                    // Study timer widget (Floating)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                        child: const StudyTimerWidget(),
                      ),
                    ),

                    // Today's study summary card
                    const TodayStudyCard(),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Recent notes section
                    if (provider.noteService.allNotes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '최근 노트',
                              style: AppTheme.heading2(isDarkMode),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pushSlideRight(const NotesListScreen());
                              },
                              child: Text(
                                '전체보기',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      _buildRecentNotes(context, provider, isDarkMode),
                      const SizedBox(height: AppTheme.spaceLg),
                    ],

                    // Today's planner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '오늘의 계획',
                            style: AppTheme.heading2(isDarkMode),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _showAddPlannerItem(context, provider);
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('추가'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    // Planner items list
                    Expanded(
                      child: _buildPlannerList(context, provider, isDarkMode),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom navigation bar (minimal design)
          bottomNavigationBar: _buildBottomNav(context, isDarkMode),

          // FAB for quick note
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              // Haptic feedback
              await hapticService.medium();

              // Create quick note and navigate to canvas
              provider.createQuickNote();
              if (mounted) {
                context.pushSlideUp(const CanvasScreen());
              }
            },
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.edit),
            label: const Text('빠른 메모'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DrawingProvider provider, bool isDarkMode) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${now.month}월 ${now.day}일 $weekday요일',
                    style: AppTheme.bodySmall(isDarkMode),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$hour:$minute',
                      style: AppTheme.bodySmall(isDarkMode).copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Motivational quote
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTodayQuote().text,
                    style: AppTheme.bodyMedium(isDarkMode).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- ${_getTodayQuote().author} -',
                    style: AppTheme.bodySmall(isDarkMode).copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: (isDarkMode ? AppTheme.darkText : AppTheme.lightText)
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Hamburger menu
          IconButton(
            icon: Icon(
              Icons.menu,
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
            onPressed: () {
              _showSettingsMenu(context, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showAddPlannerItem(BuildContext context, DrawingProvider provider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedSubject;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '새 계획 추가',
                style: AppTheme.heading2(provider.isDarkMode),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // Title field
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '할 일을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Description field
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  hintText: '세부 내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Subject selector
              Text('과목', style: AppTheme.bodyMedium(provider.isDarkMode)),
              const SizedBox(height: AppTheme.spaceSm),
              Wrap(
                spacing: AppTheme.spaceSm,
                children: ['수학', '영어', '국어', '과학', '사회', '기타'].map((subject) {
                  return ChoiceChip(
                    label: Text(subject),
                    selected: selectedSubject == subject,
                    onSelected: (selected) {
                      setState(() {
                        selectedSubject = selected ? subject : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      provider.plannerManager.createTodo(
                        title: titleController.text.trim(),
                        dueDate: DateTime.now(),
                        priority: Priority.medium,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('추가'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlannerList(BuildContext context, DrawingProvider provider, bool isDarkMode) {
    final plannerItems = provider.plannerManager.todayTodos;

    if (plannerItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '오늘의 계획이 없습니다',
              style: AppTheme.heading3(isDarkMode),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 계획을 추가해보세요!',
              style: AppTheme.bodyMedium(isDarkMode).copyWith(
                color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      itemCount: plannerItems.length,
      itemBuilder: (context, index) {
        final item = plannerItems[index];
        return _buildPlannerCard(context, provider, item, isDarkMode);
      },
    );
  }

  Widget _buildPlannerCard(
    BuildContext context,
    DrawingProvider provider,
    TodoItem item,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: AppTheme.containerDecoration(isDarkMode),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to linked note if exists
            if (item.linkedNoteId != null) {
              provider.switchToNote(item.linkedNoteId!);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CanvasScreen()),
              );
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () async {
                    await hapticService.toggle();
                    provider.plannerManager.toggleComplete(item.id);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.isCompleted ? AppTheme.success : AppTheme.primary,
                        width: 2,
                      ),
                      color: item.isCompleted ? AppTheme.success : Colors.transparent,
                    ),
                    child: item.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),

                const SizedBox(width: AppTheme.spaceMd),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTheme.bodyLarge(isDarkMode).copyWith(
                          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                          color: item.isCompleted
                              ? (isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          await hapticService.selectionChanged();

          if (index == 1) {
            // Navigate to notes list
            context.pushSlideRight(const NotesListScreen());
          } else if (index == 2) {
            // Navigate to wrong answer notes
            context.pushSlideRight(const WrongAnswerScreen());
          } else if (index == 3) {
            // Navigate to stats
            context.pushSlideRight(const StatsScreen());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '오늘의 계획',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: '노트 탐색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            activeIcon: Icon(Icons.error),
            label: '오답 노트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotes(BuildContext context, DrawingProvider provider, bool isDarkMode) {
    // Filter notes modified within the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentNotes = provider.noteService.allNotes
        .where((note) => note.modifiedAt.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt)); // Most recent first

    final displayNotes = recentNotes.take(5).toList();

    if (displayNotes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          decoration: AppTheme.containerDecoration(isDarkMode),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.note_add_outlined,
                  size: 48,
                  color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  '최근 30일 내에 수정한 노트가 없습니다',
                  style: AppTheme.bodyMedium(isDarkMode).copyWith(
                    color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200, // Increased height for better thumbnails
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
        scrollDirection: Axis.horizontal,
        itemCount: displayNotes.length,
        itemBuilder: (context, index) {
          final note = displayNotes[index];
          return GestureDetector(
            onTap: () async {
              await hapticService.medium();
              provider.switchToNote(note.id);
              if (mounted) {
                context.pushSlideUp(const CanvasScreen());
              }
            },
            child: Container(
              width: 180,
              height: 195, // Explicit height constraint
              margin: EdgeInsets.only(right: index < displayNotes.length - 1 ? AppTheme.spaceMd : 0),
              clipBehavior: Clip.hardEdge, // Clip overflow
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowMd(isDarkMode),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Note preview/thumbnail
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getGradientColors(note.template),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(
                              _getNoteIcon(note.template),
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Content info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Template icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getNoteIcon(note.template),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              // Stats
                              Row(
                                children: [
                                  if (note.totalStrokes > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.edit, color: Colors.white, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${note.totalStrokes}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (note.isFavorite) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.favorite, color: Colors.white, size: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Note info
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            note.title,
                            style: AppTheme.bodyLarge(isDarkMode).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: isDarkMode
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  note.lastModifiedString,
                                  style: AppTheme.bodySmall(isDarkMode).copyWith(
                                    color: isDarkMode
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  List<Color> _getGradientColors(NoteTemplate template) {
    switch (template) {
      case NoteTemplate.blank:
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
      case NoteTemplate.lined:
        return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)];
      case NoteTemplate.grid:
        return [const Color(0xFFFA709A), const Color(0xFFFEE140)];
      case NoteTemplate.dots:
        return [const Color(0xFF30CFD0), const Color(0xFF330867)];
      case NoteTemplate.cornell:
        return [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)];
      case NoteTemplate.music:
        return [const Color(0xFFFF9A9E), const Color(0xFFFECAB6)];
    }
  }

  IconData _getNoteIcon(NoteTemplate template) {
    return switch (template) {
      NoteTemplate.blank => Icons.note,
      NoteTemplate.lined => Icons.subject,
      NoteTemplate.grid => Icons.grid_on,
      NoteTemplate.dots => Icons.scatter_plot,
      NoteTemplate.cornell => Icons.view_sidebar,
      NoteTemplate.music => Icons.music_note,
    };
  }

  void _showSettingsMenu(BuildContext context, DrawingProvider provider) {
    final isDarkMode = provider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('설정', style: AppTheme.heading2(isDarkMode)),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Theme settings
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.palette, color: AppTheme.primary),
              ),
              title: const Text('테마 설정'),
              subtitle: Text(
                _getThemeName(provider.settings.themeType),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showThemeSelector(context, provider);
              },
            ),

            // Font settings
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.font_download, color: Color(0xFF34C759)),
              ),
              title: const Text('폰트 설정'),
              subtitle: Text(
                provider.settings.customFontFamily ?? '기본 폰트 (SF Pro)',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FontSettingsScreen()),
                );
              },
            ),

            // Note settings
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.note, color: Color(0xFFFF9500)),
              ),
              title: const Text('노트 설정'),
              subtitle: const Text(
                '템플릿, 배경, 페이지 설정',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BackgroundSettingsScreen()),
                );
              },
            ),

            // App settings
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E5CE6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: Color(0xFF5E5CE6)),
              ),
              title: const Text('앱 설정'),
              subtitle: const Text(
                '펜 도구, 손바닥 거부, 자동 레이어',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),

            // Gesture guide
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.touch_app, color: Color(0xFFFF3B30)),
              ),
              title: const Text('제스처 가이드'),
              subtitle: const Text(
                '앱 사용법 보기',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GestureGuideScreen()),
                );
              },
            ),

            const SizedBox(height: AppTheme.spaceMd),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.ivory:
        return '아이보리';
      case AppThemeType.pastelPink:
        return '파스텔 핑크';
      case AppThemeType.pastelBlue:
        return '파스텔 블루';
      case AppThemeType.pastelGreen:
        return '파스텔 그린';
      case AppThemeType.minimalist:
        return '미니멀';
      case AppThemeType.darkMode:
        return '다크 모드';
    }
  }

  void _showThemeSelector(BuildContext context, DrawingProvider provider) {
    final isDarkMode = provider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('테마 선택', style: AppTheme.heading2(isDarkMode)),
            const SizedBox(height: AppTheme.spaceLg),

            Wrap(
              spacing: AppTheme.spaceMd,
              runSpacing: AppTheme.spaceMd,
              children: [
                _buildThemeOption(context, provider, AppThemeType.ivory, '아이보리', const Color(0xFFFFFAF0)),
                _buildThemeOption(context, provider, AppThemeType.pastelPink, '파스텔 핑크', const Color(0xFFFFF0F5)),
                _buildThemeOption(context, provider, AppThemeType.pastelBlue, '파스텔 블루', const Color(0xFFF0F8FF)),
                _buildThemeOption(context, provider, AppThemeType.pastelGreen, '파스텔 그린', const Color(0xFFF0FFF0)),
                _buildThemeOption(context, provider, AppThemeType.minimalist, '미니멀', Colors.white),
                _buildThemeOption(context, provider, AppThemeType.darkMode, '다크 모드', const Color(0xFF1E1E1E)),
              ],
            ),

            const SizedBox(height: AppTheme.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    DrawingProvider provider,
    AppThemeType themeType,
    String name,
    Color color,
  ) {
    final isSelected = provider.settings.themeType == themeType;

    return GestureDetector(
      onTap: () {
        provider.setThemeType(themeType);
        Navigator.pop(context);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: themeType == AppThemeType.darkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
