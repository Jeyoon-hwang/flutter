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
  });

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
    );
  }
}
