# Feature Development Tasks: Respectful Direction Tracker

**Track**: Feature Implementation (機能実装トラック)
**Status**: Phase 1-8 Completed (107/107 tasks ✅), Phase 9+ Future Enhancements
**Last Updated**: 2025-10-20

---

## Purpose

このファイルは、「あしむけれん」アプリの**機能実装タスク**を管理します。

**対象範囲**:
- ✅ **Phase 1-8**: 既存機能実装（全107タスク完了）
- 🔮 **Phase 9+**: 将来の機能追加

**対象外（別トラック）**:
- ストア公開タスク → `tasks-deployment.md` 参照

---

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- Flutter mobile app structure: `lib/` for source, `test/` for tests
- Paths follow Flutter conventions with models, services, screens, widgets subdirectories

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Flutter dependencies

**Status**: ✅ Completed (7/7 tasks)

- [x] T001 Update pubspec.yaml with required dependencies (sqflite, geolocator, geocoding, flutter_compass, sensors_plus, google_maps_flutter)
- [x] T002 Run flutter pub get to install dependencies
- [x] T003 [P] Configure Android permissions in android/app/src/main/AndroidManifest.xml (FINE_LOCATION, COARSE_LOCATION, INTERNET)
- [x] T004 [P] Configure iOS permissions in ios/Runner/Info.plist (NSLocationWhenInUseUsageDescription)
- [x] T005 [P] Setup Google Maps API key for Android in android/app/src/main/AndroidManifest.xml
- [x] T006 [P] Setup Google Maps API key for iOS in ios/Runner/AppDelegate.swift
- [x] T007 Create directory structure (lib/models/, lib/services/, lib/screens/, lib/widgets/)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data models and database infrastructure that ALL user stories depend on

**Status**: ✅ Completed (4/4 tasks)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T008 [P] Create RespectfulPerson model in lib/models/respectful_person.dart with all fields, validation, toMap/fromMap methods
- [x] T009 [P] Create UserLocation model in lib/models/user_location.dart with Position conversion and isFresh check
- [x] T010 Create DatabaseService in lib/services/database_service.dart with initialize, CRUD operations, and table schema
- [x] T011 Update lib/main.dart to initialize DatabaseService on app start

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Register Respectful Person (Priority: P1) 🎯 MVP

**Goal**: Users can register people by name and address, save to database, and view in a list

**Status**: ✅ Completed (11/11 tasks)

**Independent Test**: Open app → tap "New Registration" → enter name and address → tap "Register" → verify person appears in list with name visible. Can also delete people from list.

### Implementation for User Story 1

- [x] T012 [P] [US1] Create GeocodingService in lib/services/geocoding_service.dart with geocodeAddress method returning GeocodingResult
- [x] T013 [P] [US1] Create PersonListItem widget in lib/widgets/person_list_item.dart for displaying person name in list with delete action
- [x] T014 [US1] Create NewRegistrationScreen in lib/screens/new_registration_screen.dart with TextFormField for name and address, validation, "Register" button
- [x] T015 [US1] Add geocoding logic to NewRegistrationScreen - call GeocodingService.geocodeAddress when user taps Register
- [x] T016 [US1] Add database save logic to NewRegistrationScreen - call DatabaseService.insertPerson with geocoded coordinates (or null if geocoding failed)
- [x] T017 [US1] Add error handling to NewRegistrationScreen - show Snackbar if geocoding fails but still save record
- [x] T018 [US1] Create RegistrationListScreen in lib/screens/registration_list_screen.dart with ListView.builder displaying all persons
- [x] T019 [US1] Add "New Registration" FloatingActionButton to RegistrationListScreen that navigates to NewRegistrationScreen
- [x] T020 [US1] Add delete functionality to RegistrationListScreen - swipe to delete or tap delete icon calls DatabaseService.deletePerson
- [x] T021 [US1] Add refresh logic to RegistrationListScreen - reload list from database after returning from NewRegistrationScreen or after delete
- [x] T022 [US1] Update lib/main.dart to set RegistrationListScreen as home route and add named route for /new-registration

**Checkpoint**: At this point, User Story 1 should be fully functional - users can register, view list, and delete people

---

## Phase 4: User Story 2 - View Registered Locations on Map (Priority: P2)

