import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import '../models/drawing_stroke.dart';
import '../models/text_object.dart';
import '../models/app_settings.dart';
import '../models/layer.dart' as app_layer;
import '../models/note.dart';
import '../models/history_action.dart';
import '../models/page_layout.dart';
import '../models/favorite_pen.dart';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import '../services/ocr_service.dart';
import '../services/shape_recognition_service.dart';
import '../services/shape_drawing_service.dart';
import '../services/audio_recording_service.dart';
import '../services/note_service.dart';
import '../services/version_manager.dart';
import '../services/wrong_answer_service.dart';
import '../services/hybrid_input_detector.dart';
import '../services/app_state_service.dart';
import '../services/haptic_service.dart';
import '../models/practice_session.dart';
import '../models/planner.dart';
import '../models/lecture_mode.dart';
import '../models/study_stats.dart';
import '../models/advanced_pen.dart';
import '../models/performance_settings.dart';
import '../models/study_timer.dart';
import '../utils/stroke_smoother.dart';
import '../services/auto_save_service.dart';

enum DrawingMode { pen, eraser, select, shape, text, wrongAnswerClip }

class DrawingProvider extends ChangeNotifier {
  // Layer system
  final List<app_layer.Layer> _layers = [];
  int _currentLayerIndex = 1; // Default to writing layer

  final List<DrawingStroke> _strokes = [];
  final List<TextObject> _textObjects = [];

  // New granular history system
  final HistoryManager _historyManager = HistoryManager();

  final List<DrawingPoint> _currentStroke = [];

  // App settings
  AppSettings _settings = AppSettings();

  // Drawing settings
  Color _currentColor = Colors.black;
  double _lineWidth = 3.0;
  double _opacity = 1.0;
  double _pressureStabilization = 0.5; // 0 = 사실적, 1 = 완전 안정화
  DrawingMode _mode = DrawingMode.pen;
  bool _isDarkMode = false;
  bool _autoShapeEnabled = false;
  bool _focusMode = false; // 포커스 모드

  // Pen/Stylus detection
  InputDeviceType _currentInputDevice = InputDeviceType.touch;
  bool _isStylusDetected = false;

  // Canvas transform (zoom & pan) - 필기앱 필수 기능
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  static const double _minScale = 0.5;
  static const double _maxScale = 5.0;

  // Recent colors (최근 사용한 색상, 최대 8개)
  final List<Color> _recentColors = [];

  // Text input
  Offset? _textInputPosition;
  TextObject? _selectedTextObject;

  // Selection
  Rect? _selectionRect;
  Offset? _selectionStart;
  bool _isSelecting = false;

  // Services
  final OCRService _ocrService = OCRService();
  final ShapeRecognitionService _shapeService = ShapeRecognitionService();
  final ShapeDrawingService _shapeDrawingService = ShapeDrawingService();
  bool _isProcessingOCR = false;

  // Audio recording service
  final AudioRecordingService _audioService = AudioRecordingService();
  bool get isRecordingAudio => _audioService.isRecording;
  bool get isPlayingAudio => _audioService.isPlaying;

  // Note service for quick capture and auto-save
  final NoteService _noteService = NoteService();
  NoteService get noteService => _noteService;

  // Page layout management
  final PageManager _pageManager = PageManager();
  PageManager get pageManager => _pageManager;

  // Version control management (Git-like system)
  final VersionManager _versionManager = VersionManager();
  VersionManager get versionManager => _versionManager;

  // Wrong answer clipping service
  final WrongAnswerService _wrongAnswerService = WrongAnswerService();
  WrongAnswerService get wrongAnswerService => _wrongAnswerService;

  // Practice session manager (N회독)
  final PracticeSessionManager _practiceSessionManager = PracticeSessionManager();
  PracticeSessionManager get practiceSessionManager => _practiceSessionManager;
  PracticeViewMode _practiceViewMode = PracticeViewMode.current;
  PracticeViewMode get practiceViewMode => _practiceViewMode;
  // Planner manager
  final PlannerManager _plannerManager = PlannerManager();
  PlannerManager get plannerManager => _plannerManager;

  // Study stats manager
  final StudyStatsManager _studyStatsManager = StudyStatsManager();
  StudyStatsManager get studyStatsManager => _studyStatsManager;

  // App state service for persistence
  final AppStateService _appStateService = AppStateService();
  AppStateService get appStateService => _appStateService;

  // Auto-save service (prevents work loss)
  final AutoSaveService _autoSaveService = AutoSaveService();
  AutoSaveService get autoSaveService => _autoSaveService;

  // Advanced pen system
  final List<AdvancedPen> _advancedPens = [];
  String? _selectedAdvancedPenId;
  List<AdvancedPen> get advancedPens => List.unmodifiable(_advancedPens);
  String? get selectedAdvancedPenId => _selectedAdvancedPenId;

  // Lecture mode (split view optimization)
  bool _isLectureMode = false;
  final List<LectureScreenshot> _lectureScreenshots = [];
  bool get isLectureMode => _isLectureMode;
  List<LectureScreenshot> get lectureScreenshots => List.unmodifiable(_lectureScreenshots);

  // Hybrid input detector (lazy initialization)
  HybridInputDetector? _hybridInputDetector;

  // Performance settings for optimization
  PerformanceSettings _performanceSettings = PerformanceSettings.balanced;
  PerformanceSettings get performanceSettings => _performanceSettings;

  // Study timer manager (열품타 스타일)
  final StudyTimerManager _studyTimerManager = StudyTimerManager();
  StudyTimerManager get studyTimerManager => _studyTimerManager;

  // Shape drawing
  ShapeType2D _selectedShape2D = ShapeType2D.circle;
  ShapeType3D? _selectedShape3D;
  double _shapeSize = 100.0;
  double _triangleAngle1 = 60.0;
  double _triangleAngle2 = 60.0;
  double _triangleAngle3 = 60.0;
  Offset? _shapeStartPoint;

  // Constructor - Initialize default layers and load notes
  DrawingProvider() {
    _initializeLayers();
    _initializeApp();
  }

  /// Initialize app - load saved state and notes
  Future<void> _initializeApp() async {
    // Increment launch count
    await _appStateService.incrementLaunchCount();

    // Load saved settings
    await _loadSavedSettings();

    // Initialize note service
    await _initializeNoteService();

    // Restore last opened note if exists
    await _restoreLastSession();

    // Initialize auto-save
    _initializeAutoSave();
  }

  /// Initialize auto-save system
  void _initializeAutoSave() {
    // Configure auto-save callbacks
    _autoSaveService.onAutoSave = () async {
      // Save current note
      if (_noteService.currentNote != null) {
        await _noteService.saveCurrentNote();
      }
    };

    _autoSaveService.onSaveSuccess = () {
      debugPrint('✅ Auto-save successful');
    };

    _autoSaveService.onSaveError = (error) {
      debugPrint('❌ Auto-save error: $error');
    };

    // Start auto-save timer (30 seconds)
    _autoSaveService.startAutoSave();
  }

  /// Load saved settings from persistence
  Future<void> _loadSavedSettings() async {
    try {
      // Load theme
      final savedTheme = await _appStateService.getThemeType();
      if (savedTheme != null) {
        final themeType = AppThemeType.values.firstWhere(
          (t) => t.name == savedTheme,
          orElse: () => AppThemeType.ivory,
        );
        _settings = _settings.copyWith(themeType: themeType);
        _isDarkMode = themeType == AppThemeType.darkMode;
      }

      // Load custom font
      final savedFont = await _appStateService.getCustomFont();
      if (savedFont != null) {
        _settings = _settings.copyWith(customFontFamily: savedFont);
      }

      // Load favorite pens
      final savedPens = await _appStateService.getFavoritePens();
      if (savedPens != null && savedPens.isNotEmpty) {
        // Convert to FavoritePen objects
        // (Implementation depends on FavoritePen.fromJson)
      }
    } catch (e) {
      print('Error loading saved settings: $e');
    }
  }

  Future<void> _initializeNoteService() async {
    await _noteService.loadNotesFromDisk();

    // If no notes exist or no current note, we'll create one later if needed
  }

