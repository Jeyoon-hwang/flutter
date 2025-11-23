import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ResponsiveUtil {
  static DeviceType getDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    // Tablet if shortest side is larger than 600px
    if (shortestSide >= 600) {
      return DeviceType.tablet;
    }
    return DeviceType.phone;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.phone;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Get scaled size based on device type
  static double getScaledSize(BuildContext context, {
    required double phoneSize,
    required double tabletSize,
  }) {
    return isTablet(context) ? tabletSize : phoneSize;
  }

  // Get toolbar height based on device
  static double getToolbarHeight(BuildContext context) {
    return isTablet(context) ? 70.0 : 60.0;
  }

  // Get button size based on device
  static double getButtonSize(BuildContext context) {
    return isTablet(context) ? 56.0 : 48.0;
  }

  // Get icon size based on device
  static double getIconSize(BuildContext context) {
    return isTablet(context) ? 28.0 : 24.0;
  }

  // Get font size based on device
  static double getFontSize(BuildContext context, double baseSize) {
    return isTablet(context) ? baseSize * 1.2 : baseSize;
  }

  // Get padding based on device
  static EdgeInsets getPadding(BuildContext context, EdgeInsets basePadding) {
    if (isTablet(context)) {
      return basePadding * 1.5;
    }
    return basePadding;
  }

  // Get safe area for drawing considering toolbar positions
  static EdgeInsets getDrawingAreaInsets(BuildContext context) {
    final isTabletDevice = isTablet(context);
    return EdgeInsets.only(
      top: isTabletDevice ? 80 : 70,
      bottom: isTabletDevice ? 120 : 100,
      left: 0,
      right: 0,
    );
  }

  // Toolbar positioning for phone vs tablet
  static ToolbarLayout getToolbarLayout(BuildContext context) {
    if (isTablet(context)) {
      return ToolbarLayout.floating; // Draggable anywhere
    } else {
      return ToolbarLayout.bottom; // Fixed at bottom
    }
  }

  // Get toolbar position based on device
  static Offset getDefaultToolbarPosition(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isTablet(context)) {
      // Tablet: center middle
      return Offset(size.width / 2, size.height - 150);
    } else {
      // Phone: bottom center
      return Offset(size.width / 2, size.height - 100);
    }
  }

  // Button layout for different devices
  static ButtonLayout getButtonLayout(BuildContext context) {
    if (isTablet(context)) {
      return ButtonLayout.expanded; // Show all buttons with labels
    } else {
      return ButtonLayout.compact; // Icons only, collapsed
    }
  }

  // Get spacing multiplier
  static double getSpacing(BuildContext context) {
    return isTablet(context) ? 12.0 : 8.0;
  }

  // Get border radius
  static double getBorderRadius(BuildContext context) {
    return isTablet(context) ? 16.0 : 12.0;
  }

  // Animation duration based on device
  static Duration getAnimationDuration(BuildContext context) {
    // Faster on phone for better responsiveness
    return isPhone(context)
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 300);
  }
}

enum ToolbarLayout { floating, bottom, top }
enum ButtonLayout { compact, expanded }
