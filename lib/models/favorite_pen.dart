import 'package:flutter/material.dart';

/// Favorite pen configuration for quick access
/// Allows users to save 3-5 pen/highlighter combinations
class FavoritePen {
  final String id;
  final String name;
  final Color color;
  final double width;
  final double opacity;
  final bool isHighlighter; // 형광펜 여부
  final IconData icon;

  FavoritePen({
    required this.id,
    required this.name,
    required this.color,
    required this.width,
    this.opacity = 1.0,
    this.isHighlighter = false,
    this.icon = Icons.edit,
  });

  FavoritePen copyWith({
    String? id,
    String? name,
    Color? color,
    double? width,
    double? opacity,
    bool? isHighlighter,
    IconData? icon,
  }) {
    return FavoritePen(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
      isHighlighter: isHighlighter ?? this.isHighlighter,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'width': width,
      'opacity': opacity,
      'isHighlighter': isHighlighter,
      'icon': icon.codePoint,
    };
  }

  factory FavoritePen.fromJson(Map<String, dynamic> json) {
    return FavoritePen(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      isHighlighter: json['isHighlighter'] as bool? ?? false,
      icon: IconData(json['icon'] as int? ?? Icons.edit.codePoint, fontFamily: 'MaterialIcons'),
    );
  }

  // Default favorite pens for high school students
  static List<FavoritePen> getDefaultFavorites() {
    return [
      FavoritePen(
        id: 'black_pen',
        name: '검은펜 0.5mm',
        color: Colors.black,
        width: 2.5,
        icon: Icons.edit,
      ),
      FavoritePen(
        id: 'red_pen',
        name: '빨간펜 0.7mm',
        color: const Color(0xFFFF3B30),
        width: 3.0,
        icon: Icons.edit,
      ),
      FavoritePen(
        id: 'blue_pen',
        name: '파란펜 0.5mm',
        color: const Color(0xFF007AFF),
        width: 2.5,
        icon: Icons.edit,
      ),
      FavoritePen(
        id: 'yellow_highlighter',
        name: '노란 형광펜',
        color: const Color(0xFFFFCC00),
        width: 12.0,
        opacity: 0.4,
        isHighlighter: true,
        icon: Icons.highlight,
      ),
      FavoritePen(
        id: 'green_highlighter',
        name: '초록 형광펜',
        color: const Color(0xFF34C759),
        width: 12.0,
        opacity: 0.4,
        isHighlighter: true,
        icon: Icons.highlight,
      ),
    ];
  }
}
