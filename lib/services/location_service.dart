import 'package:geolocator/geolocator.dart';
import '../models/user_location.dart';

/// Service for handling device location access
///
/// Manages GPS permissions and provides location streams
class LocationService {
  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission from user
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location (single reading)
  Future<UserLocation?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Check/request permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) {
          throw Exception('Location permission denied');
        }
      }

      // Try last known position first (instant)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return UserLocation.fromPosition(lastKnown);
      }

      // Get current position with short timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10), // Short timeout, fallback to last known
        ),
      );

      return UserLocation.fromPosition(position);
    } catch (e) {
      // Return null on error - caller should handle
      return null;
    }
  }

  /// Get continuous location updates stream
  ///
  /// Updates approximately every 5 seconds or when position changes by 10 meters
  Stream<UserLocation> getLocationStream() async* {
    // Check if location service is enabled
    if (!await isLocationServiceEnabled()) {
      throw Exception('Location services are disabled');
    }

    // Check/request permission
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }

    // Try to get last known position first (cached, instant)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        yield UserLocation.fromPosition(lastKnown);
      }
    } catch (e) {
      // Ignore if last known position is not available
    }

    // Create position stream with settings (no timeLimit for continuous stream)
    final positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium, // Medium accuracy for faster acquisition
        distanceFilter: 10, // Update every 10 meters
        // No timeLimit - let it run continuously
      ),
    );

    // Convert Position stream to UserLocation stream
    await for (final position in positionStream) {
      yield UserLocation.fromPosition(position);
    }
  }
}