**Goal**: Users can visualize all registered people's locations on Google Maps with red pins

**Status**: ✅ Completed (8/8 tasks)

**Independent Test**: Register one or more people with valid addresses → navigate to Map screen → verify red pins appear at correct locations → tap pin to see person name → zoom/pan map

### Implementation for User Story 2

- [x] T023 [US2] Create MapScreen in lib/screens/map_screen.dart with GoogleMap widget configured
- [x] T024 [US2] Load all persons with valid coordinates from DatabaseService.getPersonsWithCoordinates in MapScreen
- [x] T025 [US2] Generate Marker objects for each person in MapScreen using BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
- [x] T026 [US2] Add marker info windows to display person name on tap in MapScreen
- [x] T027 [US2] Implement map camera positioning in MapScreen to show all markers (auto-zoom) or default location if no markers
- [x] T028 [US2] Add map controls (zoom, pan) and handle empty state (no registered people) in MapScreen
- [x] T029 [US2] Add navigation to MapScreen from RegistrationListScreen - add button or menu item with route /map
- [x] T030 [US2] Update lib/main.dart to add named route for /map → MapScreen

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - list + map views functional

---

## Phase 5: User Story 3 - Use Direction-Aware Compass (Priority: P3)

**Goal**: Users can use compass to see directions to registered people with red/green color warnings based on phone orientation

**Status**: ✅ Completed (22/22 tasks)

**Independent Test**: Register at least one person → navigate to Compass screen → hold phone horizontally → rotate to point toward/away from registered direction → verify screen turns red when pointing toward (within ±15°) and green when pointing away

### Implementation for User Story 3

- [x] T031 [P] [US3] Create DirectionData model in lib/models/direction_data.dart (runtime model, not persisted) with bearing, distance, cardinalDirection, formattedDistance
- [x] T032 [P] [US3] Create LocationService in lib/services/location_service.dart with permission check, request, getCurrentLocation, getLocationStream methods
- [x] T033 [P] [US3] Create CompassService in lib/services/compass_service.dart with isCompassAvailable, getHeadingStream, getOrientationStream methods
- [x] T034 [US3] Create DirectionCalculator in lib/services/direction_calculator.dart with calculateBearing, calculateDistance, calculateDirectionToPerson, isPointingToward using haversine formula
- [x] T035 [US3] Create DirectionIndicator widget in lib/widgets/direction_indicator.dart to display direction arrow or text for a person
- [x] T036 [US3] Create CompassDisplay widget in lib/widgets/compass_display.dart to render compass circle with N/S/E/W labels and person direction indicators
- [x] T037 [US3] Create CompassScreen in lib/screens/compass_screen.dart with state management for location, heading, orientation, and direction calculations
- [x] T038 [US3] Add location permission check and request in CompassScreen initState - show error if denied
- [x] T039 [US3] Add sensor availability check in CompassScreen - call CompassService.isCompassAvailable and show error if not supported
- [x] T040 [US3] Stream user location updates in CompassScreen using LocationService.getLocationStream
- [x] T041 [US3] Stream compass heading updates in CompassScreen using CompassService.getHeadingStream
- [x] T042 [US3] Stream phone orientation updates in CompassScreen using CompassService.getOrientationStream
- [x] T043 [US3] Load all persons with coordinates from DatabaseService.getPersonsWithCoordinates in CompassScreen
- [x] T044 [US3] Calculate DirectionData for each person in CompassScreen using DirectionCalculator when user location updates
- [x] T045 [US3] Implement color state logic in CompassScreen - check if heading points toward any person using DirectionCalculator.isPointingToward with ±15° tolerance
- [x] T046 [US3] Add background color changes in CompassScreen - red (Colors.red[700]) when pointing toward, green (Colors.green[700]) when safe, grey (Colors.grey[300]) when phone not horizontal or no people
- [x] T047 [US3] Add warning text display in CompassScreen - show person name and "Warning: Pointing toward respected direction" in red state
- [x] T048 [US3] Add horizontal orientation check in CompassScreen - show "Hold phone horizontally" message if phone not horizontal (using PhoneOrientation.isHorizontal)
- [x] T049 [US3] Render CompassDisplay widget in CompassScreen with calculated directions, heading, and orientation data
- [x] T050 [US3] Add navigation to CompassScreen from RegistrationListScreen - add button or menu item with route /compass
- [x] T051 [US3] Update lib/main.dart to add named route for /compass → CompassScreen
- [x] T052 [US3] Add dispose logic to CompassScreen to cancel all stream subscriptions (location, heading, orientation) when screen closes

