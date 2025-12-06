import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../bloc/game_bloc.dart';
import '../widgets/command_terminal.dart';
import '../../logic/code_alchemist_game.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyberpunk_button.dart';

class GameScreen extends StatelessWidget {
  GameScreen({super.key});
  final _game = CodeAlchemistGame();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>(),
      child: BlocListener<GameBloc, GameState>(
        listenWhen: (prev, curr) => !prev.isRunning && curr.isRunning,
        listener: (context, state) async {
          for (int i = 0; i < state.commands.length; i++) {
            context.read<GameBloc>().setCurrentIndex(i);
            await _game.executeCommand(state.commands[i]);
            await Future.delayed(const Duration(milliseconds: 200));
          }
          context.read<GameBloc>().endRun();
        },
        child: Scaffold(
          backgroundColor: AppColors.voidBackground,
          body: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return Stack(
                children: [
                  GameWidget(game: _game),
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
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CommandTerminal(
                      onRun: (commands) => context.read<GameBloc>().add(RunCommandsEvent()),
                      busy: state.status == GameStatus.running,
                      currentExecutingIndex: state.currentExecutingIndex,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
