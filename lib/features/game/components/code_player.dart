import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/game_enums.dart';

class CodePlayer extends SpriteAnimationGroupComponent<AgentState>
    with HasGameRef {
  int gridX = 0;
  int gridY = 0;
  Direction facing = Direction.right;
  bool _moving = false;

  late final Map<AgentState, SpriteAnimation> animations;
  late final double tileSize;

  // Grid bounds - assume simple 10x10 for now, or injectable.
  // In a real scenario, this should come from a LevelController.
  final int maxX = 10;
  final int maxY = 10;
  final int minX = -10;
  final int minY = -10;

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
    final recorder = ui.PictureRecorder();
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

  Future<void> moveForward() async {
    if (_moving) return;

    // 1. Calculate target logic position
    int nextX = gridX;
    int nextY = gridY;

    switch (facing) {
      case Direction.up:
        nextY -= 1;
        break;
      case Direction.right:
        nextX += 1;
        break;
      case Direction.down:
        nextY += 1;
        break;
      case Direction.left:
        nextX -= 1;
        break;
    }

    // 2. Bounds Check (Simple collision)
    // In future, check against Level Map for Walls
    if (nextX < minX || nextX > maxX || nextY < minY || nextY > maxY) {
       // Hit wall effect or just return
       // For now, shake or nothing
       await add(
         MoveEffect.by(
           Vector2((nextX - gridX) * 10.0, (nextY - gridY) * 10.0),
           EffectController(duration: 0.1, alternate: true),
         )
       );
       return;
    }

    _moving = true;
    final origin = _getWorldPos();

    // 3. Update Logic Position
    gridX = nextX;
    gridY = nextY;

    final dest = _getWorldPos();
    current = AgentState.dash;

    // 4. Ghost Trail (Cyberpunk Feel)
    final int ghostCount = 4;
    for (var i = 1; i <= ghostCount; i++) {
      Future.delayed(Duration(milliseconds: 36 * i), () async {
        if (parent == null) return;
        final ghost = _GhostTrail(
          pos: Vector2.lerp(origin, dest, i / ghostCount)!,
          tileSize: tileSize,
          color: AppColors.neonCyan.withOpacity(0.12 + 0.07 * (ghostCount - i)),
        );
        parent?.add(ghost);
      });
    }

    // 5. Visual Movement
    await add(
      MoveEffect.to(
        dest,
        CurvedEffectController(0.25, Curves.easeInOutCubic), // Polished curve
        onComplete: () => _moving = false,
      ),
    );

    // Wait for animation to finish
    while (_moving) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    current = AgentState.idle;
  }

  Future<void> turn({required bool left}) async {
    if (_moving) return;
    _moving = true;

    facing = Direction.values[(facing.index + (left ? 3 : 1)) % 4];
    current = AgentState.run; // Use run anim for turning

    await add(
      RotateEffect.to(
        _angleForDir(facing),
        CurvedEffectController(0.2, Curves.easeInOutCubic),
        onComplete: () => _moving = false,
      ),
    );

    while (_moving) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    current = AgentState.idle;
  }

  // Placeholder for Hack - can be expanded later
  Future<void> hack() async {
    if (_moving) return;
    // ... Logic for interacting with components ...
    await Future.delayed(const Duration(milliseconds: 200));
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
