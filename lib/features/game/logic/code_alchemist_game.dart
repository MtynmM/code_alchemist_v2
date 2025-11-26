import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../components/code_player.dart';
import '../components/joystick_component.dart';
import '../components/digital_background.dart';

class CodeAlchemistGame extends FlameGame with HasDraggables {
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

    final background = DigitalBackground();
    world.add(background);

    _player = CodePlayer();
    // Start in center of world
    _player.position = background.size / 2;
    world.add(_player);

    // Add joystick as HUD so it doesn't move with the world
    _joystick = JoystickComponent(position: Vector2(80, size.y - 80));
    camera.viewport.add(_joystick);

    _player.joystick = _joystick;

    // Camera configuration
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(_player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Place joystick at bottom left
    if (_joystick != null) {
      final joystickPosition = Vector2(80, size.y - 80);
      _joystick.position = joystickPosition;
      _joystick.updateCenter(joystickPosition);
    }
  }
}