**Checkpoint**: All user stories should now be independently functional - full app with registration, map, and compass features

---

## Phase 6: 日本語化 (Japanese Localization)

**Purpose**: アプリ内の全ての英語表記を日本語に翻訳

**Status**: ✅ Completed (6/6 tasks)

**Goal**: ユーザーインターフェースを日本語化し、日本人ユーザーにとって使いやすいアプリにする

- [x] T053 [P] [L10n] RegistrationListScreen の日本語化 - タイトル、ボタン、メッセージ、エラーメッセージを全て日本語に変更 (lib/screens/registration_list_screen.dart)
- [x] T054 [P] [L10n] NewRegistrationScreen の日本語化 - タイトル、ラベル、ヒント、バリデーションメッセージ、ボタン、説明文を全て日本語に変更 (lib/screens/new_registration_screen.dart)
- [x] T055 [P] [L10n] MapScreen の日本語化 - タイトル、ツールチップ、エラーメッセージを全て日本語に変更 (lib/screens/map_screen.dart)
- [x] T056 [P] [L10n] CompassScreen の日本語化 - タイトル、エラーメッセージ、警告メッセージ、説明文を全て日本語に変更 (lib/screens/compass_screen.dart)
- [x] T057 [P] [L10n] PersonListItem の日本語化 - 削除確認ダイアログなど (lib/widgets/person_list_item.dart)
- [x] T058 [P] [L10n] Main.dart のアプリタイトル確認 - "Ashimukeren" → "あしむけれん" に変更 (lib/main.dart)

**Checkpoint**: アプリ全体が日本語表記になり、日本人ユーザーが違和感なく使用できる

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements and refinements that affect multiple user stories

**Status**: ⏳ In Progress (5/9 tasks)

- [x] T059 [P] Add error handling for edge cases - location timeout errors fixed with cached position fallback in LocationService
- [ ] T060 [P] Add loading indicators - show CircularProgressIndicator during geocoding in NewRegistrationScreen, during map loading in MapScreen
- [x] T061 [P] Optimize performance - heading smoothing (10-sample moving average), debounce reduced to 50ms, sensor throttling implemented
- [ ] T062 [P] Add empty state messages - enhance existing empty states with better UX
- [ ] T063 [P] Add app navigation structure - BottomNavigationBar or Drawer to switch between List/Map/Compass screens for better UX
- [x] T064 Code cleanup and refactoring - constants extracted to lib/utils/constants.dart, debug print statements removed
- [ ] T065 [P] Update CLAUDE.md documentation with final architecture and usage instructions
- [x] T066 Run flutter analyze to check for linting issues and fix any warnings
- [ ] T067 Validate quickstart.md setup instructions - verify API key setup, permissions, dependencies are correct
- [x] T108 [P] Add safe direction message to CompassScreen - display "足を向けて寝ることができる方角です！" when pointing safe direction (green background)

---

## Phase 8: Architecture Migration to MVVM + Riverpod

**Purpose**: Refactor existing code to follow MVVM architecture with Riverpod state management (per Constitution v2.0.0)

**Status**: ✅ 80% Completed (32/40 tasks) - Compass migration deferred for device testing

**Goal**: Migrate all screens from StatefulWidget + setState to MVVM + Riverpod for better testability, maintainability, and adherence to project standards

**Constitution Reference**: `.specify/memory/constitution.md` v2.0.0 - Principles VI & VII (NON-NEGOTIABLE)

### Setup: Dependencies & Project Structure

- [x] T068 [P] Add flutter_riverpod dependency to pubspec.yaml (^2.6.0)
- [x] T069 [P] Add riverpod_lint to dev_dependencies in pubspec.yaml (^2.5.0)
- [x] T070 [P] Add freezed to dev_dependencies in pubspec.yaml (^2.4.0) for immutable models
- [x] T071 [P] Add build_runner to dev_dependencies in pubspec.yaml (^2.4.0) for code generation
- [x] T072 Run flutter pub get to install new dependencies
- [x] T073 [P] Create lib/viewmodels/ directory for ViewModels
- [x] T074 [P] Create lib/providers/ directory for Riverpod provider definitions
- [x] T075 [P] Create lib/repositories/ directory for data access layer
- [x] T076 Update lib/main.dart to wrap MaterialApp with ProviderScope

