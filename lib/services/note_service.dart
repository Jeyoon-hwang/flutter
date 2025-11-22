import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../models/layer.dart';
import '../models/text_object.dart';

/// Service for managing notes - creation, storage, retrieval, auto-save
class NoteService extends ChangeNotifier {
  final List<Note> _allNotes = [];
  Note? _currentNote;
  bool _autoSaveEnabled = true;
  DateTime? _lastSaveTime;

  // Getters
  List<Note> get allNotes => _allNotes;
  Note? get currentNote => _currentNote;
  bool get autoSaveEnabled => _autoSaveEnabled;

  /// Get inbox notes (notes with default title or no tags)
  List<Note> get inboxNotes {
    return _allNotes.where((note) =>
      note.tags.isEmpty || note.title.startsWith('빠른 노트')
    ).toList();
  }

  /// Get organized notes (notes with tags and custom titles)
  List<Note> get organizedNotes {
    return _allNotes.where((note) =>
      note.tags.isNotEmpty && !note.title.startsWith('빠른 노트')
    ).toList();
  }

  /// Quick capture: Create a new note instantly without any prompts
  /// Returns the created note
  Note createQuickNote({
    NoteTemplate template = NoteTemplate.blank,
    Color? backgroundColor,
  }) {
    final now = DateTime.now();
    final quickNoteCount = inboxNotes.length + 1;

    final note = Note(
      id: 'note_${now.millisecondsSinceEpoch}',
      title: '빠른 노트 $quickNoteCount',
      createdAt: now,
      modifiedAt: now,
      template: template,
      backgroundColor: backgroundColor ?? Colors.white,
    );

    _allNotes.insert(0, note); // Add to front (most recent first)
    _currentNote = note;
    notifyListeners();

    // Auto-save to disk
    if (_autoSaveEnabled) {
      _autoSaveNote(note);
    }

    return note;
  }

  /// Create a note with specific parameters
  Note createNote({
    required String title,
    NoteTemplate template = NoteTemplate.blank,
    List<String> tags = const [],
    Color? backgroundColor,
    List<Layer>? layers,
    List<TextObject>? textObjects,
  }) {
    final now = DateTime.now();

    final note = Note(
      id: 'note_${now.millisecondsSinceEpoch}',
      title: title,
      createdAt: now,
      modifiedAt: now,
      template: template,
      backgroundColor: backgroundColor ?? Colors.white,
      tags: tags,
      layers: layers,
      textObjects: textObjects,
    );

    _allNotes.insert(0, note);
    _currentNote = note;
    notifyListeners();

    if (_autoSaveEnabled) {
      _autoSaveNote(note);
    }

    return note;
  }

  /// Switch to a different note
  void switchToNote(String noteId) {
    final note = _allNotes.firstWhere(
      (n) => n.id == noteId,
      orElse: () => throw Exception('Note not found: $noteId'),
    );

    _currentNote = note;
    notifyListeners();
  }

  /// Update current note with new data
  void updateCurrentNote({
    String? title,
    List<String>? tags,
    NoteTemplate? template,
    Color? backgroundColor,
    String? audioPath,
    String? pdfPath,
  }) {
    if (_currentNote == null) return;

    final index = _allNotes.indexWhere((n) => n.id == _currentNote!.id);
    if (index == -1) return;

    _allNotes[index] = _currentNote!.copyWith(
      title: title,
      modifiedAt: DateTime.now(),
      tags: tags,
      template: template,
      backgroundColor: backgroundColor,
      audioPath: audioPath,
      pdfPath: pdfPath,
    );

    _currentNote = _allNotes[index];
    notifyListeners();

    if (_autoSaveEnabled) {
      _autoSaveNote(_currentNote!);
    }
  }

  /// Update note's title (useful for organizing inbox notes)
  void updateNoteTitle(String noteId, String newTitle) {
    final index = _allNotes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    _allNotes[index].title = newTitle;
    _allNotes[index].modifiedAt = DateTime.now();

    if (_currentNote?.id == noteId) {
      _currentNote = _allNotes[index];
    }

    notifyListeners();

    if (_autoSaveEnabled) {
      _autoSaveNote(_allNotes[index]);
    }
  }

