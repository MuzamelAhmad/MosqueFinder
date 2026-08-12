import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Seclection_Screen/selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    debugPrint('APP: Splash navigation started...');
    
    try {
      // 1. Minimum delay for animation brand awareness
      await Future.delayed(const Duration(milliseconds: 3000));
      
      if (!mounted) return;

      // 2. Check for persisted user session
      final String? userId = await SharedPrefsService.getUserId().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('APP: SharedPrefs check timed out.');
          return null;
        },
      );

      debugPrint('APP: Cached UserId: $userId');

      if (mounted) {
        debugPrint('APP: Navigating to next screen...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => userId != null 
              ? ImamScreen(userId: userId) 
              : const SelectionScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('APP: Splash Error: $e');
      // Emergency Fallback
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SelectionScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // High-quality SVG Logo
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 180.w,
                        height: 180.h,
                        placeholderBuilder: (context) => const CircularProgressIndicator(color: Colors.white24),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'MosqueFinder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Punctuality in Prayer, Unity in Jama’at',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '“Never Miss a Jama’at Again”',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
