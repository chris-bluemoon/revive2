import 'package:flutter/material.dart';

// Preload and cache the logo image for better performance
class LogoImageCache {
  static ImageProvider? _cachedImageProvider;
  
  static ImageProvider get logoProvider {
    _cachedImageProvider ??= const AssetImage('assets/logos/new_velaa_logo_transparent.png');
    return _cachedImageProvider!;
  }
  
  static Widget getCachedLogoWidget(double size) {
    return Image(
      image: logoProvider,
      width: size * 0.6,
      height: size * 0.6,
      fit: BoxFit.contain,
      // Disable loading animations to prevent interference
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return child;
      },
    );
  }
  
  // Preload the logo image at app startup
  static void preloadLogo(BuildContext context) {
    precacheImage(logoProvider, context);
  }
}

class AnimatedLogoSpinner extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  
  const AnimatedLogoSpinner({
    super.key,
    this.size = 60.0,
    this.backgroundColor,
  });

  @override
  State<AnimatedLogoSpinner> createState() => _AnimatedLogoSpinnerState();
}

class _AnimatedLogoSpinnerState extends State<AnimatedLogoSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Slower animation for better performance
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the breathing animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: LogoImageCache.getCachedLogoWidget(widget.size),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Static logo spinner for better performance when animation isn't critical
class StaticLogoSpinner extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  
  const StaticLogoSpinner({
    super.key,
    this.size = 60.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: LogoImageCache.getCachedLogoWidget(size),
      ),
    );
  }
}

// Widget to replace CircularProgressIndicator with centered logo spinner
class CenteredLogoSpinner extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final bool animated;
  
  const CenteredLogoSpinner({
    super.key,
    this.size = 60.0,
    this.backgroundColor,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: animated 
        ? AnimatedLogoSpinner(
            size: size,
            backgroundColor: backgroundColor,
          )
        : StaticLogoSpinner(
            size: size,
            backgroundColor: backgroundColor,
          ),
    );
  }
}

// Ultra-fast static spinner for small thumbnails
class FastLogoSpinner extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  
  const FastLogoSpinner({
    super.key,
    this.size = 40.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          'assets/logos/new_velaa_logo_transparent.png',
          width: size * 0.6,
          height: size * 0.6,
          fit: BoxFit.contain,
          // Disable all image loading effects for maximum performance
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
