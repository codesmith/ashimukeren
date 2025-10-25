import 'respectful_person.dart';

/// Runtime model for direction calculations to a person
///
/// This is not persisted to database - calculated on-demand
class DirectionData {
  final RespectfulPerson person;
  final double bearing; // Degrees from north (0-360)
  final double distance; // Meters
  final String cardinalDirection; // N, NE, E, SE, S, SW, W, NW
  final String formattedDistance; // Human-readable distance

  DirectionData({
    required this.person,
    required this.bearing,
    required this.distance,
    required this.cardinalDirection,
    required this.formattedDistance,
  });

  /// Get cardinal direction from bearing (0-360 degrees)
  static String getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Format distance in human-readable form
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else if (meters < 10000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    } else {
      return '${(meters / 1000).round()}km';
    }
  }

  @override
  String toString() {
    return 'DirectionData(person: ${person.name}, bearing: ${bearing.toStringAsFixed(1)}°, '
        'distance: $formattedDistance, direction: $cardinalDirection)';
  }
}