### Repository Layer: Data Access

- [x] T077 Create PersonRepository in lib/repositories/person_repository.dart wrapping DatabaseService
  - Methods: getAllPersons(), getPersonsWithCoordinates(), insertPerson(), deletePerson()
  - This abstracts database operations from ViewModels

### Registration List Screen Migration (US1)

- [x] T078 [P] Create RegistrationState class in lib/viewmodels/registration_viewmodel.dart (loading, persons list, error)
- [x] T079 Create RegistrationViewModel in lib/viewmodels/registration_viewmodel.dart extending StateNotifier<RegistrationState>
  - Methods: loadPersons(), deletePerson(id), refresh()
  - Inject PersonRepository via constructor
- [x] T080 Create registrationViewModelProvider in lib/providers/registration_providers.dart
- [x] T081 Refactor RegistrationListScreen to extend ConsumerWidget in lib/screens/registration_list_screen.dart
  - Replace setState with ref.watch(registrationViewModelProvider)
  - Call ViewModel methods instead of direct database calls
  - Remove State class and move UI-only state to StatefulWidget if needed (e.g., scroll position)

### New Registration Screen Migration (US1)

- [x] T082 [P] Create NewRegistrationState class in lib/viewmodels/registration_viewmodel.dart (idle, loading, success, error)
- [x] T083 Add registerPerson(name, address) method to RegistrationViewModel
  - Call GeocodingService, then PersonRepository
  - Update state accordingly
- [x] T084 Refactor NewRegistrationScreen to extend ConsumerStatefulWidget in lib/screens/new_registration_screen.dart
  - Use ref.read() to call registerPerson() on button press
  - Use ref.listen() to show SnackBar on success/error state changes
  - Keep TextEditingController in State (local UI state)

### Map Screen Migration (US2)

- [x] T085 [P] Create MapState class in lib/viewmodels/map_viewmodel.dart (loading, persons with coords, camera position)
- [x] T086 Create MapViewModel in lib/viewmodels/map_viewmodel.dart extending StateNotifier<MapState>
  - Methods: loadPersonsForMap(), calculateCameraPosition()
  - Inject PersonRepository via constructor
- [x] T087 Create mapViewModelProvider in lib/providers/map_providers.dart
- [x] T088 Refactor MapScreen to extend ConsumerStatefulWidget in lib/screens/map_screen.dart
  - Use ref.watch(mapViewModelProvider) for persons data
  - Keep GoogleMapController in State (local UI state)
  - Replace direct database calls with ViewModel methods
- [x] T088a Add tap handling for list items to navigate to MapScreen centered on person location

### Compass Screen Migration (US3)

**Status**: ⏸️ Deferred (requires real device testing)

- [ ] T089 [P] Create CompassState class in lib/viewmodels/compass_viewmodel.dart (location, heading, orientation, persons, directions, warning state)
- [ ] T090 Create CompassViewModel in lib/viewmodels/compass_viewmodel.dart extending StateNotifier<CompassState>
  - Methods: startCompass(), stopCompass(), updateLocation(), updateHeading(), updateOrientation()
  - Inject PersonRepository, LocationService, CompassService, DirectionCalculator
  - Handle all stream subscriptions internally via ref.onDispose()
- [ ] T091 Create compassViewModelProvider in lib/providers/compass_providers.dart
- [ ] T092 Refactor CompassScreen to extend ConsumerWidget in lib/screens/compass_screen.dart
  - Use ref.watch(compassViewModelProvider) for all state
  - Remove all State class and StreamSubscriptions (move to ViewModel)
  - Call ViewModel.startCompass() in initState equivalent (using ref lifecycle)

### Services as Providers

- [x] T093 [P] Create databaseServiceProvider in lib/providers/services_providers.dart
- [x] T094 [P] Create locationServiceProvider in lib/providers/services_providers.dart
- [x] T095 [P] Create compassServiceProvider in lib/providers/services_providers.dart
- [x] T096 [P] Create geocodingServiceProvider in lib/providers/services_providers.dart
- [x] T097 [P] Create directionCalculatorProvider in lib/providers/services_providers.dart
- [x] T098 [P] Create personRepositoryProvider in lib/providers/services_providers.dart (depends on databaseServiceProvider)

