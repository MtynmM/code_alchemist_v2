import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../logic/code_alchemist_game.dart';
import 'level_components.dart';

enum AgentState { idle, run, dash }
enum Direction { up, right, down, left }

class CodePlayer extends SpriteAnimationGroupComponent<AgentState>
    with HasGameRef {
  int gridX = 0;
  int gridY = 0;
  Direction facing = Direction.right;
  bool _moving = false;

  late final Map<AgentState, SpriteAnimation> animations;
  late final double tileSize;

  CodePlayer({this.tileSize = 64.0})
      : super(size: Vector2.all(64.0), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Create placeholder animations:
    animations = {
      AgentState.idle: _makeAnim(AppColors.neonCyan),
      AgentState.run: _makeAnim(Colors.cyanAccent),
      AgentState.dash: _makeAnim(Colors.white),
    };
    animation = animations[AgentState.idle];
    current = AgentState.idle;
    position = _getWorldPos();
    angle = _angleForDir(facing);
  }

  SpriteAnimation _makeAnim(Color color) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, tileSize, tileSize));
    final paint = Paint()..color = color;
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, tileSize, tileSize), const Radius.circular(16));
    canvas.drawRRect(r, paint);
    final picture = recorder.endRecording();
    return SpriteAnimation.spriteList([
      Sprite.fromImage(picture.toImageSync(tileSize.toInt(), tileSize.toInt())),
    ], stepTime: 1);
  }

  static double _angleForDir(Direction f) {
    switch (f) {
      case Direction.up:
        return -1.5708;
      case Direction.right:
        return 0;
      case Direction.down:
        return 1.5708;
      case Direction.left:
        return 3.1416;
    }
  }

  Vector2 _getWorldPos() =>
      Vector2(gridX * tileSize, gridY * tileSize);

  Future<void> dashForward() async {
    if (_moving) return;
    _moving = true;
    final origin = _getWorldPos();
    int dx = 0, dy = 0;
    switch (facing) {
      case Direction.up:
        dy = -1;
        break;
      case Direction.right:
        dx = 1;
        break;
      case Direction.down:
        dy = 1;
        break;
      case Direction.left:
        dx = -1;
        break;
    }
    gridX += dx;
    gridY += dy;
    final dest = _getWorldPos();
    current = AgentState.dash;
    // Spawn ghost trail with a timer during dash
    final int ghostCount = 4;
    for (var i = 1; i <= ghostCount; i++) {
      Future.delayed(Duration(milliseconds: 36 * i), () async {
        final ghost = _GhostTrail(
          pos: Vector2.lerp(origin, dest, i / ghostCount)!,
          tileSize: tileSize,
          color: AppColors.neonCyan.withOpacity(0.12 + 0.07 * (ghostCount - i)),
        );
        parent?.add(ghost);
      });
    }
    await add(
      MoveEffect.to(
        dest,
        CurvedEffectController(0.18, Curves.easeInOutCubic),
        onComplete: () => _moving = false,
      ),
    );
    while (_moving) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    current = AgentState.idle;
  }

  Future<void> turn({required bool left}) async {
    if (_moving) return;
    _moving = true;
    facing = Direction.values[(facing.index + (left ? 3 : 1)) % 4];
    current = AgentState.run;
    await add(
      RotateEffect.to(
        _angleForDir(facing),
        CurvedEffectController(0.18, Curves.easeInOutCubic),
        onComplete: () => _moving = false,
      ),
    );
    while (_moving) {
      await Future.delayed(const Duration(milliseconds: 12));
    }
    current = AgentState.idle;
  }

  Future<void> hack() async {
    if (_moving) return;
    // Calculate front position
    int dx = 0, dy = 0;
    switch (facing) {
      case Direction.up:
        dy = -1;
        break;
      case Direction.right:
        dx = 1;
        break;
      case Direction.down:
        dy = 1;
        break;
      case Direction.left:
        dx = -1;
        break;
    }
    final frontPos = _getWorldPos() + Vector2(dx * tileSize, dy * tileSize);

    // Find interactable components at front position
    final components = parent?.children.where((c) =>
      c is PositionComponent &&
      c.position.distanceTo(frontPos) < tileSize / 2 &&
      (c is Firewall || c is DataNode)
    );

    if (components != null) {
      for (final c in components) {
        if (c is Firewall) {
          c.hack();
        } else if (c is DataNode) {
          c.collect();
          // Add to inventory or notify
        }
      }
    }
  }
}

class _GhostTrail extends SpriteComponent {
  _GhostTrail({
    required Vector2 pos,
    required double tileSize,
    required Color color,
  }) : super(
          position: pos,
          size: Vector2.all(tileSize),
          anchor: Anchor.center,
        ) {
    paint = Paint()
      ..color = color;
  }

  double _opacity = 1;
  @override
  void update(double dt) {
    _opacity -= dt * 3.5; // fades over ~0.28s
    paint.color = paint.color.withOpacity(_opacity.clamp(0, 1));
    if (_opacity <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(16));
    canvas.drawRRect(r, paint);
  }
}

