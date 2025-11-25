import 'package:flame/components.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../logic/code_alchemist_game.dart';
import 'joystick_component.dart';

class CodePlayer extends PositionComponent with HasGameRef<CodeAlchemistGame> {
  double speed = 200.0;
  JoystickComponent? joystick;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(50, 50);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = AppColors.neonCyan;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (joystick != null && joystick!.relativeDelta.length2 > 0) {
      position.add(joystick!.relativeDelta * speed * dt);
      
      // Keep player within screen bounds
      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
      position.y = position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2);
    }
  }
}

