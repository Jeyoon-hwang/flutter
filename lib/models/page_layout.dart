import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Page size standards for note layouts
enum PageSize {
  a4,           // 210 x 297 mm
  letter,       // 8.5 x 11 inches (216 x 279 mm)
  a5,           // 148 x 210 mm
  legal,        // 8.5 x 14 inches (216 x 356 mm)
  infinite,     // Unlimited size (current behavior)
}

/// Page orientation
enum PageOrientation {
  portrait,
  landscape,
}

/// Represents a single page in the note
class NotePage {
  final String id;
  final int pageNumber;
  final PageSize size;
  final PageOrientation orientation;

  /// Offset from the top of the canvas
  final double yOffset;

  NotePage({
    required this.id,
    required this.pageNumber,
    required this.size,
    required this.orientation,
    required this.yOffset,
  });

  /// Get page dimensions in pixels (at 96 DPI)
  Size get dimensions {
    final (width, height) = _getDimensionsInMm();

    // Convert mm to pixels at 96 DPI
    // 1 inch = 96 pixels, 1 inch = 25.4 mm
    // So: pixels = (mm / 25.4) * 96 = mm * 3.7795
    final pixelsPerMm = 96.0 / 25.4;

    double pixelWidth = width * pixelsPerMm;
    double pixelHeight = height * pixelsPerMm;

    if (orientation == PageOrientation.landscape) {
      return Size(pixelHeight, pixelWidth);
    }

    return Size(pixelWidth, pixelHeight);
  }

  /// Get dimensions in millimeters (width, height)
  (double, double) _getDimensionsInMm() {
    switch (size) {
      case PageSize.a4:
        return (210.0, 297.0);
      case PageSize.letter:
        return (215.9, 279.4);
      case PageSize.a5:
        return (148.0, 210.0);
      case PageSize.legal:
        return (215.9, 355.6);
      case PageSize.infinite:
        return (10000.0, 10000.0); // Very large
    }
  }

  /// Get bounds (Rect) for this page
  Rect get bounds {
    final size = dimensions;
    return Rect.fromLTWH(0, yOffset, size.width, size.height);
  }

  /// Check if a point is within this page
  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  NotePage copyWith({
    String? id,
    int? pageNumber,
    PageSize? size,
    PageOrientation? orientation,
    double? yOffset,
  }) {
    return NotePage(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      size: size ?? this.size,
      orientation: orientation ?? this.orientation,
      yOffset: yOffset ?? this.yOffset,
    );
  }

  /// Get user-friendly page size name in Korean
  static String getPageSizeName(PageSize size) {
    switch (size) {
      case PageSize.a4:
        return 'A4 (210×297mm)';
      case PageSize.letter:
        return 'Letter (8.5×11")';
      case PageSize.a5:
        return 'A5 (148×210mm)';
      case PageSize.legal:
        return 'Legal (8.5×14")';
      case PageSize.infinite:
        return '무한 캔버스';
    }
  }

  /// Get icon for page size
  static IconData getPageSizeIcon(PageSize size) {
    switch (size) {
      case PageSize.a4:
      case PageSize.letter:
      case PageSize.a5:
      case PageSize.legal:
        return Icons.description;
      case PageSize.infinite:
        return Icons.all_inclusive;
    }
  }
}

/// Manages multiple pages in a note
class PageManager extends ChangeNotifier {
  final List<NotePage> _pages = [];
  int _currentPageIndex = 0;
  PageSize _defaultPageSize = PageSize.a4;
  PageOrientation _defaultOrientation = PageOrientation.portrait;

  // Spacing between pages in pixels
  static const double pageSpacing = 40.0;

  /// Get all pages
  List<NotePage> get pages => List.unmodifiable(_pages);

  /// Get current page
  NotePage get currentPage => _pages[_currentPageIndex];

  /// Get current page index
  int get currentPageIndex => _currentPageIndex;

