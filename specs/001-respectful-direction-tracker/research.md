# Research: Respectful Direction Tracker

**Feature**: 001-respectful-direction-tracker
**Date**: 2025-10-18
**Purpose**: Resolve technical unknowns and establish best practices for implementation

## Overview

This document consolidates research findings for the Respectful Direction Tracker mobile application. The app requires integration with device sensors (GPS, magnetometer, accelerometer), geocoding services, and map display functionality.

---

## 1. Local Data Persistence Strategy

### Decision
Use **sqflite** (SQLite for Flutter) for local data persistence.

### Rationale
- Native support for structured data with relationships
- Better query performance for 100+ records compared to shared_preferences
- Supports complex queries (e.g., filtering, sorting registered people)
- Industry standard for Flutter apps requiring relational data
- No size limitations (shared_preferences has 2MB limit on some platforms)

### Alternatives Considered
- **shared_preferences**: Too limited for structured data, no query capabilities, size restrictions
- **Hive**: NoSQL solution, good performance but less familiar for relational data models
- **Drift (formerly Moor)**: More complex, adds code generation overhead for this simple use case

### Implementation Notes
- Create `RespectfulPerson` table with columns: id (primary key), name (TEXT), address (TEXT), latitude (REAL), longitude (REAL), created_at (INTEGER)
- Use database_service.dart to encapsulate all SQLite operations
- Migrations not needed for v1 (fresh install scenario)

---

## 2. Address Geocoding Service

### Decision
Use **geocoding** package (geocoding: ^3.0.0) for address to lat/lng conversion.

### Rationale
- Official Flutter-recommended package for geocoding
- Supports both forward (address → coordinates) and reverse (coordinates → address) geocoding
- Works on both iOS (Core Location) and Android (Geocoder API)
- Free tier available (no API key required for basic usage)
- Handles international addresses across different coordinate systems

### Alternatives Considered
- **Google Geocoding API**: Requires API key, billing setup, and quota management - unnecessary complexity
- **Mapbox Geocoding**: Good alternative but requires SDK setup and API key
- **Here Geocoding**: Similar to Mapbox, adds dependency management overhead

### Implementation Notes
- Cache geocoded coordinates in SQLite to avoid repeated API calls
- Handle geocoding failures gracefully with user-friendly error messages (FR-017)
- Implement retry logic for network failures
- Validate address format before geocoding (basic string validation)

### Edge Cases
- Invalid/non-existent addresses: Show error message, prevent registration until valid address provided
- Network unavailable during registration: Queue geocoding request or require user to retry
- International addresses: geocoding package handles different formats automatically

---

## 3. Compass and Sensor Integration

### Decision
Use combination of **flutter_compass** (magnetometer) and **sensors_plus** (accelerometer/gyroscope).

### Rationale
- **flutter_compass**: Provides magnetic heading (0-360°) from device magnetometer
- **sensors_plus**: Provides accelerometer data to detect phone orientation (horizontal vs tilted)
- Both packages are actively maintained and widely used in Flutter community
- Native platform support (iOS CoreMotion, Android SensorManager)

### Alternatives Considered
- **flutter_sensors**: Less maintained, fewer stars on pub.dev
- **sensors**: Deprecated, replaced by sensors_plus
- Custom native platform channels: Reinventing the wheel, unnecessary complexity

### Implementation Notes
- **Horizontal Detection**: Use accelerometer Z-axis reading
  - When phone is horizontal (parallel to ground): |Z| ≈ 9.8 m/s² (gravity)
  - Threshold: Consider horizontal if Z is within ±1.5 m/s² of ±9.8
  - Show warning message if not horizontal (User Story 3, Acceptance Scenario 4)

- **Direction Calculation**:
  - Magnetic heading from flutter_compass (0° = North, 90° = East, etc.)
  - Calculate bearing to each registered person using haversine formula
  - Compare phone heading to person bearing
  - Trigger red warning if within ±15 degrees (FR-013)

- **Sensor Sampling Rate**:
  - Compass updates: 10-20 Hz (sufficient for smooth UI)
  - Accelerometer updates: 10 Hz (sufficient for orientation detection)
  - Debounce color changes to avoid flicker (500ms requirement from SC-003)

### Edge Cases
- Device without magnetometer: Show error message, disable compass feature
- Magnetic interference: Display calibration prompt if heading jumps erratically
- Multiple people in similar directions: Show all relevant names in warning

