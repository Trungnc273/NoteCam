import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentSlide = 0;
  final PageController _pageController = PageController();

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Ghi chú thông minh & riêng tư',
      subtitle:
          'Một nơi lưu trữ tất cả ghi chú hàng ngày của bạn — đơn giản, nhanh, và an toàn.',
      icon: Icons.note_alt_outlined,
    ),
    OnboardingSlide(
      title: 'Chọn chế độ hiển thị',
      subtitle: 'Chọn cách ứng dụng xuất hiện trên màn hình chính của bạn.',
      icon: Icons.smartphone_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentSlide == 0)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(color: Color(0xFF71717A)),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 72),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF27272A)),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 72,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 300.ms,
                            )
                            .fadeIn(duration: 300.ms),
                        const SizedBox(height: 40),
                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF71717A),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        // Mode selection for slide 2
                        if (index == 1) ...[
                          const SizedBox(height: 32),
                          _buildModeOption(
                            icon: LucideIcons.fileText,
                            title: 'Fake Notepad',
                            subtitle: 'Trông như ứng dụng ghi chú bình thường',
                            mode: 'notepad',
                            route: '/notepad',
                          ),
                          const SizedBox(height: 12),
                          _buildModeOption(
                            icon: LucideIcons.square,
                            title: 'Black Screen',
                            subtitle: 'Màn hình đen, chạm 3 lần để mở',
                            mode: 'black-screen',
                            route: '/black-screen',
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: index == _currentSlide ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(index == _currentSlide ? 1 : 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Continue button (only on first slide)
                  if (_currentSlide == 0)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(LucideIcons.chevronRight, size: 16),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMode(String mode, String route) async {
    await StorageService.setDisplayMode(mode);
    await StorageService.setOnboardingCompleted(true);
    if (mounted) context.go(route);
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String mode,
    required String route,
  }) {
    return Material(
      color: const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _selectMode(mode, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF27272A)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: Color(0xFF52525B),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 150.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 150.ms);
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
