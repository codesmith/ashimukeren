import 'package:flutter/material.dart';

/// App-wide constants for configuration and theming
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Compass configuration
  static const double compassDirectionTolerance = 5.0; // degrees (±5° tolerance)
  static const Duration compassDebounceDelay = Duration(milliseconds: 50); // reduced for faster response

  // Sensor throttling (20 Hz max = 50ms)
  static const Duration sensorThrottleDelay = Duration(milliseconds: 50);

  // Compass colors
  static const Color compassWarningColor = Color(0xFFD32F2F); // red[700]
  static const Color compassSafeColor = Color(0xFF689F38); // green[700]
  static const Color compassNeutralColor = Color(0xFFE0E0E0); // grey[300]

  // Location settings
  static const double locationDistanceFilter = 10.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  // Orientation detection threshold
  static const double orientationGravityThreshold = 8.0; // m/s²
}