---

## 4. Google Maps Integration

### Decision
Use **google_maps_flutter** package (official Google plugin).

### Rationale
- Official Google plugin, best support and documentation
- Supports both iOS and Android with single API
- Native map rendering performance
- Built-in marker support with customization
- Standard map interactions (zoom, pan, marker tap) included

### Alternatives Considered
- **flutter_map**: Open-source alternative using OpenStreetMap, but requires tile server setup
- **mapbox_gl**: Good alternative but requires Mapbox account and API key management
- Apple Maps (iOS only): Platform-specific, would need separate Android solution

### Implementation Notes
- **API Key Setup**:
  - Requires Google Maps API key for both iOS and Android
  - Configure in AndroidManifest.xml and AppDelegate.swift
  - Enable "Maps SDK for Android" and "Maps SDK for iOS" in Google Cloud Console

- **Marker Display**:
  - Red markers using BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
  - Show person name in marker info window on tap (User Story 2, Acceptance Scenario 4)
  - Auto-zoom map to show all markers when multiple people registered

- **Performance**:
  - Markers are efficiently rendered by native map view
  - 100 markers should render in <3 seconds (SC-005)
  - Use marker clustering if performance issues arise with many markers

### Edge Cases
- No API key configured: Show error message with setup instructions
- No registered people: Show map centered at user's current location or default (Tokyo, Japan)
- Network unavailable: Map tiles may not load, show offline message

---

## 5. Location Services Integration

### Decision
Use **geolocator** package (geolocator: ^13.0.0) for device GPS/location access.

### Rationale
- Most popular location package in Flutter ecosystem (pub.dev)
- Handles platform-specific permissions automatically (iOS/Android)
- Supports continuous location updates and one-time position retrieval
- Provides location accuracy settings (high accuracy needed for bearing calculations)
- Built-in error handling for permission denied, service disabled, etc.

### Alternatives Considered
- **location**: Similar functionality, but geolocator has better documentation and community support
- **flutter_location**: Less maintained
- Native platform channels: Unnecessary complexity for standard location access

### Implementation Notes
- **Permissions**:
  - Request "while using app" location permission
  - Configure Info.plist (iOS) and AndroidManifest.xml with permission rationale
  - Handle permission denied gracefully (FR-012 edge case)

- **Location Updates**:
  - Use high accuracy mode for precise bearing calculations
  - Update location when compass screen is active (battery optimization)
  - Cache last known location for quick access

- **Bearing Calculation**:
  - Use haversine formula to calculate bearing from user location to registered person location
  - Formula: θ = atan2(sin(Δλ)·cos(φ₂), cos(φ₁)·sin(φ₂) − sin(φ₁)·cos(φ₂)·cos(Δλ))
  - Convert result to degrees (0-360°)
  - Accuracy requirement: ±5 degrees (SC-007)

### Edge Cases
- Location services disabled: Show alert prompting user to enable in Settings
- Location permission denied: Show message explaining feature requires location access
- GPS signal unavailable (indoors): Show "acquiring location" message, use last known location if available
- User at exact same location as registered person: Bearing undefined, show neutral state

---

## 6. State Management Strategy

### Decision
Use **StatefulWidget** with **setState** for state management (Flutter built-in).

### Rationale
- Simple application with local-only data (no complex global state)
- 4 screens with independent state (no deep state sharing)
- setState is sufficient for UI updates from sensors and database
- Reduces complexity - no need for Provider, Riverpod, or Bloc for this scope
- Follows Flutter best practices for simple apps

### Alternatives Considered
- **Provider**: Overkill for this application, no global state sharing needed
- **Riverpod**: More complex setup, not justified for 4 simple screens
- **Bloc**: Too much boilerplate for simple sensor → UI updates

### Implementation Notes
- Each screen manages its own state independently
- Database service can be accessed directly from screens
- Sensor streams (compass, accelerometer, location) managed within CompassScreen
- List refresh after registration handled via Navigator pop with result

---

## 7. Navigation Strategy

### Decision
Use **Navigator 1.0** (push/pop) with named routes.

### Rationale
- Simple linear navigation flow (list → form → list, list → map, list → compass)
- No deep linking or complex navigation state required
- Named routes provide clear navigation paths
- Standard Flutter approach for simple apps

### Alternatives Considered
- **Navigator 2.0 / Router**: Overkill for simple stack-based navigation
- **go_router**: Adds dependency, not needed without deep linking requirements
- **Auto_route**: Code generation overhead not justified

