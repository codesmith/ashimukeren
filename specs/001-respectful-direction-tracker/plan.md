# Implementation Plan: Respectful Direction Tracker

**Branch**: `001-respectful-direction-tracker` | **Date**: 2025-10-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-respectful-direction-tracker/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

A Flutter mobile application that helps users track and avoid pointing their feet toward people they must show respect to (such as parents, teachers, or honored individuals). The app allows users to register people by name and address, visualize their locations on Google Maps, and provides a direction-aware compass that alerts users with color-coded warnings (red when pointing toward, green when pointing away) based on device orientation and registered person locations.

## Technical Context

**Language/Version**: Dart/Flutter (SDK: ^3.5.4)
**Primary Dependencies**:
- google_maps_flutter (for map display and pins)
- geolocator (for device location services)
- flutter_compass (for magnetometer/compass sensor access)
- geocoding (for address to lat/lng conversion)
- sensors_plus (for accelerometer/gyroscope to detect phone orientation)
- shared_preferences or sqflite (for local data persistence)

**Storage**: Local device storage using SQLite (sqflite) or shared_preferences for persisting registered people data
**Testing**: flutter_test (built-in Flutter testing framework), integration_test for end-to-end flows
**Target Platform**: Android and iOS mobile devices (iOS 12+, Android API 21+)
**Project Type**: Mobile (Flutter cross-platform application)
**Performance Goals**:
- 60 FPS UI rendering on all screens
- <500ms visual feedback for compass direction changes
- <3 seconds map load time with 100 pins
- Smooth list scrolling with 100+ entries

**Constraints**:
- Requires device GPS/location services for direction calculation
- Requires magnetometer/compass sensor for direction detection
- Must work offline after initial address geocoding
- Phone must be held horizontally for accurate compass readings

**Scale/Scope**:
- 4 primary screens (Registration List, New Registration, Map, Compass)
- Support for 100+ registered people without performance degradation
- Single-user local-only application (no backend/cloud sync)

**Security Architecture**:
- **API Key Management**: Pattern A - Direct Embedding with API Restrictions (Industry Standard 80-90%)
- **Layer 1**: Environment variables for development (local.properties, Secrets.xcconfig) - Git-ignored
- **Layer 2**: Google Cloud Console restrictions ⭐ CRITICAL
  - Package name restriction: jp.codesmith.ashimukeren (Android/iOS)
  - SHA-1 certificate fingerprint (Android release key)
  - API restriction: Maps SDK + Geocoding API only
  - Quota limits: 10,000 Maps requests/day, 1,000 Geocoding/day
  - Billing alerts: $50/month threshold
- **Layer 3**: ProGuard/R8 code obfuscation (Android release builds)
- **Accepted Trade-off**: API keys embedded in binary (inevitable), mitigated by Google Cloud restrictions
- **Rejected Alternative**: Backend proxy (Pattern B) - unnecessary complexity for personal app

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ PASS

The project does not have a defined constitution file yet. Applying standard Flutter mobile development best practices:

- ✅ **Clean Architecture**: Following Flutter best practices with separation of concerns (models, services, UI)
- ✅ **Testability**: Using flutter_test for unit and widget tests, integration_test for E2E
- ✅ **State Management**: Using standard Flutter state management (StatefulWidget) for simplicity
- ✅ **Platform Support**: Targeting both iOS and Android with single codebase
- ✅ **Offline-First**: Local data persistence with optional online geocoding

**Re-evaluation after Phase 1**: ✅ CONFIRMED

After completing Phase 1 design:
- ✅ **Data Model**: Clean entity design with clear validation rules and state transitions
- ✅ **Service Contracts**: Well-defined interfaces with proper error handling
- ✅ **Architecture**: Separation of concerns maintained (models, services, screens, widgets)
- ✅ **Testability**: All services have testable contracts with clear test cases defined
- ✅ **Simplicity**: No unnecessary complexity, using built-in Flutter patterns where possible

The architecture and data model align with Flutter best practices and are ready for implementation.

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── models/
│   ├── respectful_person.dart       # Data model for registered people
│   └── user_location.dart            # Data model for user's current location
├── services/
│   ├── database_service.dart         # SQLite persistence service
│   ├── geocoding_service.dart        # Address → lat/lng conversion
│   ├── location_service.dart         # GPS/location access
│   ├── compass_service.dart          # Sensor data and direction calculation
│   └── direction_calculator.dart     # Bearing calculation logic
├── screens/
│   ├── registration_list_screen.dart # P1: List view of registered people
│   ├── new_registration_screen.dart  # P1: Form to register new person
│   ├── map_screen.dart               # P2: Google Maps with pins
│   └── compass_screen.dart           # P3: Direction-aware compass UI
├── widgets/
│   ├── person_list_item.dart         # List item widget for registered person
│   ├── compass_display.dart          # Compass visualization widget
│   └── direction_indicator.dart      # Visual direction indicator
└── main.dart                          # App entry point

test/
├── unit/
│   ├── models/
│   ├── services/
│   └── direction_calculator_test.dart
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    └── user_flow_test.dart            # E2E test: register → map → compass

android/                                # Android platform configuration
ios/                                    # iOS platform configuration
```

**Structure Decision**: Standard Flutter mobile application structure with clear separation of concerns. Models contain data classes, Services contain business logic and platform integrations, Screens are top-level UI pages, and Widgets are reusable UI components. This structure aligns with Flutter best practices and supports the 3 prioritized user stories (P1: Registration, P2: Map, P3: Compass).

## Complexity Tracking

*No violations - this section is not needed for this feature.*

