import 'package:flutter/material.dart';

/// Custom page route animations for smooth transitions
/// "Gong-stagram" aesthetic: smooth, elegant animations

class PageRoutes {
  /// Slide from right (default material style but smoother)
  static Route<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Slide from bottom (for modals and secondary screens)
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Fade transition (for subtle changes)
  static Route<T> fade<T>(Widget page, {Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 300),
    );
  }

  /// Scale transition (for emphasized content)
  static Route<T> scale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        var scaleTween = Tween(begin: 0.9, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Smooth rotation + fade (for special transitions)
  static Route<T> rotateScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        var rotateTween = Tween(begin: 0.02, end: 0.0).chain(
          CurveTween(curve: curve),
        );

        var scaleTween = Tween(begin: 0.95, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return Transform.rotate(
          angle: animation.drive(rotateTween).value,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Shared axis transition (material design style)
  static Route<T> sharedAxis<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        // Enter animation
        var enterOffset = Tween(begin: const Offset(0.3, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: curve));
        var enterFade =
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(enterOffset),
          child: FadeTransition(
            opacity: animation.drive(enterFade),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// No animation (instant transition)
  static Route<T> instant<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
    );
  }
}

/// Extension method for easier navigation
extension NavigatorExtension on BuildContext {
  /// Navigate with slide right animation
  Future<T?> pushSlideRight<T>(Widget page) {
    return Navigator.of(this).push<T>(PageRoutes.slideRight(page));
  }

  /// Navigate with slide up animation
  Future<T?> pushSlideUp<T>(Widget page) {
    return Navigator.of(this).push<T>(PageRoutes.slideUp(page));
  }

  /// Navigate with fade animation
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.of(this).push<T>(PageRoutes.fade(page));
  }

  /// Navigate with scale animation
  Future<T?> pushScale<T>(Widget page) {
    return Navigator.of(this).push<T>(PageRoutes.scale(page));
  }

  /// Navigate with shared axis animation
  Future<T?> pushSharedAxis<T>(Widget page) {
    return Navigator.of(this).push<T>(PageRoutes.sharedAxis(page));
  }
}