### Implementation Notes
- Define routes in main.dart:
  - `/` → RegistrationListScreen (home)
  - `/new-registration` → NewRegistrationScreen
  - `/map` → MapScreen
  - `/compass` → CompassScreen
- Use Navigator.pushNamed() for navigation
- Return data from NewRegistrationScreen to trigger list refresh

---

## 8. UI/UX Design Patterns

### Decision
Use **Material Design 3** (Flutter's default) with custom color scheme for compass warnings.

### Rationale
- Material Design provides consistent, familiar UI patterns
- Built-in widgets for forms, lists, buttons, app bars
- Accessibility support out of the box
- Custom colors easy to define (red/green for compass states)

### Implementation Notes
- **Color Scheme**:
  - Red warning state: Colors.red[700] (strong, noticeable)
  - Green safe state: Colors.green[700] (calming, positive)
  - Neutral state: Colors.grey[300] (when no registered people or phone not horizontal)

- **Screen Layouts**:
  - RegistrationListScreen: Scaffold + ListView.builder + FloatingActionButton
  - NewRegistrationScreen: Scaffold + Form + TextFormField widgets
  - MapScreen: Scaffold + GoogleMap widget (full screen)
  - CompassScreen: Scaffold + CustomPaint (for compass visualization)

- **Accessibility**:
  - Color changes accompanied by text warnings (not color-only)
  - Semantic labels for screen readers
  - Sufficient touch target sizes (min 48x48 dp)

---

## 9. Testing Strategy

### Decision
3-layer testing approach: Unit tests, Widget tests, Integration tests.

### Rationale
- **Unit tests**: Verify business logic in isolation (direction calculation, data models)
- **Widget tests**: Verify UI behavior (form validation, list display)
- **Integration tests**: Verify end-to-end user flows (User Stories 1-3)
- Follows Flutter testing best practices and pyramid approach

### Implementation Notes
- **Unit Tests**:
  - direction_calculator_test.dart: Verify bearing calculation accuracy
  - database_service_test.dart: Mock database operations
  - Models: Test data serialization/deserialization

- **Widget Tests**:
  - Test form validation in NewRegistrationScreen
  - Test list item rendering in RegistrationListScreen
  - Test compass color changes in CompassScreen (mock sensor data)

- **Integration Tests**:
  - user_flow_test.dart: Complete workflow from spec User Story acceptance scenarios
  - Test P1: Register → verify list display
  - Test P2: Register → view on map → verify pin
  - Test P3: Register → compass → verify color changes

---

## 10. Error Handling and Edge Cases

### Decision
Graceful degradation with user-friendly error messages and fallback behavior.

### Rationale
- Many potential failure points: sensors, location, network, geocoding
- User should always understand what went wrong and what action to take
- App should never crash - always handle exceptions

### Implementation Notes
- **Geocoding Failures** (FR-017):
  - Show Snackbar: "Unable to find address. Please check and try again."
  - Keep user on registration form to correct address
  - Log error for debugging

- **Location Services Disabled**:
  - Show dialog: "Location access required for compass feature. Enable in Settings?"
  - Provide button to open Settings app
  - Disable compass feature if permanently denied

- **Sensor Unavailable**:
  - Check sensor availability on app start
  - Show warning if magnetometer not available: "Compass feature not supported on this device"
  - Disable compass screen navigation

- **Network Unavailable**:
  - Geocoding requires network - queue request or show retry prompt
  - Map tiles may not load - show "Offline" message
  - Allow viewing cached data without network

- **Performance Edge Cases**:
  - 100+ registered people: Test list scrolling performance, implement pagination if needed
  - Sensor update flood: Debounce updates to max 20 Hz, throttle UI updates

---

## Summary

All technical unknowns have been resolved. The implementation will use:
- **sqflite** for local SQLite persistence
- **geocoding** for address → coordinates conversion
- **flutter_compass** + **sensors_plus** for compass and orientation detection
- **google_maps_flutter** for map display with markers
- **geolocator** for GPS location access
- **StatefulWidget + setState** for simple state management
- **Navigator 1.0** for navigation
- **Material Design 3** for UI/UX
- **3-layer testing** approach (unit, widget, integration)
- **Graceful error handling** for all failure scenarios

Ready to proceed to Phase 1: Data Model and Contracts.
