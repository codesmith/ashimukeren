import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/constants.dart';

/// Phone orientation state
enum PhoneOrientation {
  horizontal, // Phone is flat (compass mode)
  vertical, // Phone is upright
  unknown; // Cannot determine

  bool get isHorizontal => this == PhoneOrientation.horizontal;
}

/// Service for accessing device compass and orientation sensors
class CompassService {
  /// Check if compass/magnetometer is available on device
  Future<bool> isCompassAvailable() async {
    try {
      final events = FlutterCompass.events;
      if (events == null) {
        return false;
      }
      // Try to get first event with timeout
      await events.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get continuous compass heading stream
  ///
  /// Returns heading in degrees from north (0-360)
  /// Returns null events if compass is unavailable
  /// Throttled to max 20 Hz (50ms) for performance
  Stream<double?> getHeadingStream() async* {
    final events = FlutterCompass.events;
    if (events == null) {
      yield null;
      return;
    }

    DateTime? lastUpdate;
    const throttleDuration = AppConstants.sensorThrottleDelay; // 20 Hz max

    await for (final event in events) {
      final now = DateTime.now();

      // Throttle: Skip if too soon after last update
      if (lastUpdate != null && now.difference(lastUpdate) < throttleDuration) {
        continue;
      }

      lastUpdate = now;

      if (event.heading != null) {
        // Normalize heading to 0-360 range
        double heading = event.heading!;
        if (heading < 0) {
          heading = 360 + heading;
        }
        yield heading % 360;
      } else {
        yield null;
      }
    }
  }

  /// Get continuous phone orientation stream
  ///
  /// Determines if phone is held horizontally (compass mode) or vertically
  /// Throttled to max 20 Hz (50ms) for performance
  Stream<PhoneOrientation> getOrientationStream() async* {
    // Use accelerometer to detect orientation
    // When phone is horizontal (flat), Z axis should be ~9.8 or ~-9.8
    // When phone is vertical, X or Y axis should be ~9.8 or ~-9.8

    DateTime? lastUpdate;
    const throttleDuration = AppConstants.sensorThrottleDelay; // 20 Hz max

    await for (final event in accelerometerEventStream()) {
      final now = DateTime.now();

      // Throttle: Skip if too soon after last update
      if (lastUpdate != null && now.difference(lastUpdate) < throttleDuration) {
        continue;
      }

      lastUpdate = now;

      final x = event.x.abs();
      final y = event.y.abs();
      final z = event.z.abs();

      // Check if Z axis is dominant (horizontal orientation)
      // Threshold: Z should be > threshold m/s² (most gravity on Z axis)
      if (z > AppConstants.orientationGravityThreshold && z > x && z > y) {
        yield PhoneOrientation.horizontal;
      } else if (x > AppConstants.orientationGravityThreshold ||
                 y > AppConstants.orientationGravityThreshold) {
        yield PhoneOrientation.vertical;
      } else {
        yield PhoneOrientation.unknown;
      }
    }
  }
}
