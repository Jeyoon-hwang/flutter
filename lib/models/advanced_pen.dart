import 'package:flutter/material.dart';

/// Advanced pen types with different characteristics
enum PenType {
  ballpoint,    // 볼펜 (일정한 굵기)
  fountain,     // 만년필 (압력에 따라 굵기 변화 큼)
  brush,        // 붓펜 (부드럽고 예술적)
  marker,       // 마커 (약간 투명, 굵음)
  highlighter,  // 형광펜 (매우 투명, 넓음)
  pencil,       // 연필 (약간 거칠고 압력 민감)
  calligraphy,  // 캘리그라피 (각진 끝, 방향 민감)
  neon,         // 네온 (빛나는 효과)
  rainbow,      // 무지개 (색상 변화)
  glitter,      // 글리터 (반짝이는 효과)
}

/// Pen tip shape
enum PenTipShape {
  round,        // 둥근 끝
  square,       // 사각 끝
  chisel,       // 캘리그라피용 평평한 끝
  brush,        // 붓 모양
}

/// Advanced pen configuration
class AdvancedPen {
  final String id;
  final String name;
  final PenType type;
  final Color color;
  final double width;
  final double opacity;
  final PenTipShape tipShape;

  // Advanced settings
  final double pressureSensitivity; // 0.0 (no pressure) to 1.0 (max pressure)
  final double smoothing;           // 0.0 (no smoothing) to 1.0 (max smoothing)
  final double tapering;            // 0.0 (no taper) to 1.0 (max taper at ends)
  final bool antiAliasing;
  final bool velocityBased;         // Speed affects width

  // Special effects
  final bool enableGlow;
  final bool enableShadow;
  final List<Color>? gradientColors; // For rainbow/gradient pens
  final double? glitterDensity;      // For glitter pen

  AdvancedPen({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.width = 3.0,
    this.opacity = 1.0,
    this.tipShape = PenTipShape.round,
    this.pressureSensitivity = 0.7,
    this.smoothing = 0.5,
    this.tapering = 0.0,
    this.antiAliasing = true,
    this.velocityBased = false,
    this.enableGlow = false,
    this.enableShadow = false,
    this.gradientColors,
    this.glitterDensity,
  });

  /// Get pen characteristics based on type
  factory AdvancedPen.fromType({
    required String id,
    required String name,
    required PenType type,
    required Color color,
    double? width,
  }) {
    switch (type) {
      case PenType.ballpoint:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 2.5,
          opacity: 1.0,
          pressureSensitivity: 0.2, // 거의 일정한 굵기
          smoothing: 0.3,
          tapering: 0.0,
        );

      case PenType.fountain:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 3.5,
          opacity: 0.9,
          pressureSensitivity: 0.9, // 압력에 매우 민감
          smoothing: 0.6,
          tapering: 0.3,
        );

