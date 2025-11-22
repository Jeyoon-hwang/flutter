import 'package:flutter/material.dart';

enum TextType { normal, latex }

class TextObject {
  final String text;
  final Offset position;
  final double fontSize;
  final Color color;
  final TextType type;
  final String id;

  TextObject({
    required this.text,
    required this.position,
    this.fontSize = 16.0,
    this.color = Colors.black,
    this.type = TextType.normal,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  TextObject copyWith({
    String? text,
    Offset? position,
    double? fontSize,
    Color? color,
    TextType? type,
  }) {
    return TextObject(
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      type: type ?? this.type,
      id: id,
    );
  }
}
