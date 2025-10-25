# Service Contracts: Respectful Direction Tracker

**Feature**: 001-respectful-direction-tracker
**Date**: 2025-10-18
**Purpose**: Define service interfaces and contracts for internal application services

## Overview

This document defines the contracts for internal services in the Respectful Direction Tracker application. Since this is a local-only mobile app with no backend API, these contracts represent the interfaces between the UI layer and service layer.

---

## 1. DatabaseService

**Purpose**: Manages all SQLite database operations for persisting RespectfulPerson records.

**Interface**:

```dart
abstract class DatabaseService {
  /// Initialize the database and create tables if needed
  /// Returns: Future that completes when database is ready
  /// Throws: DatabaseException if initialization fails
  Future<void> initialize();

  /// Insert a new person into the database
  /// Returns: Future<int> with the ID of the inserted person
  /// Throws: DatabaseException if insert fails
  Future<int> insertPerson(RespectfulPerson person);

  /// Retrieve all registered people, ordered by creation date (newest first)
  /// Returns: Future<List<RespectfulPerson>> with all persons
  /// Throws: DatabaseException if query fails
  Future<List<RespectfulPerson>> getAllPersons();

  /// Retrieve all people with valid coordinates (for map and compass)
  /// Returns: Future<List<RespectfulPerson>> with persons that have non-null lat/lng
  /// Throws: DatabaseException if query fails
  Future<List<RespectfulPerson>> getPersonsWithCoordinates();

  /// Delete a person by ID
  /// Returns: Future<int> with number of rows deleted (0 or 1)
  /// Throws: DatabaseException if delete fails
  Future<int> deletePerson(int id);

  /// Close the database connection
  /// Returns: Future that completes when database is closed
  Future<void> close();
}
```

**Error Handling**:
- All methods throw `DatabaseException` with descriptive message on failure
- UI layer should catch and display user-friendly error messages

**Example Usage**:
```dart
// Initialize on app start
await databaseService.initialize();

// Insert new person
final person = RespectfulPerson(name: 'John', address: '123 Main St');
final id = await databaseService.insertPerson(person);

// Get all persons
final persons = await databaseService.getAllPersons();

// Delete person
await databaseService.deletePerson(id);
```

---

## 2. GeocodingService

**Purpose**: Converts address strings to geographic coordinates (latitude/longitude).

**Interface**:

```dart
abstract class GeocodingService {
  /// Convert an address string to coordinates
  /// Returns: Future<GeocodingResult> with lat/lng or error
  /// Throws: GeocodingException if service is unavailable
  Future<GeocodingResult> geocodeAddress(String address);
}

class GeocodingResult {
  final double? latitude;
  final double? longitude;
  final bool success;
  final String? errorMessage;

  GeocodingResult.success({
    required this.latitude,
    required this.longitude,
  })  : success = true,
        errorMessage = null;

  GeocodingResult.failure({required this.errorMessage})
      : success = false,
        latitude = null,
        longitude = null;
}
```

**Contract**:
- Input: Non-empty address string
- Output: `GeocodingResult` with coordinates or error
- Network: May require internet connection (returns failure if offline)
- Timeout: 10 seconds maximum for geocoding API call
- Rate Limiting: No rate limiting on client side (platform handles it)

**Error Cases**:
- Address not found: `GeocodingResult.failure(errorMessage: 'Address not found')`
- Network unavailable: `GeocodingResult.failure(errorMessage: 'Network unavailable')`
- Service timeout: `GeocodingResult.failure(errorMessage: 'Request timed out')`

**Example Usage**:
```dart
final result = await geocodingService.geocodeAddress('Tokyo, Japan');
if (result.success) {
  print('Coordinates: ${result.latitude}, ${result.longitude}');
} else {
  print('Error: ${result.errorMessage}');
}
```

---

## 3. LocationService

**Purpose**: Provides access to device GPS location and manages location permissions.

**Interface**:

