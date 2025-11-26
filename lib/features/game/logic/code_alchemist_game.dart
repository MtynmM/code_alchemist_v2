import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../components/code_player.dart';
import '../components/joystick_component.dart';
import '../components/digital_background.dart';

class CodeAlchemistGame extends FlameGame {
  late final World world;
  late final CodePlayer _player;
  late final JoystickComponent _joystick;

  @override
  Color get backgroundColor => AppColors.voidBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world = World();
    add(world);

    // Background
    final DigitalBackground background = DigitalBackground();
    world.add(background);

    // Player (spawned at world center)
    _player = CodePlayer();
    _player.position = Vector2.zero();
    world.add(_player);

    // HUD: Joystick (added to the viewport so it stays static on screen)
    _joystick = JoystickComponent(position: Vector2.zero());
    camera.viewport.add(_joystick);
    _joystick.priority = 10; // Ensure joystick is above world

    // Link joystick to player
    _player.joystick = _joystick;

    // Camera setup: center/lock to player
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(_player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Place joystick at consistent HUD position (e.g. bottom left, 80px offset)
    if (_joystick != null) {
      final Vector2 joystickPos = Vector2(80, size.y - 80);
      _joystick.position = joystickPos;
      _joystick.updateCenter(joystickPos);
    }
  }
}

