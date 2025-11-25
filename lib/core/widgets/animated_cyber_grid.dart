import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedCyberGrid extends StatefulWidget {
  const AnimatedCyberGrid({super.key});

  @override
  State<AnimatedCyberGrid> createState() => _AnimatedCyberGridState();
}

class _AnimatedCyberGridState extends State<AnimatedCyberGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CyberGridPainter(
            progress: _controller.value,
            color: AppColors.neonCyan.withOpacity(0.1),
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CyberGridPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    final gridSize = 50.0;
    final offset = (progress * gridSize * 2) % (gridSize * 2);

    // Draw vertical lines
    for (double x = -offset; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = -offset; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Add floating particles
    final particlePaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final particleCount = 15;
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 1000.0;
      final x = (math.sin(progress * math.pi * 2 + seed) * size.width / 3 +
              size.width / 2) %
          size.width;
      final y = (math.cos(progress * math.pi * 2 + seed * 0.7) *
                  size.height /
                  3 +
              size.height / 2) %
          size.height;

      canvas.drawCircle(
        Offset(x, y),
        2,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CyberGridPainter oldDelegate) => true;
}

