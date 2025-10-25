import 'dart:math';
import '../models/direction_data.dart';
import '../models/respectful_person.dart';
import '../models/user_location.dart';

/// Service for calculating bearings and distances to registered persons
class DirectionCalculator {
  /// Calculate bearing from user location to person
  ///
  /// Returns bearing in degrees from north (0-360)
  /// Uses standard geographic bearing calculation
  static double calculateBearing(
    double userLat,
    double userLng,
    double personLat,
    double personLng,
  ) {
    // Convert to radians
    final lat1 = userLat * pi / 180;
    final lat2 = personLat * pi / 180;
    final dLng = (personLng - userLng) * pi / 180;

    // Calculate bearing using forward azimuth formula
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;

    // Normalize to 0-360
    return (bearing + 360) % 360;
  }

  /// Calculate distance from user location to person using Haversine formula
  ///
  /// Returns distance in meters
  static double calculateDistance(
    double userLat,
    double userLng,
    double personLat,
    double personLng,
  ) {
    const earthRadius = 6371000.0; // meters

    // Convert to radians
    final lat1 = userLat * pi / 180;
    final lat2 = personLat * pi / 180;
    final dLat = (personLat - userLat) * pi / 180;
    final dLng = (personLng - userLng) * pi / 180;

    // Haversine formula
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate full direction data to a person from user location
  static DirectionData calculateDirectionToPerson(
    UserLocation userLocation,
    RespectfulPerson person,
  ) {
    if (!person.hasValidCoordinates) {
      throw ArgumentError('Person does not have valid coordinates');
    }

    final bearing = calculateBearing(
      userLocation.latitude,
      userLocation.longitude,
      person.latitude!,
      person.longitude!,
    );

    final distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      person.latitude!,
      person.longitude!,
    );

    return DirectionData(
      person: person,
      bearing: bearing,
      distance: distance,
      cardinalDirection: DirectionData.getCardinalDirection(bearing),
      formattedDistance: DirectionData.formatDistance(distance),
    );
  }

  /// Check if user is pointing toward a person (within tolerance)
  ///
  /// heading: Current phone heading in degrees (0-360)
  /// bearing: Bearing to person in degrees (0-360)
  /// tolerance: Tolerance angle in degrees (default ±15°)
  ///
  /// Returns true if heading is within ±tolerance of bearing
  static bool isPointingToward(
    double heading,
    double bearing, {
    double tolerance = 15.0,
  }) {
    // Calculate angular difference accounting for 0/360 wraparound
    double diff = (bearing - heading).abs();
    if (diff > 180) {
      diff = 360 - diff;
    }

    return diff <= tolerance;
  }
}
