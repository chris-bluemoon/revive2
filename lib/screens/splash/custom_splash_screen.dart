import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:revivals/screens/home_page.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _fadeController;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();

    // Animation controllers - only need text and fade controllers now
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Text fade in and scale animation
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    // Fade out animation for the entire splash content
    _fadeOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Remove the native splash screen after a small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 100));
    FlutterNativeSplash.remove();
    
    // Wait 1.5 seconds to show the logo (native splash already showed it)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Start showing text (logo will fade out automatically due to opacity animation)
    _textController.forward();
    
    // Wait for text animation to complete + 2 seconds for reading
    await Future.delayed(const Duration(milliseconds: 1200 + 2000));
    
    // Start fading out the entire splash screen
    _fadeController.forward();
    
    // Wait for fade to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Navigate to main app
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: animation,
              child: Container(
                color: Colors.white,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
                  ),
                  child: const HomePage(),
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: AnimatedBuilder(
        animation: _fadeOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOpacity.value,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // Logo that stays visible until text appears
                  AnimatedBuilder(
                    animation: _textOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1.0 - _textOpacity.value, // Fade out as text fades in
                        child: Center(
                          child: Image.asset(
                            'assets/logos/new_velaa_icon_1024.png',
                            width: 144, // Fixed size to match exactly with native splash
                            height: 144, // Fixed size to match exactly with native splash
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Thai text "เวลา" that fades in
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.scale(
                          scale: _textScale.value,
                          child: Center(
                            child: Text(
                              'เวลา',
                              style: TextStyle(
                                fontSize: width * 0.15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
