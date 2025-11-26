import 'dart:ui';
import 'package:flame/components.dart';
import '../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';

class DigitalBackground extends PositionComponent {
  late final Image _gridGlowImage;

  DigitalBackground()
      : super(
          position: Vector2(-16 * GameConstants.tileSize, -16 * GameConstants.tileSize),
          size: Vector2.all(32 * GameConstants.tileSize),
        );

  @override
  Future<void> onLoad() async {
    // Create a neon glow grid image with PictureRecorder
    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.x, size.y),
    );
    // Gradient background
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.voidBackground,
        const Color(0xFF051C28),
        const Color(0xFF000D1A),
      ],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = gradient.createShader(rect),
    );
    // Neon grid
    final gridPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    // Glowing lines background layer
    for (double x = 0; x <= size.x; x += GameConstants.tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (double y = 0; y <= size.y; y += GameConstants.tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
    // Bright inner grid layer (crisp)
    final gridPaint2 = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.12)
      ..strokeWidth = 1.3;
    for (double x = 0; x <= size.x; x += GameConstants.tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint2);
    }
    for (double y = 0; y <= size.y; y += GameConstants.tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint2);
    }
    final picture = recorder.endRecording();
    _gridGlowImage = await picture.toImage(size.x.toInt(), size.y.toInt());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_gridGlowImage != null) {
      canvas.drawImage(_gridGlowImage, Offset.zero, Paint());
    }
  }
}