### Testing: ViewModel Unit Tests

- [x] T099 [P] Create test/unit/viewmodels/ directory
- [x] T100 Create RegistrationViewModel unit tests in test/unit/viewmodels/registration_viewmodel_test.dart
  - Test loadPersons(), deletePerson(), error handling
  - Use ProviderContainer for isolated testing
- [x] T101 Create MapViewModel unit tests in test/unit/viewmodels/map_viewmodel_test.dart
- [ ] T102 Create CompassViewModel unit tests in test/unit/viewmodels/compass_viewmodel_test.dart
  - Test state transitions, stream handling, direction calculations

### Widget Tests with Mocked Providers

- [x] T103 Update test/widget_test.dart to use ProviderScope.overrideWith()
  - Mock ViewModels for testing UI in isolation
  - Fix existing widget tests for Japanese UI

### Documentation & Cleanup

- [x] T104 Update CLAUDE.md to mark migration complete and update "Implementation Status"
- [x] T105 Run flutter analyze to verify no issues with new architecture
- [x] T106 Run flutter test to verify all tests pass
- [x] T107 Create migration documentation in specs/001-respectful-direction-tracker/migration-notes.md
  - Document before/after architecture
  - Lessons learned
  - Benefits of MVVM + Riverpod

**Checkpoint**: Registration + Map screens migrated to MVVM + Riverpod, tested, Constitution v2.0.0 compliant (80% complete)

**Compass Migration**: Deferred to allow real device testing before refactoring

---

## Future Enhancements (Phase 9+)

**Status**: 🔮 Not Yet Planned

このセクションには、将来追加される新機能のタスクを記載します。

### 例: Phase 9 - Notification System (仮)

- [ ] T200 Add local notification support
- [ ] T201 Notify user when pointing toward forbidden direction while sleeping
- ...

### 例: Phase 10 - Data Sync (仮)

- [ ] T250 Add cloud backup support
- [ ] T251 Implement multi-device sync
- ...

---

## Task Summary

### Completed Phases
- **Phase 1**: Setup (7 tasks) ✅
- **Phase 2**: Foundational (4 tasks) ✅
- **Phase 3**: User Story 1 - 登録機能 (11 tasks) ✅
- **Phase 4**: User Story 2 - 地図機能 (8 tasks) ✅
- **Phase 5**: User Story 3 - コンパス機能 (22 tasks) ✅
- **Phase 6**: 日本語化 (6 tasks) ✅
- **Phase 7**: Polish (5/9 tasks) ⏳
- **Phase 8**: MVVM + Riverpod移行 (32/40 tasks) ✅ 80%

### Total
- **Completed**: 95 tasks
- **In Progress**: 4 tasks (Phase 7)
- **Deferred**: 8 tasks (Phase 8 Compass)
- **Future**: TBD

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (T001-T007) - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion (T008-T011)
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3) for single developer
- **日本語化 (Phase 6)**: Can start after User Stories are complete - independent localization work
- **Polish (Phase 7)**: Depends on all desired user stories being complete
- **Architecture Migration (Phase 8)**: Should start AFTER Polish (Phase 7) is complete
  - This is a refactoring phase that touches all screens
  - Requires working app to validate migration doesn't break functionality
  - Can be done incrementally: one screen at a time (recommended)

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2, T011) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2, T011) - Depends on RespectfulPerson model (T008) and DatabaseService (T010) but can run in parallel with US1
- **User Story 3 (P3)**: Can start after Foundational (Phase 2, T011) - Depends on RespectfulPerson model (T008), UserLocation model (T009), and DatabaseService (T010) but can run in parallel with US1/US2

**Note**: All three user stories depend on the same foundational models and database service, but each story's screen and service implementations are independent. This means after Phase 2, a team could work on all three stories in parallel.

---

## Related Documentation

- **Deployment Tasks**: See `tasks-deployment.md` for store publication workflow
- **Specification**: See `spec.md` for feature requirements
- **Implementation Plan**: See `plan.md` for technical approach
- **Main Task Index**: See `tasks.md` for overview of both tracks
