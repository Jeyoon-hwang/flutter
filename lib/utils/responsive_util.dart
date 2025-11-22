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
}
