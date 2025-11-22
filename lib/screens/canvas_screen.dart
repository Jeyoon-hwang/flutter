import 'package:flutter/material.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/header.dart';
import '../widgets/floating_toolbar.dart';
import '../widgets/slider_panel.dart';
import '../widgets/shape_palette.dart';
import '../widgets/layer_panel.dart';
import '../widgets/page_navigation.dart';
import '../widgets/version_control_panel.dart';
import '../widgets/favorite_pen_bar.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _showGestureHint = false;
  bool _showVersionControl = false; // Toggle for version control panel

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showGestureHint = true);
      }
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _showGestureHint = false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: provider.isDarkMode
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                    : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  DrawingCanvas(repaintBoundaryKey: _repaintBoundaryKey),

                  // Show header and toolbar only when not in focus mode
                  if (!provider.focusMode) ...[
                    AppHeader(repaintBoundaryKey: _repaintBoundaryKey),
                    FloatingToolbar(repaintBoundaryKey: _repaintBoundaryKey),
                  ],

                  const SliderPanel(),
                  const ShapePalette(),
                  const LayerPanel(),
                  const PageNavigation(),
                  if (_showVersionControl) const VersionControlPanel(),

                  // Favorite pen bar (always visible, minimal design)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: const FavoritePenBar(),
                    ),
                  ),
                  // Version control toggle button
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showVersionControl = !_showVersionControl;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _showVersionControl
                              ? const Color(0xFF667EEA)
                              : provider.isDarkMode
                                  ? Colors.black.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF667EEA).withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_tree,
                          color: _showVersionControl
                              ? Colors.white
                              : const Color(0xFF667EEA),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  if (_showGestureHint) _buildGestureHint(),
                  if (provider.isSelectMode) _buildSelectionHint(),
                  if (provider.isShapeMode) _buildShapeHint(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGestureHint() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '👆 두 손가락 탭: 실행 취소 | 세 손가락 탭: 다시 실행',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionHint() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '📐 드래그하여 텍스트 인식할 영역을 선택하세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShapeHint() {
    return Positioned(
      top: 80,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '⬡ 도형을 선택하고 드래그하여 그리세요',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
