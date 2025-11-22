import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Custom font loader service
/// Allows users to load .ttf and .otf fonts for "Gong-stagram" aesthetic
class FontLoaderService {
  static const String _fontDirectory = 'custom_fonts';
  final Map<String, FontLoader> _loadedFonts = {};
  final List<CustomFont> _availableFonts = [];

  List<CustomFont> get availableFonts => List.unmodifiable(_availableFonts);

  /// Initialize service and load existing fonts
  Future<void> initialize() async {
    try {
      final directory = await _getFontsDirectory();
      if (await directory.exists()) {
        final files = directory.listSync();

        for (var file in files) {
          if (file is File) {
            final extension = file.path.split('.').last.toLowerCase();
            if (extension == 'ttf' || extension == 'otf') {
              final fontName = _getFontNameFromPath(file.path);
              await _loadFontFromFile(file, fontName);
            }
          }
        }
      }
    } catch (e) {
      print('Error initializing font loader: $e');
    }
  }

  /// Pick and load a custom font file
  Future<CustomFont?> pickAndLoadFont() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          final file = File(filePath);
          final fontName = result.files.first.name.split('.').first;

          // Copy to app's font directory
          final directory = await _getFontsDirectory();
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          final newPath = '${directory.path}/${result.files.first.name}';
          final copiedFile = await file.copy(newPath);

          // Load the font
          return await _loadFontFromFile(copiedFile, fontName);
        }
      }
    } catch (e) {
      print('Error picking font: $e');
    }
    return null;
  }

  /// Load a font from file
  Future<CustomFont?> _loadFontFromFile(File file, String fontName) async {
    try {
      // Check if already loaded
      if (_loadedFonts.containsKey(fontName)) {
        return _availableFonts.firstWhere((f) => f.name == fontName);
      }

      // Read font file
      final bytes = await file.readAsBytes();

      // Create font loader
      final fontLoader = FontLoader(fontName);
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await fontLoader.load();

      _loadedFonts[fontName] = fontLoader;

      final customFont = CustomFont(
        name: fontName,
        family: fontName,
        filePath: file.path,
        fileSize: bytes.length,
      );

      _availableFonts.add(customFont);

      return customFont;
    } catch (e) {
      print('Error loading font $fontName: $e');
      return null;
    }
  }

  /// Delete a custom font
  Future<bool> deleteFont(String fontName) async {
    try {
      final font = _availableFonts.firstWhere(
        (f) => f.name == fontName,
        orElse: () => throw Exception('Font not found'),
      );

      final file = File(font.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      _loadedFonts.remove(fontName);
      _availableFonts.removeWhere((f) => f.name == fontName);

      return true;
    } catch (e) {
      print('Error deleting font $fontName: $e');
      return false;
    }
  }

  /// Get fonts directory
  Future<Directory> _getFontsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$_fontDirectory');
  }

  /// Extract font name from file path
  String _getFontNameFromPath(String path) {
    return path.split('/').last.split('.').first;
  }

  /// Get popular Korean handwriting fonts (for reference)
  static List<String> get popularKoreanFonts => [
        '3B연필체',
        'Aa폰트',
        '나눔손글씨',
        '배민주아체',
        '귀여운체',
        '다이어리체',
        '필기체',
      ];

  /// Dispose resources
  void dispose() {
    _loadedFonts.clear();
    _availableFonts.clear();
  }
}

/// Custom font model
class CustomFont {
  final String name;
  final String family;
  final String filePath;
  final int fileSize;
  final DateTime addedAt;

  CustomFont({
    required this.name,
    required this.family,
    required this.filePath,
    required this.fileSize,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'family': family,
      'filePath': filePath,
      'fileSize': fileSize,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CustomFont.fromJson(Map<String, dynamic> json) {
    return CustomFont(
      name: json['name'] as String,
      family: json['family'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
