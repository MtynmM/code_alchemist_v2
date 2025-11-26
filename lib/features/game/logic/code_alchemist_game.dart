import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../components/code_player.dart';
import '../components/digital_background.dart';

enum AgentCommand { dash, turnLeft, turnRight }

enum Direction { up, right, down, left }

enum AgentState { idle, run, dash }

class CodeAlchemistGame extends FlameGame {
  late final World world;
  late final CodePlayer agent;

  bool _isBusy = false;

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
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(agent);
  }

  Future<void> executeBatch(List<AgentCommand> commands) async {
    if (_isBusy) return;
    _isBusy = true;

    for (final cmd in commands) {
      switch (cmd) {
        case AgentCommand.dash:
          await agent.dashForward();
          break;
        case AgentCommand.turnLeft:
          await agent.turn(left: true);
          break;
        case AgentCommand.turnRight:
          await agent.turn(left: false);
          break;
      }
      await camera.moveTo(agent.position,
        effectController: EffectController(
            duration: 0.22, curve: Curves.easeInOutCubic)); // cam smooth follow
    }
    _isBusy = false;
  }
}

