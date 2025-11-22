import 'package:flutter/material.dart';
import 'dart:async';

/// Performance optimization utilities
class PerformanceUtils {
  /// Debounce function calls to reduce unnecessary operations
  /// Usage: _debouncer.run(() => expensiveOperation());
  static Debouncer debouncer({Duration delay = const Duration(milliseconds: 500)}) {
    return Debouncer(delay: delay);
  }

  /// Throttle function calls to limit execution frequency
  /// Usage: _throttler.run(() => frequentOperation());
  static Throttler throttler({Duration duration = const Duration(milliseconds: 300)}) {
    return Throttler(duration: duration);
  }

  /// Measure widget build performance
  static void measureBuildTime(String widgetName, VoidCallback buildFunction) {
    final stopwatch = Stopwatch()..start();
    buildFunction();
    stopwatch.stop();

    if (stopwatch.elapsedMilliseconds > 16) {
      // More than one frame (16ms at 60fps)
      debugPrint('⚠️ Slow build: $widgetName took ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// Check if rebuild is necessary
  static bool shouldRebuild<T>(T oldValue, T newValue) {
    return oldValue != newValue;
  }
}

/// Debouncer - delays execution until after wait time has elapsed
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler - limits execution frequency
class Throttler {
  final Duration duration;
  DateTime? _lastExecution;

  Throttler({required this.duration});

  void run(VoidCallback action) {
    final now = DateTime.now();

    if (_lastExecution == null ||
        now.difference(_lastExecution!) >= duration) {
      _lastExecution = now;
      action();
    }
  }
}

/// Optimized list builder with lazy loading
class LazyListBuilder extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? separator;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const LazyListBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.separator,
    this.controller,
    this.padding,
  }) : super(key: key);

  @override
  State<LazyListBuilder> createState() => _LazyListBuilderState();
}

class _LazyListBuilderState extends State<LazyListBuilder> {
  final Set<int> _builtItems = {};

  @override
  Widget build(BuildContext context) {
    if (widget.separator != null) {
      return ListView.separated(
        controller: widget.controller,
        padding: widget.padding,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          _builtItems.add(index);
          return widget.itemBuilder(context, index);
        },
        separatorBuilder: (context, index) => widget.separator!,
      );
    }

    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        _builtItems.add(index);
        return widget.itemBuilder(context, index);
      },
    );
  }

  @override
  void dispose() {
    _builtItems.clear();
    super.dispose();
  }
}

/// Memoized widget - only rebuilds when dependencies change
class MemoizedWidget<T> extends StatefulWidget {
  final T dependency;
  final Widget Function(T) builder;

  const MemoizedWidget({
    Key? key,
    required this.dependency,
    required this.builder,
  }) : super(key: key);

  @override
  State<MemoizedWidget<T>> createState() => _MemoizedWidgetState<T>();
}

class _MemoizedWidgetState<T> extends State<MemoizedWidget<T>> {
  late T _lastDependency;
  late Widget _cachedWidget;

  @override
  void initState() {
    super.initState();
    _lastDependency = widget.dependency;
    _cachedWidget = widget.builder(widget.dependency);
  }

  @override
  void didUpdateWidget(MemoizedWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dependency != _lastDependency) {
      _lastDependency = widget.dependency;
      _cachedWidget = widget.builder(widget.dependency);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget;
  }
}

/// Optimized image loader with caching
class OptimizedImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedImage({
    Key? key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        // Use FilterQuality.medium for balance between quality and performance
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// Frame rate monitor (for development)
class FrameRateMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const FrameRateMonitor({
    Key? key,
    required this.child,
    this.enabled = false,
  }) : super(key: key);

  @override
  State<FrameRateMonitor> createState() => _FrameRateMonitorState();
}

class _FrameRateMonitorState extends State<FrameRateMonitor> {
  int _frameCount = 0;
  int _fps = 0;
  DateTime _lastCheck = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _frameCount++;
      final now = DateTime.now();
      final diff = now.difference(_lastCheck);

      if (diff.inMilliseconds >= 1000) {
        setState(() {
          _fps = _frameCount;
          _frameCount = 0;
          _lastCheck = now;
        });
      }

      _startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 40,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _fps < 55 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_fps FPS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
