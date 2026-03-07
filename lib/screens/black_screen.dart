import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BlackScreen extends StatefulWidget {
  const BlackScreen({super.key});

  @override
  State<BlackScreen> createState() => _BlackScreenState();
}

class _BlackScreenState extends State<BlackScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  bool _showFlash = false;
  final List<Offset> _ripples = [];

  void _handleTap(TapDownDetails details) {
    final now = DateTime.now();
    
    // Add ripple effect
    setState(() {
      _ripples.add(details.localPosition);
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _ripples.isNotEmpty) {
        setState(() => _ripples.removeAt(0));
      }
    });

    // Check tap timing
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds > 800) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= 3) {
      _tapCount = 0;
      setState(() => _showFlash = true);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          context.go('/vault');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _handleTap,
        child: Stack(
          children: [
            // Main black screen
            Container(color: Colors.black),

            // Ripple effects
            ..._ripples.map((position) {
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeOut(duration: 600.ms, curve: Curves.easeOut),
              );
            }),

            // Flash effect
            if (_showFlash)
              Container(
                color: Colors.white,
              )
                  .animate()
                  .fadeIn(duration: 100.ms)
                  .then()
                  .fadeOut(duration: 250.ms),

            // Hint text
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Tap 3 times to open Vault',
                  style: TextStyle(
                    color: Color(0x1AFFFFFF),
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms, delay: 1500.ms),
            ),

            // Decorative dots
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    width: 2,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(
                      color: Color(0x0DFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
