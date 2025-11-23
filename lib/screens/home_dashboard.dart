import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/app_theme.dart';
import '../utils/page_routes.dart';
import '../models/planner.dart';
import '../models/app_settings.dart';
import '../widgets/study_timer_widget.dart' hide TodayStudyCard;
import '../widgets/today_study_card.dart';
import '../services/haptic_service.dart';
import 'canvas_screen.dart';
import 'notes_list_screen.dart';
import 'stats_screen.dart';
import 'font_settings_screen.dart';
import 'gesture_guide_screen.dart';

/// Home dashboard with planner-centric design
/// "Gong-stagram" aesthetic: minimal, clean, motivating
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool _performanceInitialized = false;

  // Inspirational quotes
  static const List<String> _quotes = [
    '오늘도 화이팅!',
    '작은 진전도 진전입니다',
    '꾸준함이 재능을 이긴다',
    '오늘의 노력이 내일의 결과',
    '할 수 있다고 믿으면 이미 반은 성공',
    '포기하지 않는 한 실패는 없다',
    '지금 이 순간에 집중하세요',
    '당신은 생각보다 강합니다',
    '매일 조금씩 성장하고 있어요',
    '완벽하지 않아도 괜찮아요',
    '시작이 반이다',
    '노력은 배신하지 않습니다',
  ];

  String _getTodayQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
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
              const SizedBox(height: 4),
              Text(
                _getTodayQuote(),
                style: AppTheme.heading1(isDarkMode),
              ),
            ],
          ),
          // Settings button
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
            onPressed: () {
              // Navigate to settings
              _showThemeSelector(context, provider);
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

  void _showThemeSelector(BuildContext context, DrawingProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('설정', style: AppTheme.heading2(provider.isDarkMode)),
            const SizedBox(height: AppTheme.spaceLg),

            // Font settings button
            ListTile(
              leading: const Icon(Icons.font_download),
              title: const Text('폰트 설정'),
              subtitle: Text(
                provider.settings.customFontFamily ?? '기본 폰트 (SF Pro)',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FontSettingsScreen()),
                );
              },
            ),

            const Divider(),

            Text('테마 선택', style: AppTheme.heading3(provider.isDarkMode)),
            const SizedBox(height: AppTheme.spaceMd),
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
