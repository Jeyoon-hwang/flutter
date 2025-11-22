import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/notes_list_screen.dart';
import './history_feedback_toast.dart';

class AppHeader extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;

  const AppHeader({Key? key, required this.repaintBoundaryKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        // Focus mode: Show minimal header
        if (provider.focusMode) {
          return Positioned(
            top: 20,
            right: 20,
            child: _ModernIconButton(
              icon: Icons.fullscreen_exit,
              onTap: provider.toggleFocusMode,
              isDarkMode: provider.isDarkMode,
              isEnabled: true,
            ),
          );
        }

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: provider.isDarkMode
                      ? [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.6),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: provider.isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.draw,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Digital Note',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _QuickNoteButton(
                          onTap: () => provider.createQuickNote(),
                          isDarkMode: provider.isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: Icons.folder_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotesListScreen(),
                              ),
                            );
                          },
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                        ),
                        const SizedBox(width: 12),
                        _ModernIconButton(
                          icon: Icons.undo_rounded,
                          onTap: provider.canUndo ? () {
                            final action = provider.historyManager.nextUndoAction;
                            provider.undo();
                            if (action != null) {
                              HistoryFeedbackToast.showUndo(context, action, provider.isDarkMode);
                            }
                          } : null,
                          isDarkMode: provider.isDarkMode,
                          isEnabled: provider.canUndo,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: Icons.redo_rounded,
                          onTap: provider.canRedo ? () {
                            final action = provider.historyManager.nextRedoAction;
                            provider.redo();
                            if (action != null) {
                              HistoryFeedbackToast.showRedo(context, action, provider.isDarkMode);
                            }
                          } : null,
                          isDarkMode: provider.isDarkMode,
                          isEnabled: provider.canRedo,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: Icons.delete_outline_rounded,
                          onTap: () => _showClearDialog(context, provider),
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: Icons.save_alt_rounded,
                          onTap: () => provider.saveImage(repaintBoundaryKey),
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          onTap: provider.toggleDarkMode,
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: Icons.fullscreen,
                          onTap: provider.toggleFocusMode,
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: provider.isRecordingAudio ? Icons.stop : Icons.mic,
                          onTap: provider.toggleAudioRecording,
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                          isRecording: provider.isRecordingAudio,
                        ),
                        const SizedBox(width: 8),
                        _ModernIconButton(
                          icon: Icons.settings_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          isDarkMode: provider.isDarkMode,
                          isEnabled: true,
                        ),
                      ],
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

  void _showClearDialog(BuildContext context, DrawingProvider provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: provider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF3B30),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '전체 지우기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '모든 내용을 지우시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              fontSize: 15,
              color: provider.isDarkMode ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  color: provider.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clear();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: const Color(0xFFFF3B30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '지우기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickNoteButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDarkMode;

  const _QuickNoteButton({
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              '빠른 노트',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final bool isEnabled;
  final bool isRecording;

  const _ModernIconButton({
    required this.icon,
    required this.onTap,
    required this.isDarkMode,
    required this.isEnabled,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.3,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isRecording
                ? Colors.red.withValues(alpha: 0.2)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRecording
                  ? Colors.red.withValues(alpha: 0.5)
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05)),
              width: isRecording ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isRecording
                ? Colors.red
                : (isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}
