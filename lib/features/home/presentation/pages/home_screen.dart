import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyberpunk_button.dart';
import '../../../../core/widgets/animated_cyber_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBackground,
      body: Stack(
        children: [
          // Animated background grid
          const AnimatedCyberGrid(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glitched game title
                        Text(
                          'CODE ALCHEMIST',
                          style: GoogleFonts.jetbrainsMono(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonCyan,
                            letterSpacing: 6,
                            height: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .then()
                            .shimmer(
                              duration: const Duration(milliseconds: 2000),
                              color: AppColors.neonCyan.withOpacity(0.3),
                            )
                            .then()
                            .shimmer(
                              duration: const Duration(milliseconds: 1500),
                              color: AppColors.glitchRed.withOpacity(0.2),
                              delay: const Duration(milliseconds: 500),
                            ),
                        const SizedBox(height: 80),
                        // Menu buttons
                        CyberpunkButton(
                          label: 'INITIALIZE',
                          icon: Icons.play_arrow,
                          onPressed: () {
                            context.go('/game');
                          },
                        ),
                        CyberpunkButton(
                          label: 'ARCHIVES',
                          icon: Icons.folder,
                          onPressed: () {
                            debugPrint('ARCHIVES pressed - Levels/Chapters');
                          },
                        ),
                        CyberpunkButton(
                          label: 'SYSTEM',
                          icon: Icons.settings,
                          onPressed: () {
                            debugPrint('SYSTEM pressed - Settings');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'v1.0.0 // SYSTEM ONLINE',
                    style: GoogleFonts.jetbrainsMono(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
