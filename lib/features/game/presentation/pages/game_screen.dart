import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'GAME LOOP START',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}