```dart
abstract class LocationService {
  /// Check if location services are enabled on device
  /// Returns: Future<bool> indicating if location is enabled
  Future<bool> isLocationServiceEnabled();

  /// Check current location permission status
  /// Returns: Future<LocationPermission> with current permission state
  Future<LocationPermission> checkPermission();

  /// Request location permission from user
  /// Returns: Future<LocationPermission> with granted or denied status
  Future<LocationPermission> requestPermission();

  /// Get current device location (one-time)
  /// Returns: Future<UserLocation> with current position
  /// Throws: LocationException if location unavailable or permission denied
  Future<UserLocation> getCurrentLocation();

  /// Stream of location updates (for real-time tracking)
  /// Returns: Stream<UserLocation> that emits new positions
  /// Throws: LocationException if permission denied
  Stream<UserLocation> getLocationStream();
}

enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
}
```

**Contract**:
- **Permission Flow**: Must call `checkPermission()` before accessing location
- **Error Handling**: Throws `LocationException` if permission denied or service disabled
- **Accuracy**: Requests high accuracy mode for precise bearing calculations
- **Battery**: Location stream should be cancelled when not in use (compass screen)

**Permission States**:
- `denied`: User denied permission this session, can request again
- `deniedForever`: User denied with "Don't ask again", must open Settings
- `whileInUse`: Permission granted while app is in foreground
- `always`: Permission granted even in background (not needed for this app)

**Example Usage**:
```dart
// Check and request permission
final permission = await locationService.checkPermission();
if (permission == LocationPermission.denied) {
  await locationService.requestPermission();
}

// Get one-time location
final location = await locationService.getCurrentLocation();
print('Current: ${location.latitude}, ${location.longitude}');

// Stream location updates
final stream = locationService.getLocationStream();
await for (final location in stream) {
  print('Updated: ${location.latitude}, ${location.longitude}');
}
```

---

## 4. CompassService

**Purpose**: Provides access to device magnetometer (compass heading) and accelerometer (orientation detection).

**Interface**:

```dart
abstract class CompassService {
  /// Check if magnetometer sensor is available on device
  /// Returns: Future<bool> indicating if compass is supported
  Future<bool> isCompassAvailable();

  /// Stream of compass heading updates (magnetic north)
  /// Returns: Stream<double> emitting heading in degrees (0-360, 0=North)
  /// Throws: CompassException if sensor unavailable
  Stream<double> getHeadingStream();

  /// Stream of phone orientation updates (accelerometer)
  /// Returns: Stream<PhoneOrientation> with orientation state
  Stream<PhoneOrientation> getOrientationStream();
}

class PhoneOrientation {
  final bool isHorizontal;
  final double tiltAngle; // Degrees from horizontal (0 = perfectly horizontal)

  PhoneOrientation({
    required this.isHorizontal,
    required this.tiltAngle,
  });
}
```

**Contract**:
- **Heading Range**: 0-360 degrees (0 = North, 90 = East, 180 = South, 270 = West)
- **Update Rate**: 10-20 Hz (sufficient for smooth UI)
- **Horizontal Detection**: `isHorizontal = true` when tilt < 15 degrees from horizontal
- **Calibration**: If heading jumps erratically, emit calibration needed event

**Example Usage**:
```dart
// Check sensor availability
final available = await compassService.isCompassAvailable();
if (!available) {
  showError('Compass not supported on this device');
  return;
}

// Stream heading updates
final headingStream = compassService.getHeadingStream();
await for (final heading in headingStream) {
  print('Heading: $heading degrees');
}

// Stream orientation updates
final orientationStream = compassService.getOrientationStream();
await for (final orientation in orientationStream) {
  if (!orientation.isHorizontal) {
    showWarning('Hold phone horizontally');
  }
}
```

---

## 5. DirectionCalculator

**Purpose**: Calculates bearing and distance between two geographic points using haversine formula.

**Interface**:

