# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "あしむけれん" (Respectful Direction Tracker). The app helps users track and avoid pointing their feet toward people they must show respect to by providing:
- Registration of people with names and addresses (with geocoding)
- Map visualization of registered locations on Google Maps
- Direction-aware compass with visual warnings (red = danger, green = safe)

**App Name**: あしむけれん (ashimukeren)
**Current Feature**: 001-respectful-direction-tracker (see specs/001-respectful-direction-tracker/)
**Development Status**: Phase 6 (Localization) completed, Phase 7 (Polish) in progress

**Technology Stack**:
- Language: Dart/Flutter (SDK: ^3.5.4)
- Database: sqflite (SQLite for local storage)
- Key Dependencies: google_maps_flutter, geolocator, flutter_compass, geocoding, sensors_plus

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter run -d <device-id>` - Run on specific device
- `flutter run --release` - Run the app in release mode
- `flutter hot-reload` - Hot reload changes (press 'r' in terminal)
- `flutter hot-restart` - Hot restart the app (press 'R' in terminal)

### Build Commands
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS and Xcode)
- `flutter build web` - Build web app
- `flutter build macos` - Build macOS app

### Testing and Analysis
- `flutter test` - Run all tests (optional - currently failing due to outdated widget tests)
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter analyze` - Run static analysis using linter rules (REQUIRED before commit)
- `dart fix --apply` - Auto-fix common linting issues

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter pub outdated` - Check for outdated dependencies

### Useful Device Commands
- `flutter devices` - List available devices
- `xcrun simctl list devices` - List iOS simulators (macOS only)

## Important: Development Workflow

**BEFORE EVERY COMMIT** (see `.specify/memory/constitution.md`):
1. Run `flutter analyze` - Must show "No issues found!"
2. Run `flutter run` - App must launch successfully
3. Verify affected user flows manually
4. Take screenshots documenting working state if needed
5. Only then proceed with `git commit`

This "Verification Before Commit" rule is NON-NEGOTIABLE per the project constitution.

## Project Structure

### Core Application
```
lib/
├── main.dart                      # App entry point with ProviderScope (Riverpod)
├── models/                        # Immutable data classes
│   ├── direction_data.dart        # Direction/bearing data
│   ├── respectful_person.dart     # Person with name/address/coords
│   └── user_location.dart         # User's current location
├── viewmodels/                    # Business logic + state (NEW - for Riverpod features)
│   ├── registration_viewmodel.dart     # Registration state management (MIGRATED)
│   ├── map_viewmodel.dart              # Map state management (MIGRATED)
│   └── compass_viewmodel.dart          # Compass state management (PENDING - migration deferred)
├── providers/                     # Riverpod provider definitions (NEW)
│   ├── registration_providers.dart     # Registration-related providers (MIGRATED)
│   ├── map_providers.dart              # Map-related providers (MIGRATED)
│   ├── compass_providers.dart          # Compass-related providers (PENDING - migration deferred)
│   └── services_providers.dart         # Service dependency providers (COMPLETE)
├── repositories/                  # Data access layer (NEW - wraps database)
│   └── person_repository.dart          # Person CRUD operations
├── services/                      # Platform integrations (stateless)
│   ├── compass_service.dart       # Compass/magnetometer + orientation
│   ├── database_service.dart      # SQLite CRUD operations (legacy)
│   ├── direction_calculator.dart  # Bearing calculations
│   ├── geocoding_service.dart     # Address → coordinates
│   └── location_service.dart      # GPS location stream
├── screens/                       # UI pages (ConsumerWidget for migrated features)
│   ├── registration_list_screen.dart   # List all registered people (MIGRATED to MVVM)
│   ├── new_registration_screen.dart    # Register new person (MIGRATED to MVVM)
│   ├── map_screen.dart                 # Google Maps with pins (MIGRATED to MVVM)
│   └── compass_screen.dart             # Direction-aware compass (LEGACY - migration deferred)
├── widgets/                       # Reusable UI components
│   ├── compass_display.dart       # Compass rose visualization
│   ├── direction_indicator.dart   # Person direction marker
│   └── registration_list_item.dart     # List item for person
└── utils/                         # Constants and helpers
    └── constants.dart             # App-wide configuration constants