  /// Add tags to a note (for organizing)
  void addTagsToNote(String noteId, List<String> tags) {
    final index = _allNotes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    final existingTags = Set<String>.from(_allNotes[index].tags);
    existingTags.addAll(tags);
    _allNotes[index].tags = existingTags.toList();
    _allNotes[index].modifiedAt = DateTime.now();

    if (_currentNote?.id == noteId) {
      _currentNote = _allNotes[index];
    }

    notifyListeners();

    if (_autoSaveEnabled) {
      _autoSaveNote(_allNotes[index]);
    }
  }

  /// Delete a note
  void deleteNote(String noteId) {
    final index = _allNotes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    _allNotes.removeAt(index);

    if (_currentNote?.id == noteId) {
      _currentNote = _allNotes.isNotEmpty ? _allNotes.first : null;
    }

    notifyListeners();

    // Delete from disk
    _deleteNoteFromDisk(noteId);
  }

  /// Mark current note as modified (triggers auto-save)
  void markCurrentNoteAsModified() {
    if (_currentNote == null) return;

    final index = _allNotes.indexWhere((n) => n.id == _currentNote!.id);
    if (index == -1) return;

    _allNotes[index].modifiedAt = DateTime.now();
    _currentNote = _allNotes[index];

    notifyListeners();

    if (_autoSaveEnabled) {
      _autoSaveNote(_currentNote!);
    }
  }

  /// Toggle auto-save
  void toggleAutoSave() {
    _autoSaveEnabled = !_autoSaveEnabled;
    notifyListeners();
  }

  /// Auto-save note to disk with debouncing (1 second)
  Future<void> _autoSaveNote(Note note) async {
    final now = DateTime.now();

    // Debounce: Don't save if we saved less than 1 second ago
    if (_lastSaveTime != null &&
        now.difference(_lastSaveTime!).inSeconds < 1) {
      return;
    }

    _lastSaveTime = now;
    await saveNoteToDisk(note);
  }

  /// Save note to disk
  Future<void> saveNoteToDisk(Note note) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final notesDir = Directory('${directory.path}/notes');

      if (!await notesDir.exists()) {
        await notesDir.create(recursive: true);
      }

      final file = File('${notesDir.path}/${note.id}.json');
      final json = jsonEncode(note.toJson());
      await file.writeAsString(json);

      print('Note saved: ${note.id}');
    } catch (e) {
      print('Error saving note: $e');
    }
  }

  /// Load all notes from disk
  Future<void> loadNotesFromDisk() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final notesDir = Directory('${directory.path}/notes');

      if (!await notesDir.exists()) {
        return;
      }

      final files = notesDir.listSync();
      _allNotes.clear();

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final json = await file.readAsString();
            final noteData = jsonDecode(json);
            final note = Note.fromJson(noteData);
            _allNotes.add(note);
          } catch (e) {
            print('Error loading note ${file.path}: $e');
          }
        }
      }

      // Sort by modified date (most recent first)
      _allNotes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));

      // Set current note to most recent if none is set
      if (_currentNote == null && _allNotes.isNotEmpty) {
        _currentNote = _allNotes.first;
      }

      notifyListeners();
      print('Loaded ${_allNotes.length} notes');
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  /// Delete note from disk
  Future<void> _deleteNoteFromDisk(String noteId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes/$noteId.json');

      if (await file.exists()) {
        await file.delete();
        print('Note deleted from disk: $noteId');
      }
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  /// Search notes by title, tags, or content
  List<Note> searchNotes(String query) {
    if (query.trim().isEmpty) return _allNotes;

    final lowerQuery = query.toLowerCase();

    return _allNotes.where((note) {
      // Search in title
      if (note.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in tags
      for (final tag in note.tags) {
        if (tag.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }

      // Could also search in text objects here
      // for (final textObj in note.textObjects) {
      //   if (textObj.text.toLowerCase().contains(lowerQuery)) {
      //     return true;
      //   }
      // }

      return false;
    }).toList();
  }

  /// Get notes by tag
  List<Note> getNotesByTag(String tag) {
    return _allNotes.where((note) => note.tags.contains(tag)).toList();
  }

  /// Get all unique tags
  Set<String> getAllTags() {
    final tags = <String>{};
    for (final note in _allNotes) {
      tags.addAll(note.tags);
    }
    return tags;
  }

  /// Export note as JSON
  String exportNoteAsJson(String noteId) {
    final note = _allNotes.firstWhere(
      (n) => n.id == noteId,
      orElse: () => throw Exception('Note not found: $noteId'),
    );

    return jsonEncode(note.toJson());
  }
}