```dart
abstract class DirectionCalculator {
  /// Calculate bearing from origin to destination
  /// Returns: double bearing in degrees (0-360, 0=North)
  /// Throws: ArgumentError if coordinates are invalid
  double calculateBearing({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  });

  /// Calculate distance between two points
  /// Returns: double distance in meters
  /// Throws: ArgumentError if coordinates are invalid
  double calculateDistance({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  });

  /// Calculate DirectionData for a person from user's location
  /// Returns: DirectionData with bearing and distance
  /// Throws: ArgumentError if person has no coordinates
  DirectionData calculateDirectionToPerson({
    required UserLocation userLocation,
    required RespectfulPerson person,
  });

  /// Check if heading is pointing toward target bearing (within tolerance)
  /// Returns: bool true if within ±tolerance degrees
  bool isPointingToward({
    required double currentHeading,
    required double targetBearing,
    double tolerance = 15.0,
  });
}
```

**Contract**:
- **Formula**: Uses haversine formula for great circle distance
- **Accuracy**: ±5 degrees bearing accuracy required (SC-007)
- **Edge Cases**:
  - Same location (zero distance): Return bearing = 0, distance = 0
  - Antipodal points: Return bearing based on initial heading
  - Invalid coordinates: Throw ArgumentError

**Formulas**:
- **Bearing**: θ = atan2(sin(Δλ)·cos(φ₂), cos(φ₁)·sin(φ₂) − sin(φ₁)·cos(φ₂)·cos(Δλ))
- **Distance**: d = 2r · arcsin(√(sin²(Δφ/2) + cos(φ₁)·cos(φ₂)·sin²(Δλ/2)))
  where r = Earth radius (6371 km)

**Example Usage**:
```dart
// Calculate bearing
final bearing = calculator.calculateBearing(
  fromLatitude: 35.6762,
  fromLongitude: 139.6503,
  toLatitude: 34.6937,
  toLongitude: 135.5023,
);
print('Bearing: $bearing degrees'); // ~240 degrees (Tokyo to Osaka)

// Check if pointing toward target
final pointing = calculator.isPointingToward(
  currentHeading: 242.0,
  targetBearing: 240.0,
  tolerance: 15.0,
);
print('Pointing toward: $pointing'); // true (within ±15 degrees)

// Calculate full direction data
final directionData = calculator.calculateDirectionToPerson(
  userLocation: userLocation,
  person: person,
);
print('${directionData.personName}: ${directionData.cardinalDirection} ${directionData.formattedDistance}');
```

---

## Contract Testing

Each service should have contract tests to verify interface compliance:

**DatabaseService Tests**:
- ✅ Initialize creates tables successfully
- ✅ Insert returns valid ID
- ✅ GetAllPersons returns list ordered by createdAt DESC
- ✅ GetPersonsWithCoordinates filters null lat/lng
- ✅ DeletePerson removes record and returns 1
- ✅ Errors throw DatabaseException with message

**GeocodingService Tests**:
- ✅ Valid address returns success with coordinates
- ✅ Invalid address returns failure with error message
- ✅ Network unavailable returns failure
- ✅ Timeout after 10 seconds

**LocationService Tests**:
- ✅ CheckPermission returns correct permission state
- ✅ RequestPermission prompts user (mock on test)
- ✅ GetCurrentLocation returns UserLocation with valid coordinates
- ✅ GetLocationStream emits updates at regular intervals
- ✅ Permission denied throws LocationException

**CompassService Tests**:
- ✅ IsCompassAvailable returns true/false based on hardware
- ✅ GetHeadingStream emits values in 0-360 range
- ✅ GetOrientationStream detects horizontal vs tilted correctly
- ✅ Unavailable sensor throws CompassException

**DirectionCalculator Tests**:
- ✅ CalculateBearing returns correct bearing for known points (Tokyo→Osaka ≈ 240°)
- ✅ CalculateDistance returns correct distance (Tokyo→Osaka ≈ 400km)
- ✅ IsPointingToward detects within tolerance correctly
- ✅ Same location returns bearing=0, distance=0
- ✅ Invalid coordinates throw ArgumentError

---

## Summary

All internal service contracts are defined with clear interfaces, error handling, and test cases. These contracts provide:

1. **DatabaseService**: CRUD operations for RespectfulPerson persistence
2. **GeocodingService**: Address to coordinates conversion
3. **LocationService**: GPS access and permission management
4. **CompassService**: Sensor data for heading and orientation
5. **DirectionCalculator**: Geographic calculations for bearing and distance

Ready to proceed to quickstart.md generation.
