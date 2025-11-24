import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/page_layout.dart';
import '../screens/home_dashboard.dart';

/// Page navigation widget for switching between pages (HORIZONTAL LAYOUT)
class PageNavigation extends StatefulWidget {
  final Function(bool)? onVersionControlToggle;
  final bool showVersionControl;

  const PageNavigation({
    Key? key,
    this.onVersionControlToggle,
    this.showVersionControl = false,
  }) : super(key: key);

  @override
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {
  Offset _position = const Offset(20, 0); // Will be calculated in build

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Initialize position on first build
    if (_position == const Offset(20, 0)) {
      _position = Offset(20, screenSize.height - 100);
    }

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Hide in focus mode
        if (provider.focusMode) {
          return const SizedBox.shrink();
        }

        final pageManager = provider.pageManager;
        if (pageManager.pageCount == 0) {
          return const SizedBox.shrink();
        }

        final isDarkMode = provider.isDarkMode;
        final currentPage = pageManager.currentPageIndex + 1;
        final totalPages = pageManager.pageCount;

        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: (details) {},
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(0.0, screenSize.width - 250),
                  (_position.dy + details.delta.dy).clamp(0.0, screenSize.height - 100),
                );
              });
            },
            onPanEnd: (details) {},
            child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            const Color(0xFF2A2A2A).withValues(alpha: 0.9),
                            const Color(0xFF1E1E1E).withValues(alpha: 0.9),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.85),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Home button
                    _NavButton(
                      icon: Icons.home,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeDashboard()),
                        );
                      },
                      isDarkMode: isDarkMode,
                      isEnabled: true,
                      isSpecial: true,
                    ),
                    const SizedBox(width: 8),

                    // Previous page button
                    _NavButton(
                      icon: Icons.keyboard_arrow_left,
                      onTap: pageManager.currentPageIndex > 0
                          ? () => provider.pageManager.previousPage()
                          : null,
                      isDarkMode: isDarkMode,
                      isEnabled: pageManager.currentPageIndex > 0,
                    ),
                    const SizedBox(width: 8),

                    // Page indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$currentPage/$totalPages',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Next page button
                    _NavButton(
                      icon: Icons.keyboard_arrow_right,
                      onTap: pageManager.currentPageIndex < totalPages - 1
                          ? () => provider.pageManager.nextPage()
                          : null,
                      isDarkMode: isDarkMode,
                      isEnabled: pageManager.currentPageIndex < totalPages - 1,
                    ),

                    const SizedBox(width: 12),
                    // Divider
                    Container(
                      width: 1,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDarkMode
                              ? [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0),
                                ]
                              : [
                                  Colors.black.withValues(alpha: 0),
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0),
                                ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add page button
                    _NavButton(
                      icon: Icons.add,
                      onTap: () => provider.addNewPage(),
                      isDarkMode: isDarkMode,
                      isEnabled: true,
                    ),

                    // Page menu button
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: Icons.more_horiz,
                      onTap: () => _showPageMenu(context, provider),
                      isDarkMode: isDarkMode,
                      isEnabled: true,
                    ),

                    // Version control button
                    if (provider.noteService.currentNote != null) ...[
                      const SizedBox(width: 8),
                      _VersionControlButton(
                        versionCount: provider.versionManager
                            .getVersions(provider.noteService.currentNote!.id)
                            .length,
                        isActive: widget.showVersionControl,
                        onTap: () {
                          if (widget.onVersionControlToggle != null) {
                            widget.onVersionControlToggle!(!widget.showVersionControl);
                          }
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  void _showPageMenu(BuildContext context, DrawingProvider provider) {
    final isDarkMode = provider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '페이지 설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),

            // Page size selector
            _buildPageSizeOption(context, provider, isDarkMode, PageSize.a4),
            _buildPageSizeOption(context, provider, isDarkMode, PageSize.letter),
            _buildPageSizeOption(context, provider, isDarkMode, PageSize.a5),
            _buildPageSizeOption(context, provider, isDarkMode, PageSize.legal),
            _buildPageSizeOption(context, provider, isDarkMode, PageSize.infinite),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSizeOption(
    BuildContext context,
    DrawingProvider provider,
    bool isDarkMode,
    PageSize size,
  ) {
    final isSelected = provider.pageManager.defaultPageSize == size;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withValues(alpha: 0.15)
              : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          NotePage.getPageSizeIcon(size),
          color: isSelected
              ? const Color(0xFF667EEA)
              : (isDarkMode ? Colors.white70 : Colors.black54),
          size: 24,
        ),
      ),
      title: Text(
        NotePage.getPageSizeName(size),
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? const Color(0xFF667EEA)
              : (isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF667EEA))
          : null,
      onTap: () {
        provider.pageManager.setDefaultPageSize(size);
        Navigator.pop(context);
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final bool isEnabled;
  final bool isSpecial;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.isDarkMode,
    required this.isEnabled,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.3,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: isSpecial
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: isSpecial
                ? null
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSpecial
                  ? Colors.transparent
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05)),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSpecial
                ? Colors.white
                : (isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}

class _VersionControlButton extends StatelessWidget {
  final int versionCount;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _VersionControlButton({
    required this.versionCount,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF667EEA).withValues(alpha: 0.2)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF667EEA)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_tree,
              size: 18,
              color: isActive
                  ? const Color(0xFF667EEA)
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 6),
            Text(
              '$versionCount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFF667EEA)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
