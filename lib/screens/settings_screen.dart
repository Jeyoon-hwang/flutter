import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../utils/responsive_util.dart';
import 'background_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final isTabletDevice = ResponsiveUtil.isTablet(context);

        return Scaffold(
          backgroundColor: provider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          appBar: AppBar(
            title: const Text(
              '설정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: provider.isDarkMode ? Colors.white : Colors.black,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: provider.isDarkMode
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                ),
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(isTabletDevice ? 24 : 16),
            children: [
              // Appearance Section
              _buildSectionHeader('외관', provider.isDarkMode),
              _buildSettingCard(
                context,
                icon: Icons.wallpaper,
                title: '배경 설정',
                subtitle: '종이 템플릿, 이미지, 색상 변경',
                trailing: const Icon(Icons.chevron_right),
                isDarkMode: provider.isDarkMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackgroundSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                context,
                icon: Icons.dark_mode,
                title: '다크 모드',
                subtitle: '어두운 테마 사용',
                trailing: Switch(
                  value: provider.isDarkMode,
                  onChanged: (value) => provider.toggleDarkMode(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.grid_on,
                title: '격자 표시',
                subtitle: '배경에 격자선 표시',
                trailing: Switch(
                  value: provider.settings.showGridLines,
                  onChanged: (value) => provider.toggleGridLines(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),

              const SizedBox(height: 24),

              // Drawing Section
              _buildSectionHeader('필기 설정', provider.isDarkMode),
              _buildSettingCard(
                context,
                icon: Icons.touch_app,
                title: '손바닥 거부 (Palm Rejection)',
                subtitle: '펜/스타일러스만 인식, 손바닥 터치 무시',
                trailing: Switch(
                  value: provider.palmRejection,
                  onChanged: (value) => provider.togglePalmRejection(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.auto_fix_high,
                title: '자동 도형 변환',
                subtitle: '손으로 그린 도형을 자동으로 정리',
                trailing: Switch(
                  value: provider.autoShapeEnabled,
                  onChanged: (value) => provider.toggleAutoShape(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.tune,
                title: '필압 안정화',
                subtitle: provider.pressureStabilization < 0.3
                    ? '사실적 (${(provider.pressureStabilization * 100).toInt()}%)'
                    : provider.pressureStabilization < 0.7
                        ? '균형 (${(provider.pressureStabilization * 100).toInt()}%)'
                        : '안정화 (${(provider.pressureStabilization * 100).toInt()}%)',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: provider.pressureStabilization,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (value) => provider.setPressureStabilization(value),
                  ),
                ),
                isDarkMode: provider.isDarkMode,
              ),

              const SizedBox(height: 24),

              // Toolbar Customization
              _buildSectionHeader('툴바 커스터마이징', provider.isDarkMode),
              _buildSettingCard(
                context,
                icon: Icons.aspect_ratio,
                title: '버튼 크기',
                subtitle: provider.settings.buttonSize < 0.9
                    ? '작게 (${(provider.settings.buttonSize * 100).toInt()}%)'
                    : provider.settings.buttonSize > 1.1
                        ? '크게 (${(provider.settings.buttonSize * 100).toInt()}%)'
                        : '보통 (${(provider.settings.buttonSize * 100).toInt()}%)',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: provider.settings.buttonSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (value) => provider.setButtonSize(value),
                  ),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.edit,
                title: '펜 도구',
                subtitle: '펜 도구 표시',
                trailing: Switch(
                  value: provider.settings.showPenTool,
                  onChanged: (value) => provider.togglePenTool(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.auto_fix_high_outlined,
                title: '지우개 도구',
                subtitle: '지우개 도구 표시',
                trailing: Switch(
                  value: provider.settings.showEraserTool,
                  onChanged: (value) => provider.toggleEraserTool(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.select_all,
                title: '선택 도구',
                subtitle: '선택 도구 표시',
                trailing: Switch(
                  value: provider.settings.showSelectTool,
                  onChanged: (value) => provider.toggleSelectTool(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.category_outlined,
                title: '도형 도구',
                subtitle: '도형 도구 표시',
                trailing: Switch(
                  value: provider.settings.showShapeTool,
                  onChanged: (value) => provider.toggleShapeTool(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.text_fields,
                title: '텍스트 도구',
                subtitle: '텍스트 도구 표시',
                trailing: Switch(
                  value: provider.settings.showTextTool,
                  onChanged: (value) => provider.toggleTextTool(),
                  activeThumbColor: const Color(0xFF667EEA),
                ),
                isDarkMode: provider.isDarkMode,
              ),

              const SizedBox(height: 24),

              // Default Settings
              _buildSectionHeader('기본 설정', provider.isDarkMode),
              _buildSettingCard(
                context,
                icon: Icons.line_weight,
                title: '기본 선 굵기',
                subtitle: '${provider.lineWidth.toStringAsFixed(1)}px',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: provider.lineWidth,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (value) => provider.setLineWidth(value),
                  ),
                ),
                isDarkMode: provider.isDarkMode,
              ),
              _buildSettingCard(
                context,
                icon: Icons.opacity,
                title: '기본 불투명도',
                subtitle: '${(provider.opacity * 100).toInt()}%',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: provider.opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (value) => provider.setOpacity(value),
                  ),
                ),
                isDarkMode: provider.isDarkMode,
              ),

              const SizedBox(height: 24),

              // Info Section
              _buildSectionHeader('정보', provider.isDarkMode),
              _buildSettingCard(
                context,
                icon: Icons.info_outline,
                title: '버전',
                subtitle: '1.0.0',
                trailing: const SizedBox(),
                isDarkMode: provider.isDarkMode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF404040)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.white60 : Colors.black54,
          ),
        ),
        trailing: trailing,
      ),
      ),
    );
  }
}
