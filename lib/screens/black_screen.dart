import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/vault_pin_modal.dart';

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
          _showVaultPinModal();
        }
      });
    }
  }

  void _showVaultPinModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VaultPinModal(
        onSuccess: () {
          Navigator.pop(context);
          context.go('/vault');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Do nothing - prevent back button from exiting app
      },
      child: Scaffold(
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
                  left: position.dx - 60,
                  top: position.dy - 60,
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

              // Center instruction (very subtle)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.03),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chạm 3 lần nhanh',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.05),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1500.ms, delay: 2000.ms),

              // Bottom hint
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'BLACK SCREEN MODE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.08),
                        fontSize: 9,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chạm 3 lần để mở Vault',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.05),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1500.ms, delay: 3000.ms),

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
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Settings button (hidden in top right corner)
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    size: 20,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  onPressed: () => context.go('/app-settings'),
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms, delay: 4000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
