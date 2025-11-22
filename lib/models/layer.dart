import 'package:flutter/material.dart';
import 'drawing_stroke.dart';

enum LayerType { background, writing, decoration }

class Layer {
  final String id;
  final String name;
  final LayerType type;
  final List<DrawingStroke> strokes;
  bool isVisible;
  bool isLocked;
  double opacity;

  Layer({
    required this.id,
    required this.name,
    required this.type,
    List<DrawingStroke>? strokes,
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
  }) : strokes = strokes ?? [];

  Layer copyWith({
    String? id,
    String? name,
    LayerType? type,
    List<DrawingStroke>? strokes,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
  }) {
    return Layer(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      strokes: strokes ?? this.strokes,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
    );
  }

  IconData getIcon() {
    switch (type) {
      case LayerType.background:
        return Icons.image;
      case LayerType.writing:
        return Icons.edit;
      case LayerType.decoration:
        return Icons.auto_awesome;
    }
  }

  Color getColor() {
    switch (type) {
      case LayerType.background:
        return const Color(0xFF5E5CE6);
      case LayerType.writing:
        return const Color(0xFF007AFF);
      case LayerType.decoration:
        return const Color(0xFFFF9500);
    }
  }
}