  /// Restore last opened note and page
  Future<void> _restoreLastSession() async {
    try {
      final lastNote = await _appStateService.getLastOpenedNote();

      if (lastNote != null) {
        final noteId = lastNote['noteId'] as String;
        final pageIndex = lastNote['pageIndex'] as int;

        // Try to load the note
        final note = _noteService.allNotes.firstWhere(
          (n) => n.id == noteId,
          orElse: () => _noteService.currentNote!,
        );

        _loadNoteData(note);
        _pageManager.goToPage(pageIndex);
        print('Restored last session: note=$noteId, page=$pageIndex');
        notifyListeners();
        return;
      }
    } catch (e) {
      print('Error restoring last session: $e');
    }

    // Fallback: create quick note if no current note
    if (_noteService.currentNote == null) {
      createQuickNote();
    } else {
      _loadNoteData(_noteService.currentNote!);
    }
  }

  /// Create a quick note for instant capture
  void createQuickNote({NoteTemplate template = NoteTemplate.blank}) {
    final note = _noteService.createQuickNote(
      template: template,
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
    );
    _loadNoteData(note);
  }

  /// Load note data into drawing provider
  void _loadNoteData(Note note) {
    // Clear current state
    _layers.clear();
    _textObjects.clear();
    _strokes.clear();

    // Load layers from note
    if (note.layers.isNotEmpty) {
      _layers.addAll(note.layers);
    } else {
      _initializeLayers();
    }

    // Load text objects from note
    _textObjects.addAll(note.textObjects);

    // Set background color
    // Note: You might want to expose backgroundColor setter

    // Load template
    // Template rendering would be implemented separately

    notifyListeners();
  }

  /// Save current state to current note
  void _saveToCurrentNote() {
    if (_noteService.currentNote == null) return;

    // Update the note's layers with current state
    // The layers are already being modified in place, so just mark as modified
    _noteService.markCurrentNoteAsModified();
  }

  void _initializeLayers() {
    _layers.addAll([
      app_layer.Layer(
        id: 'background_0',
        name: '배경',
        type: app_layer.LayerType.background,
      ),
      app_layer.Layer(
        id: 'writing_1',
        name: '필기',
        type: app_layer.LayerType.writing,
      ),
      app_layer.Layer(
        id: 'decoration_2',
        name: '꾸미기',
        type: app_layer.LayerType.decoration,
      ),
    ]);
    _currentLayerIndex = 1; // 필기 레이어가 기본

    // Initialize advanced pens
    _advancedPens.addAll(AdvancedPen.getDefaultAdvancedPens());
  }

  // Getters
  List<app_layer.Layer> get layers => _layers;
  app_layer.Layer get currentLayer => _layers[_currentLayerIndex];
  int get currentLayerIndex => _currentLayerIndex;
  List<DrawingStroke> get strokes => _getAllVisibleStrokes();
  double get pressureStabilization => _pressureStabilization;
  bool get focusMode => _focusMode;
  List<TextObject> get textObjects => _textObjects;
  AppSettings get settings => _settings;
  Color get currentColor => _currentColor;
  double get lineWidth => _lineWidth;
  double get opacity => _opacity;

  // Pen/Stylus detection getters
  InputDeviceType get currentInputDevice => _currentInputDevice;
  bool get isStylusDetected => _isStylusDetected;
  String get inputDeviceName {
    switch (_currentInputDevice) {
      case InputDeviceType.stylus:
        return 'S펜/Apple Pencil';
      case InputDeviceType.touch:
        return '터치';
      case InputDeviceType.mouse:
        return '마우스';
      case InputDeviceType.unknown:
        return '알 수 없음';
    }
  }

  // Canvas transform getters
  double get scale => _scale;
  Offset get offset => _offset;
  DrawingMode get mode => _mode;
  bool get isEraser => _mode == DrawingMode.eraser;
  bool get isSelectMode => _mode == DrawingMode.select;
  bool get isWrongAnswerClipMode => _mode == DrawingMode.wrongAnswerClip;
  bool get isDarkMode => _isDarkMode;
  bool get autoShapeEnabled => _autoShapeEnabled;
  bool get canUndo => _historyManager.canUndo;
  bool get canRedo => _historyManager.canRedo;
  Rect? get selectionRect => _selectionRect;
  HistoryManager get historyManager => _historyManager;
  bool get isProcessingOCR => _isProcessingOCR;
  ShapeType2D get selectedShape2D => _selectedShape2D;
  ShapeType3D? get selectedShape3D => _selectedShape3D;
  double get shapeSize => _shapeSize;
  double get triangleAngle1 => _triangleAngle1;
  double get triangleAngle2 => _triangleAngle2;
  double get triangleAngle3 => _triangleAngle3;
  bool get isShapeMode => _mode == DrawingMode.shape;
  bool get isTextMode => _mode == DrawingMode.text;
  Offset? get textInputPosition => _textInputPosition;
  TextObject? get selectedTextObject => _selectedTextObject;
  bool get palmRejection => _settings.palmRejection;
  List<Color> get recentColors => _recentColors;

  // Setters
  void setColor(Color color) {
    _currentColor = color;

    // Add to recent colors
    _recentColors.remove(color); // Remove if already exists
    _recentColors.insert(0, color); // Add to front

    // Keep only 8 most recent colors
    if (_recentColors.length > 8) {
      _recentColors.removeLast();
    }

    notifyListeners();
  }

  void setLineWidth(double width) {
    _lineWidth = width;
    notifyListeners();
  }

  void setOpacity(double opacity) {
    _opacity = opacity;
    notifyListeners();
  }

  void setButtonSize(double size) {
    _settings = _settings.copyWith(buttonSize: size);
    notifyListeners();
  }

  void setMode(DrawingMode mode) {
    _mode = mode;
    _selectionRect = null;
    notifyListeners();
  }

  void toggleAutoShape() {
    _autoShapeEnabled = !_autoShapeEnabled;
    notifyListeners();
  }

  // Canvas transform methods (필기앱 필수 기능)
  void setScale(double newScale) {
    _scale = newScale.clamp(_minScale, _maxScale);
    notifyListeners();
  }

  void setOffset(Offset newOffset) {
    _offset = newOffset;
    notifyListeners();
  }

  void updateTransform(double newScale, Offset newOffset) {
    _scale = newScale.clamp(_minScale, _maxScale);
    _offset = newOffset;
    notifyListeners();
  }

  void resetTransform() {
    _scale = 1.0;
    _offset = Offset.zero;
    notifyListeners();
  }

  // Zoom convenience methods for keyboard shortcuts
  void resetZoom() => resetTransform();

  void zoomIn() {
    setScale(_scale * 1.2);
  }

  void zoomOut() {
    setScale(_scale / 1.2);
  }

  // Selection operations for keyboard shortcuts
  void deleteSelection() {
    if (_selectionRect != null) {
      // Delete all strokes within selection
      final deletedStrokes = <DrawingStroke>[];
      _strokes.removeWhere((stroke) {
        final shouldRemove = stroke.points.any((point) => _selectionRect!.contains(point.offset));
        if (shouldRemove) deletedStrokes.add(stroke);
        return shouldRemove;
      });

      clearSelection();

      // Record history if strokes were deleted
      if (deletedStrokes.isNotEmpty) {
        _historyManager.recordAction(HistoryAction(
          type: HistoryActionType.removeStroke,
          data: deletedStrokes,
          description: 'Delete ${deletedStrokes.length} strokes',
        ));
      }

      notifyListeners();
    }
  }

  void selectAll() {
    if (_strokes.isEmpty) return;

    // Calculate bounding box of all strokes
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in _strokes) {
      for (final point in stroke.points) {
        if (point.offset.dx < minX) minX = point.offset.dx;
        if (point.offset.dy < minY) minY = point.offset.dy;
        if (point.offset.dx > maxX) maxX = point.offset.dx;
        if (point.offset.dy > maxY) maxY = point.offset.dy;
      }
    }

