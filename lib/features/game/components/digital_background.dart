import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';

class DigitalBackground extends PositionComponent {
  late final Picture _cachedGridPicture;
  late final double _size;

  DigitalBackground()
      : super(
          position: Vector2(-GameConstants.gridHalfExtent, -GameConstants.gridHalfExtent),
          size: Vector2.all(GameConstants.gridHalfExtent * 2),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & Size(size.x, size.y));

    final Paint gridPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.15)
      ..strokeWidth = 1.0;

    for (double x = 0; x <= size.x; x += GameConstants.gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.y),
        gridPaint,
      );
    }
    for (double y = 0; y <= size.y; y += GameConstants.gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        gridPaint,
      );
    }
    _cachedGridPicture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw pre-rendered grid
    canvas.drawPicture(_cachedGridPicture);
  }
}
