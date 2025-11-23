import 'package:flutter/material.dart';
import 'favorite_pen.dart';

/// App theme type for "Gong-stagram" aesthetic
enum AppThemeType {
  ivory, // 아이보리 종이 테마 (기본)
  pastelPink, // 파스텔 핑크
  pastelBlue, // 파스텔 블루
  pastelGreen, // 파스텔 그린
  minimalist, // 순백 미니멀
  darkMode, // 다크 모드
}

class AppSettings {
  bool palmRejection;
  bool isDarkMode;
  bool autoShapeEnabled;
  bool showGridLines;
  double defaultLineWidth;
  double defaultOpacity;

  // Intelligent layer management
  // When enabled, app automatically assigns content to appropriate layers:
  // - Handwriting → Writing layer
  // - Images/Stickers → Decoration layer
  // - PDF imports → Background layer
  bool autoLayerManagement;

  // Toolbar customization
  bool showPenTool;
  bool showEraserTool;
  bool showSelectTool;
  bool showShapeTool;
  bool showTextTool;

  // Favorite pens (3~5 quick access pens)
  List<FavoritePen> favoritePens;
  String? selectedFavoritePenId; // Currently selected favorite pen

  // Theme settings
  AppThemeType themeType;
  String? customFontFamily; // Custom font loaded by user

  // Button size customization (1.0 = normal, 0.8 = small, 1.2 = large)
  double buttonSize;

  AppSettings({
    this.palmRejection = false,
    this.isDarkMode = false,
    this.autoShapeEnabled = false,
    this.showGridLines = false,
    this.defaultLineWidth = 3.0,
    this.defaultOpacity = 1.0,
    this.autoLayerManagement = true, // Enabled by default for 90% of users
    this.showPenTool = true,
    this.showEraserTool = true,
    this.showSelectTool = true,
    this.showShapeTool = true,
    this.showTextTool = true,
    List<FavoritePen>? favoritePens,
    this.selectedFavoritePenId,
    this.themeType = AppThemeType.ivory,
    this.customFontFamily,
    this.buttonSize = 1.0,
  }) : favoritePens = favoritePens ?? FavoritePen.getDefaultFavorites();

  AppSettings copyWith({
    bool? palmRejection,
    bool? isDarkMode,
    bool? autoShapeEnabled,
    bool? showGridLines,
    double? defaultLineWidth,
    double? defaultOpacity,
    bool? autoLayerManagement,
    bool? showPenTool,
    bool? showEraserTool,
    bool? showSelectTool,
    bool? showShapeTool,
    bool? showTextTool,
    List<FavoritePen>? favoritePens,
    String? selectedFavoritePenId,
    AppThemeType? themeType,
    String? customFontFamily,
    double? buttonSize,
  }) {
    return AppSettings(
      palmRejection: palmRejection ?? this.palmRejection,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoShapeEnabled: autoShapeEnabled ?? this.autoShapeEnabled,
      showGridLines: showGridLines ?? this.showGridLines,
      defaultLineWidth: defaultLineWidth ?? this.defaultLineWidth,
      defaultOpacity: defaultOpacity ?? this.defaultOpacity,
      autoLayerManagement: autoLayerManagement ?? this.autoLayerManagement,
      showPenTool: showPenTool ?? this.showPenTool,
      showEraserTool: showEraserTool ?? this.showEraserTool,
      showSelectTool: showSelectTool ?? this.showSelectTool,
      showShapeTool: showShapeTool ?? this.showShapeTool,
      showTextTool: showTextTool ?? this.showTextTool,
      favoritePens: favoritePens ?? this.favoritePens,
      selectedFavoritePenId: selectedFavoritePenId ?? this.selectedFavoritePenId,
      themeType: themeType ?? this.themeType,
      customFontFamily: customFontFamily ?? this.customFontFamily,
      buttonSize: buttonSize ?? this.buttonSize,
    );
  }

  /// Get background color for current theme
  Color getBackgroundColor() {
    switch (themeType) {
      case AppThemeType.ivory:
        return const Color(0xFFFFFAF0); // 아이보리 (크림색 종이)
      case AppThemeType.pastelPink:
        return const Color(0xFFFFF0F5); // 라벤더 블러시
      case AppThemeType.pastelBlue:
        return const Color(0xFFF0F8FF); // 앨리스 블루
      case AppThemeType.pastelGreen:
        return const Color(0xFFF0FFF0); // 허니듀
      case AppThemeType.minimalist:
        return Colors.white; // 순백
      case AppThemeType.darkMode:
        return const Color(0xFF1E1E1E); // 다크 그레이
    }
  }

  /// Get primary text color for theme
  Color getTextColor() {
    return themeType == AppThemeType.darkMode
        ? Colors.white
        : const Color(0xFF1C1C1E);
  }
}

