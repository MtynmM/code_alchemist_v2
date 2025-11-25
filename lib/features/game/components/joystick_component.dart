import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:ui' as ui;
import '../../../../core/theme/app_colors.dart';

class JoystickComponent extends PositionComponent with HasGameRef, Draggable {
  late Vector2 _backgroundCenter;
  late Vector2 _knobPosition;
  final double _backgroundRadius;
  final double _knobRadius;
  
  Vector2 relativeDelta = Vector2.zero();
  
  JoystickComponent({
    required Vector2 position,
    this._backgroundRadius = 60.0,
    this._knobRadius = 20.0,
  }) {
    this.position = position;
    anchor = Anchor.center;
    _backgroundCenter = position;
    _knobPosition = position;
  }

  void updateCenter(Vector2 newCenter) {
    position = newCenter;
    _backgroundCenter = newCenter;
    _knobPosition = newCenter;
    relativeDelta = Vector2.zero();
  }

  @override
  bool onDragStart(DragStartInfo info) {
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    final localPoint = info.eventPosition.game;
    final distance = _backgroundCenter.distanceTo(localPoint);
    
    if (distance <= _backgroundRadius) {
      _knobPosition = localPoint;
    } else {
      final direction = (localPoint - _backgroundCenter).normalized();
      _knobPosition = _backgroundCenter + direction * _backgroundRadius;
    }
    
    relativeDelta = (_knobPosition - _backgroundCenter) / _backgroundRadius;
    return true;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    _knobPosition = _backgroundCenter;
    relativeDelta = Vector2.zero();
    return true;
  }

  @override
  void render(Canvas canvas) {
    // Draw background circle
    final backgroundPaint = Paint()
      ..color = AppColors.hologramBlue.withOpacity(0.5)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(
      Offset(_backgroundCenter.x, _backgroundCenter.y),
      _backgroundRadius,
      backgroundPaint,
    );
    
    // Draw background border
    final borderPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.3)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(_backgroundCenter.x, _backgroundCenter.y),
      _backgroundRadius,
      borderPaint,
    );
    
    // Draw knob
    final knobPaint = Paint()
      ..color = AppColors.neonCyan
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(
      Offset(_knobPosition.x, _knobPosition.y),
      _knobRadius,
      knobPaint,
    );
  }

  @override
  bool containsPoint(Vector2 point) {
    return _backgroundCenter.distanceTo(point) <= _backgroundRadius * 1.5;
  }
}

