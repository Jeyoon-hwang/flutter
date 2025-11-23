import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/responsive_util.dart';

/// Page thumbnail navigator for multi-page notes
/// Shows thumbnails of all pages for easy navigation
class PageThumbnailNavigator extends StatefulWidget {
  const PageThumbnailNavigator({Key? key}) : super(key: key);

  @override
  State<PageThumbnailNavigator> createState() => _PageThumbnailNavigatorState();
}

class _PageThumbnailNavigatorState extends State<PageThumbnailNavigator> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isTablet = ResponsiveUtil.isTablet(context);
        final isDarkMode = provider.isDarkMode;
        final pages = provider.pageManager.pages;
        final currentPageIndex = provider.pageManager.currentPageIndex;

        // Don't show if only one page
        if (pages.length <= 1) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: isTablet ? 20 : 16,
          bottom: isTablet ? 100 : 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 12 : 10,
                      ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isExpanded ? Icons.close : Icons.library_books,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currentPageIndex + 1}/${pages.length}',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Page thumbnails
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: isTablet ? 200 : 160,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_stories,
                                    size: isTablet ? 20 : 18,
                                    color: const Color(0xFF667EEA),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '페이지',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Divider(
                              height: 1,
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),

                            // Page list
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(12),
                                itemCount: pages.length,
                                itemBuilder: (context, index) {
                                  final page = pages[index];
                                  final isCurrentPage = index == currentPageIndex;

                                  return GestureDetector(
                                    onTap: () {
                                      provider.pageManager.goToPage(index);
                                      setState(() {
                                        _isExpanded = false;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isCurrentPage
                                            ? const Color(0xFF667EEA)
                                                .withValues(alpha: 0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isCurrentPage
                                            ? Border.all(
                                                color: const Color(0xFF667EEA),
                                                width: 2,
                                              )
                                            : Border.all(
                                                color: isDarkMode
                                                    ? Colors.white
                                                        .withValues(alpha: 0.1)
                                                    : Colors.black
                                                        .withValues(alpha: 0.1),
                                                width: 1,
                                              ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Page preview placeholder (미래 개선: 실제 썸네일)
                                          AspectRatio(
                                            aspectRatio: page.bounds.width /
                                                page.bounds.height,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Colors.white
                                                        .withValues(alpha: 0.05)
                                                    : Colors.black
                                                        .withValues(alpha: 0.03),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isDarkMode
                                                      ? Colors.white.withValues(
                                                          alpha: 0.1)
                                                      : Colors.black.withValues(
                                                          alpha: 0.1),
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.description_outlined,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                          .withValues(alpha: 0.3)
                                                      : Colors.black
                                                          .withValues(alpha: 0.3),
                                                  size: isTablet ? 32 : 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Page info
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '페이지 ${index + 1}',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 13 : 12,
                                                  fontWeight: isCurrentPage
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (isCurrentPage)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF667EEA),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    '현재',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Add page button
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  provider.pageManager.addPage();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('새 페이지'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667EEA),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