    _selectionRect = Rect.fromLTRB(minX, minY, maxX, maxY);
    _isSelecting = false;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPressureStabilization(double value) {
    _pressureStabilization = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleFocusMode() {
    _focusMode = !_focusMode;
    notifyListeners();
  }

  /// Set performance settings based on device capability
  void setPerformanceSettings(PerformanceSettings settings) {
    _performanceSettings = settings;
    notifyListeners();
  }

  /// Auto-detect and set appropriate performance settings
  void autoDetectPerformanceSettings(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // TV/Desktop - High quality
    if (screenWidth > 1200) {
      _performanceSettings = PerformanceSettings.tv;
    }
    // Tablet - Balanced
    else if (screenWidth > 600) {
      _performanceSettings = PerformanceSettings.balanced;
    }
    // Phone with high DPI - Quality
    else if (devicePixelRatio > 2.5) {
      _performanceSettings = PerformanceSettings.quality;
    }
    // Phone with low DPI - Performance
    else {
      _performanceSettings = PerformanceSettings.highPerformance;
    }

    notifyListeners();
  }

  // Layer management methods
  List<DrawingStroke> _getAllVisibleStrokes() {
    List<DrawingStroke> allStrokes = [];
    for (var layer in _layers) {
      if (layer.isVisible) {
        allStrokes.addAll(layer.strokes);
      }
    }
    return allStrokes;
  }

  void selectLayer(int index) {
    if (index >= 0 && index < _layers.length) {
      if (!_layers[index].isLocked) {
        _currentLayerIndex = index;
        notifyListeners();
      }
    }
  }

  void toggleLayerVisibility(int index) {
    if (index >= 0 && index < _layers.length) {
      _layers[index].isVisible = !_layers[index].isVisible;
      notifyListeners();
    }
  }

  void toggleLayerLock(int index) {
    if (index >= 0 && index < _layers.length) {
      _layers[index].isLocked = !_layers[index].isLocked;
      notifyListeners();
    }
  }

  void setLayerOpacity(int index, double opacity) {
    if (index >= 0 && index < _layers.length) {
      _layers[index].opacity = opacity.clamp(0.0, 1.0);
      notifyListeners();
    }
  }

  void addLayer(app_layer.LayerType type) {
    final newId = '${type.name}_${DateTime.now().millisecondsSinceEpoch}';
    final newLayer = app_layer.Layer(
      id: newId,
      name: '${type == app_layer.LayerType.background ? '배경' : type == app_layer.LayerType.writing ? '필기' : '꾸미기'} ${_layers.length + 1}',
      type: type,
    );
    _layers.add(newLayer);

    // Record history action
    _historyManager.recordAction(HistoryAction(
      type: HistoryActionType.addLayer,
      data: newLayer,
      description: 'Add layer: ${newLayer.name}',
      index: _layers.length - 1,
    ));

    _saveToCurrentNote();
    notifyListeners();
  }

  // ============================================================================
  // INTELLIGENT LAYER MANAGEMENT
  // ============================================================================

  /// Get the auto layer management setting
  bool get autoLayerManagement => _settings.autoLayerManagement;

  /// Toggle auto layer management (for power users who want manual control)
  void toggleAutoLayerManagement() {
    _settings = _settings.copyWith(
      autoLayerManagement: !_settings.autoLayerManagement,
    );
    notifyListeners();
  }

  /// Find the first layer of a specific type
  /// Returns the layer index, or -1 if not found
  int _findLayerByType(app_layer.LayerType type) {
    for (int i = 0; i < _layers.length; i++) {
      if (_layers[i].type == type) {
        return i;
      }
    }
    return -1;
  }

  /// Automatically switch to the appropriate layer based on content type
  /// This is the core of intelligent layer management
  void _autoSelectLayerForContent(app_layer.LayerType contentType) {
    // Skip if auto layer management is disabled
    if (!_settings.autoLayerManagement) return;

    // Find the layer for this content type
    final layerIndex = _findLayerByType(contentType);

    if (layerIndex >= 0 && layerIndex < _layers.length) {
      // Switch to this layer if it's not locked
      if (!_layers[layerIndex].isLocked) {
        _currentLayerIndex = layerIndex;
        print('Auto-switched to ${_layers[layerIndex].name} layer for ${contentType.name} content');
      }
    } else {
      // Layer doesn't exist - create it automatically
      addLayer(contentType);
      _currentLayerIndex = _layers.length - 1;
      print('Auto-created ${contentType.name} layer');
    }
  }

  /// Prepare layer for handwriting (pen/stylus input)
  void _prepareForHandwriting() {
    _autoSelectLayerForContent(app_layer.LayerType.writing);
  }

  /// Prepare layer for decoration (shapes, stickers, images)
  void _prepareForDecoration() {
    _autoSelectLayerForContent(app_layer.LayerType.decoration);
  }

  void deleteLayer(int index) {
    if (index >= 0 && index < _layers.length && _layers.length > 1) {
      final removedLayer = _layers[index];

      // Record history action
      _historyManager.recordAction(HistoryAction(
        type: HistoryActionType.removeLayer,
        data: removedLayer,
        description: 'Delete layer: ${removedLayer.name}',
        index: index,
      ));

      _layers.removeAt(index);
      if (_currentLayerIndex >= _layers.length) {
        _currentLayerIndex = _layers.length - 1;
      }
      _saveToCurrentNote();
      notifyListeners();
    }
  }

  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final layer = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, layer);
    if (_currentLayerIndex == oldIndex) {
      _currentLayerIndex = newIndex;
    }
    notifyListeners();
  }

  void setShape2D(ShapeType2D shape) {
    _selectedShape2D = shape;
    _selectedShape3D = null;
    notifyListeners();
  }

  void setShape3D(ShapeType3D shape) {
    _selectedShape3D = shape;
    notifyListeners();
  }

  void setShapeSize(double size) {
    _shapeSize = size;
    notifyListeners();
  }

  void setTriangleAngles(double angle1, double angle2, double angle3) {
    _triangleAngle1 = angle1;
    _triangleAngle2 = angle2;
    _triangleAngle3 = angle3;
    notifyListeners();
  }

  // Drawing methods
  void startDrawing(Offset offset, double pressure, {
    bool isPen = false,
    PointerDeviceKind? deviceKind,
    double? tiltX,
    double? tiltY,
  }) {
    // Debug logging for S-Pen detection
    if (deviceKind != null) {
      debugPrint('🖊️ Pointer Device: ${deviceKind.toString()}, Pressure: $pressure');
    }

    // Update current input device
    bool isStylusInput = false;
    if (deviceKind != null) {
      switch (deviceKind) {
        case PointerDeviceKind.stylus:
        case PointerDeviceKind.invertedStylus: // S-Pen 지우개 모드도 인식
          _currentInputDevice = InputDeviceType.stylus;
          isStylusInput = true;
          // Haptic feedback when stylus is first detected
          if (!_isStylusDetected) {
            hapticService.stylusDetected();
            debugPrint('✅ S-Pen/Stylus detected!');
          }
          _isStylusDetected = true;
          break;
        case PointerDeviceKind.touch:
          _currentInputDevice = InputDeviceType.touch;
          break;
        case PointerDeviceKind.mouse:
          _currentInputDevice = InputDeviceType.mouse;
          break;
        default:
          _currentInputDevice = InputDeviceType.unknown;
          // Unknown devices with pressure > 0.3 are likely styluses (S-Pen fallback)
          if (pressure > 0.3) {
            debugPrint('⚠️ Unknown device with pressure $pressure - treating as stylus');
            _currentInputDevice = InputDeviceType.stylus;
            isStylusInput = true;
            _isStylusDetected = true;
          }
      }
    }

    // Smart Palm rejection:
    // - If stylus has NEVER been detected in this session, allow touch input
    // - If stylus was detected before, reject touch (palm rejection)
    // - ALWAYS allow stylus pen input (including inverted stylus)
    // CRITICAL: Never reject stylus input!
    if (_settings.palmRejection &&
        deviceKind == PointerDeviceKind.touch &&
        !isStylusInput &&
        _isStylusDetected && // Only reject touch if stylus was previously detected
        _mode == DrawingMode.pen) {
      debugPrint('🚫 Touch input rejected by palm rejection (stylus was detected before)');
      return;
    }

    // Allow touch if no stylus has been detected yet
    if (deviceKind == PointerDeviceKind.touch && !_isStylusDetected) {
      debugPrint('✅ Touch input allowed (no stylus detected yet)');
    }

    // Additional debug logging
    debugPrint('✅ Drawing started: mode=$_mode, stylus=$isStylusInput, pressure=$pressure, layer=${_currentLayerIndex}/${_layers.length}');

    // Auto-add pages if drawing beyond current pages
    _pageManager.autoAddPagesForPoint(offset);

    if (_mode == DrawingMode.select || _mode == DrawingMode.wrongAnswerClip) {
      _selectionStart = offset;
      _isSelecting = true;
      _selectionRect = null;
      notifyListeners();
      return;
    }

    if (_mode == DrawingMode.shape) {
      // Intelligent layer: shapes go to decoration layer
      _prepareForDecoration();
      _shapeStartPoint = offset;
      notifyListeners();
      return;
    }

    if (_mode == DrawingMode.text) {
      // Intelligent layer: text goes to writing layer
      _prepareForHandwriting();
      startTextInput(offset);
      return;
    }

    // Intelligent layer: pen/eraser strokes go to writing layer
    if (_mode == DrawingMode.pen || _mode == DrawingMode.eraser) {
      _prepareForHandwriting();
    }

    _currentStroke.clear();

    // Create drawing point with device type information
    final point = deviceKind != null
        ? DrawingPoint.fromPointer(
            offset: offset,
            pressure: pressure,
            kind: deviceKind,
            tiltX: tiltX,
            tiltY: tiltY,
          )
        : DrawingPoint(offset: offset, pressure: pressure);

    _currentStroke.add(point);
    notifyListeners();
  }

  void updateDrawing(Offset offset, double pressure, {
    PointerDeviceKind? deviceKind,
    double? tiltX,
    double? tiltY,
  }) {
    if ((_mode == DrawingMode.select || _mode == DrawingMode.wrongAnswerClip) &&
        _isSelecting && _selectionStart != null) {
      _selectionRect = Rect.fromPoints(_selectionStart!, offset);
      notifyListeners();
      return;
    }

    if (_mode == DrawingMode.shape && _shapeStartPoint != null) {
      // Update shape preview based on drag
      _shapeSize = (offset - _shapeStartPoint!).distance;
      notifyListeners();
      return;
    }

    // Create drawing point with device type information
    final point = deviceKind != null
        ? DrawingPoint.fromPointer(
            offset: offset,
            pressure: pressure,
            kind: deviceKind,
            tiltX: tiltX,
            tiltY: tiltY,
          )
        : DrawingPoint(offset: offset, pressure: pressure);

    _currentStroke.add(point);
    notifyListeners();
  }

  void endDrawing() {
    if (_mode == DrawingMode.select || _mode == DrawingMode.wrongAnswerClip) {
      _isSelecting = false;
      // For wrongAnswerClip mode, keep the selection rect visible
      // UI will show popup dialog to complete clipping
      notifyListeners();
      return;
    }

    if (_mode == DrawingMode.shape && _shapeStartPoint != null) {
      // Create the shape
      List<DrawingPoint> shapePoints = [];

      if (_selectedShape3D != null) {
        // Draw 3D shape
        switch (_selectedShape3D!) {
          case ShapeType3D.cube:
            shapePoints = _shapeDrawingService.drawCube(_shapeStartPoint!, _shapeSize);
            break;
          case ShapeType3D.cylinder:
            shapePoints = _shapeDrawingService.drawCylinder(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
            break;
          case ShapeType3D.pyramid:
            shapePoints = _shapeDrawingService.drawPyramid(_shapeStartPoint!, _shapeSize, _shapeSize);
            break;
          case ShapeType3D.sphere:
            shapePoints = _shapeDrawingService.drawSphere(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType3D.cone:
            shapePoints = _shapeDrawingService.drawCone(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
            break;
          case ShapeType3D.prism:
            shapePoints = _shapeDrawingService.drawPrism(_shapeStartPoint!, _shapeSize, _shapeSize);
            break;
        }
      } else {
        // Draw 2D shape
        switch (_selectedShape2D) {
          case ShapeType2D.circle:
            shapePoints = _shapeDrawingService.drawCircle(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.rectangle:
            shapePoints = _shapeDrawingService.drawRectangle(_shapeStartPoint!, _shapeSize, _shapeSize * 0.6);
            break;
          case ShapeType2D.square:
            shapePoints = _shapeDrawingService.drawSquare(_shapeStartPoint!, _shapeSize);
            break;
          case ShapeType2D.triangle:
            shapePoints = _shapeDrawingService.drawTriangle(
              _shapeStartPoint!,
              _shapeSize,
              angle1: _triangleAngle1,
              angle2: _triangleAngle2,
              angle3: _triangleAngle3,
            );
            break;
          case ShapeType2D.line:
            final endPoint = Offset(
              _shapeStartPoint!.dx + _shapeSize,
              _shapeStartPoint!.dy,
            );
            shapePoints = _shapeDrawingService.drawLine(_shapeStartPoint!, endPoint);
            break;
          case ShapeType2D.arrow:
            final endPoint = Offset(
              _shapeStartPoint!.dx + _shapeSize,
              _shapeStartPoint!.dy,
            );
            shapePoints = _shapeDrawingService.drawArrow(_shapeStartPoint!, endPoint);
            break;
          case ShapeType2D.pentagon:
            shapePoints = _shapeDrawingService.drawPentagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.hexagon:
            shapePoints = _shapeDrawingService.drawHexagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.star:
            shapePoints = _shapeDrawingService.drawStar(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.parallelogram:
            shapePoints = _shapeDrawingService.drawParallelogram(_shapeStartPoint!, _shapeSize, _shapeSize * 0.6);
            break;
          case ShapeType2D.rhombus:
            shapePoints = _shapeDrawingService.drawRhombus(_shapeStartPoint!, _shapeSize);
            break;
          case ShapeType2D.trapezoid:
            shapePoints = _shapeDrawingService.drawTrapezoid(_shapeStartPoint!, _shapeSize * 0.6, _shapeSize, _shapeSize * 0.6);
            break;
          case ShapeType2D.ellipse:
            shapePoints = _shapeDrawingService.drawEllipse(_shapeStartPoint!, _shapeSize / 2, _shapeSize / 3);
            break;
          case ShapeType2D.sector:
            shapePoints = _shapeDrawingService.drawSector(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.arc:
            shapePoints = _shapeDrawingService.drawArc(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.rightAngle:
            shapePoints = _shapeDrawingService.drawRightAngle(_shapeStartPoint!, _shapeSize);
            break;
          case ShapeType2D.tangent:
            final touchPoint = Offset(_shapeStartPoint!.dx + _shapeSize / 2, _shapeStartPoint!.dy);
            shapePoints = _shapeDrawingService.drawTangent(_shapeStartPoint!, _shapeSize / 3, touchPoint);
            break;
          case ShapeType2D.chord:
            shapePoints = _shapeDrawingService.drawChord(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.heptagon:
            shapePoints = _shapeDrawingService.drawHeptagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.octagon:
            shapePoints = _shapeDrawingService.drawOctagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.nonagon:
            shapePoints = _shapeDrawingService.drawNonagon(_shapeStartPoint!, _shapeSize / 2);
            break;
          case ShapeType2D.decagon:
            shapePoints = _shapeDrawingService.drawDecagon(_shapeStartPoint!, _shapeSize / 2);
            break;
        }
      }

      if (shapePoints.isNotEmpty) {
        final penProps = _getAdvancedPenProperties();
        final stroke = DrawingStroke(
          points: shapePoints,
          color: _currentColor,
          width: _lineWidth,
          opacity: _opacity,
          isEraser: false,
          penType: penProps['penType'],
          gradientColors: penProps['gradientColors'],
          enableGlow: penProps['enableGlow'],
          glitterDensity: penProps['glitterDensity'],
          smoothing: penProps['smoothing'],
          tapering: penProps['tapering'],
          pressureSensitivity: penProps['pressureSensitivity'],
        );
        // Add stroke to current layer instead of _strokes
        if (_currentLayerIndex >= 0 && _currentLayerIndex < _layers.length) {
          _layers[_currentLayerIndex].strokes.add(stroke);

          // Record history action
          _historyManager.recordAction(HistoryAction(
            type: HistoryActionType.addStroke,
            layerId: _layers[_currentLayerIndex].id,
            data: stroke,
            description: 'Shape on ${_layers[_currentLayerIndex].name}',
            index: _layers[_currentLayerIndex].strokes.length - 1,
          ));

          // Add audio sync point if recording
          if (_audioService.isRecording) {
            final strokeIndex = _layers[_currentLayerIndex].strokes.length - 1;
            _audioService.addSyncPoint(strokeIndex, description: 'Shape on ${_layers[_currentLayerIndex].name}');
          }
        } else {
          _strokes.add(stroke);  // Fallback
          // Add audio sync point if recording
          if (_audioService.isRecording) {
            _audioService.addSyncPoint(_strokes.length - 1, description: 'Shape');
          }
        }
      }

      _shapeStartPoint = null;
      notifyListeners();
      return;
    }

    if (_currentStroke.isNotEmpty) {
      DrawingStroke stroke;
      final penProps = _getAdvancedPenProperties();

      // Apply stroke smoothing and jitter reduction
      List<DrawingPoint> processedPoints = List.from(_currentStroke);

      // Remove jitter (micro-movements)
      processedPoints = StrokeSmoother.removeJitter(processedPoints, minDistance: 1.5);

      // Apply smoothing based on pen settings
      final smoothingFactor = penProps['smoothing'] ?? 0.0;
      if (smoothingFactor > 0) {
        processedPoints = StrokeSmoother.smoothPoints(processedPoints, smoothingFactor);
      }

      // Apply velocity-based width adjustment if pen supports it
      final currentPen = _advancedPens.firstWhere(
        (p) => p.id == _selectedAdvancedPenId,
        orElse: () => _advancedPens.first,
      );
      if (currentPen.velocityBased) {
        processedPoints = StrokeSmoother.applyVelocityAdjustment(
          processedPoints,
          velocityFactor: 0.3,
        );
      }

      // Try shape recognition if auto-shape is enabled
      if (_autoShapeEnabled && _mode == DrawingMode.pen) {
        final recognizedShape = _shapeService.recognizeShape(_currentStroke);

        if (recognizedShape != null) {
          // Convert recognized shape to stroke
          stroke = DrawingStroke(
            points: recognizedShape.points.map((offset) =>
              DrawingPoint(offset: offset, pressure: 0.5)
            ).toList(),
            color: _currentColor,
            width: _lineWidth,
            opacity: _opacity,
            isEraser: false,
            penType: penProps['penType'],
            gradientColors: penProps['gradientColors'],
            enableGlow: penProps['enableGlow'],
            glitterDensity: penProps['glitterDensity'],
            smoothing: penProps['smoothing'],
            tapering: penProps['tapering'],
            pressureSensitivity: penProps['pressureSensitivity'],
          );
        } else {
          // Use processed (smoothed) stroke
          stroke = DrawingStroke(
            points: processedPoints,
            color: _currentColor,
            width: _lineWidth,
            opacity: _opacity,
            isEraser: _mode == DrawingMode.eraser,
            penType: penProps['penType'],
            gradientColors: penProps['gradientColors'],
            enableGlow: penProps['enableGlow'],
            glitterDensity: penProps['glitterDensity'],
            smoothing: penProps['smoothing'],
            tapering: penProps['tapering'],
            pressureSensitivity: penProps['pressureSensitivity'],
          );
        }
      } else {
        stroke = DrawingStroke(
          points: processedPoints,
          color: _currentColor,
          width: _lineWidth,
          opacity: _opacity,
          isEraser: _mode == DrawingMode.eraser,
          penType: penProps['penType'],
          gradientColors: penProps['gradientColors'],
          enableGlow: penProps['enableGlow'],
          glitterDensity: penProps['glitterDensity'],
          smoothing: penProps['smoothing'],
          tapering: penProps['tapering'],
          pressureSensitivity: penProps['pressureSensitivity'],
        );
      }

      // Add stroke to current layer instead of _strokes
      if (_currentLayerIndex >= 0 && _currentLayerIndex < _layers.length) {
        _layers[_currentLayerIndex].strokes.add(stroke);

        // Record history action
        _historyManager.recordAction(HistoryAction(
          type: HistoryActionType.addStroke,
          layerId: _layers[_currentLayerIndex].id,
          data: stroke,
          description: 'Stroke on ${_layers[_currentLayerIndex].name}',
          index: _layers[_currentLayerIndex].strokes.length - 1,
        ));

        // Add audio sync point if recording
        if (_audioService.isRecording) {
          final strokeIndex = _layers[_currentLayerIndex].strokes.length - 1;
          _audioService.addSyncPoint(strokeIndex, description: 'Layer ${_layers[_currentLayerIndex].name}');
        }
      } else {
        _strokes.add(stroke);  // Fallback
        // Add audio sync point if recording
        if (_audioService.isRecording) {
          _audioService.addSyncPoint(_strokes.length - 1);
        }
      }
      _currentStroke.clear();

      // Auto-save to current note
      _saveToCurrentNote();

      // Mark unsaved changes for auto-save system
      _autoSaveService.markUnsavedChanges(isStroke: true);
    }
    notifyListeners();
  }

  List<DrawingPoint> get currentStroke => _currentStroke;

  // Get preview shape for current shape mode
  List<DrawingPoint> getShapePreview() {
    if (_mode != DrawingMode.shape || _shapeStartPoint == null) {
      return [];
    }

    if (_selectedShape3D != null) {
      switch (_selectedShape3D!) {
        case ShapeType3D.cube:
          return _shapeDrawingService.drawCube(_shapeStartPoint!, _shapeSize);
        case ShapeType3D.cylinder:
          return _shapeDrawingService.drawCylinder(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
        case ShapeType3D.pyramid:
          return _shapeDrawingService.drawPyramid(_shapeStartPoint!, _shapeSize, _shapeSize);
        case ShapeType3D.sphere:
          return _shapeDrawingService.drawSphere(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType3D.cone:
          return _shapeDrawingService.drawCone(_shapeStartPoint!, _shapeSize / 2, _shapeSize);
        case ShapeType3D.prism:
          return _shapeDrawingService.drawPrism(_shapeStartPoint!, _shapeSize, _shapeSize);
      }
    } else {
      switch (_selectedShape2D) {
        case ShapeType2D.circle:
          return _shapeDrawingService.drawCircle(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.rectangle:
          return _shapeDrawingService.drawRectangle(_shapeStartPoint!, _shapeSize, _shapeSize * 0.6);
        case ShapeType2D.square:
          return _shapeDrawingService.drawSquare(_shapeStartPoint!, _shapeSize);
        case ShapeType2D.triangle:
          return _shapeDrawingService.drawTriangle(
            _shapeStartPoint!,
            _shapeSize,
            angle1: _triangleAngle1,
            angle2: _triangleAngle2,
            angle3: _triangleAngle3,
          );
        case ShapeType2D.line:
          final endPoint = Offset(
            _shapeStartPoint!.dx + _shapeSize,
            _shapeStartPoint!.dy,
          );
          return _shapeDrawingService.drawLine(_shapeStartPoint!, endPoint);
        case ShapeType2D.arrow:
          final endPoint = Offset(
            _shapeStartPoint!.dx + _shapeSize,
            _shapeStartPoint!.dy,
          );
          return _shapeDrawingService.drawArrow(_shapeStartPoint!, endPoint);
        case ShapeType2D.pentagon:
          return _shapeDrawingService.drawPentagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.hexagon:
          return _shapeDrawingService.drawHexagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.star:
          return _shapeDrawingService.drawStar(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.parallelogram:
          return _shapeDrawingService.drawParallelogram(_shapeStartPoint!, _shapeSize, _shapeSize * 0.6);
        case ShapeType2D.rhombus:
          return _shapeDrawingService.drawRhombus(_shapeStartPoint!, _shapeSize);
        case ShapeType2D.trapezoid:
          return _shapeDrawingService.drawTrapezoid(_shapeStartPoint!, _shapeSize * 0.6, _shapeSize, _shapeSize * 0.6);
        case ShapeType2D.ellipse:
          return _shapeDrawingService.drawEllipse(_shapeStartPoint!, _shapeSize / 2, _shapeSize / 3);
        case ShapeType2D.sector:
          return _shapeDrawingService.drawSector(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.arc:
          return _shapeDrawingService.drawArc(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.rightAngle:
          return _shapeDrawingService.drawRightAngle(_shapeStartPoint!, _shapeSize);
        case ShapeType2D.tangent:
          final touchPoint = Offset(_shapeStartPoint!.dx + _shapeSize / 2, _shapeStartPoint!.dy);
          return _shapeDrawingService.drawTangent(_shapeStartPoint!, _shapeSize / 3, touchPoint);
        case ShapeType2D.chord:
          return _shapeDrawingService.drawChord(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.heptagon:
          return _shapeDrawingService.drawHeptagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.octagon:
          return _shapeDrawingService.drawOctagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.nonagon:
          return _shapeDrawingService.drawNonagon(_shapeStartPoint!, _shapeSize / 2);
        case ShapeType2D.decagon:
          return _shapeDrawingService.drawDecagon(_shapeStartPoint!, _shapeSize / 2);
      }
    }
  }

  void undo() {
    final action = _historyManager.undo();
    if (action == null) return;

    _performUndoAction(action);
    notifyListeners();
  }

  void redo() {
    final action = _historyManager.redo();
    if (action == null) return;

    _performRedoAction(action);
    notifyListeners();
  }

  void _performUndoAction(HistoryAction action) {
    switch (action.type) {
      case HistoryActionType.addStroke:
        // Remove the added stroke
        final layerIndex = _layers.indexWhere((l) => l.id == action.layerId);
        if (layerIndex != -1 && action.index != null) {
          if (action.index! < _layers[layerIndex].strokes.length) {
            _layers[layerIndex].strokes.removeAt(action.index!);
          }
        }
        break;

      case HistoryActionType.removeStroke:
        // Re-add the removed stroke
        final layerIndex = _layers.indexWhere((l) => l.id == action.layerId);
        if (layerIndex != -1 && action.data is DrawingStroke && action.index != null) {
          _layers[layerIndex].strokes.insert(action.index!, action.data as DrawingStroke);
        }
        break;

      case HistoryActionType.addText:
        // Remove the added text
        if (action.data is TextObject) {
          _textObjects.removeWhere((obj) => obj.id == (action.data as TextObject).id);
        }
        break;

      case HistoryActionType.removeText:
        // Re-add the removed text
        if (action.data is TextObject) {
          _textObjects.add(action.data as TextObject);
        }
        break;

      case HistoryActionType.moveText:
        // Move back to previous position
        if (action.data is String && action.previousData is Offset) {
          final index = _textObjects.indexWhere((obj) => obj.id == action.data);
          if (index != -1) {
            _textObjects[index] = _textObjects[index].copyWith(position: action.previousData as Offset);
          }
        }
        break;

      case HistoryActionType.updateText:
        // Restore previous text
        if (action.data is String && action.previousData is String) {
          final index = _textObjects.indexWhere((obj) => obj.id == action.data);
          if (index != -1) {
            _textObjects[index] = _textObjects[index].copyWith(text: action.previousData as String);
          }
        }
        break;

      case HistoryActionType.addLayer:
        // Remove the added layer
        if (action.index != null && action.index! < _layers.length) {
          _layers.removeAt(action.index!);
        }
        break;

      case HistoryActionType.removeLayer:
        // Re-add the removed layer
        if (action.data is app_layer.Layer && action.index != null) {
          _layers.insert(action.index!, action.data as app_layer.Layer);
        }
        break;

      case HistoryActionType.clear:
        // This would require storing all previous state - complex
        // For now, we won't support undoing clear
        break;

      default:
        break;
    }

    _saveToCurrentNote();
  }

  void _performRedoAction(HistoryAction action) {
    switch (action.type) {
      case HistoryActionType.addStroke:
        // Re-add the stroke
        final layerIndex = _layers.indexWhere((l) => l.id == action.layerId);
        if (layerIndex != -1 && action.data is DrawingStroke && action.index != null) {
          // Make sure we don't exceed the list length
          if (action.index! <= _layers[layerIndex].strokes.length) {
            _layers[layerIndex].strokes.insert(action.index!, action.data as DrawingStroke);
          }
        }
        break;

      case HistoryActionType.removeStroke:
        // Remove the stroke again
        final layerIndex = _layers.indexWhere((l) => l.id == action.layerId);
        if (layerIndex != -1 && action.index != null) {
          if (action.index! < _layers[layerIndex].strokes.length) {
            _layers[layerIndex].strokes.removeAt(action.index!);
          }
        }
        break;

      case HistoryActionType.addText:
        // Re-add the text
        if (action.data is TextObject) {
          _textObjects.add(action.data as TextObject);
        }
        break;

      case HistoryActionType.removeText:
        // Remove the text again
        if (action.data is TextObject) {
          _textObjects.removeWhere((obj) => obj.id == (action.data as TextObject).id);
        }
        break;

      case HistoryActionType.moveText:
        // Move to new position
        if (action.data is String && action.previousData is Offset) {
          final index = _textObjects.indexWhere((obj) => obj.id == action.data);
          if (index != -1) {
            // The "data" field contains the textObject ID, we need to get the new position from somewhere
            // This is a bit tricky - we might need to redesign this
          }
        }
        break;

      case HistoryActionType.updateText:
        // Apply the new text
        if (action.data is String) {
          final parts = action.data.toString().split('::');
          if (parts.length == 2) {
            final id = parts[0];
            final newText = parts[1];
            final index = _textObjects.indexWhere((obj) => obj.id == id);
            if (index != -1) {
              _textObjects[index] = _textObjects[index].copyWith(text: newText);
            }
          }
        }
        break;

      case HistoryActionType.addLayer:
        // Re-add the layer
        if (action.data is app_layer.Layer && action.index != null) {
          _layers.insert(action.index!, action.data as app_layer.Layer);
        }
        break;

      case HistoryActionType.removeLayer:
        // Remove the layer again
        if (action.index != null && action.index! < _layers.length) {
          _layers.removeAt(action.index!);
        }
        break;

      default:
        break;
    }

    _saveToCurrentNote();
  }

  void clear() {
    // Record clear action (would need to store all data for proper undo)
    _historyManager.recordAction(HistoryAction(
      type: HistoryActionType.clear,
      data: null,
      description: 'Clear all',
    ));

    _strokes.clear();

    // Clear all layers
    for (var layer in _layers) {
      layer.strokes.clear();
    }

    _textObjects.clear();
    _saveToCurrentNote();
    notifyListeners();
  }

  void clearSelection() {
    _selectionRect = null;
    _selectionStart = null;
    notifyListeners();
  }

  // Convert selected strokes to shapes
  void convertSelectionToShapes() {
    if (_selectionRect == null) return;

    // Find strokes within selection
    final selectedIndices = <int>[];
    for (int i = 0; i < _strokes.length; i++) {
      final stroke = _strokes[i];
      if (_isStrokeInSelection(stroke, _selectionRect!)) {
        selectedIndices.add(i);
      }
    }

    // Try to recognize and replace each stroke
    for (final index in selectedIndices.reversed) {
      final stroke = _strokes[index];
      final recognizedShape = _shapeService.recognizeShape(stroke.points);
      
      if (recognizedShape != null) {
        // Replace with perfect shape
        _strokes[index] = DrawingStroke(
          points: recognizedShape.points.map((offset) =>
            DrawingPoint(offset: offset, pressure: 0.5)
          ).toList(),
          color: stroke.color,
          width: stroke.width,
          opacity: stroke.opacity,
          isEraser: stroke.isEraser,
          penType: stroke.penType,
          gradientColors: stroke.gradientColors,
          enableGlow: stroke.enableGlow,
          glitterDensity: stroke.glitterDensity,
          smoothing: stroke.smoothing,
          tapering: stroke.tapering,
          pressureSensitivity: stroke.pressureSensitivity,
        );
      }
    }

    if (selectedIndices.isNotEmpty) {
      // State changes are tracked through HistoryManager
      clearSelection();
      notifyListeners();
    }
  }

  bool _isStrokeInSelection(DrawingStroke stroke, Rect selection) {
    // Check if any point of the stroke is within selection
    for (final point in stroke.points) {
      if (selection.contains(point.offset)) {
        return true;
      }
    }
    return false;
  }

  Future<void> saveImage(GlobalKey repaintBoundaryKey) async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        await Gal.putImageBytes(
          pngBytes,
          name: 'note_${DateTime.now().millisecondsSinceEpoch}',
        );
        print('Image saved successfully');
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<Map<String, dynamic>?> recognizeSelection(GlobalKey repaintBoundaryKey) async {
    if (_selectionRect == null) return null;

    _isProcessingOCR = true;
    notifyListeners();

    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      canvas.drawImageRect(
        fullImage,
        _selectionRect!,
        Rect.fromLTWH(0, 0, _selectionRect!.width, _selectionRect!.height),
        Paint(),
      );
      
      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(
        _selectionRect!.width.toInt(),
        _selectionRect!.height.toInt(),
      );

      final result = await _ocrService.processHandwriting(croppedImage);

      _isProcessingOCR = false;
      notifyListeners();

      return result;
    } catch (e) {
      print('Error recognizing text: $e');
      _isProcessingOCR = false;
      notifyListeners();
      return null;
    }
  }

  // Convert OCR result to LaTeX text object
  Future<void> convertSelectionToLatex(GlobalKey repaintBoundaryKey) async {
    final result = await recognizeSelection(repaintBoundaryKey);

    if (result != null && _selectionRect != null) {
      final text = result['text'] as String;
      final isMath = result['isMath'] as bool;
      final latex = result['latex'] as String;

      if (text.isNotEmpty) {
        // Add as text object at selection center
        final center = _selectionRect!.center;
        _textInputPosition = center;

        if (isMath && latex.isNotEmpty) {
          // Add as LaTeX
          addTextObject(latex, type: TextType.latex);
        } else {
          // Add as normal text
          addTextObject(text, type: TextType.normal);
        }

        clearSelection();
      }
    }
  }

  // Double-tap OCR conversion: Convert strokes at position to text
  // Preserves layout by maintaining position and size of recognized text
  Future<void> convertStrokesToTextAtPosition(
    Offset position,
    GlobalKey repaintBoundaryKey,
  ) async {
    try {
      // Create a selection rect around the tap position (150x150px area)
      const selectionSize = 150.0;
      final selectionRect = Rect.fromCenter(
        center: position,
        width: selectionSize,
        height: selectionSize,
      );

      // Find strokes within this area across all layers
      final List<({int layerIndex, int strokeIndex, DrawingStroke stroke})> strokesInArea = [];

      for (int i = 0; i < _layers.length; i++) {
        final layer = _layers[i];
        if (!layer.isVisible) continue; // Skip invisible layers

        for (int j = 0; j < layer.strokes.length; j++) {
          final stroke = layer.strokes[j];
          if (_isStrokeInSelection(stroke, selectionRect)) {
            strokesInArea.add((layerIndex: i, strokeIndex: j, stroke: stroke));
          }
        }
      }

      // If no strokes found, return early
      if (strokesInArea.isEmpty) {
        print('No strokes found at position for OCR conversion');
        return;
      }

      // Render the strokes in the selection area to an image
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);

      // Create a recorder to capture just the selected area
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the selected portion
      canvas.drawImageRect(
        fullImage,
        selectionRect,
        Rect.fromLTWH(0, 0, selectionRect.width, selectionRect.height),
        Paint(),
      );

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(
        selectionRect.width.toInt(),
        selectionRect.height.toInt(),
      );

      // Perform OCR with layout preservation
      final textBlocks = await _ocrService.recognizeTextWithLayout(
        croppedImage,
        Rect.fromLTWH(0, 0, selectionRect.width, selectionRect.height),
      );

      // Convert each recognized text block to a TextObject
      for (final block in textBlocks) {
        if (block.text.trim().isEmpty) continue;

        // Calculate absolute position (block.position is relative to selectionRect)
        final absolutePosition = Offset(
          selectionRect.left + block.position.dx,
          selectionRect.top + block.position.dy,
        );

        // Check if this is a math formula
        final isMath = _ocrService.isMathFormula(block.text);
        final text = isMath ? _ocrService.convertToLaTeX(block.text) : block.text;

        // Set text input position for addTextObject
        _textInputPosition = absolutePosition;

        // Add the text object
        addTextObject(
          text,
          type: isMath ? TextType.latex : TextType.normal,
        );
      }

      // Remove the original strokes that were converted
      // Process in reverse order to maintain indices
      strokesInArea.sort((a, b) {
        final layerCompare = b.layerIndex.compareTo(a.layerIndex);
        if (layerCompare != 0) return layerCompare;
        return b.strokeIndex.compareTo(a.strokeIndex);
      });

      for (final strokeInfo in strokesInArea) {
        final layer = _layers[strokeInfo.layerIndex];
        if (strokeInfo.strokeIndex < layer.strokes.length) {
          // Record history for each removed stroke
          _historyManager.recordAction(HistoryAction(
            type: HistoryActionType.removeStroke,
            layerId: layer.id,
            data: strokeInfo.stroke,
            description: 'Remove stroke (OCR conversion)',
            index: strokeInfo.strokeIndex,
          ));

          layer.strokes.removeAt(strokeInfo.strokeIndex);
        }
      }

      _saveToCurrentNote();
      notifyListeners();

      print('OCR conversion completed: ${textBlocks.length} text blocks recognized');
    } catch (e) {
      print('Error converting strokes to text: $e');
    }
  }

  // Text input methods
  void startTextInput(Offset position) {
    _textInputPosition = position;
    notifyListeners();
  }

  void addTextObject(String text, {TextType type = TextType.normal}) {
    if (_textInputPosition == null || text.trim().isEmpty) return;

    final textObj = TextObject(
      text: text,
      position: _textInputPosition!,
      color: _currentColor,
      type: type,
    );

    _textObjects.add(textObj);
    _textInputPosition = null;

    // Record history action
    _historyManager.recordAction(HistoryAction(
      type: HistoryActionType.addText,
      data: textObj,
      description: 'Add text: ${text.substring(0, text.length > 20 ? 20 : text.length)}...',
    ));

    // Auto-save to current note
    _saveToCurrentNote();

    notifyListeners();
  }

  void selectTextObject(TextObject? textObj) {
    _selectedTextObject = textObj;
    notifyListeners();
  }

  void updateTextObject(String id, String newText) {
    final index = _textObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      _textObjects[index] = _textObjects[index].copyWith(text: newText);
      notifyListeners();
    }
  }

  void deleteTextObject(String id) {
    final index = _textObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      final removedObj = _textObjects[index];

      // Record history action
      _historyManager.recordAction(HistoryAction(
        type: HistoryActionType.removeText,
        data: removedObj,
        description: 'Delete text',
      ));

      _textObjects.removeAt(index);
      if (_selectedTextObject?.id == id) {
        _selectedTextObject = null;
      }
      _saveToCurrentNote();
      notifyListeners();
    }
  }

  void moveTextObject(String id, Offset newPosition) {
    final index = _textObjects.indexWhere((obj) => obj.id == id);
    if (index != -1) {
      final previousPosition = _textObjects[index].position;

      // Record history action
      _historyManager.recordAction(HistoryAction(
        type: HistoryActionType.moveText,
        data: id,
        previousData: previousPosition,
        description: 'Move text',
      ));

      _textObjects[index] = _textObjects[index].copyWith(position: newPosition);
      _saveToCurrentNote();
      notifyListeners();
    }
  }

  void cancelTextInput() {
    _textInputPosition = null;
    notifyListeners();
  }

  // Settings methods
  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _isDarkMode = newSettings.isDarkMode;
    _autoShapeEnabled = newSettings.autoShapeEnabled;
    notifyListeners();
  }

  void togglePalmRejection() {
    _settings = _settings.copyWith(palmRejection: !_settings.palmRejection);
    notifyListeners();
  }

  void toggleGridLines() {
    _settings = _settings.copyWith(showGridLines: !_settings.showGridLines);
    notifyListeners();
  }

  // Toolbar customization methods
  void togglePenTool() {
    _settings = _settings.copyWith(showPenTool: !_settings.showPenTool);
    notifyListeners();
  }

  void toggleEraserTool() {
    _settings = _settings.copyWith(showEraserTool: !_settings.showEraserTool);
    notifyListeners();
  }

  void toggleSelectTool() {
    _settings = _settings.copyWith(showSelectTool: !_settings.showSelectTool);
    notifyListeners();
  }

  void toggleShapeTool() {
    _settings = _settings.copyWith(showShapeTool: !_settings.showShapeTool);
    notifyListeners();
  }

  void toggleTextTool() {
    _settings = _settings.copyWith(showTextTool: !_settings.showTextTool);
    notifyListeners();
  }

  // ============================================================================
  // FAVORITE PEN MANAGEMENT
  // ============================================================================

  /// Select a favorite pen by ID
  void selectFavoritePen(String penId) {
    final pen = _settings.favoritePens.firstWhere(
      (p) => p.id == penId,
      orElse: () => _settings.favoritePens.first,
    );

    // Apply pen settings
    _currentColor = pen.color;
    _lineWidth = pen.width;
    _opacity = pen.opacity;
    _mode = DrawingMode.pen;

    // Update selected pen in settings
    _settings = _settings.copyWith(selectedFavoritePenId: penId);

    notifyListeners();
  }

  /// Add a new favorite pen
  void addFavoritePen(FavoritePen pen) {
    final updatedPens = List<FavoritePen>.from(_settings.favoritePens);

    // Limit to 5 favorite pens
    if (updatedPens.length >= 5) {
      updatedPens.removeLast();
    }

    updatedPens.add(pen);
    _settings = _settings.copyWith(favoritePens: updatedPens);
    notifyListeners();
  }

  /// Remove a favorite pen
  void removeFavoritePen(String penId) {
    final updatedPens = _settings.favoritePens.where((p) => p.id != penId).toList();
    _settings = _settings.copyWith(favoritePens: updatedPens);
    notifyListeners();
  }

  /// Update a favorite pen's settings
  void updateFavoritePen(String penId, FavoritePen updatedPen) {
    final updatedPens = _settings.favoritePens.map((p) {
      return p.id == penId ? updatedPen : p;
    }).toList();
    _settings = _settings.copyWith(favoritePens: updatedPens);
    notifyListeners();
  }

  // ============================================================================
  // ADVANCED PEN MANAGEMENT
  // ============================================================================

  /// Select an advanced pen
  void selectAdvancedPen(String penId) {
    final pen = _advancedPens.firstWhere(
      (p) => p.id == penId,
      orElse: () => _advancedPens.first,
    );

    // Apply pen settings
    _currentColor = pen.color;
    _lineWidth = pen.width;
    _opacity = pen.opacity;
    _pressureStabilization = 1.0 - pen.pressureSensitivity; // Invert for compatibility
    _mode = DrawingMode.pen;

    _selectedAdvancedPenId = penId;
    notifyListeners();
  }

  /// Get current advanced pen properties for stroke creation
  Map<String, dynamic> _getAdvancedPenProperties() {
    final selectedPen = selectedAdvancedPen;
    if (selectedPen != null) {
      return {
        'penType': selectedPen.type,
        'gradientColors': selectedPen.gradientColors,
        'enableGlow': selectedPen.enableGlow,
        'glitterDensity': selectedPen.glitterDensity,
        'smoothing': selectedPen.smoothing,
        'tapering': selectedPen.tapering,
        'pressureSensitivity': selectedPen.pressureSensitivity,
      };
    }
    return {
      'penType': null,
      'gradientColors': null,
      'enableGlow': false,
      'glitterDensity': null,
      'smoothing': 0.0,
      'tapering': 0.0,
      'pressureSensitivity': 0.7,
    };
  }

  /// Add a new advanced pen
  void addAdvancedPen(AdvancedPen pen) {
    _advancedPens.add(pen);
    notifyListeners();
  }

  /// Update an advanced pen
  void updateAdvancedPen(String penId, AdvancedPen updatedPen) {
    final index = _advancedPens.indexWhere((p) => p.id == penId);
    if (index != -1) {
      _advancedPens[index] = updatedPen;

      // If this is the currently selected pen, update settings
      if (_selectedAdvancedPenId == penId) {
        _currentColor = updatedPen.color;
        _lineWidth = updatedPen.width;
        _opacity = updatedPen.opacity;
        _pressureStabilization = 1.0 - updatedPen.pressureSensitivity;
      }

      notifyListeners();
    }
  }

  /// Delete an advanced pen
  void deleteAdvancedPen(String penId) {
    _advancedPens.removeWhere((p) => p.id == penId);

    // If deleted pen was selected, select another
    if (_selectedAdvancedPenId == penId && _advancedPens.isNotEmpty) {
      selectAdvancedPen(_advancedPens.first.id);
    }

    notifyListeners();
  }

  /// Get currently selected advanced pen
  AdvancedPen? get selectedAdvancedPen {
    if (_selectedAdvancedPenId == null) return null;
    try {
      return _advancedPens.firstWhere((p) => p.id == _selectedAdvancedPenId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // THEME MANAGEMENT
  // ============================================================================

  /// Set app theme type
  void setThemeType(AppThemeType themeType) {
    _settings = _settings.copyWith(themeType: themeType);

    // Update dark mode based on theme
    _isDarkMode = themeType == AppThemeType.darkMode;

    // Save to persistence
    _appStateService.saveThemeType(themeType.name);

    notifyListeners();
  }

  /// Get current background color based on theme
  Color getBackgroundColor() {
    return _settings.getBackgroundColor();
  }

  /// Set custom font family
  void setCustomFont(String? fontFamily) {
    _settings = _settings.copyWith(customFontFamily: fontFamily);

    // Save to persistence
    _appStateService.saveCustomFont(fontFamily);

    notifyListeners();
  }

  // Audio recording methods
  Future<bool> startAudioRecording() async {
    final result = await _audioService.startRecording();
    notifyListeners();
    return result;
  }

  Future<String?> stopAudioRecording() async {
    final path = await _audioService.stopRecording();
    notifyListeners();
    return path;
  }

  Future<void> toggleAudioRecording() async {
    if (_audioService.isRecording) {
      await stopAudioRecording();
    } else {
      await startAudioRecording();
    }
  }

  Future<void> playAudioRecording(String path) async {
    await _audioService.playRecording(path);
    notifyListeners();
  }

  Future<void> stopAudioPlayback() async {
    await _audioService.stopPlayback();
    notifyListeners();
  }

  /// Switch to a different note
  void switchToNote(String noteId) {
    _noteService.switchToNote(noteId);
    if (_noteService.currentNote != null) {
      _loadNoteData(_noteService.currentNote!);

      // Save as last opened note
      _saveCurrentSession();
    }
  }

  /// Update current note's template
  void updateNoteTemplate(NoteTemplate template) {
    _noteService.updateCurrentNote(template: template);
    notifyListeners();
  }

  /// Update current note's title
  void updateNoteTitle(String title) {
    if (_noteService.currentNote == null) return;
    _noteService.updateNoteTitle(_noteService.currentNote!.id, title);
    notifyListeners();
  }

  /// Add tags to current note
  void addTagsToCurrentNote(List<String> tags) {
    if (_noteService.currentNote == null) return;
    _noteService.addTagsToNote(_noteService.currentNote!.id, tags);
    notifyListeners();
  }

  /// Navigate to specific page
  void goToPage(int pageIndex) {
    _pageManager.goToPage(pageIndex);

    // Save current session
    _saveCurrentSession();

    notifyListeners();
  }

  /// Save current session (note + page)
  void _saveCurrentSession() {
    if (_noteService.currentNote != null) {
      _appStateService.saveLastOpenedNote(
        noteId: _noteService.currentNote!.id,
        pageIndex: _pageManager.currentPageIndex,
      );
    }
  }

  /// Add a new page
  void addNewPage() {
    _pageManager.addPage();
    notifyListeners();
  }

  /// Delete a page
  void deletePage(int pageIndex) {
    _pageManager.deletePage(pageIndex);
    notifyListeners();
  }

  /// Get or create hybrid input detector
  HybridInputDetector getHybridInputDetector(GlobalKey repaintBoundaryKey) {
    _hybridInputDetector ??= HybridInputDetector(this, repaintBoundaryKey);
    return _hybridInputDetector!;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _audioService.dispose();
    _noteService.dispose();
    _pageManager.dispose();
    super.dispose();
  }
}
