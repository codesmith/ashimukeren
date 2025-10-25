import 'package:geolocator/geolocator.dart';

/// Model representing the current geographic position of the user's device.
///
/// This is a runtime-only model (not persisted to database).
/// Used as the origin point for calculating directions to registered people.
class UserLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Check if this location is still fresh (less than 60 seconds old)
  bool get isFresh {
    final age = DateTime.now().difference(timestamp);
    return age.inSeconds < 60;
  }

  /// Factory constructor to create UserLocation from geolocator Position
  factory UserLocation.fromPosition(Position position) {
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  @override
  String toString() {
    return 'UserLocation{lat: $latitude, lng: $longitude, '
        'accuracy: ${accuracy.toStringAsFixed(1)}m, '
        'timestamp: $timestamp, fresh: $isFresh}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.accuracy == accuracy &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      accuracy,
      timestamp,
    );
  }
}
