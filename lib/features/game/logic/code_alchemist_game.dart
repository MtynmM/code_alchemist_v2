import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../components/code_player.dart';
import '../components/joystick_component.dart';

class CodeAlchemistGame extends FlameGame with HasDraggables {
  @override
  Color get backgroundColor => AppColors.voidBackground;

  late final CodePlayer _player;
  late final JoystickComponent _joystick;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create player component
    _player = CodePlayer();
    add(_player);

    // Create joystick component (position will be set in onGameResize)
    _joystick = JoystickComponent(position: Vector2.zero());
    add(_joystick);

    // Connect joystick to player
    _player.joystick = _joystick;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Position player in center
    _player.position = size / 2;
    
    // Position joystick at bottom-left
    final joystickPosition = Vector2(80, size.y - 80);
    _joystick.position = joystickPosition;
    _joystick.updateCenter(joystickPosition);
  }
}

