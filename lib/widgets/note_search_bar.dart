import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/note_search_service.dart';
import '../utils/responsive_util.dart';

/// Advanced search bar with filters for notes
class NoteSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String query) onSearch;
  final Function({
    String? subject,
    String? category,
    List<String>? tags,
    bool? isFavorite,
    NoteSortBy? sortBy,
  })? onFilterChanged;
  final List<String> availableSubjects;
  final List<String> availableCategories;
  final List<String> availableTags;

  const NoteSearchBar({
    Key? key,
    this.initialQuery,
    required this.onSearch,
    this.onFilterChanged,
    this.availableSubjects = const [],
    this.availableCategories = const [],
    this.availableTags = const [],
  }) : super(key: key);

  @override
  State<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends State<NoteSearchBar> {
  late TextEditingController _searchController;
  bool _showFilters = false;
  String? _selectedSubject;
  String? _selectedCategory;
  List<String> _selectedTags = [];
  bool? _filterFavorite;
  NoteSortBy _sortBy = NoteSortBy.modifiedDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged?.call(
      subject: _selectedSubject,
      category: _selectedCategory,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
      isFavorite: _filterFavorite,
      sortBy: _sortBy,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedCategory = null;
      _selectedTags = [];
      _filterFavorite = null;
      _sortBy = NoteSortBy.modifiedDate;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);

    return Column(
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: isTablet ? 20 : 16),
                      child: Icon(
                        Icons.search,
                        color: Colors.black54,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: widget.onSearch,
                        decoration: InputDecoration(
                          hintText: '노트 검색... (제목, 태그, 내용)',
                          hintStyle: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.black38,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 16 : 12,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                    // Clear button
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                        },
                      ),
                    // Filter toggle button
                    IconButton(
                      icon: Icon(
                        _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                        color: _hasActiveFilters()
                            ? const Color(0xFF667EEA)
                            : Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Filter panel
        if (_showFilters)
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '필터',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('초기화'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subject filter
                if (widget.availableSubjects.isNotEmpty) ...[
                  Text(
                    '과목',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final subject in widget.availableSubjects)
                        FilterChip(
                          label: Text(subject),
                          selected: _selectedSubject == subject,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSubject = selected ? subject : null;
                            });
                            _applyFilters();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Favorite filter
                Row(
                  children: [
                    Checkbox(
                      value: _filterFavorite == true,
                      onChanged: (value) {
                        setState(() {
                          _filterFavorite = value == true ? true : null;
                        });
                        _applyFilters();
                      },
                    ),
                    const Text('즐겨찾기만 보기'),
                  ],
                ),
                const SizedBox(height: 16),

                // Sort by
                Text(
                  '정렬',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('최근 수정'),
                      selected: _sortBy == NoteSortBy.modifiedDate,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = NoteSortBy.modifiedDate;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('생성일'),
                      selected: _sortBy == NoteSortBy.createdDate,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = NoteSortBy.createdDate;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('제목'),
                      selected: _sortBy == NoteSortBy.title,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = NoteSortBy.title;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('학습 횟수'),
                      selected: _sortBy == NoteSortBy.studyCount,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = NoteSortBy.studyCount;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _selectedSubject != null ||
        _selectedCategory != null ||
        _selectedTags.isNotEmpty ||
        _filterFavorite != null ||
        _sortBy != NoteSortBy.modifiedDate;
  }
}
