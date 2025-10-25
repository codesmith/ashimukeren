import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/direction_data.dart';

/// Widget to display a direction indicator for a respectful person
///
/// Shows an arrow or text pointing toward the person's location
class DirectionIndicator extends StatelessWidget {
  final DirectionData directionData;
  final double currentHeading;
  final Color color;

  const DirectionIndicator({
    super.key,
    required this.directionData,
    required this.currentHeading,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate relative bearing (direction relative to current heading)
    final relativeBearing = (directionData.bearing - currentHeading) % 360;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arrow pointing to person
        Transform.rotate(
          angle: relativeBearing * math.pi / 180,
          child: Icon(
            Icons.arrow_upward,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 4),
        // Person name
        Text(
          directionData.person.name,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        // Distance and cardinal direction
        Text(
          '${directionData.cardinalDirection} ${directionData.formattedDistance}',
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
