# Quickstart Guide: あしむけれん (Respectful Direction Tracker)

**Feature**: 001-respectful-direction-tracker
**Date**: 2025-10-18 (Updated: 2025-10-18)
**Status**: Phase 6 (Localization) complete, Phase 7 (Polish) in progress
**Purpose**: Quick reference for developers implementing this feature

## Overview

The Respectful Direction Tracker (あしむけれん) is a Flutter mobile app that helps users track and avoid pointing their feet toward people they must show respect to. This quickstart provides essential information for implementation.

**Note**: This feature is now fully implemented with all 4 screens (registration list, new registration, map, compass) working with Japanese UI. Refer to `/CLAUDE.md` for current project state and `/.specify/memory/constitution.md` for development workflow rules.

---

## Prerequisites

**Development Environment**:
- Flutter SDK ^3.5.4
- Dart SDK (included with Flutter)
- Android Studio / Xcode for platform-specific setup
- Device or emulator with GPS and magnetometer sensor

**Required Permissions**:
- **iOS** (Info.plist):
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Location access is required to calculate directions to registered people</string>
  ```

- **Android** (AndroidManifest.xml):
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

**Google Maps API Setup**:
1. Create Google Cloud project at console.cloud.google.com
2. Enable "Maps SDK for Android" and "Maps SDK for iOS"
3. Generate API keys for both platforms
4. Add to android/app/src/main/AndroidManifest.xml:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ANDROID_API_KEY"/>
   ```
5. Add to ios/Runner/AppDelegate.swift:
   ```swift
   GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
   ```

---

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Database
  sqflite: ^2.3.0
  path: ^1.8.3

  # Location & Geocoding
  geolocator: ^13.0.0
  geocoding: ^3.0.0

  # Sensors
  flutter_compass: ^0.8.0
  sensors_plus: ^6.0.0

  # Maps
  google_maps_flutter: ^2.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

Run: `flutter pub get`

---

## Project Structure

```
lib/
├── models/              # Data models
│   ├── direction_data.dart      # Direction/bearing data
│   ├── respectful_person.dart   # Person with name/address/coords
│   └── user_location.dart       # User's current location
├── services/            # Business logic
│   ├── compass_service.dart         # Compass/magnetometer + orientation
│   ├── database_service.dart        # SQLite CRUD operations
│   ├── direction_calculator.dart    # Bearing calculations
│   ├── geocoding_service.dart       # Address → coordinates
│   └── location_service.dart        # GPS location stream
├── screens/             # UI screens
│   ├── registration_list_screen.dart   # List all registered people
│   ├── new_registration_screen.dart    # Register new person
│   ├── map_screen.dart                 # Google Maps with pins
│   └── compass_screen.dart             # Direction-aware compass
├── widgets/             # Reusable widgets
│   ├── compass_display.dart         # Compass rose visualization
│   ├── direction_indicator.dart     # Person direction marker
│   └── registration_list_item.dart  # List item for person
├── utils/               # Constants and helpers
│   └── constants.dart   # App-wide configuration constants
└── main.dart            # Entry point (AshimukerenApp)
```

---

## Implementation Order (By Priority)

**STATUS**: All phases (P1, P2, P3) are now complete. Phase 7 (Polish) in progress.

Follow the user story priorities from spec.md:

### Phase 1: P1 - Registration (Foundation) ✅ COMPLETED
**Files implemented**:
1. `lib/models/respectful_person.dart` - Data model ✅
2. `lib/services/database_service.dart` - SQLite persistence ✅
3. `lib/services/geocoding_service.dart` - Address → coordinates ✅
4. `lib/screens/new_registration_screen.dart` - Registration form ✅
5. `lib/screens/registration_list_screen.dart` - List display ✅
6. `lib/widgets/registration_list_item.dart` - List item widget ✅

**Key functionality**:
- Form validation (name and address required) ✅
- Geocoding address to lat/lng ✅
- Saving to SQLite database ✅
- Displaying list of registered people ✅
- Delete functionality ✅
- Japanese UI ("新規登録", "登録一覧") ✅

**Test**: User can register a person and see them in the list ✅

---

### Phase 2: P2 - Map View ✅ COMPLETED
**Files implemented**:
1. `lib/screens/map_screen.dart` - Google Maps with pins ✅

**Key functionality**:
- Load all people with valid coordinates ✅
- Display red markers at each location ✅
- Show person name on marker tap ✅
- Map interactions (zoom, pan) ✅
- Camera auto-adjusts to show all pins ✅
- Japanese UI ("地図", "Xを地図上に表示") ✅

**Test**: User can view registered locations on Google Maps ✅

---

