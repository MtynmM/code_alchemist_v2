import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyberpunk_button.dart';
import '../../logic/code_alchemist_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBackground,
      body: Stack(
        children: [
          // Fullscreen game widget
          GameWidget<CodeAlchemistGame>.controlled(
            gameFactory: CodeAlchemistGame.new,
          ),
          // Floating back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: CyberpunkButton(
                  label: 'BACK',
                  icon: Icons.arrow_back,
                  onPressed: () {
                    context.go('/home');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
