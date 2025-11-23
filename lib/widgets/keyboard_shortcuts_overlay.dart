import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/keyboard_shortcuts.dart';
import '../utils/responsive_util.dart';

/// Keyboard shortcuts help overlay
/// Shows available shortcuts to users (press ? to toggle)
class KeyboardShortcutsOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const KeyboardShortcutsOverlay({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtil.isTablet(context);
    final shortcuts = KeyboardShortcuts.getShortcutHints();

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping the panel
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: isTablet ? 600 : 340,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.keyboard,
                                color: Colors.white,
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Keyboard Shortcuts',
                                    style: TextStyle(
                                      fontSize: isTablet ? 24 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Press ? to toggle this panel',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: onClose,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),

                      // Shortcuts list
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                context,
                                'Tools',
                                Icons.build,
                                {
                                  'Select': 'V',
                                  'Pen': 'P',
                                  'Eraser': 'E',
                                  'Rectangle': 'R',
                                  'Text': 'T',
                                  'Shape': 'S',
                                },
                                isTablet,
                              ),
                              SizedBox(height: isTablet ? 24 : 20),
                              _buildSection(
                                context,
                                'Edit',
                                Icons.edit,
                                {
                                  'Undo': 'Ctrl+Z',
                                  'Redo': 'Ctrl+Y',
                                  'Delete': 'Del',
                                  'Select All': 'Ctrl+A',
                                },
                                isTablet,
                              ),
                              SizedBox(height: isTablet ? 24 : 20),
                              _buildSection(
                                context,
                                'View',
                                Icons.visibility,
                                {
                                  'Zoom In': 'Ctrl++',
                                  'Zoom Out': 'Ctrl+-',
                                  'Reset Zoom': 'Ctrl+0',
                                  'Focus Mode': 'F',
                                },
                                isTablet,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer
                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.03),
                          border: Border(
                            top: BorderSide(
                              color: Colors.black.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: isTablet ? 18 : 16,
                              color: const Color(0xFF667EEA),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tip: Use keyboard shortcuts for faster workflow',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Map<String, String> shortcuts,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isTablet ? 20 : 18,
              color: const Color(0xFF667EEA),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12 : 10),
        ...shortcuts.entries.map((entry) => _buildShortcutRow(
              entry.key,
              entry.value,
              isTablet,
            )),
      ],
    );
  }

  Widget _buildShortcutRow(String label, String keys, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 6 : 5,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: const Color(0xFF667EEA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
