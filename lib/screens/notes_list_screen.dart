import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/note.dart';
import '../utils/responsive_util.dart';

/// Notes list screen showing all notes with inbox and organized sections
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  String _searchQuery = '';
  bool _showInboxOnly = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isTabletDevice = ResponsiveUtil.isTablet(context);
        final isDarkMode = provider.isDarkMode;

        List<Note> notesToShow;
        if (_searchQuery.isNotEmpty) {
          notesToShow = provider.noteService.searchNotes(_searchQuery);
        } else if (_showInboxOnly) {
          notesToShow = provider.noteService.inboxNotes;
        } else {
          notesToShow = provider.noteService.allNotes;
        }

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          appBar: AppBar(
            title: const Text(
              '모든 노트',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_showInboxOnly ? Icons.all_inbox : Icons.inbox),
                onPressed: () {
                  setState(() {
                    _showInboxOnly = !_showInboxOnly;
                  });
                },
                tooltip: _showInboxOnly ? '모든 노트 보기' : 'Inbox만 보기',
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(isTabletDevice ? 24 : 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF404040)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: '노트 검색...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),

              // Notes count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showInboxOnly
                          ? 'Inbox (${provider.noteService.inboxNotes.length})'
                          : '전체 (${notesToShow.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    if (!_showInboxOnly && provider.noteService.inboxNotes.isNotEmpty)
                      Text(
                        '정리 필요: ${provider.noteService.inboxNotes.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notes list
              Expanded(
                child: notesToShow.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              size: 80,
                              color: isDarkMode ? Colors.white24 : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? '검색 결과가 없습니다'
                                  : '아직 노트가 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(isTabletDevice ? 24 : 16),
                        itemCount: notesToShow.length,
                        itemBuilder: (context, index) {
                          final note = notesToShow[index];
                          final isCurrentNote =
                              provider.noteService.currentNote?.id == note.id;

                          return _buildNoteCard(
                            context,
                            provider,
                            note,
                            isCurrentNote,
                            isDarkMode,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    DrawingProvider provider,
    Note note,
    bool isCurrentNote,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentNote
              ? const Color(0xFF667EEA)
              : (isDarkMode
                  ? const Color(0xFF404040)
                  : const Color(0xFFE0E0E0)),
          width: isCurrentNote ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTemplateIcon(note.template),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          note.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              note.lastModifiedString,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: note.tags.map((tag) => _buildTag(tag, isDarkMode)).toList(),
              ),
            ],
            if (note.totalStrokes > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${note.totalStrokes} 획',
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentNote)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '현재',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('제목 변경'),
                    ],
                  ),
                  onTap: () => _showRenameDialog(context, provider, note),
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.label, size: 18),
                      SizedBox(width: 8),
                      Text('태그 추가'),
                    ],
                  ),
                  onTap: () => _showAddTagsDialog(context, provider, note),
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () => _confirmDelete(context, provider, note),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          provider.switchToNote(note.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildTag(String tag, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF667EEA).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF667EEA),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getTemplateIcon(NoteTemplate template) {
    switch (template) {
      case NoteTemplate.blank:
        return Icons.note;
      case NoteTemplate.lined:
        return Icons.subject;
      case NoteTemplate.grid:
        return Icons.grid_on;
      case NoteTemplate.dots:
        return Icons.scatter_plot;
      case NoteTemplate.cornell:
        return Icons.view_sidebar;
      case NoteTemplate.music:
        return Icons.music_note;
    }
  }

  void _showRenameDialog(BuildContext context, DrawingProvider provider, Note note) {
    // Delay to allow popup menu to close first
    Future.delayed(const Duration(milliseconds: 100), () {
      final controller = TextEditingController(text: note.title);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('노트 제목 변경'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '새 제목 입력...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.noteService.updateNoteTitle(note.id, controller.text.trim());
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('변경'),
            ),
          ],
        ),
      );
    });
  }

  void _showAddTagsDialog(BuildContext context, DrawingProvider provider, Note note) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final controller = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('태그 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '태그 입력 (쉼표로 구분)...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (note.tags.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('현재 태그:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: note.tags
                      .map((tag) => _buildTag(tag, provider.isDarkMode))
                      .toList(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final tags = controller.text
                      .split(',')
                      .map((t) => t.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();

                  provider.noteService.addTagsToNote(note.id, tags);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, DrawingProvider provider, Note note) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('노트 삭제'),
          content: Text('정말로 "${note.title}"를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.noteService.deleteNote(note.id);
                setState(() {});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        ),
      );
    });
  }
}
