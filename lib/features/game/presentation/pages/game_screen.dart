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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CodeAlchemistGame _game;
  // We need a key to access the Bloc context from the game callbacks if needed,
  // OR we can just capture the Bloc instance in the callbacks.
  // Using a Stateful widget allows us to initialize the game with callbacks that reference the context (or a captured Bloc).
  // But since we are creating the Bloc inside the build via BlocProvider, we need to be careful.

  // Actually, standard practice: GameWidget should be inside BlocBuilder/Consumer
  // but the Game instance often needs to be created once.
  // The Game needs to call back to the Bloc.

  // Solution: We will create the game instance in `initState` but we can't access the Bloc there because it's created in `build`.
  // BETTER: Move BlocProvider ABOVE GameScreen (e.g. in AppRouter or a wrapper).
  // But given existing structure, let's wrap the content in a Builder to get the Bloc.

  // Wait, `_game` is final.
  // We can pass the callbacks to the game constructor.
  // Those callbacks can call a `GlobalKey` or we can use a closure that we update?
  // No, easiest is to let the Game communicate via a `Bloc` if we passed it, but we registered it via GetIt.

  // Let's stick to the plan: Game has `onStepChanged` and `onFinished` callbacks.
  // We need to implement these callbacks to talk to the Bloc.

  GameBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _game = CodeAlchemistGame(
      onStepChanged: (index) {
        _bloc?.add(UpdateExecutionIndexEvent(index));
      },
      onFinished: () {
        _bloc?.add(ExecutionCompletedEvent());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>(),
      child: Builder( // Builder to get context with GameBloc
        builder: (context) {
          // Capture the bloc instance for the game callbacks
          _bloc = context.read<GameBloc>();

          return BlocListener<GameBloc, GameState>(
            listenWhen: (prev, curr) => prev.status != GameStatus.running && curr.status == GameStatus.running,
            listener: (context, state) {
              // Trigger game execution when Bloc switches to running
              _game.executeBatch(state.commands);
            },
            child: Scaffold(
              backgroundColor: AppColors.voidBackground,
              body: Stack(
                children: [
                  // We wrap GameWidget to prevent rebuilds of the Game instance
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

                  // Terminal Overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BlocBuilder<GameBloc, GameState>(
                      builder: (context, state) {
                        return CommandTerminal(
                          onRun: () => context.read<GameBloc>().add(RunCommandsEvent()),
                          busy: state.status == GameStatus.running,
                          currentExecutingIndex: state.currentExecutingIndex,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