### Phase 3: P3 - Compass ✅ COMPLETED
**Files implemented**:
1. `lib/models/user_location.dart` - User location model ✅
2. `lib/models/direction_data.dart` - Direction/bearing data ✅
3. `lib/services/location_service.dart` - GPS access ✅
4. `lib/services/compass_service.dart` - Sensor access + orientation ✅
5. `lib/services/direction_calculator.dart` - Bearing calculations ✅
6. `lib/screens/compass_screen.dart` - Compass UI ✅
7. `lib/widgets/compass_display.dart` - Compass visualization ✅
8. `lib/widgets/direction_indicator.dart` - Direction indicator ✅
9. `lib/utils/constants.dart` - App-wide constants ✅

**Key functionality**:
- Get user's current location ✅
- Calculate bearing to each registered person ✅
- Display compass with cardinal directions (N/E/S/W) ✅
- Show person directions on compass ✅
- Detect phone orientation (horizontal check) ✅
- Change background color (red when pointing toward, green when safe, grey when not horizontal) ✅
- Display warning message in red state ✅
- Performance optimizations (throttling 20Hz, debouncing 500ms) ✅
- Japanese UI ("コンパス", "警告：足を向けてはいけない方向です") ✅

**Test**: User can use compass to avoid pointing toward registered people ✅

---

## Key Technical Decisions

**Database**:
- Use sqflite for local SQLite persistence
- Single table: `respectful_persons`
- See `data-model.md` for schema

**Geocoding**:
- Use geocoding package (no API key required for basic usage)
- Cache results in database (never re-geocode)
- Handle failures gracefully (allow saving without coordinates)

**Sensors**:
- flutter_compass: Magnetic heading (0-360°)
- sensors_plus: Accelerometer for horizontal detection
- Update rate: 20 Hz max (50ms throttle) for smooth UI and performance

**Direction Calculation**:
- Haversine formula for bearing and distance
- Tolerance: ±15 degrees for "pointing toward" detection
- See `contracts/service-interfaces.md` for formulas

**State Management**:
- StatefulWidget + setState (simple approach)
- No complex state management needed
- Each screen manages its own state

**Development Workflow** (see `/.specify/memory/constitution.md`):
- ⚠️ **REQUIRED BEFORE COMMIT**: Run `flutter analyze` (zero warnings), run `flutter run` (verify it works), document verification
- Constitution defines all workflow rules and best practices
- "Verification Before Commit" is NON-NEGOTIABLE

---

## Testing Strategy

**Unit Tests** (`test/unit/`):
```bash
flutter test test/unit/
```
- Models: Serialization, validation
- Services: Direction calculation, database operations
- Focus on business logic

**Widget Tests** (`test/widget/`):
```bash
flutter test test/widget/
```
- Form validation
- List rendering
- Compass color changes (mock sensor data)

**Integration Tests** (`test/integration/`):
```bash
flutter test integration_test/
```
- Complete user flows (P1, P2, P3)
- Register → List → Map → Compass workflow

---

## Common Gotchas

1. **Google Maps API Key**: Must configure for both iOS and Android platforms separately
2. **Permissions**: Request location permission before accessing GPS
3. **Sensor Availability**: Check if magnetometer exists before accessing compass
4. **Geocoding Rate Limits**: Platform may rate limit; handle failures gracefully
5. **Horizontal Detection**: Phone must be truly horizontal for accurate compass readings
6. **Bearing Calculation**: Remember to normalize bearing to 0-360 range
7. **Angle Tolerance**: Use ±15 degrees to detect "pointing toward" (not exact match)

---

## Running the App

**Debug Mode**:
```bash
flutter run
```

**Release Mode** (Android):
```bash
flutter build apk
flutter install
```

**Release Mode** (iOS):
```bash
flutter build ios
# Open Xcode and run from there
```

**Run Tests**:
```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/direction_calculator_test.dart

# Integration tests
flutter test integration_test/user_flow_test.dart
```

---

## Next Steps

**For New Developers**:
1. Read `/.specify/memory/constitution.md` - Workflow rules (REQUIRED)
2. Read `/CLAUDE.md` - Current project state and architecture
3. Read `spec.md` for detailed user requirements
4. Review `data-model.md` for data structures
5. Check `contracts/service-interfaces.md` for service APIs

**Current Work** (Phase 7 - Polish):
- T059: Error handling improvements (invalid address, network errors)
- T063: Navigation structure (BottomNavigationBar for screen switching)
- Testing: Update widget tests for Japanese UI
- Documentation: Keep docs in sync with implementation

---

## Support

- **Documentation**: See `research.md` for detailed technical decisions
- **Flutter Docs**: https://docs.flutter.dev
- **Package Docs**:
  - sqflite: https://pub.dev/packages/sqflite
  - geolocator: https://pub.dev/packages/geolocator
  - geocoding: https://pub.dev/packages/geocoding
  - flutter_compass: https://pub.dev/packages/flutter_compass
  - google_maps_flutter: https://pub.dev/packages/google_maps_flutter
