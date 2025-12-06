import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../../domain/entities/game_enums.dart';

class CommandTerminal extends StatelessWidget {
  const CommandTerminal({
    super.key,
    required this.onRun,
    required this.busy,
    required this.currentExecutingIndex,
  });

  final VoidCallback onRun;
  final bool busy;
  final int currentExecutingIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.85),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STATUS: ${busy ? 'EXECUTING SEQ...' : 'WAITING FOR INPUT'}',
                        style: TextStyle(
                          color: busy ? Colors.yellow : Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .fadeIn(duration: 1.seconds),
                      Text(
                        'MEM: ${state.commands.length} / ∞',
                        style: const TextStyle(
                            color: Colors.green, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Command Queue Display
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
                      color: Colors.black54,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      reverse: true, // Auto scroll to bottom usually, but here maybe top
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(state.commands.length, (i) {
                          final cmd = state.commands[i];
                          final isExecuting = i == currentExecutingIndex;
                          final isDone = i < currentExecutingIndex;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Text(
                                  '${i.toString().padLeft(2, '0')} ',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _textFor(cmd),
                                  style: TextStyle(
                                    color: isExecuting
                                        ? Colors.yellowAccent
                                        : (isDone ? Colors.grey : Colors.green),
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    fontWeight: isExecuting ? FontWeight.bold : FontWeight.normal,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (isExecuting)
                                  const Text(' <_EXEC', style: TextStyle(color: Colors.yellow, fontSize: 10))
                                      .animate(onPlay: (c) => c.repeat())
                                      .fadeIn(duration: 200.ms)
                                      .fadeOut(delay: 200.ms),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Controls
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _cliBtn(context, 'MOVE', AgentCommand.dash, busy),
                        const SizedBox(width: 8),
                        _cliBtn(context, 'LEFT', AgentCommand.turnLeft, busy),
                        const SizedBox(width: 8),
                        _cliBtn(context, 'RIGHT', AgentCommand.turnRight, busy),
                        const SizedBox(width: 8),
                        _cliBtn(context, 'HACK', AgentCommand.hack, busy),
                        const SizedBox(width: 24),
                        _actionBtn('EXECUTE', Colors.cyanAccent, state.commands.isEmpty || busy ? null : onRun),
                        const SizedBox(width: 8),
                        _actionBtn('RESET', Colors.redAccent, busy ? null : () => context.read<GameBloc>().add(ClearCommandsEvent())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _textFor(AgentCommand c) {
    switch (c) {
      case AgentCommand.dash:
        return 'MOVE_FORWARD();';
      case AgentCommand.turnLeft:
        return 'TURN_LEFT();';
      case AgentCommand.turnRight:
        return 'TURN_RIGHT();';
      case AgentCommand.hack:
        return 'HACK_NODE();';
    }
  }

  Widget _cliBtn(BuildContext context, String label, AgentCommand cmd, bool busy) {
    return ElevatedButton(
      onPressed: busy ? null : () => context.read<GameBloc>().add(AddCommandEvent(cmd)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.green, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: busy ? Colors.grey : Colors.green,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        side: BorderSide(color: onTap == null ? Colors.grey : color, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onTap == null ? Colors.grey : color,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
