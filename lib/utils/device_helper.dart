import 'package:flutter/material.dart';

/// Device type detection and optimization helper
class DeviceHelper {
  /// Screen size categories
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1200;
  static const double desktopMaxWidth = 1920;

  /// Get device type from context
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < phoneMaxWidth) {
      return DeviceType.phone;
    } else if (width < tabletMaxWidth) {
      return DeviceType.tablet;
    } else if (width < desktopMaxWidth) {
      return DeviceType.desktop;
    } else {
      return DeviceType.tv;
    }
  }

  /// Check if device is large screen (TV/Desktop)
  static bool isLargeScreen(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.tv;
  }

  /// Get appropriate scale factor for UI elements
  static double getScaleFactor(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.phone:
        return 1.0;
      case DeviceType.tablet:
        return 1.3;
      case DeviceType.desktop:
        return 1.5;
      case DeviceType.tv:
        return 2.0; // TV needs larger UI elements
    }
  }

  /// Get appropriate touch target size
  static double getTouchTargetSize(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.phone:
        return 48.0;
      case DeviceType.tablet:
        return 56.0;
      case DeviceType.desktop:
        return 64.0;
      case DeviceType.tv:
        return 80.0; // TV needs extra large touch targets
    }
  }

  /// Get appropriate font scale
  static double getFontScale(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.phone:
        return 1.0;
      case DeviceType.tablet:
        return 1.2;
      case DeviceType.desktop:
        return 1.4;
      case DeviceType.tv:
        return 1.8; // TV needs larger text
    }
  }

  /// Check if device should use performance mode (low-end devices)
  static bool shouldUsePerformanceMode(BuildContext context) {
    // On web or very large screens, assume powerful hardware
    final type = getDeviceType(context);
    if (type == DeviceType.tv || type == DeviceType.desktop) {
      return false; // High-end devices
    }

    // For mobile devices, could add more sophisticated detection
    // For now, assume tablets and phones might need optimization
    return true;
  }

  /// Get pixel ratio for rendering
  static double getPixelRatio(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final type = getDeviceType(context);

    // Limit pixel ratio on low-end devices to save memory
    if (shouldUsePerformanceMode(context)) {
      return devicePixelRatio.clamp(1.0, 2.0);
    }

    // High-end devices can use full resolution
    return devicePixelRatio;
  }

  /// Get canvas dimensions optimized for device
  static Size getOptimizedCanvasSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final type = getDeviceType(context);

    // TV and desktop get full resolution
    if (type == DeviceType.tv || type == DeviceType.desktop) {
      return screenSize;
    }

    // Tablets get slightly reduced for performance
    if (type == DeviceType.tablet) {
      return Size(
        screenSize.width * 0.95,
        screenSize.height * 0.95,
      );
    }

    // Phones get optimized size
    return Size(
      screenSize.width * 0.9,
      screenSize.height * 0.9,
    );
  }
}

enum DeviceType {
  phone,
  tablet,
  desktop,
  tv,
}
