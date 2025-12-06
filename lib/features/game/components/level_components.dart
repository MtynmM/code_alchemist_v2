import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../logic/code_alchemist_game.dart';

/// Collectible Data Node - Rotating neon cube, must be collected to open exit.
class DataNode extends PositionComponent with HasGameRef<CodeAlchemistGame> {
  bool collected = false;

  DataNode({required Vector2 position})
      : super(position: position, size: Vector2.all(GameConstants.tileSize), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    if (collected) return;
    final paint = Paint()..color = AppColors.neonCyan.withOpacity(0.8);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, paint);
    // Add rotation effect
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(gameRef.currentTime * 2); // Rotate over time
    canvas.drawRect(rect.translate(-size.x / 2, -size.y / 2), Paint()..color = Colors.white.withOpacity(0.3));
    canvas.restore();
  }

  void collect() {
    collected = true;
    removeFromParent();
    // Notify game or bloc about collection
  }
}

/// Firewall - Red translucent wall, blocks movement unless hacked.
class Firewall extends PositionComponent with HasGameRef<CodeAlchemistGame> {
  bool hacked = false;

  Firewall({required Vector2 position})
      : super(position: position, size: Vector2.all(GameConstants.tileSize), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    if (hacked) return;
    final paint = Paint()..color = AppColors.glitchRed.withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }

  void hack() {
    hacked = true;
    removeFromParent();
  }
}

/// Sentinel - Enemy that patrols, detects player in line of sight.
class Sentinel extends PositionComponent with HasGameRef<CodeAlchemistGame> {
  List<Vector2> patrolPath;
  int currentPathIndex = 0;
  double patrolSpeed = 50.0;
  Direction facing = Direction.right;

  Sentinel({required Vector2 position, required this.patrolPath})
      : super(position: position, size: Vector2.all(GameConstants.tileSize), anchor: Anchor.center);

  @override
  void update(double dt) {
    // Simple patrol logic
    if (patrolPath.isNotEmpty) {
      final target = patrolPath[currentPathIndex];
      final direction = (target - position).normalized();
      position += direction * patrolSpeed * dt;
      if (position.distanceTo(target) < 5) {
        currentPathIndex = (currentPathIndex + 1) % patrolPath.length;
      }
    }

    // Line of sight detection (simplified)
    final player = gameRef.agent;
    final distance = position.distanceTo(player.position);
    if (distance < 200 && _isInLineOfSight(player.position)) {
      // Trigger game over
      gameRef.detected();
    }
  }

  bool _isInLineOfSight(Vector2 playerPos) {
    // Simplified: check if facing direction aligns
    final delta = playerPos - position;
    final angle = delta.angleToSigned(Vector2(1, 0));
    final facingAngle = _angleForDir(facing);
    return (angle - facingAngle).abs() < 0.5; // 28 degrees tolerance
  }

  double _angleForDir(Direction d) {
    switch (d) {
      case Direction.up:
        return -3.14159 / 2;
      case Direction.right:
        return 0;
      case Direction.down:
        return 3.14159 / 2;
      case Direction.left:
        return 3.14159;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
