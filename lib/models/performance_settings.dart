/// Performance settings for different device capabilities
class PerformanceSettings {
  final bool enableGlowEffects;
  final bool enableGlitterEffects;
  final bool enableShadows;
  final bool enableAnimations;
  final int maxStrokesPerLayer;
  final double canvasQuality; // 0.5 to 1.0
  final bool useCachedRendering;

  const PerformanceSettings({
    this.enableGlowEffects = true,
    this.enableGlitterEffects = true,
    this.enableShadows = true,
    this.enableAnimations = true,
    this.maxStrokesPerLayer = 1000,
    this.canvasQuality = 1.0,
    this.useCachedRendering = true,
  });

  /// High performance preset (for low-end devices)
  static const PerformanceSettings highPerformance = PerformanceSettings(
    enableGlowEffects: false,
    enableGlitterEffects: false,
    enableShadows: false,
    enableAnimations: false,
    maxStrokesPerLayer: 500,
    canvasQuality: 0.75,
    useCachedRendering: true,
  );

  /// Balanced preset (for mid-range devices)
  static const PerformanceSettings balanced = PerformanceSettings(
    enableGlowEffects: true,
    enableGlitterEffects: false,
    enableShadows: true,
    enableAnimations: true,
    maxStrokesPerLayer: 750,
    canvasQuality: 0.9,
    useCachedRendering: true,
  );

  /// Quality preset (for high-end devices)
  static const PerformanceSettings quality = PerformanceSettings(
    enableGlowEffects: true,
    enableGlitterEffects: true,
    enableShadows: true,
    enableAnimations: true,
    maxStrokesPerLayer: 1500,
    canvasQuality: 1.0,
    useCachedRendering: true,
  );

  /// TV preset (optimized for large screens with pen input)
  static const PerformanceSettings tv = PerformanceSettings(
    enableGlowEffects: true,
    enableGlitterEffects: true,
    enableShadows: true,
    enableAnimations: true,
    maxStrokesPerLayer: 2000,
    canvasQuality: 1.0,
    useCachedRendering: true,
  );

  PerformanceSettings copyWith({
    bool? enableGlowEffects,
    bool? enableGlitterEffects,
    bool? enableShadows,
    bool? enableAnimations,
    int? maxStrokesPerLayer,
    double? canvasQuality,
    bool? useCachedRendering,
  }) {
    return PerformanceSettings(
      enableGlowEffects: enableGlowEffects ?? this.enableGlowEffects,
      enableGlitterEffects: enableGlitterEffects ?? this.enableGlitterEffects,
      enableShadows: enableShadows ?? this.enableShadows,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      maxStrokesPerLayer: maxStrokesPerLayer ?? this.maxStrokesPerLayer,
      canvasQuality: canvasQuality ?? this.canvasQuality,
      useCachedRendering: useCachedRendering ?? this.useCachedRendering,
    );
  }
}
