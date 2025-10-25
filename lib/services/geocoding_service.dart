import 'package:geocoding/geocoding.dart';

/// Service for converting address strings to geographic coordinates.
///
/// Uses the geocoding package to perform address to lat/lng conversion.
class GeocodingService {
  /// Convert an address string to coordinates
  ///
  /// Returns a [GeocodingResult] with coordinates or error information
  Future<GeocodingResult> geocodeAddress(String address) async {
    if (address.trim().isEmpty) {
      return GeocodingResult.failure(
        errorMessage: 'Address cannot be empty',
      );
    }

    try {
      // Perform geocoding with a timeout
      final locations = await locationFromAddress(address).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Geocoding request timed out');
        },
      );

      if (locations.isEmpty) {
        return GeocodingResult.failure(
          errorMessage: 'Address not found. Please check and try again.',
        );
      }

      // Use the first result
      final location = locations.first;
      return GeocodingResult.success(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } on Exception catch (e) {
      // Handle various error cases
      String errorMessage = 'Failed to geocode address';

      if (e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network unavailable. Please check your connection.';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'Address not found. Please check and try again.';
      }

      return GeocodingResult.failure(errorMessage: errorMessage);
    } catch (e) {
      return GeocodingResult.failure(
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Reverse geocode: convert coordinates to an address string
  ///
  /// This is optional functionality for future use
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        parts.add(place.country!);
      }

      return parts.join(', ');
    } catch (e) {
      return null;
    }
  }
}

/// Result of a geocoding operation
class GeocodingResult {
  final double? latitude;
  final double? longitude;
  final bool success;
  final String? errorMessage;

  GeocodingResult._({
    this.latitude,
    this.longitude,
    required this.success,
    this.errorMessage,
  });

  /// Create a successful geocoding result with coordinates
  factory GeocodingResult.success({
    required double latitude,
    required double longitude,
  }) {
    return GeocodingResult._(
      latitude: latitude,
      longitude: longitude,
      success: true,
      errorMessage: null,
    );
  }

  /// Create a failed geocoding result with an error message
  factory GeocodingResult.failure({
    required String errorMessage,
  }) {
    return GeocodingResult._(
      latitude: null,
      longitude: null,
      success: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'GeocodingResult{success: true, lat: $latitude, lng: $longitude}';
    } else {
      return 'GeocodingResult{success: false, error: $errorMessage}';
    }
  }
}
