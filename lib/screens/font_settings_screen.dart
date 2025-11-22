import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../services/font_loader_service.dart';
import '../utils/app_theme.dart';

/// Font settings screen for managing custom fonts
/// "Gong-stagram" aesthetic: clean font management
class FontSettingsScreen extends StatefulWidget {
  const FontSettingsScreen({Key? key}) : super(key: key);

  @override
  State<FontSettingsScreen> createState() => _FontSettingsScreenState();
}

class _FontSettingsScreenState extends State<FontSettingsScreen> {
  final FontLoaderService _fontService = FontLoaderService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFonts();
  }

  Future<void> _initializeFonts() async {
    await _fontService.initialize();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.isDarkMode;
        final backgroundColor = provider.getBackgroundColor();

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '폰트 설정',
              style: AppTheme.heading2(isDarkMode),
            ),
            iconTheme: IconThemeData(
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // System font
                      Text(
                        '시스템 폰트',
                        style: AppTheme.heading3(isDarkMode),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      _buildFontCard(
                        context,
                        provider,
                        isDarkMode,
                        fontFamily: null,
                        fontName: '기본 폰트 (SF Pro)',
                        isSystem: true,
                      ),

                      const SizedBox(height: AppTheme.spaceLg),

                      // Custom fonts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '사용자 폰트',
                            style: AppTheme.heading3(isDarkMode),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _pickFont(provider),
                            icon: const Icon(Icons.add),
                            label: const Text('폰트 추가'),
                            style: AppTheme.primaryButton,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceMd),

                      if (_fontService.availableFonts.isEmpty)
                        _buildEmptyState(isDarkMode)
                      else
                        ..._fontService.availableFonts.map((font) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                            child: _buildFontCard(
                              context,
                              provider,
                              isDarkMode,
                              fontFamily: font.family,
                              fontName: font.name,
                              fileSize: font.formattedSize,
                              onDelete: () => _deleteFont(provider, font.name),
                            ),
                          );
                        }),

                      const SizedBox(height: AppTheme.spaceLg),

                      // Popular fonts info
                      _buildPopularFontsInfo(isDarkMode),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFontCard(
    BuildContext context,
    DrawingProvider provider,
    bool isDarkMode, {
    String? fontFamily,
    required String fontName,
    String? fileSize,
    bool isSystem = false,
    VoidCallback? onDelete,
  }) {
    final isSelected = provider.settings.customFontFamily == fontFamily;

    return GestureDetector(
      onTap: () {
        provider.setCustomFont(fontFamily);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fontName 폰트가 적용되었습니다')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : (isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Font preview icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : (isDarkMode ? AppTheme.darkBorder : AppTheme.lightBorder),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Center(
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? AppTheme.darkText : AppTheme.lightText),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppTheme.spaceMd),

            // Font info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fontName,
                    style: AppTheme.bodyLarge(isDarkMode).copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '공스타그램에서 글씨를 쓸 때 이 폰트가 사용됩니다',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: isDarkMode
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                  if (fileSize != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '파일 크기: $fileSize',
                      style: AppTheme.bodySmall(isDarkMode),
                    ),
                  ],
                ],
              ),
            ),

            // Selected indicator or delete button
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primary,
                size: 24,
              )
            else if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                onPressed: () => _confirmDelete(context, fontName, onDelete),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3xl),
      child: Column(
        children: [
          Icon(
            Icons.font_download_outlined,
            size: 64,
            color: isDarkMode
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            '사용자 폰트가 없습니다',
            style: AppTheme.heading3(isDarkMode),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '감성 있는 필기체 폰트를 추가해보세요!',
            style: AppTheme.bodyMedium(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularFontsInfo(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.info, size: 20),
              const SizedBox(width: 8),
              Text(
                '추천 폰트',
                style: AppTheme.bodyLarge(isDarkMode).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            '고등학생들이 많이 사용하는 감성 폰트:',
            style: AppTheme.bodyMedium(isDarkMode),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ...FontLoaderService.popularKoreanFonts.map((fontName) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Text(
                    fontName,
                    style: AppTheme.bodyMedium(isDarkMode),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            '.ttf 또는 .otf 파일을 선택하여 추가할 수 있습니다.',
            style: AppTheme.bodySmall(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFont(DrawingProvider provider) async {
    try {
      final customFont = await _fontService.pickAndLoadFont();

      if (customFont != null && mounted) {
        setState(() {});
        provider.setCustomFont(customFont.family);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customFont.name} 폰트가 추가되었습니다!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('폰트 로드 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteFont(DrawingProvider provider, String fontName) async {
    final success = await _fontService.deleteFont(fontName);

    if (mounted) {
      if (success) {
        setState(() {});

        // If deleted font was selected, reset to default
        if (provider.settings.customFontFamily == fontName) {
          provider.setCustomFont(null);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fontName 폰트가 삭제되었습니다'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('폰트 삭제 실패'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, String fontName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('폰트 삭제'),
        content: Text('$fontName 폰트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fontService.dispose();
    super.dispose();
  }
}
