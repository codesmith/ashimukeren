import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/direction_data.dart';

/// Widget to display a compass with cardinal directions and person indicators
///
/// Shows N/S/E/W labels and markers for registered people
class CompassDisplay extends StatelessWidget {
  final double heading; // Current compass heading (0-360)
  final List<DirectionData> directions; // Directions to registered people
  final double size; // Compass circle diameter

  const CompassDisplay({
    super.key,
    required this.heading,
    required this.directions,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(
          heading: heading,
          directions: directions,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${heading.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getCardinalDirection(heading),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

/// Custom painter for compass circle
class _CompassPainter extends CustomPainter {
  final double heading;
  final List<DirectionData> directions;

  _CompassPainter({
    required this.heading,
    required this.directions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;

    // Draw outer circle
    final circlePaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw cardinal direction labels (N, E, S, W)
    _drawCardinalLabels(canvas, center, radius);

    // Draw tick marks every 30 degrees
    _drawTickMarks(canvas, center, radius);

    // Draw indicators for registered people
    _drawPersonIndicators(canvas, center, radius);
  }

  void _drawCardinalLabels(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final cardinals = [
      {'label': 'N', 'angle': 0.0, 'color': Colors.red},
      {'label': 'E', 'angle': 90.0, 'color': Colors.black87},
      {'label': 'S', 'angle': 180.0, 'color': Colors.black87},
      {'label': 'W', 'angle': 270.0, 'color': Colors.black87},
    ];

    for (final cardinal in cardinals) {
      final label = cardinal['label'] as String;
      final angle = cardinal['angle'] as double;
      final color = cardinal['color'] as Color;

      // Calculate position accounting for current heading
      final adjustedAngle = (angle - heading) * math.pi / 180;
      final x = center.dx + radius * math.sin(adjustedAngle);
      final y = center.dy - radius * math.cos(adjustedAngle);

      // Draw label
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - heading) * math.pi / 180;
      final innerRadius = radius - 10;
      final outerRadius = radius - 5;

      final x1 = center.dx + innerRadius * math.sin(angle);
      final y1 = center.dy - innerRadius * math.cos(angle);
      final x2 = center.dx + outerRadius * math.sin(angle);
      final y2 = center.dy - outerRadius * math.cos(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  void _drawPersonIndicators(Canvas canvas, Offset center, double radius) {
    for (final direction in directions) {
      // Calculate position accounting for current heading
      final adjustedAngle = (direction.bearing - heading) * math.pi / 180;
      final indicatorRadius = radius * 0.7;
      final x = center.dx + indicatorRadius * math.sin(adjustedAngle);
      final y = center.dy - indicatorRadius * math.cos(adjustedAngle);

      // Draw person indicator (red circle)
      final personPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 8, personPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), 8, borderPaint);

      // Draw person name next to indicator
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.text = TextSpan(
        text: direction.person.name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
      textPainter.layout();

      // Position text slightly outward from indicator
      final textRadius = radius * 0.85;
      final textX = center.dx + textRadius * math.sin(adjustedAngle);
      final textY = center.dy - textRadius * math.cos(adjustedAngle);

      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) {
    return heading != oldDelegate.heading ||
        directions != oldDelegate.directions;
  }
}
