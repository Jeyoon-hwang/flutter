import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/drawing_provider.dart';
import '../models/note.dart';
import '../utils/app_theme.dart';
import '../services/haptic_service.dart';
import '../widgets/common/animated_widgets.dart';

/// Background customization screen
/// 배경 커스터마이징: 이미지, 템플릿, 색상
class BackgroundSettingsScreen extends StatefulWidget {
  const BackgroundSettingsScreen({Key? key}) : super(key: key);

  @override
  State<BackgroundSettingsScreen> createState() => _BackgroundSettingsScreenState();
}

class _BackgroundSettingsScreenState extends State<BackgroundSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final currentNote = provider.noteService.currentNote;

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '배경 설정',
              style: AppTheme.heading2(isDarkMode),
            ),
            iconTheme: IconThemeData(
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 배경 이미지 섹션
                Text(
                  '배경 이미지',
                  style: AppTheme.heading3(isDarkMode),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // 현재 배경 프리뷰
                if (currentNote?.backgroundImagePath != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(currentNote!.backgroundImagePath!),
                            fit: BoxFit.cover,
                            opacity: AlwaysStoppedAnimation(currentNote.backgroundImageOpacity),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => _removeBackgroundImage(provider),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: currentNote?.backgroundColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '배경 이미지 없음',
                            style: AppTheme.bodyMedium(isDarkMode).copyWith(
                              color: isDarkMode
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: AppTheme.spaceMd),

                // 이미지 선택 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickBackgroundImage(provider),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                // 투명도 조절 (이미지가 있을 때만)
                if (currentNote?.backgroundImagePath != null) ...[
                  const SizedBox(height: AppTheme.spaceLg),
                  Text(
                    '이미지 투명도',
                    style: AppTheme.bodyMedium(isDarkMode),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: currentNote?.backgroundImageOpacity ?? 1.0,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          label: '${((currentNote?.backgroundImageOpacity ?? 1.0) * 100).round()}%',
                          onChanged: (value) {
                            _setImageOpacity(provider, value);
                          },
                        ),
                      ),
                      Text(
                        '${((currentNote?.backgroundImageOpacity ?? 1.0) * 100).round()}%',
                        style: AppTheme.bodyMedium(isDarkMode),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppTheme.space2xl),

                // 템플릿 섹션
                Text(
                  '노트 템플릿',
                  style: AppTheme.heading3(isDarkMode),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // 템플릿 그리드
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: AppTheme.spaceMd,
                  crossAxisSpacing: AppTheme.spaceMd,
                  children: [
                    _buildTemplateCard(provider, NoteTemplate.blank, '백지', Icons.crop_square, isDarkMode),
                    _buildTemplateCard(provider, NoteTemplate.lined, '줄 노트', Icons.view_headline, isDarkMode),
                    _buildTemplateCard(provider, NoteTemplate.grid, '격자', Icons.grid_on, isDarkMode),
                    _buildTemplateCard(provider, NoteTemplate.dots, '점선', Icons.more_horiz, isDarkMode),
                    _buildTemplateCard(provider, NoteTemplate.cornell, '코넬식', Icons.view_column, isDarkMode),
                    _buildTemplateCard(provider, NoteTemplate.music, '오선지', Icons.music_note, isDarkMode),
                  ],
                ),

                const SizedBox(height: AppTheme.space2xl),

                // 배경색 섹션
                Text(
                  '배경색',
                  style: AppTheme.heading3(isDarkMode),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // 배경색 선택
                Wrap(
                  spacing: AppTheme.spaceMd,
                  runSpacing: AppTheme.spaceMd,
                  children: [
                    _buildColorOption(provider, Colors.white, '흰색', isDarkMode),
                    _buildColorOption(provider, const Color(0xFFFFFAF0), '아이보리', isDarkMode),
                    _buildColorOption(provider, const Color(0xFFFFF0F5), '연한 핑크', isDarkMode),
                    _buildColorOption(provider, const Color(0xFFF0F8FF), '연한 파랑', isDarkMode),
                    _buildColorOption(provider, const Color(0xFFF0FFF0), '연한 그린', isDarkMode),
                    _buildColorOption(provider, const Color(0xFFFFFACD), '연한 노랑', isDarkMode),
                    _buildColorOption(provider, const Color(0xFF1E1E1E), '다크', isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateCard(
    DrawingProvider provider,
    NoteTemplate template,
    String name,
    IconData icon,
    bool isDarkMode,
  ) {
    final isSelected = provider.noteService.currentNote?.template == template;

    return BouncyButton(
      onTap: () => _setTemplate(provider, template),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? AppTheme.primary
                  : (isDarkMode ? AppTheme.darkText : AppTheme.lightText),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primary
                    : (isDarkMode ? AppTheme.darkText : AppTheme.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    DrawingProvider provider,
    Color color,
    String name,
    bool isDarkMode,
  ) {
    final isSelected = provider.noteService.currentNote?.backgroundColor == color;

    return GestureDetector(
      onTap: () => _setBackgroundColor(provider, color),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBackgroundImage(DrawingProvider provider) async {
    try {
      await hapticService.buttonPress();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null && mounted) {
          await hapticService.success();
          provider.noteService.setBackgroundImage(filePath);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('배경 이미지가 설정되었습니다'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      await hapticService.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeBackgroundImage(DrawingProvider provider) async {
    await hapticService.medium();
    provider.noteService.removeBackgroundImage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('배경 이미지가 제거되었습니다'),
        ),
      );
    }
  }

  void _setImageOpacity(DrawingProvider provider, double opacity) {
    provider.noteService.setBackgroundImageOpacity(opacity);
  }

  Future<void> _setTemplate(DrawingProvider provider, NoteTemplate template) async {
    await hapticService.selectionChanged();
    provider.noteService.setTemplate(template);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('템플릿이 변경되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _setBackgroundColor(DrawingProvider provider, Color color) async {
    await hapticService.selectionChanged();
    provider.noteService.setBackgroundColor(color);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('배경색이 변경되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
