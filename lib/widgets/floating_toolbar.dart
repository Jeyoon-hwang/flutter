import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/responsive_util.dart';
import '../models/advanced_pen.dart';
import './pen_customizer.dart';

enum EdgeLocation { none, top, bottom, left, right }

class FloatingToolbar extends StatefulWidget {
  final GlobalKey repaintBoundaryKey;

  const FloatingToolbar({Key? key, required this.repaintBoundaryKey}) : super(key: key);

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar> with TickerProviderStateMixin {
  String? _selectedPenId;
  bool _isHidden = false; // Toolbar hidden at edge

  // Toolbar position
  double _toolbarX = 0;
  double _toolbarY = 0; // Will be set in initState to bottom
  EdgeLocation _dockedEdge = EdgeLocation.none;

  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set toolbar to bottom after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _toolbarY = MediaQuery.of(context).size.height - 150;
      });
    });

    // Slide animation for hiding/showing toolbar
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Scale animation for button press effects
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details, Size screenSize) {
    const edgeThreshold = 50.0;

    setState(() {
      // Check proximity to edges
      if (_toolbarY < edgeThreshold) {
        // Dock to top
        _dockedEdge = EdgeLocation.top;
        _toolbarY = 0;
        _isHidden = true;
      } else if (_toolbarY > screenSize.height - 100) {
        // Dock to bottom
        _dockedEdge = EdgeLocation.bottom;
        _toolbarY = screenSize.height - 80;
        _isHidden = true;
      } else if (_toolbarX < edgeThreshold) {
        // Dock to left
        _dockedEdge = EdgeLocation.left;
        _toolbarX = -300; // Hide off screen
        _isHidden = true;
      } else if (_toolbarX > screenSize.width - edgeThreshold) {
        // Dock to right
        _dockedEdge = EdgeLocation.right;
        _toolbarX = screenSize.width - 60;
        _isHidden = true;
      } else {
        _dockedEdge = EdgeLocation.none;
        _isHidden = false;
      }
    });
  }

  void _showToolbar() {
    setState(() {
      _isHidden = false;

      // Move toolbar to visible position based on docked edge
      if (_dockedEdge == EdgeLocation.left) {
        _toolbarX = 10;
      } else if (_dockedEdge == EdgeLocation.right) {
        _toolbarX = MediaQuery.of(context).size.width - 400;
      } else if (_dockedEdge == EdgeLocation.top) {
        _toolbarY = 20;
      } else if (_dockedEdge == EdgeLocation.bottom) {
        _toolbarY = MediaQuery.of(context).size.height - 150;
      }
    });
  }

  IconData _getArrowIcon() {
    switch (_dockedEdge) {
      case EdgeLocation.top:
        return Icons.keyboard_arrow_down;
      case EdgeLocation.bottom:
        return Icons.keyboard_arrow_up;
      case EdgeLocation.left:
        return Icons.keyboard_arrow_right;
      case EdgeLocation.right:
        return Icons.keyboard_arrow_left;
      default:
        return Icons.drag_handle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);
    final screenSize = MediaQuery.of(context).size;

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final advancedPens = provider.advancedPens;

        return Stack(
          children: [
            // Docked edge indicator (arrow button)
            if (_isHidden && _dockedEdge != EdgeLocation.none)
              Positioned(
                left: _dockedEdge == EdgeLocation.left ? 0 : (_dockedEdge == EdgeLocation.right ? screenSize.width - 50 : null),
                top: _dockedEdge == EdgeLocation.top ? 0 : (_dockedEdge == EdgeLocation.bottom ? null : screenSize.height / 2 - 25),
                bottom: _dockedEdge == EdgeLocation.bottom ? 0 : null,
                child: GestureDetector(
                  onTap: _showToolbar,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.95)]
                            : [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.95)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getArrowIcon(),
                      color: const Color(0xFF667EEA),
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Main draggable toolbar
            if (!_isHidden)
              Positioned(
                left: _toolbarX,
                top: _toolbarY,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _toolbarX += details.delta.dx;
                      _toolbarY += details.delta.dy;

                      // Keep within screen bounds
                      _toolbarX = _toolbarX.clamp(0.0, screenSize.width - 400);
                      _toolbarY = _toolbarY.clamp(0.0, screenSize.height - 100);
                    });
                  },
                  onPanEnd: (details) => _onDragEnd(details, screenSize),
                  child: Container(
                    width: isTablet ? 500 : 400,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDarkMode
                            ? [
                                Colors.black.withValues(alpha: 0.95),
                                Colors.black.withValues(alpha: 0.98),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.95),
                                Colors.white.withValues(alpha: 0.98),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 16,
                            vertical: isTablet ? 16 : 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Advanced Pens Section
                                    ...advancedPens.take(isTablet ? 6 : 4).map((pen) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: _buildPenButton(
                                            context,
                                            provider,
                                            pen,
                                            isSelected: pen.id == _selectedPenId,
                                            isDarkMode: isDarkMode,
                                          ),
                                        )),

                                    // Add Pen Button
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildToolButton(
                                        context,
                                        icon: Icons.add_circle_outline,
                                        label: '펜 추가',
                                        isActive: false,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          _showPenCustomizer(context, provider);
                                        },
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),

                                    // Divider
                                    Container(
                                      width: 2,
                                      height: 40,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: isDarkMode
                                              ? [
                                                  Colors.white.withValues(alpha: 0.1),
                                                  Colors.white.withValues(alpha: 0.05),
                                                ]
                                              : [
                                                  Colors.black.withValues(alpha: 0.1),
                                                  Colors.black.withValues(alpha: 0.05),
                                                ],
                                        ),
                                      ),
                                    ),

                                    // Tools Section
                                    if (provider.settings.showEraserTool) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildToolButton(
                                          context,
                                          icon: Icons.auto_fix_high,
                                          label: '지우개',
                                          isActive: provider.mode == DrawingMode.eraser,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            provider.setMode(DrawingMode.eraser);
                                          },
                                          isDarkMode: isDarkMode,
                                        ),
                                      ),
                                    ],

                                    // Clear All (only in eraser mode)
                                    if (provider.mode == DrawingMode.eraser) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildToolButton(
                                          context,
                                          icon: Icons.delete_sweep,
                                          label: '전체 지우기',
                                          isActive: false,
                                          onTap: () {
                                            _showClearAllDialog(context, provider);
                                          },
                                          isDarkMode: isDarkMode,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],

                                    if (provider.settings.showSelectTool) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildToolButton(
                                          context,
                                          icon: Icons.select_all,
                                          label: '선택',
                                          isActive: provider.mode == DrawingMode.select,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            provider.setMode(DrawingMode.select);
                                          },
                                          isDarkMode: isDarkMode,
                                        ),
                                      ),
                                    ],

                                    // Wrong Answer Clip
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildToolButton(
                                        context,
                                        icon: Icons.content_cut,
                                        label: '오답',
                                        isActive: provider.mode == DrawingMode.wrongAnswerClip,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          provider.setMode(DrawingMode.wrongAnswerClip);
                                        },
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),

                                    if (provider.settings.showShapeTool) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildToolButton(
                                          context,
                                          icon: Icons.category_outlined,
                                          label: '도형',
                                          isActive: provider.mode == DrawingMode.shape,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            provider.setMode(DrawingMode.shape);
                                          },
                                          isDarkMode: isDarkMode,
                                        ),
                                      ),
                                    ],

                                    if (provider.settings.showTextTool) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildToolButton(
                                          context,
                                          icon: Icons.text_fields,
                                          label: '텍스트',
                                          isActive: provider.mode == DrawingMode.text,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            provider.setMode(DrawingMode.text);
                                          },
                                          isDarkMode: isDarkMode,
                                        ),
                                      ),
                                    ],

                                    // Divider
                                    Container(
                                      width: 2,
                                      height: 40,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: isDarkMode
                                              ? [
                                                  Colors.white.withValues(alpha: 0.1),
                                                  Colors.white.withValues(alpha: 0.05),
                                                ]
                                              : [
                                                  Colors.black.withValues(alpha: 0.1),
                                                  Colors.black.withValues(alpha: 0.05),
                                                ],
                                        ),
                                      ),
                                    ),

                                    // Undo/Redo
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildToolButton(
                                        context,
                                        icon: Icons.undo,
                                        label: 'Undo',
                                        isActive: false,
                                        onTap: provider.canUndo
                                            ? () {
                                                HapticFeedback.mediumImpact();
                                                provider.undo();
                                              }
                                            : null,
                                        isDarkMode: isDarkMode,
                                        isEnabled: provider.canUndo,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildToolButton(
                                        context,
                                        icon: Icons.redo,
                                        label: 'Redo',
                                        isActive: false,
                                        onTap: provider.canRedo
                                            ? () {
                                                HapticFeedback.mediumImpact();
                                                provider.redo();
                                              }
                                            : null,
                                        isDarkMode: isDarkMode,
                                        isEnabled: provider.canRedo,
                                      ),
                                    ),

                                    // Template Tool
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildToolButton(
                                        context,
                                        icon: Icons.grid_on,
                                        label: '템플릿',
                                        isActive: false,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          _showTemplatePicker(context, provider);
                                        },
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPenButton(
    BuildContext context,
    DrawingProvider provider,
    AdvancedPen pen,
    {required bool isSelected, required bool isDarkMode}
  ) {
    return Tooltip(
      message: '${pen.name}\n탭: 선택 | 길게 누르기: 편집',
      preferBelow: false,
      verticalOffset: 10,
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
        },
        onTapUp: (_) {
          _scaleController.reverse();
        },
        onTapCancel: () {
          _scaleController.reverse();
        },
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedPenId = pen.id;
          });
          provider.selectAdvancedPen(pen.id);
          provider.setMode(DrawingMode.pen);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showPenCustomizer(context, provider, pen: pen);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667EEA).withValues(alpha: 0.2)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF667EEA)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pen preview
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: pen.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            // Pen name
            Text(
              pen.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
    required bool isDarkMode,
    bool isEnabled = true,
    Color? color,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      verticalOffset: 10,
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      waitDuration: const Duration(milliseconds: 500),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.3,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            splashColor: (color ?? const Color(0xFF667EEA)).withValues(alpha: 0.3),
            highlightColor: (color ?? const Color(0xFF667EEA)).withValues(alpha: 0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? (color ?? const Color(0xFF667EEA)).withValues(alpha: 0.2)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? (color ?? const Color(0xFF667EEA))
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1)),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: color ??
                        (isActive
                            ? const Color(0xFF667EEA)
                            : (isDarkMode ? Colors.white : Colors.black87)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: color ??
                          (isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPenCustomizer(BuildContext context, DrawingProvider provider, {AdvancedPen? pen}) {
    // Create a default pen if none provided
    final initialPen = pen ?? AdvancedPen.getDefaultAdvancedPens().first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PenCustomizer(
        initialPen: initialPen,
        onPenChanged: (newPen) {
          if (pen == null) {
            // Adding new pen
            provider.addAdvancedPen(newPen);
          } else {
            // Updating existing pen
            provider.updateAdvancedPen(pen.id, newPen);
          }
          setState(() {
            _selectedPenId = newPen.id;
          });
        },
        isDarkMode: provider.isDarkMode,
      ),
    );
  }

  void _showTemplatePicker(BuildContext context, DrawingProvider provider) {
    // TODO: Implement template picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('템플릿 기능은 곧 추가될 예정입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, DrawingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_sweep,
                color: Color(0xFFFF3B30),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('전체 지우기'),
          ],
        ),
        content: const Text('모든 내용을 지우시겠습니까?\n이 작업은 실행 취소할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              elevation: 0,
            ),
            child: const Text(
              '전체 지우기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