```

**Note**: Directories marked "NEW" contain MVVM + Riverpod architecture. Screens marked "MIGRATED" have been refactored to MVVM pattern. "LEGACY" screens use StatefulWidget + setState (compass migration deferred for device testing). "PENDING" files will be created when compass migration is completed.

### Platform-Specific Code
- `android/` - Android platform configuration and native code
- `ios/` - iOS platform configuration and native code
  - `ios/Runner/AppDelegate.swift` - Includes state restoration fix for crash bug
- `macos/` - macOS platform configuration and native code

### Configuration
- `pubspec.yaml` - Project dependencies and metadata
- `analysis_options.yaml` - Dart analyzer configuration with flutter_lints
- `.specify/memory/constitution.md` - Project principles and workflow rules (READ THIS!)
- `DEPLOYMENT.md` - App store deployment guide (Android/iOS)

### Specification & Task Management
- `specs/001-respectful-direction-tracker/` - Feature specification directory
  - `spec.md` - Detailed requirements
  - `plan.md` - Implementation plan
  - **Task Management (2-Track Structure)**:
    - `tasks.md` - **Main index** for both tracks (START HERE)
    - `tasks-features.md` - Feature development tasks (Phase 1-8 + future)
    - `tasks-deployment.md` - Store deployment tasks (Phase D1-D4)
  - `migration-notes.md` - MVVM + Riverpod migration documentation

## Architecture Notes

**IMPORTANT**: As of Constitution v2.0.0, this project uses MVVM + Riverpod architecture for all new features.

The app follows MVVM (Model-View-ViewModel) architecture with Riverpod state management:

### Layer Structure (MVVM)
- **Models** (`lib/models/`) - Immutable data classes (RespectfulPerson, UserLocation, DirectionData)
- **ViewModels** (`lib/viewmodels/`) - Business logic + state management (StateNotifier/Notifier)
  - Example: RegistrationViewModel, MapViewModel, CompassViewModel
  - Handle user interactions and coordinate with Services/Repositories
- **Providers** (`lib/providers/`) - Riverpod provider definitions
  - Define providers for Services, ViewModels, and dependencies
  - Example: registrationProviders, mapProviders, compassProviders
- **Views** (`lib/screens/`, `lib/widgets/`) - UI components (ConsumerWidget/ConsumerStatefulWidget)
  - **Screens**: Full-page UI (registration list, new registration, map, compass)
  - **Widgets**: Reusable UI components
  - Consume ViewModels through Riverpod providers
- **Repositories** (`lib/repositories/`) - Data access layer (database CRUD operations)
  - Example: PersonRepository wraps DatabaseService
- **Services** (`lib/services/`) - Platform integrations (sensors, geocoding, location, etc.)
  - Stateless services injected via providers
- **Utils** (`lib/utils/`) - Constants, helpers, shared utilities

### State Management (Constitution v2.0.0)
- **New features**: MUST use Riverpod (flutter_riverpod ^2.6.0)
  - ViewModels manage state using StateNotifier/Notifier
  - Views consume state using ref.watch(), ref.read(), Consumer, or ConsumerWidget
  - Testable using ProviderContainer and overrideWith()
- **Legacy code**: Existing screens use StatefulWidget + setState (can remain temporarily)
  - When modifying existing screens, refactor to MVVM + Riverpod if time permits
  - Streams for real-time data (location, compass heading) can be wrapped in StreamProvider
- **Required**: Add flutter_riverpod and riverpod_lint to pubspec.yaml for new features
- **Proper cleanup**: Dispose StreamSubscriptions, Timers in StateNotifier.dispose() or using ref.onDispose()

### Key Design Decisions
- **Material Design 3**: Using Flutter's M3 theming with custom color scheme
- **Color Coding**: Red (warning) when pointing toward person, Green (safe) otherwise, Grey (neutral) when sensors not ready
- **Performance Optimizations**:
  - Sensor throttling: 20 Hz max update rate (50ms interval)
  - Debouncing: 500ms delay for compass color changes to prevent flickering
  - Constants extracted to `lib/utils/constants.dart` for maintainability
- **Japanese UI**: All text in Japanese as primary language for users

### Database Schema
SQLite table `people`:
- `id` INTEGER PRIMARY KEY
- `name` TEXT NOT NULL
- `address` TEXT NOT NULL
- `latitude` REAL (nullable, from geocoding)
- `longitude` REAL (nullable, from geocoding)

## Implementation Status

### Completed (Phase 1-6)
- ✅ P1: Registration system (name + address input, list display, delete)
- ✅ P2: Map view with Google Maps integration and red pin markers
- ✅ P3: Compass with direction indicators and color-coded warnings
- ✅ Database persistence with sqflite
- ✅ Geocoding (address → coordinates)
- ✅ Location services with permission handling
- ✅ Compass/magnetometer integration
- ✅ Phone orientation detection (horizontal = compass mode)
- ✅ Direction calculation (bearing from user to persons)
- ✅ Full Japanese localization
- ✅ Performance optimizations (throttling, debouncing)
- ✅ Code cleanup and constants extraction
- ✅ Spec Kit constitution created

### Phase 8: MVVM + Riverpod Architecture Migration (Mostly Complete)
- ✅ T068-T076: Setup dependencies and project structure
- ✅ T077: Created `PersonRepository` for data access layer
- ✅ T078-T084: Migrated Registration screens to MVVM + Riverpod
- ✅ T085-T088a: Migrated Map screen to MVVM + Riverpod (including list item tap navigation)
- ✅ T093-T098: Created all service providers
- ✅ T099-T103: Testing infrastructure (unit tests + widget tests)
- ✅ T104: CLAUDE.md updates
- ✅ T105: flutter analyze (No issues found!)
- ✅ T106: flutter test infrastructure complete (some timing issues remain)
- ✅ T107: Migration documentation created
- ⏸️ T089-T092: **Compass migration deferred** (requires real device testing)

**Migration Status**: 80% complete (Registration + Map migrated, Compass deferred)
**See**: `specs/001-respectful-direction-tracker/migration-notes.md` for full details

### In Progress (Phase 7 - Polish)
- ⏳ T059: Error handling improvements (invalid address, network errors)
- ⏳ T063: Navigation structure (BottomNavigationBar for screen switching)
- ⏳ T067: quickstart.md verification

### Known Issues & Technical Debt
- ⏸️ **Compass Screen**: Still using legacy StatefulWidget pattern (migration deferred for device testing)
- ⚠️ **Test Timing**: Some unit tests fail due to async ViewModel initialization
- ℹ️ iOS simulator state restoration crash (fixed in AppDelegate.swift)

## Development Environment

- Dart SDK: ^3.5.4
- Flutter SDK: 3.32.5 (or compatible)
- iOS Simulator: iPhone 16 Plus (iOS 18.0) - tested
- Uses `flutter_lints` package for code quality
- Zero warnings/errors required from `flutter analyze`

## Key Features by Screen

### 1. Registration List Screen (登録一覧)
- Displays all registered people in scrollable list
- Shows name, address, and location status ("位置情報あり"/"位置情報なし")
- Delete button (trash icon) for each person
- Floating action button "新規登録" to add new person
- Navigation icons: Map (地図), Compass (コンパス), Refresh

### 2. New Registration Screen (新規登録)
- Input fields for name and address
- "登録" button to save person
- Auto-geocodes address to coordinates on registration
- Shows loading indicator during geocoding
- Shows success/error snackbar messages

### 3. Map Screen (地図)
- Google Maps integration with current location
- Red pins for each registered person with valid coordinates
- Info banner at top showing count (e.g., "1人を地図上に表示")
- Camera auto-adjusts to show all pins + current location
- Navigation icons: Back, Refresh

### 4. Compass Screen (コンパス)
- Requires phone held horizontally (shows message if not)
- Compass rose with N/E/S/W cardinal directions
- Direction indicators for each registered person
- Background color changes:
  - Red: Pointing toward person (±15° tolerance)
  - Green: Safe direction (no person nearby)
  - Grey: Not horizontal or no data
- Warning message at top when pointing toward person
- Shows registered person count and GPS accuracy at bottom
- Navigation icons: Back, Refresh

## Performance Characteristics

From `lib/utils/constants.dart`:
- `compassDirectionTolerance`: 15.0 degrees (warning zone)
- `compassDebounceDelay`: 500ms (color change debouncing)
- `sensorThrottleDelay`: 50ms (20 Hz max sensor updates)
- `locationDistanceFilter`: 10.0 meters (location update threshold)
- `locationUpdateInterval`: 5 seconds (location polling)
- `orientationGravityThreshold`: 8.0 m/s² (horizontal detection)

## API Key Security Management

**Strategy**: Pattern A - Direct Embedding with API Restrictions (Industry Standard 80-90%)

### Core Security Principle

**Reality**: API keys MUST be embedded in mobile app binaries (APK/IPA). Complete hiding is impossible.

Google's official stance: *"Treat client devices as compromised. API keys will exist somewhere in binary code. Defending against knowledgeable attackers is impossible, but we can make their lives harder."*

### Three-Layer Defense

#### Layer 1: Source Control Protection (Development)
**Purpose**: Prevent GitHub leaks (operational, not security-focused)

**Implementation**:
- **Android**: `android/local.properties` (git-ignored)
  ```properties
  GOOGLE_MAPS_API_KEY=AIzaSy...
  ```
- **iOS**: `ios/Flutter/Secrets.xcconfig` (git-ignored)
  ```
  GOOGLE_MAPS_API_KEY=AIzaSy...
  ```
- `.gitignore` includes both files

**Build Integration**:
- `android/app/build.gradle` reads from local.properties
- `AndroidManifest.xml` uses manifestPlaceholders
- `ios/Runner/Info.plist` references xcconfig variable

#### Layer 2: Google Cloud Console Restrictions ⭐ MOST CRITICAL
**Purpose**: Even if API key is extracted from APK, it cannot be used by unauthorized apps

**Required Restrictions** (Manual setup in Google Cloud Console):
1. **Application Restrictions**:
   - Android: Package name `jp.codesmith.ashimukeren`
   - iOS: Bundle ID `jp.codesmith.ashimukeren`
   - SHA-1 certificate fingerprint (release signing key)

2. **API Restrictions**:
   - Maps SDK for Android ONLY
   - Maps SDK for iOS ONLY
   - Geocoding API ONLY
   - Do NOT use "Don't restrict key"

3. **Quota Limits**:
   - Maps SDK: 10,000 requests/day
   - Geocoding API: 1,000 requests/day

4. **Billing Alerts**:
   - Budget: $50/month
   - Thresholds: 50%, 80%, 90%, 100%

**Result**: Stolen API keys are useless without matching package name + SHA-1 signature.

#### Layer 3: Code Obfuscation (Android Release)
**Purpose**: Make API key discovery more difficult (not foolproof, but raises the bar)

**Implementation** (android/app/build.gradle):
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### Accepted Trade-offs

✅ **Accepted**: API keys visible in decompiled APK/IPA (inevitable for mobile apps)
✅ **Accepted**: No backend proxy (adds cost, latency, complexity - unnecessary for this app)
✅ **Mitigated**: API key abuse via Google Cloud Console restrictions
✅ **Monitored**: Usage alerts notify of anomalies before significant billing impact

### Why Not Backend Proxy (Pattern B)?

**Rejected Alternative**: Mobile app → Backend server → Google Maps API

**Reasons**:
- ✗ Server infrastructure cost ($10-50+/month)
- ✗ Increased latency (slower UX)
- ✗ Implementation and maintenance complexity
- ✓ Only used by 10-20% of apps (banks, high-security apps with existing backends)

**Decision**: Overkill for personal/small-scale app. Pattern A provides sufficient security with Google's built-in restrictions.

**Examples Using Pattern A**: Uber, Airbnb, most mapping apps

---

## Dependencies Rationale

**Core Dependencies** (already in pubspec.yaml):
- `sqflite`: Local database for persisting registered people
- `path_provider`: Get device paths for database file (implied by sqflite)
- `google_maps_flutter`: Official Google Maps SDK for map visualization
- `geolocator`: Location services (GPS) with permission handling
- `flutter_compass`: Magnetometer access for compass heading
- `geocoding`: Convert addresses to coordinates
- `sensors_plus`: Accelerometer for phone orientation detection

**Architecture Dependencies** (ADD for new features per Constitution v2.0.0):
- `flutter_riverpod`: State management (REQUIRED for MVVM architecture)
- `riverpod_lint`: Linting rules for Riverpod best practices (dev dependency)
- `freezed`: Immutable model generation (RECOMMENDED for data classes)
- `riverpod_annotation`: Code generation for providers (OPTIONAL)
- `build_runner`: Code generation support (if using freezed/riverpod_annotation)

## Testing Notes

- `test/widget_test.dart`: Currently failing (expects old English text)
- Need to update tests for Japanese UI ("足を向けられない人" instead of "Respectful Direction Tracker")
- Integration tests recommended for: registration flow, map display, compass warnings
- Manual testing priority: iOS simulator + physical device for sensor accuracy

## Tips for Development

1. **Always check constitution first**: See `.specify/memory/constitution.md` for workflow rules
2. **Simulator limitations**: Compass may not work in simulator, use physical device for full testing
3. **Location services**: iOS simulator can simulate location via Xcode
4. **Hot reload**: Works for UI changes, but sensor changes may require hot restart
5. **Background processes**: Kill old flutter run processes if app won't launch: `killall -9 Flutter Runner`
6. **Git workflow**: Feature branch `001-respectful-direction-tracker`, no main branch set yet
