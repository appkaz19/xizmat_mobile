import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import '../main/main_navigation.dart';

class PasswordSuccessScreen extends StatefulWidget {
  const PasswordSuccessScreen({super.key});

  @override
  State<PasswordSuccessScreen> createState() => _PasswordSuccessScreenState();
}

class _PasswordSuccessScreenState extends State<PasswordSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _dotsController;
  late Animation<double> _scaleAnimation;

  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();

    // Scale animation for the check icon
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Dots animation
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animations
    _scaleController.forward();
    _dotsController.repeat();

    // Auto-navigate after 3 seconds
    _autoNavigateTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToMain();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _dotsController.dispose();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  void _navigateToMain() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated background decoration
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green[100]!,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Floating dots animation
                      ...List.generate(6, (index) {
                        return AnimatedBuilder(
                          animation: _dotsController,
                          builder: (context, child) {
                            final angle = (index * 60.0) + (_dotsController.value * 360);
                            final radian = angle * (3.14159 / 180);
                            final radius = 50.0;
                            final x = radius * (1 + 0.5 * (_dotsController.value));
                            final y = radius * (1 + 0.5 * (_dotsController.value));

                            return Positioned(
                              left: 70 + (x * 0.6) * (cos(radian)),
                              top: 70 + (y * 0.6) * (sin(radian)),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D5F).withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      // Main success icon
                      Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D5F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Готово!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D5F),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Ваш пароль успешно обновлен.\nСейчас вы будете\nперенаправлены на главный экран',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                // Loading dots animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return AnimatedBuilder(
                      animation: _dotsController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final animValue = (_dotsController.value + delay) % 1.0;
                        final scale = animValue < 0.5
                            ? 1.0 + (animValue * 2 * 0.5)
                            : 1.5 - ((animValue - 0.5) * 2 * 0.5);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: animValue < 0.5
                                    ? const Color(0xFF2E7D5F)
                                    : const Color(0xFF2E7D5F).withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _navigateToMain,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D5F)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Продолжить',
                      style: TextStyle(
                        color: Color(0xFF2E7D5F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}