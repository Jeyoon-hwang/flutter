import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/layer.dart';
import '../utils/responsive_util.dart';

class LayerPanel extends StatelessWidget {
  const LayerPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);

    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        if (provider.focusMode) {
          return const SizedBox.shrink(); // 포커스 모드일 때 숨김
        }

        return Positioned(
          right: isTablet ? 30 : 20,
          top: isTablet ? 100 : 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: isTablet ? 280 : 240,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: provider.isDarkMode
                        ? [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.5),
                          ]
                        : [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  border: Border.all(
                    color: provider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.layers,
                            size: isTablet ? 24 : 20,
                            color: provider.isDarkMode
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black.withOpacity(0.8),
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Text(
                            '레이어',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: provider.isDarkMode
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.8),
                            ),
                          ),
                          const Spacer(),
                          // Auto layer management toggle
                          Tooltip(
                            message: provider.autoLayerManagement
                                ? '자동 레이어 관리: 켜짐\n(콘텐츠 타입에 따라 자동 배정)'
                                : '자동 레이어 관리: 꺼짐\n(수동 레이어 선택)',
                            child: GestureDetector(
                              onTap: () => provider.toggleAutoLayerManagement(),
                              child: Container(
                                padding: EdgeInsets.all(isTablet ? 8 : 6),
                                decoration: BoxDecoration(
                                  color: provider.autoLayerManagement
                                      ? const Color(0xFF34C759).withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                                ),
                                child: Icon(
                                  provider.autoLayerManagement
                                      ? Icons.auto_awesome
                                      : Icons.auto_awesome_outlined,
                                  size: isTablet ? 20 : 18,
                                  color: provider.autoLayerManagement
                                      ? const Color(0xFF34C759)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          GestureDetector(
                            onTap: () => _showAddLayerDialog(context, provider),
                            child: Container(
                              padding: EdgeInsets.all(isTablet ? 8 : 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667EEA).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                              ),
                              child: Icon(
                                Icons.add,
                                size: isTablet ? 20 : 18,
                                color: const Color(0xFF667EEA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Layer list
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        reverse: true, // Bottom layer first
                        itemCount: provider.layers.length,
                        itemBuilder: (context, index) {
                          final layer = provider.layers[index];
                          final isSelected = index == provider.currentLayerIndex;

                          return _LayerItem(
                            layer: layer,
                            index: index,
                            isSelected: isSelected,
                            isTablet: isTablet,
                            onTap: () => provider.selectLayer(index),
                            onToggleVisibility: () => provider.toggleLayerVisibility(index),
                            onToggleLock: () => provider.toggleLayerLock(index),
                            onDelete: provider.layers.length > 1
                                ? () => provider.deleteLayer(index)
                                : null,
                            onOpacityChange: (value) => provider.setLayerOpacity(index, value),
                            isDarkMode: provider.isDarkMode,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddLayerDialog(BuildContext context, DrawingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레이어 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFF5E5CE6)),
              title: const Text('배경 레이어'),
              onTap: () {
                provider.addLayer(LayerType.background);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF007AFF)),
              title: const Text('필기 레이어'),
              onTap: () {
                provider.addLayer(LayerType.writing);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Color(0xFFFF9500)),
              title: const Text('꾸미기 레이어'),
              onTap: () {
                provider.addLayer(LayerType.decoration);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerItem extends StatelessWidget {
  final Layer layer;
  final int index;
  final bool isSelected;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;
  final VoidCallback? onDelete;
  final Function(double) onOpacityChange;
  final bool isDarkMode;

  const _LayerItem({
    required this.layer,
    required this.index,
    required this.isSelected,
    required this.isTablet,
    required this.onTap,
    required this.onToggleVisibility,
    required this.onToggleLock,
    this.onDelete,
    required this.onOpacityChange,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 6 : 4,
        ),
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected
              ? null
              : (isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Layer icon
                Container(
                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : layer.getColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Icon(
                    layer.getIcon(),
                    size: isTablet ? 20 : 16,
                    color: isSelected ? Colors.white : layer.getColor(),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),

                // Layer name
                Expanded(
                  child: Text(
                    layer.name,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black.withOpacity(0.7)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        layer.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: isTablet ? 20 : 18,
                      ),
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : (isDarkMode
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black.withOpacity(0.5)),
                      onPressed: onToggleVisibility,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: isTablet ? 32 : 28,
                        minHeight: isTablet ? 32 : 28,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        layer.isLocked ? Icons.lock : Icons.lock_open,
                        size: isTablet ? 20 : 18,
                      ),
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : (isDarkMode
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black.withOpacity(0.5)),
                      onPressed: onToggleLock,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: isTablet ? 32 : 28,
                        minHeight: isTablet ? 32 : 28,
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: isTablet ? 20 : 18,
                        ),
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : Colors.red.withOpacity(0.6),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isTablet ? 32 : 28,
                          minHeight: isTablet ? 32 : 28,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Opacity slider
            if (isSelected) ...[
              SizedBox(height: isTablet ? 8 : 6),
              Row(
                children: [
                  Icon(
                    Icons.opacity,
                    size: isTablet ? 16 : 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                        trackHeight: isTablet ? 4 : 3,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: isTablet ? 8 : 6,
                        ),
                      ),
                      child: Slider(
                        value: layer.opacity,
                        onChanged: onOpacityChange,
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    '${(layer.opacity * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
