import 'package:flutter/material.dart';
import 'text_object.dart';
import 'layer.dart';

/// Note template type
enum NoteTemplate {
  blank,        // 백지
  lined,        // 줄 노트
  grid,         // 격자
  dots,         // 점선
  cornell,      // 코넬식
  music,        // 오선지
}

/// Note metadata and content
class Note {
  final String id;
  String title;
  DateTime createdAt;
  DateTime modifiedAt;
  List<String> tags;
  NoteTemplate template;
  Color backgroundColor;

  // Drawing content
  final List<Layer> layers;
  final List<TextObject> textObjects;

  // Audio recording path (if any)
  String? audioPath;

  // PDF background (if any)
  String? pdfPath;

  // Custom background image path (사진 배경)
  String? backgroundImagePath;

  // Background image opacity (0.0 ~ 1.0)
  double backgroundImageOpacity;

  Note({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.modifiedAt,
    this.tags = const [],
    this.template = NoteTemplate.blank,
    this.backgroundColor = Colors.white,
    List<Layer>? layers,
    List<TextObject>? textObjects,
    this.audioPath,
    this.pdfPath,
    this.backgroundImagePath,
    this.backgroundImageOpacity = 1.0,
  })  : layers = layers ?? _createDefaultLayers(),
        textObjects = textObjects ?? [];

  static List<Layer> _createDefaultLayers() {
    return [
      Layer(
        id: 'background_0',
        name: '배경',
        type: LayerType.background,
      ),
      Layer(
        id: 'writing_1',
        name: '필기',
        type: LayerType.writing,
      ),
      Layer(
        id: 'decoration_2',
        name: '꾸미기',
        type: LayerType.decoration,
      ),
    ];
  }

  /// Get total stroke count across all layers
  int get totalStrokes {
    return layers.fold(0, (sum, layer) => sum + layer.strokes.length);
  }

  /// Get last modified time as friendly string
  String get lastModifiedString {
    final now = DateTime.now();
    final difference = now.difference(modifiedAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${modifiedAt.year}.${modifiedAt.month}.${modifiedAt.day}';
    }
  }

  /// Check if note has any content
  bool get hasContent {
    return totalStrokes > 0 || textObjects.isNotEmpty || pdfPath != null;
  }

  /// Create a copy with updated fields
  Note copyWith({
    String? title,
    DateTime? modifiedAt,
    List<String>? tags,
    NoteTemplate? template,
    Color? backgroundColor,
    String? audioPath,
    String? pdfPath,
    String? backgroundImagePath,
    double? backgroundImageOpacity,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      template: template ?? this.template,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      layers: layers,
      textObjects: textObjects,
      audioPath: audioPath ?? this.audioPath,
      pdfPath: pdfPath ?? this.pdfPath,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundImageOpacity: backgroundImageOpacity ?? this.backgroundImageOpacity,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'tags': tags,
        'template': template.index,
        'backgroundColor': backgroundColor.toARGB32(),
        'audioPath': audioPath,
        'pdfPath': pdfPath,
        'backgroundImagePath': backgroundImagePath,
        'backgroundImageOpacity': backgroundImageOpacity,
        // Layers and strokes would need more complex serialization
      };

  /// Create from JSON
  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        createdAt: DateTime.parse(json['createdAt']),
        modifiedAt: DateTime.parse(json['modifiedAt']),
        tags: List<String>.from(json['tags'] ?? []),
        template: NoteTemplate.values[json['template'] ?? 0],
        backgroundColor: Color(json['backgroundColor'] ?? Colors.white.toARGB32()),
        audioPath: json['audioPath'],
        pdfPath: json['pdfPath'],
        backgroundImagePath: json['backgroundImagePath'],
        backgroundImageOpacity: json['backgroundImageOpacity'] ?? 1.0,
      );
}
