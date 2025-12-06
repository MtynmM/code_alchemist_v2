import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';

class CommandTerminal extends StatelessWidget {
  const CommandTerminal({
    super.key,
    required this.onRun,
    required this.busy,
    required this.currentExecutingIndex,
  });

  final void Function(List<AgentCommand>) onRun;
  final bool busy;
  final int currentExecutingIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trace Level (assume from game, for now static)
              Text(
                'TRACE: ${busy ? 'EXECUTING' : 'IDLE'}',
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Command Queue as CLI lines
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.commands.length, (i) {
                      final cmd = state.commands[i];
                      final isExecuting = i == currentExecutingIndex;
                      return Text(
                        '> ${isExecuting ? '[EXEC]' : ''} ${_textFor(cmd)}',
                        style: TextStyle(
                          color: isExecuting ? Colors.yellow : Colors.green,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: isExecuting ? FontWeight.bold : FontWeight.normal,
                        ),
                      ).animate(
                        effects: isExecuting ? [ShakeEffect(duration: 500.ms)] : [],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _cliBtn('DASH', () => context.read<GameBloc>().add(AddCommandEvent(AgentCommand.dash))),
                  _cliBtn('LEFT', () => context.read<GameBloc>().add(AddCommandEvent(AgentCommand.turnLeft))),
                  _cliBtn('RIGHT', () => context.read<GameBloc>().add(AddCommandEvent(AgentCommand.turnRight))),
                  _cliBtn('HACK', () => context.read<GameBloc>().add(AddCommandEvent(AgentCommand.hack))),
                  _cliBtn('RUN', state.commands.isEmpty || busy ? null : onRun),
                  _cliBtn('CLEAR', () => context.read<GameBloc>().add(ClearCommandsEvent())),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _textFor(AgentCommand c) {
    switch (c) {
      case AgentCommand.dash:
        return 'DASH';
      case AgentCommand.turnLeft:
        return 'TURN LEFT';
      case AgentCommand.turnRight:
        return 'TURN RIGHT';
      case AgentCommand.hack:
        return 'HACK';
    }
  }

  String _textFor(AgentCommand c) {
    switch (c) {
      case AgentCommand.dash:
        return 'DASH';
      case AgentCommand.turnLeft:
        return 'TURN LEFT';
      case AgentCommand.turnRight:
        return 'TURN RIGHT';
      case AgentCommand.hack:
        return 'HACK';
    }
  }

  Widget _cliBtn(String label, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.green,
          fontFamily: 'monospace',
          fontSize: 10,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.green, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
