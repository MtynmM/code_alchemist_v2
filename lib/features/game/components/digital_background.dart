import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DigitalBackground extends PositionComponent {
  static const double gridSize = 50.0;
  static const double worldSize = 4000.0;

  DigitalBackground() : super(size: Vector2.all(worldSize));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), paint);
    }
    for (double y = 0; y <= size.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), paint);
    }
  }
}
