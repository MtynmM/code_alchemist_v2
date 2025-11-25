import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';

class CodeAlchemistGame extends FlameGame {
  @override
  Color get backgroundColor => AppColors.voidBackground;

  late final RectangleComponent _player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create a player component (50x50 rectangle)
    _player = RectangleComponent(
      size: Vector2(50, 50),
      paint: Paint()..color = AppColors.neonCyan,
    );

    // Add player to the game world
    add(_player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Position player in center after game resizes
    _player.position = size / 2 - Vector2(25, 25);
  }
}

