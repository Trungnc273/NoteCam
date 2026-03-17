import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    
    if (!mounted) return;

    // Check if onboarding is completed
    final hasCompletedOnboarding = StorageService.hasCompletedOnboarding();
    
    if (hasCompletedOnboarding) {
      // Get saved display mode
      final displayMode = StorageService.getDisplayMode();
      if (displayMode == 'black-screen') {
        context.go('/black-screen');
      } else {
        context.go('/notepad');
      }
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 38,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 300.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 16),
            // App name
            const Text(
              'NoteCam',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 7.2,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 300.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'NOTES & PRIVACY',
              style: TextStyle(
                color: Color(0xFF52525B),
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 300.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 120),
            // Pulsing dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F3F46),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .fadeIn(
                      duration: 1400.ms,
                      delay: (i * 200).ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .fadeOut(
                      duration: 1400.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
