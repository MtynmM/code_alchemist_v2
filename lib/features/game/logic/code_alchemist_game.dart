import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../components/code_player.dart';
import '../components/digital_background.dart';
import '../../domain/entities/game_enums.dart';

class CodeAlchemistGame extends FlameGame {
  late final World world;
  late final CodePlayer agent;

  // Callbacks for UI/State updates
  final Function(int) onStepChanged;
  final VoidCallback onFinished;

  bool _isBusy = false;

  CodeAlchemistGame({
    required this.onStepChanged,
    required this.onFinished,
  });

  @override
  Color get backgroundColor => AppColors.voidBackground;

  @override
  Future<void> onLoad() async {
    world = World();
    add(world);
    final bg = DigitalBackground();
    world.add(bg);
    agent = CodePlayer();
    agent.position = Vector2.zero();
    world.add(agent);

    // Initial Camera setup
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(agent);
  }

  /// The main execution engine.
  /// Iterates through the commands, updates the Bloc via callback,
  /// awaits the agent action, and handles camera movement.
  Future<void> executeBatch(List<AgentCommand> commands) async {
    if (_isBusy) return;
    _isBusy = true;

    for (int i = 0; i < commands.length; i++) {
      final cmd = commands[i];

      // 1. Notify UI which command is running
      onStepChanged(i);

      // 2. Execute Action
      switch (cmd) {
        case AgentCommand.dash:
          // For movement, we start the camera move *simultaneously* or slightly synced
          // but we await the agent's completion to keep the step logic synchronous.
          final moveFuture = agent.moveForward();

          // Smooth Camera Pan to new agent position
          // We assume the agent updates its grid/visual position inside moveForward
          // But since the agent is moving, camera.follow might handle it.
          // However, for strict "grid step" feel, sometimes explicit moveTo is nicer.
          // Since camera.follow(agent) is active, it will track the agent.
          // Let's rely on camera.follow() with some smoothness if configured,
          // OR explicit moveTo if we want "Turn-Based" feel.
          // The prompt requested: "ensure the camera smoothly follows the player to the new grid position".
          // Since camera.follow(agent) is on, it follows.
          // But to ensure it's polished, we can let it be.

          await moveFuture;
          break;

        case AgentCommand.turnLeft:
          await agent.turn(left: true);
          break;
        case AgentCommand.turnRight:
          await agent.turn(left: false);
          break;
        case AgentCommand.hack:
          await agent.hack();
          break;
      }

      // Small pause between steps for rhythm
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _isBusy = false;
    onFinished();
  }
}