      case PenType.brush:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 5.0,
          opacity: 0.85,
          tipShape: PenTipShape.brush,
          pressureSensitivity: 0.95,
          smoothing: 0.8, // 매우 부드러움
          tapering: 0.5,
        );

      case PenType.marker:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 8.0,
          opacity: 0.7,
          pressureSensitivity: 0.3,
          smoothing: 0.4,
        );

      case PenType.highlighter:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 15.0,
          opacity: 0.35,
          pressureSensitivity: 0.1,
          smoothing: 0.2,
          tipShape: PenTipShape.chisel,
        );

      case PenType.pencil:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 2.0,
          opacity: 0.8,
          pressureSensitivity: 0.75,
          smoothing: 0.2, // 약간 거친 느낌
          tapering: 0.2,
        );

      case PenType.calligraphy:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 6.0,
          opacity: 1.0,
          tipShape: PenTipShape.chisel,
          pressureSensitivity: 0.8,
          smoothing: 0.5,
          tapering: 0.0,
        );

      case PenType.neon:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 4.0,
          opacity: 0.95,
          pressureSensitivity: 0.5,
          smoothing: 0.6,
          enableGlow: true, // 빛나는 효과
        );

      case PenType.rainbow:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 4.0,
          opacity: 0.9,
          pressureSensitivity: 0.6,
          smoothing: 0.7,
          gradientColors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
          ],
        );

      case PenType.glitter:
        return AdvancedPen(
          id: id,
          name: name,
          type: type,
          color: color,
          width: width ?? 3.5,
          opacity: 0.8,
          pressureSensitivity: 0.6,
          smoothing: 0.5,
          glitterDensity: 0.3,
        );
    }
  }

  /// Get icon for pen type
  IconData getIcon() {
    switch (type) {
      case PenType.ballpoint:
        return Icons.edit;
      case PenType.fountain:
        return Icons.draw;
      case PenType.brush:
        return Icons.brush;
      case PenType.marker:
        return Icons.border_color;
      case PenType.highlighter:
        return Icons.highlight;
      case PenType.pencil:
        return Icons.create;
      case PenType.calligraphy:
        return Icons.abc;
      case PenType.neon:
        return Icons.lightbulb;
      case PenType.rainbow:
        return Icons.palette;
      case PenType.glitter:
        return Icons.auto_awesome;
    }
  }

  /// Get display name for pen type
  String getTypeName() {
    switch (type) {
      case PenType.ballpoint:
        return '볼펜';
      case PenType.fountain:
        return '만년필';
      case PenType.brush:
        return '붓펜';
      case PenType.marker:
        return '마커';
      case PenType.highlighter:
        return '형광펜';
      case PenType.pencil:
        return '연필';
      case PenType.calligraphy:
        return '캘리그라피';
      case PenType.neon:
        return '네온';
      case PenType.rainbow:
        return '무지개';
      case PenType.glitter:
        return '글리터';
    }
  }

  AdvancedPen copyWith({
    String? id,
    String? name,
    PenType? type,
    Color? color,
    double? width,
    double? opacity,
    PenTipShape? tipShape,
    double? pressureSensitivity,
    double? smoothing,
    double? tapering,
    bool? antiAliasing,
    bool? velocityBased,
    bool? enableGlow,
    bool? enableShadow,
    List<Color>? gradientColors,
    double? glitterDensity,
  }) {
    return AdvancedPen(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
      tipShape: tipShape ?? this.tipShape,
      pressureSensitivity: pressureSensitivity ?? this.pressureSensitivity,
      smoothing: smoothing ?? this.smoothing,
      tapering: tapering ?? this.tapering,
      antiAliasing: antiAliasing ?? this.antiAliasing,
      velocityBased: velocityBased ?? this.velocityBased,
      enableGlow: enableGlow ?? this.enableGlow,
      enableShadow: enableShadow ?? this.enableShadow,
      gradientColors: gradientColors ?? this.gradientColors,
      glitterDensity: glitterDensity ?? this.glitterDensity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'color': color.toARGB32(),
      'width': width,
      'opacity': opacity,
      'tipShape': tipShape.name,
      'pressureSensitivity': pressureSensitivity,
      'smoothing': smoothing,
      'tapering': tapering,
      'antiAliasing': antiAliasing,
      'velocityBased': velocityBased,
      'enableGlow': enableGlow,
      'enableShadow': enableShadow,
      'gradientColors': gradientColors?.map((c) => c.toARGB32()).toList(),
      'glitterDensity': glitterDensity,
    };
  }

  factory AdvancedPen.fromJson(Map<String, dynamic> json) {
    return AdvancedPen(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PenType.values.firstWhere((t) => t.name == json['type']),
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      tipShape: PenTipShape.values.firstWhere(
        (t) => t.name == json['tipShape'],
        orElse: () => PenTipShape.round,
      ),
      pressureSensitivity: (json['pressureSensitivity'] as num?)?.toDouble() ?? 0.7,
      smoothing: (json['smoothing'] as num?)?.toDouble() ?? 0.5,
      tapering: (json['tapering'] as num?)?.toDouble() ?? 0.0,
      antiAliasing: json['antiAliasing'] as bool? ?? true,
      velocityBased: json['velocityBased'] as bool? ?? false,
      enableGlow: json['enableGlow'] as bool? ?? false,
      enableShadow: json['enableShadow'] as bool? ?? false,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
          ?.map((c) => Color(c as int))
          .toList(),
      glitterDensity: (json['glitterDensity'] as num?)?.toDouble(),
    );
  }

  /// Get default advanced pens for high school students
  static List<AdvancedPen> getDefaultAdvancedPens() {
    return [
      AdvancedPen.fromType(
        id: 'ballpoint_black',
        name: '검은 볼펜',
        type: PenType.ballpoint,
        color: Colors.black,
        width: 2.5,
      ),
      AdvancedPen.fromType(
        id: 'fountain_blue',
        name: '파란 만년필',
        type: PenType.fountain,
        color: const Color(0xFF007AFF),
        width: 3.0,
      ),
      AdvancedPen.fromType(
        id: 'highlighter_yellow',
        name: '노란 형광펜',
        type: PenType.highlighter,
        color: const Color(0xFFFFCC00),
        width: 15.0,
      ),
      AdvancedPen.fromType(
        id: 'marker_red',
        name: '빨간 마커',
        type: PenType.marker,
        color: const Color(0xFFFF3B30),
        width: 6.0,
      ),
      AdvancedPen.fromType(
        id: 'brush_pink',
        name: '핑크 붓펜',
        type: PenType.brush,
        color: const Color(0xFFFF6B9D),
        width: 5.0,
      ),
    ];
  }
}
