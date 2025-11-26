import 'package:flutter/material.dart';
import 'dart:ui';

enum AgentCommand { dash, turnLeft, turnRight }

class CommandTerminal extends StatefulWidget {
  final void Function(List<AgentCommand>) onRun;
  final bool busy;
  const CommandTerminal({super.key, required this.onRun, this.busy = false});

  @override
  State<CommandTerminal> createState() => _CommandTerminalState();
}

class _CommandTerminalState extends State<CommandTerminal>
    with TickerProviderStateMixin {
  final List<AgentCommand> _queue = [];
  final List<AnimationController> _animControllers = [];

  @override
  void dispose() {
    for (final c in _animControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addAnim(AgentCommand cmd) {
    final c = AnimationController(
      value: 1,
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 1,
      upperBound: 1.15,
    );
    setState(() {
      _queue.add(cmd);
      _animControllers.add(c);
    });
    c.forward().then((_) => c.reverse());
  }

  void _clear() {
    for (final c in _animControllers) {
      c.dispose();
    }
    setState(() {
      _queue.clear();
      _animControllers.clear();
    });
  }

  void _run() {
    widget.onRun(_queue);
    _clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(29)),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.34), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.cyanAccent.withOpacity(0.11),
            Colors.black.withOpacity(0.44),
          ],
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black38, blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(29)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Command Queue Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_queue.length, (i) {
                    final icon = _iconFor(_queue[i]);
                    if (i >= _animControllers.length) return const SizedBox.shrink();
                    return ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.08).animate(
                        CurvedAnimation(
                          parent: _animControllers[i],
                          curve: Curves.easeInOutBack,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38, blurRadius: 10, offset: Offset(0, 3)),
                            ],
                          ),
                          child: Icon(icon, color: Colors.cyanAccent, size: 28),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn(() => _addAnim(AgentCommand.dash), Icons.arrow_upward, 'DASH'),
                  _btn(() => _addAnim(AgentCommand.turnLeft), Icons.rotate_left, 'LEFT'),
                  _btn(() => _addAnim(AgentCommand.turnRight), Icons.rotate_right, 'RIGHT'),
                  _btn(widget.busy || _queue.isEmpty ? null : _run, Icons.play_arrow, 'RUN',
                      color: Colors.green, fg: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AgentCommand c) {
    switch (c) {
      case AgentCommand.dash:
        return Icons.arrow_upward;
      case AgentCommand.turnLeft:
        return Icons.rotate_left;
      case AgentCommand.turnRight:
        return Icons.rotate_right;
    }
  }

  Widget _btn(VoidCallback? onTap, IconData icon, String label,
      {Color? color, Color? fg}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: fg ?? Colors.cyanAccent),
      label: Text(label, style: TextStyle(color: fg ?? Colors.cyanAccent)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.cyan.shade900.withOpacity(0.53),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: Colors.cyanAccent.withOpacity(0.13),
        elevation: 4,
      ),
    );
  }
}
