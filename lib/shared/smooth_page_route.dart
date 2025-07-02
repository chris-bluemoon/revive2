import 'package:flutter/material.dart';

/// A custom page route that provides smooth transitions between pages
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset? slideOffset;
  final bool enableSlide;
  final bool enableFade;

  SmoothPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    this.slideOffset,
    this.enableSlide = true,
    this.enableFade = true,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Combined slide and fade transition
            Widget result = child;

            if (enableFade) {
              result = FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
                child: result,
              );
            }

            if (enableSlide) {
              final offset = slideOffset ?? const Offset(0.3, 0.0);
              result = SlideTransition(
                position: Tween<Offset>(
                  begin: offset,
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: curve,
                )),
                child: result,
              );
            }

            return result;
          },
        );
}

/// Predefined smooth transitions for common navigation patterns
class SmoothTransitions {
  /// Smooth slide from right with fade
  static SmoothPageRoute<T> slideFromRight<T>(Widget child) {
    return SmoothPageRoute<T>(
      child: child,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      slideOffset: const Offset(0.25, 0.0),
      enableSlide: true,
      enableFade: true,
    );
  }

  /// Smooth fade transition
  static SmoothPageRoute<T> fade<T>(Widget child) {
    return SmoothPageRoute<T>(
      child: child,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      enableSlide: false,
      enableFade: true,
    );
  }

  /// Elegant slide up with fade
  static SmoothPageRoute<T> slideUp<T>(Widget child) {
    return SmoothPageRoute<T>(
      child: child,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      slideOffset: const Offset(0.0, 0.3),
      enableSlide: true,
      enableFade: true,
    );
  }

  /// Luxury-style transition (subtle slide with slow fade)
  static SmoothPageRoute<T> luxury<T>(Widget child) {
    return SmoothPageRoute<T>(
      child: child,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutQuart,
      slideOffset: const Offset(0.15, 0.0),
      enableSlide: true,
      enableFade: true,
    );
  }
}
