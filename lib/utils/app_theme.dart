import 'package:flutter/material.dart';

/// Unified design system for the app
/// Ensures consistency across all UI components
class AppTheme {
  // ============================================================================
  // COLOR PALETTE
  // ============================================================================

  // Primary colors
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF5E5CE6);
  static const Color primaryLight = Color(0xFF764BA2);

  // Semantic colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // Neutral colors (light mode)
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightBorder = Color(0xFFE5E5EA);

  // Neutral colors (dark mode)
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkBackgroundSecondary = Color(0xFF16213E);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkBorder = Color(0xFF2C2C2E);

  // Session colors (N회독)
  static const List<Color> sessionColors = [
    Color(0xFFFF3B30), // Red - 1회독
    Color(0xFF007AFF), // Blue - 2회독
    Color(0xFF34C759), // Green - 3회독
    Color(0xFFFF9500), // Orange - 4회독
    Color(0xFF5E5CE6), // Purple - 5회독
  ];

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static LinearGradient darkGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static LinearGradient successGradient = const LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF30D158)],
  );

  static LinearGradient errorGradient = const LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9500)],
  );

  // ============================================================================
  // SPACING
  // ============================================================================

  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double space2xl = 24.0;
  static const double space3xl = 32.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // ============================================================================
  // SHADOWS
  // ============================================================================

  static List<BoxShadow> shadowSm(bool isDarkMode) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> shadowMd(bool isDarkMode) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.15),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ];

  static List<BoxShadow> shadowLg(bool isDarkMode) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.5 : 0.2),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ];

  // ============================================================================
  // GLASSMORPHISM
  // ============================================================================

  static BoxDecoration glassBox(bool isDarkMode, {double radius = radiusLg}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.5),
              ]
            : [
                Colors.white.withValues(alpha: 0.7),
                Colors.white.withValues(alpha: 0.5),
              ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1),
        width: 1.5,
      ),
      boxShadow: shadowLg(isDarkMode),
    );
  }

  // ============================================================================
  // TEXT STYLES
  // ============================================================================

  static TextStyle heading1(bool isDarkMode) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? darkText : lightText,
        height: 1.2,
      );

  static TextStyle heading2(bool isDarkMode) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? darkText : lightText,
        height: 1.3,
      );

  static TextStyle heading3(bool isDarkMode) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? darkText : lightText,
        height: 1.3,
      );

  static TextStyle bodyLarge(bool isDarkMode) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isDarkMode ? darkText : lightText,
        height: 1.5,
      );

  static TextStyle bodyMedium(bool isDarkMode) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: isDarkMode ? darkText : lightText,
        height: 1.5,
      );

  static TextStyle bodySmall(bool isDarkMode) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: isDarkMode ? darkTextSecondary : lightTextSecondary,
        height: 1.4,
      );

  static TextStyle caption(bool isDarkMode) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: isDarkMode ? darkTextSecondary : lightTextSecondary,
        height: 1.3,
      );

  static TextStyle button(bool isDarkMode) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? darkText : lightText,
        letterSpacing: 0.5,
      );

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );

  static ButtonStyle secondaryButton(bool isDarkMode) => ElevatedButton.styleFrom(
    backgroundColor: isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05),
    foregroundColor: isDarkMode ? darkText : lightText,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );

  static ButtonStyle outlineButton(bool isDarkMode) => OutlinedButton.styleFrom(
    foregroundColor: isDarkMode ? darkText : lightText,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    side: BorderSide(
      color: isDarkMode ? darkBorder : lightBorder,
      width: 1.5,
    ),
  );

  // ============================================================================
  // ANIMATIONS
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeOutCubic;
  static const Curve animationBounceCurve = Curves.easeOutBack;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ============================================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================================

  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get responsive size based on device type
  static double responsiveSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get color based on dark mode
  static Color adaptiveColor(bool isDarkMode, Color light, Color dark) {
    return isDarkMode ? dark : light;
  }

  /// Create a container with consistent styling
  static BoxDecoration containerDecoration(bool isDarkMode, {
    Color? color,
    double radius = radiusMd,
    bool withBorder = true,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? (isDarkMode ? darkSurface : lightSurface),
      borderRadius: BorderRadius.circular(radius),
      border: withBorder
          ? Border.all(
              color: isDarkMode ? darkBorder : lightBorder,
              width: 1.5,
            )
          : null,
      boxShadow: withShadow ? shadowMd(isDarkMode) : null,
    );
  }
}

/// Common reusable widgets
class AppWidgets {
  /// Floating action button with consistent style
  static Widget fab({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? color,
    double size = 56.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: AppTheme.shadowLg(isDarkMode),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: AppTheme.iconMd,
        ),
      ),
    );
  }

  /// Badge widget (for notifications, counts, etc.)
  static Widget badge({
    required String text,
    required Color color,
    double? fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Section header
  static Widget sectionHeader({
    required String title,
    required bool isDarkMode,
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceMd,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppTheme.iconSm,
              color: isDarkMode
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            const SizedBox(width: AppTheme.spaceSm),
          ],
          Text(
            title,
            style: AppTheme.heading3(isDarkMode),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  /// Empty state widget
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool isDarkMode,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppTheme.iconXl * 1.5,
              color: isDarkMode
                  ? AppTheme.darkTextSecondary.withValues(alpha: 0.5)
                  : AppTheme.lightTextSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              title,
              style: AppTheme.heading3(isDarkMode),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              message,
              style: AppTheme.bodyMedium(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppTheme.spaceXl),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