  /// Total number of pages
  int get pageCount => _pages.length;

  /// Default page size
  PageSize get defaultPageSize => _defaultPageSize;

  /// Default orientation
  PageOrientation get defaultOrientation => _defaultOrientation;

  /// Initialize with one page
  PageManager({
    PageSize initialPageSize = PageSize.a4,
    PageOrientation initialOrientation = PageOrientation.portrait,
  }) {
    _defaultPageSize = initialPageSize;
    _defaultOrientation = initialOrientation;

    // Create first page
    if (_pages.isEmpty) {
      _addPage();
    }
  }

  /// Add a new page at the end
  void addPage() {
    _addPage();
    notifyListeners();
  }

  void _addPage() {
    final pageNumber = _pages.length + 1;
    final yOffset = _calculateYOffset();

    _pages.add(NotePage(
      id: 'page_${DateTime.now().millisecondsSinceEpoch}_$pageNumber',
      pageNumber: pageNumber,
      size: _defaultPageSize,
      orientation: _defaultOrientation,
      yOffset: yOffset,
    ));
  }

  /// Calculate Y offset for a new page
  double _calculateYOffset() {
    if (_pages.isEmpty) return 0;

    final lastPage = _pages.last;
    return lastPage.yOffset + lastPage.dimensions.height + pageSpacing;
  }

  /// Get page at specific index
  NotePage? getPage(int index) {
    if (index >= 0 && index < _pages.length) {
      return _pages[index];
    }
    return null;
  }

  /// Find which page contains a specific point
  NotePage? getPageAtPoint(Offset point) {
    for (final page in _pages) {
      if (page.containsPoint(point)) {
        return page;
      }
    }
    return null;
  }

  /// Navigate to a specific page
  void goToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to next page
  void nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _currentPageIndex++;
      notifyListeners();
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }

  /// Delete a page (can't delete if only one page remains)
  void deletePage(int index) {
    if (index >= 0 && index < _pages.length && _pages.length > 1) {
      _pages.removeAt(index);

      // Recalculate offsets and page numbers
      _recalculatePagePositions();

      // Adjust current page index
      if (_currentPageIndex >= _pages.length) {
        _currentPageIndex = _pages.length - 1;
      }

      notifyListeners();
    }
  }

  /// Recalculate page positions after deletion or reordering
  void _recalculatePagePositions() {
    double currentOffset = 0;

    for (int i = 0; i < _pages.length; i++) {
      _pages[i] = _pages[i].copyWith(
        pageNumber: i + 1,
        yOffset: currentOffset,
      );

      currentOffset += _pages[i].dimensions.height + pageSpacing;
    }
  }

  /// Change default page size
  void setDefaultPageSize(PageSize size) {
    _defaultPageSize = size;
    notifyListeners();
  }

  /// Change default orientation
  void setDefaultOrientation(PageOrientation orientation) {
    _defaultOrientation = orientation;
    notifyListeners();
  }

  /// Get total canvas height
  double get totalCanvasHeight {
    if (_pages.isEmpty) return 0;

    final lastPage = _pages.last;
    return lastPage.yOffset + lastPage.dimensions.height;
  }

  /// Auto-add pages if drawing goes beyond current pages
  void autoAddPagesForPoint(Offset point) {
    // Check if point is beyond the last page
    if (_pages.isEmpty) {
      _addPage();
      return;
    }

    final lastPage = _pages.last;
    final lastPageBottom = lastPage.yOffset + lastPage.dimensions.height;

    // If point is below the last page, add new pages
    if (point.dy > lastPageBottom) {
      // Calculate how many pages we need
      final pagesNeeded = ((point.dy - lastPageBottom) / (lastPage.dimensions.height + pageSpacing)).ceil() + 1;

      for (int i = 0; i < pagesNeeded; i++) {
        _addPage();
      }

      notifyListeners();
    }
  }
}
