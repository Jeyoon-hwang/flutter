import 'package:flutter/material.dart';

/// Panel visibility manager for controlling all floating panels
class PanelManager extends ChangeNotifier {
  // Panel visibility states
  bool _showToolbar = true;
  bool _showPenSettings = false;
  bool _showPageNavigation = true;
  bool _showSliderPanel = false;
  bool _showShapePalette = false;
  bool _showLayerPanel = false;
  bool _showVersionControl = false;

  // Getters
  bool get showToolbar => _showToolbar;
  bool get showPenSettings => _showPenSettings;
  bool get showPageNavigation => _showPageNavigation;
  bool get showSliderPanel => _showSliderPanel;
  bool get showShapePalette => _showShapePalette;
  bool get showLayerPanel => _showLayerPanel;
  bool get showVersionControl => _showVersionControl;

  // Toggle methods
  void toggleToolbar() {
    _showToolbar = !_showToolbar;
    notifyListeners();
  }

  void togglePenSettings() {
    _showPenSettings = !_showPenSettings;
    notifyListeners();
  }

  void togglePageNavigation() {
    _showPageNavigation = !_showPageNavigation;
    notifyListeners();
  }

  void toggleSliderPanel() {
    _showSliderPanel = !_showSliderPanel;
    notifyListeners();
  }

  void toggleShapePalette() {
    _showShapePalette = !_showShapePalette;
    notifyListeners();
  }

  void toggleLayerPanel() {
    _showLayerPanel = !_showLayerPanel;
    notifyListeners();
  }

  void toggleVersionControl() {
    _showVersionControl = !_showVersionControl;
    notifyListeners();
  }

  // Show/hide all panels
  void hideAll() {
    _showToolbar = false;
    _showPenSettings = false;
    _showPageNavigation = false;
    _showSliderPanel = false;
    _showShapePalette = false;
    _showLayerPanel = false;
    _showVersionControl = false;
    notifyListeners();
  }

  void showAll() {
    _showToolbar = true;
    _showPageNavigation = true;
    notifyListeners();
  }

  // Reset to defaults
  void resetToDefaults() {
    _showToolbar = true;
    _showPenSettings = false;
    _showPageNavigation = true;
    _showSliderPanel = false;
    _showShapePalette = false;
    _showLayerPanel = false;
    _showVersionControl = false;
    notifyListeners();
  }
}
