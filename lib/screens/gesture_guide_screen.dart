import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../widgets/common/animated_widgets.dart';

/// Gesture guide overlay for first-time users
/// Shows essential gestures for note-taking app
class GestureGuideScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const GestureGuideScreen({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  /// Check if guide has been shown before
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('gesture_guide_shown') ?? false);
  }

  /// Mark guide as shown
  static Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gesture_guide_shown', true);
  }

  @override
  State<GestureGuideScreen> createState() => _GestureGuideScreenState();
}

class _GestureGuideScreenState extends State<GestureGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<GestureGuideItem> _guides = [
    GestureGuideItem(
      icon: Icons.edit,
      title: 'S펜/Apple Pencil로 필기',
      description: '펜으로 화면을 터치하면 자동으로 인식됩니다.\n압력 감지로 자연스러운 필기를 경험하세요.',
      gesture: '✍️ 펜으로 그리기',
    ),
    GestureGuideItem(
      icon: Icons.zoom_in,
      title: '확대/축소',
      description: '두 손가락으로 핀치하여 캔버스를 확대하거나 축소할 수 있습니다.',
      gesture: '🤏 두 손가락 핀치',
    ),
    GestureGuideItem(
      icon: Icons.pan_tool,
      title: '캔버스 이동',
      description: '두 손가락으로 드래그하여 캔버스를 자유롭게 이동할 수 있습니다.',
      gesture: '👆👆 두 손가락 드래그',
    ),
    GestureGuideItem(
      icon: Icons.undo,
      title: '실행 취소/다시 실행',
      description: '상단 툴바의 버튼을 눌러 실행 취소하거나 다시 실행할 수 있습니다.',
      gesture: '↩️ 실행 취소',
    ),
    GestureGuideItem(
      icon: Icons.palette,
      title: '펜 도구',
      description: '다양한 펜 도구와 색상을 선택하여\n나만의 스타일로 필기하세요.',
      gesture: '🎨 도구 선택',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _guides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _skip() {
    _complete();
  }

  Future<void> _complete() async {
    await GestureGuideScreen.markAsShown();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: SafeArea(
        child: Stack(
          children: [
            // Page view
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _guides.length,
              itemBuilder: (context, index) {
                return _buildGuidePage(_guides[index], index);
              },
            ),

            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: FadeInWidget(
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('건너뛰기'),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _guides.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next/Done button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ScaleInWidget(
                        delay: const Duration(milliseconds: 600),
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            _currentPage == _guides.length - 1
                                ? '시작하기'
                                : '다음',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidePage(GestureGuideItem item, int index) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          ScaleInWidget(
            delay: Duration(milliseconds: 200 + (index * 50)),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: 60,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          SlideInWidget(
            delay: Duration(milliseconds: 300 + (index * 50)),
            begin: const Offset(0, 0.2),
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          SlideInWidget(
            delay: Duration(milliseconds: 400 + (index * 50)),
            begin: const Offset(0, 0.2),
            child: Text(
              item.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Gesture hint
          ScaleInWidget(
            delay: Duration(milliseconds: 500 + (index * 50)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                item.gesture,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Gesture guide item model
class GestureGuideItem {
  final IconData icon;
  final String title;
  final String description;
  final String gesture;

  const GestureGuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gesture,
  });
}
