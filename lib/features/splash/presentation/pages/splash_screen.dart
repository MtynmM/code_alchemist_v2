import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CODE ALCHEMIST',
              style: GoogleFonts.jetbrainsMono(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.neonCyan,
                letterSpacing: 4,
              ),
            )
                .animate()
                .shimmer(
                  duration: const Duration(milliseconds: 1500),
                  color: AppColors.neonCyan.withOpacity(0.5),
                )
                .then()
                .shake(
                  hz: 4,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 60),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.glitchRed),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
