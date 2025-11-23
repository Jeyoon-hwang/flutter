import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/wrong_answer_screen.dart';
import '../screens/home_dashboard.dart';
import '../screens/notes_list_screen.dart';
import '../utils/responsive_util.dart';

/// Hamburger menu for unified access to all features and settings
class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({Key? key}) : super(key: key);

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;

        return Positioned(
          top: isTablet ? 20 : 16,
          left: isTablet ? 20 : 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hamburger button
              GestureDetector(
                onTap: _toggleMenu,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: isTablet ? 56 : 48,
                      height: isTablet ? 56 : 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.black.withValues(alpha: 0.5),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isExpanded ? Icons.close : Icons.menu,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Expanded menu
              if (_isExpanded)
                SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: isTablet ? 280 : 240,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      Colors.black.withValues(alpha: 0.9),
                                      Colors.black.withValues(alpha: 0.8),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.95),
                                      Colors.white.withValues(alpha: 0.9),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book,
                                      color: const Color(0xFF667EEA),
                                      size: isTablet ? 28 : 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '메뉴',
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Menu items
                              _MenuItem(
                                icon: Icons.home,
                                label: '홈',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeDashboard()),
                                  );
                                },
                              ),
                              _MenuItem(
                                icon: Icons.folder_open,
                                label: '노트 탐색',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotesListScreen()),
                                  );
                                  _toggleMenu();
                                },
                              ),
                              _MenuItem(
                                icon: Icons.bar_chart,
                                label: '학습 통계',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                                  );
                                  _toggleMenu();
                                },
                              ),
                              _MenuItem(
                                icon: Icons.assignment,
                                label: '오답 노트',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const WrongAnswerScreen()),
                                  );
                                  _toggleMenu();
                                },
                              ),

                              // Divider
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Divider(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.1),
                                ),
                              ),

                              // Panel toggles
                              _MenuItem(
                                icon: Icons.visibility,
                                label: '패널 표시/숨기기',
                                isDarkMode: isDarkMode,
                                isHeader: true,
                              ),
                              _MenuItem(
                                icon: Icons.layers,
                                label: '레이어 패널',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  // Toggle layer panel
                                },
                                compact: true,
                              ),
                              _MenuItem(
                                icon: Icons.category,
                                label: '도형 팔레트',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  // Toggle shape palette
                                },
                                compact: true,
                              ),

                              // Divider before settings
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Divider(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.1),
                                ),
                              ),

                              // Settings at bottom
                              _MenuItem(
                                icon: Icons.settings,
                                label: '설정',
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                  );
                                  _toggleMenu();
                                },
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final bool isHeader;
  final bool compact;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    this.onTap,
    this.isHeader = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHeader) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: compact ? 20 : 24,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.7),
              ),
              SizedBox(width: compact ? 12 : 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: compact ? FontWeight.normal : FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
