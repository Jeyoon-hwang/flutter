import 'dart:typed_data';

/// Represents a captured screenshot from lecture
class LectureScreenshot {
  final String id;
  final Uint8List imageData;
  final DateTime capturedAt;
  String? note; // User's note about this screenshot

  LectureScreenshot({
    required this.id,
    required this.imageData,
    required this.capturedAt,
    this.note,
  });

  LectureScreenshot copyWith({
    String? id,
    Uint8List? imageData,
    DateTime? capturedAt,
    String? note,
  }) {
    return LectureScreenshot(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      capturedAt: capturedAt ?? this.capturedAt,
      note: note ?? this.note,
    );
  }
}

/// Quick palette for lecture mode (minimal tools)
class QuickPalette {
  final List<QuickTool> tools;

  QuickPalette({required this.tools});

  static QuickPalette get defaultPalette => QuickPalette(
    tools: [
      QuickTool.blackPen,
      QuickTool.redPen,
      QuickTool.highlighter,
      QuickTool.eraser,
      QuickTool.capture, // Screenshot capture
    ],
  );
}

enum QuickTool {
  blackPen,
  redPen,
  highlighter,
  eraser,
  capture, // 📷 Quick capture
}
