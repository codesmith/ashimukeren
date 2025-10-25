<!--
Sync Impact Report - Constitution v2.0.0 → v2.1.0
==================================================
Version Change: 2.0.0 → 2.1.0 (MINOR)
Amendment Date: 2025-10-20

ADDED SECTION:
- VIII. Secret Management (NON-NEGOTIABLE) - Prohibits committing secrets to git

Modified Sections:
- Code Quality Gates: Added steps 1-2 for secret verification before commit
- Priority Order: Secret Management added as #1 priority (security-critical)

Rationale for MINOR bump:
- Adds new mandatory principle (Secret Management)
- Does NOT break existing code - enforcement is at commit-time
- Strengthens security posture without requiring code changes

Templates Requiring Updates:
✅ CLAUDE.md - Already documents API key management practices
✅ plan-template.md - No changes needed (technology-agnostic)
✅ spec-template.md - Already covers security requirements (FR-020 to FR-029)
✅ tasks-template.md - No changes needed

Code Impact:
✅ No code changes required - enforcement is via .gitignore and code review
✅ android/local.properties already in .gitignore
✅ ios/Flutter/Secrets.xcconfig already in .gitignore
✅ Documentation files cleaned (placeholders instead of actual secrets)

Follow-up Actions:
1. Ensure all developers are aware of Secret Management principle
2. Verify .gitignore includes all secret files
3. Audit existing documentation for hardcoded secrets (use placeholders)
4. Add pre-commit hooks for secret scanning (optional, recommended)
-->

<!--
Sync Impact Report - Constitution v1.0.0 → v2.0.0
==================================================
Version Change: 1.0.0 → 2.0.0 (MAJOR)
Amendment Date: 2025-10-18

BREAKING CHANGES:
- State Management paradigm shift: StatefulWidget+setState → MVVM+Riverpod
- New mandatory architecture pattern (MVVM) added
- Project structure reorganized (added viewmodels/, providers/ directories)

Modified Principles:
- "State Management" section → Replaced with "VI. MVVM Architecture (NON-NEGOTIABLE)" and "VII. Riverpod State Management (NON-NEGOTIABLE)"

Added Sections:
- VI. MVVM Architecture (NON-NEGOTIABLE) - Defines Model-View-ViewModel pattern requirements
- VII. Riverpod State Management (NON-NEGOTIABLE) - Mandates Riverpod for state management
- Updated "Architecture Constraints" section with new directory structure

Removed/Deprecated:
- Old State Management guidance (StatefulWidget + setState for business state)

Templates Requiring Updates:
✅ plan-template.md - Constitution Check section will reference new architecture requirements
✅ spec-template.md - No changes needed (technology-agnostic)
✅ tasks-template.md - Already supports flexible project structures
⚠️ CLAUDE.md - MANUAL UPDATE REQUIRED to reflect MVVM + Riverpod architecture

Code Impact:
⚠️ Existing code uses StatefulWidget + setState - migration required for new features
⚠️ pubspec.yaml - Need to add flutter_riverpod, riverpod_lint dependencies

Follow-up Actions:
1. Update CLAUDE.md to replace StatefulWidget+setState with MVVM+Riverpod guidance
2. Add flutter_riverpod ^2.6.0 to pubspec.yaml dependencies
3. Add riverpod_lint ^2.5.0 to dev_dependencies
4. Create lib/viewmodels/ and lib/providers/ directories
5. Future features MUST use MVVM+Riverpod; legacy code can be migrated incrementally

Rationale for MAJOR bump:
- This is a backward-incompatible change to development practices
- Existing code patterns (StatefulWidget for business state) are now prohibited
- New mandatory architectural constraints that affect all future development
-->

# あしむけれん (Respectful Direction Tracker) Constitution

## Core Principles

### I. Verification Before Commit (NON-NEGOTIABLE)

All code changes must be verified to work correctly before committing to git:
- **Flutter apps**: Run `flutter run` on simulator or device and confirm successful launch
- **Verify key functionality**: Test the main user flows affected by changes
- **Document verification**: Take screenshots or notes documenting the working state
- **Only commit after verification**: Never commit code without confirming it works

**Rationale**: Prevents broken commits, maintains repository stability, ensures continuous working state for team members.

### II. Flutter Best Practices

Follow Flutter framework conventions and best practices:
- Use `flutter analyze` before commits - zero warnings/errors required
- Apply `dart fix --apply` for auto-fixable linting issues
- Follow Material Design 3 guidelines for UI consistency
- Use `const` constructors wherever possible for performance
- Separate concerns: models, viewmodels, services, screens, widgets in dedicated directories

### III. Performance First

Mobile apps require careful performance optimization:
- **Sensor throttling**: Limit sensor updates (compass, accelerometer) to 20 Hz max (50ms intervals)
- **Debouncing**: Use debouncing for UI state changes that could flicker (500ms minimum)
- **Constants extraction**: Extract magic numbers to centralized constants file
- **Memory efficiency**: Dispose of stream subscriptions, timers, and controllers properly

### IV. User Experience

Japanese users are the primary audience:
- All UI text must be in Japanese
- Provide clear empty states with guidance
- Show loading indicators for async operations
- Display meaningful error messages in Japanese
- Handle edge cases gracefully (no permissions, no internet, etc.)

### V. Testing Requirements

Ensure code quality through testing:
- **ViewModels**: Unit tests REQUIRED for all ViewModels using `ProviderContainer`
- **Widgets**: Widget tests for UI components using `ProviderScope.overrideWith()` to mock dependencies
- **Services**: Unit tests for business logic in services
- **Integration tests**: For critical flows (registration → map → compass)
- Run `flutter test` before commits
- Verify on both iOS simulator and physical devices when possible

### VI. MVVM Architecture (NON-NEGOTIABLE)

All UI features MUST follow the Model-View-ViewModel (MVVM) architectural pattern:

- **Models** (`lib/models/`) - Immutable data classes representing domain entities (e.g., RespectfulPerson, UserLocation)
  - No business logic in models
  - Use `freezed` package for immutability (recommended)
  - Focus on data structure only

- **ViewModels** (`lib/viewmodels/`) - Business logic and state management
  - Implemented using Riverpod's `StateNotifier`, `Notifier`, or `AsyncNotifier`
  - Expose state and methods to Views
  - Handle user interactions and coordinate with Services/Repositories
  - Example: `RegistrationViewModel`, `MapViewModel`, `CompassViewModel`

- **Views** (`lib/screens/`, `lib/widgets/`) - UI components that consume ViewModels
  - Use `ConsumerWidget` or `ConsumerStatefulWidget` to access providers
  - No direct business logic in Views (delegate to ViewModels)
  - `StatefulWidget` acceptable ONLY for local UI state (animations, text field focus, scroll position)

**Rationale**: MVVM ensures clear separation of concerns, testability, and maintainability. Views remain simple and declarative. Business logic is isolated in ViewModels for easy unit testing.

**Enforcement**: Code reviews MUST reject:
- Business logic in Widget `build()` methods
- Direct database/service calls from UI widgets
- `StatefulWidget` with `setState` for business/app state (local UI state is acceptable)

### VII. Riverpod State Management (NON-NEGOTIABLE)

State management MUST use Riverpod (flutter_riverpod package):

- **Required dependencies** (add to pubspec.yaml):
  ```yaml
  dependencies:
    flutter_riverpod: ^2.6.0
  dev_dependencies:
    riverpod_lint: ^2.5.0
  ```

- **Providers** (`lib/providers/`) - Define all providers in dedicated files
  - `Provider` - Read-only, computed values or services
  - `StateNotifierProvider` / `NotifierProvider` - Mutable state managed by ViewModels
  - `FutureProvider` / `StreamProvider` - Asynchronous data
  - `StateProvider` - Simple local state only (avoid overuse)

- **ProviderScope**: MUST wrap root widget in `main.dart`

- **Prohibited**:
  - Other state management libraries (Provider, BLoC, GetX, etc.)
  - `setState` for business/app state
  - Global mutable singletons
  - `InheritedWidget` for app state

**Rationale**: Riverpod provides compile-time safety, excellent testability, and developer experience. Single state management approach reduces cognitive load and ensures consistency.

### VIII. Secret Management (NON-NEGOTIABLE)

All sensitive information MUST be protected from version control and public exposure:

- **Prohibited in commits**:
  - API keys (Google Maps, Firebase, etc.)
  - Certificates and signing keys
  - Passwords and authentication tokens
  - Database credentials
  - Private keys and secrets
  - SHA-1/SHA-256 fingerprints

- **Required practices**:
  - Use `.gitignore` to exclude secret files (e.g., `android/local.properties`, `ios/Flutter/Secrets.xcconfig`)
  - Store secrets in environment-specific config files (NOT in source code)
  - Use placeholders in documentation files (e.g., `[既存のAndroid用APIキー]` instead of actual keys)
  - Verify with `git status` before commits that no secret files are staged

- **Documentation guidelines**:
  - Setup guides MUST use placeholder text for secrets
  - Examples: `[YOUR_API_KEY]`, `[keytoolコマンドで取得したSHA-1フィンガープリント]`
  - Provide instructions on where to obtain/generate secrets
  - Never include actual secret values in committed markdown files

- **Environment files**:
  - Android: `android/local.properties` (already in .gitignore)
  - iOS: `ios/Flutter/Secrets.xcconfig` (must be in .gitignore)
  - Each developer creates their own local copies with their secrets

**Rationale**: Committing secrets to git creates permanent security vulnerabilities. Even if removed later, secrets remain in git history. Public repositories expose secrets to attackers. This principle protects against accidental leaks, unauthorized access, and security breaches.

**Enforcement**: Code reviews MUST reject any PR containing:
- Hardcoded API keys or passwords
- Actual secret values in documentation
- Commits that add secret files not covered by .gitignore

## Development Workflow

### Code Quality Gates

Before every commit:
1. **Secret check**: Run `git status` - verify NO secret files are staged (e.g., local.properties, Secrets.xcconfig)
2. **Secret scan**: Verify NO API keys, passwords, or secrets in staged files
3. Run `flutter analyze` - must show "No issues found!"
4. Run `flutter test` - all tests must pass
5. Run `flutter run` - app must launch and work correctly
6. Verify affected user flows manually
7. Document verification (screenshots, notes)

### Commit Message Format

Use clear, descriptive commit messages in Japanese:
```
[Phase/Task] 簡潔な説明

- 変更内容の詳細
- 影響範囲
- 検証内容

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Feature Development Process

1. **Specification**: Review specs/[feature-number]/ for requirements
2. **Planning**: Break down into tasks in tasks.md
3. **Implementation**: Follow tasks sequentially, mark in_progress/completed
4. **Verification**: Test on simulator/device after each major task
5. **Commit**: Only after verification gate passes
6. **Documentation**: Update CLAUDE.md and quickstart.md as needed

## Architecture Constraints

### Project Structure

```
lib/
├── main.dart              # App entry point with ProviderScope
├── models/                # Immutable data classes (RespectfulPerson, UserLocation, etc.)
├── viewmodels/            # Business logic + state (StateNotifier/Notifier)
│   ├── registration_viewmodel.dart
│   ├── map_viewmodel.dart
│   └── compass_viewmodel.dart
├── providers/             # Riverpod provider definitions
│   ├── registration_providers.dart
│   ├── map_providers.dart
│   ├── compass_providers.dart
│   └── services_providers.dart
├── repositories/          # Data access layer (database operations)
│   └── person_repository.dart
├── services/              # Platform integrations (sensors, geocoding, location, etc.)
│   ├── database_service.dart
│   ├── geocoding_service.dart
│   ├── location_service.dart
│   ├── compass_service.dart
│   └── direction_calculator_service.dart
├── screens/               # Full-page UI (ConsumerWidget/ConsumerStatefulWidget)
│   ├── registration_list_screen.dart
│   ├── new_registration_screen.dart
│   ├── map_screen.dart
│   └── compass_screen.dart
├── widgets/               # Reusable UI components (ConsumerWidget)
│   └── person_list_item.dart
└── utils/                 # Constants, helpers, extensions
    └── constants.dart

tests/
├── unit/                  # ViewModel and service unit tests
│   └── viewmodels/
├── widget/                # Widget tests with mocked providers
└── integration/           # End-to-end tests
```

### State Management Pattern

**New features (MVVM + Riverpod)**:
- ViewModels manage business state via Riverpod providers
- Views consume state using `Consumer`, `ConsumerWidget`, or `ref.watch()`
- Services remain stateless and are injected via providers
- Keep business logic in ViewModels, NOT in widgets

**Legacy code**:
- Existing code using `StatefulWidget + setState` can remain temporarily
- New features MUST use MVVM + Riverpod
- Incrementally refactor legacy code when modifying those screens

### Dependencies

**Core dependencies** (already in pubspec.yaml):
- `sqflite` ^2.3.0 - Local database
- `geolocator` ^13.0.0 - Location services
- `geocoding` ^3.0.0 - Address geocoding
- `flutter_compass` ^0.8.0 - Compass sensor
- `sensors_plus` ^6.0.0 - Accelerometer
- `google_maps_flutter` ^2.6.1 - Maps

**Architecture dependencies** (ADD to pubspec.yaml):
- `flutter_riverpod` ^2.6.0 - State management (REQUIRED)
- `freezed` ^2.4.0 - Immutable models (recommended)
- `riverpod_annotation` ^2.5.0 - Code generation (optional)

**Dev dependencies**:
- `flutter_lints` ^4.0.0 - Linting (already included)
- `riverpod_lint` ^2.5.0 - Riverpod linting (ADD)
- `build_runner` ^2.4.0 - Code generation (if using freezed)

**Dependency rules**:
- Keep dependencies minimal and up-to-date
- Run `flutter pub outdated` regularly
- Document why each dependency is needed
- Prefer official Flutter packages

## Governance

This constitution supersedes all other development practices. All code changes, pull requests, and reviews must verify compliance with these principles.

**Priority Order**:
1. Secret Management (blocking - no exceptions, security-critical)
2. Verification Before Commit (blocking - no exceptions)
3. MVVM Architecture (blocking for new features)
4. Riverpod State Management (blocking for new features)
5. Flutter Best Practices (blocking - must pass flutter analyze)
6. Performance First (required for production)
7. User Experience (required for production)
8. Testing Requirements (strongly recommended)

**Migration Strategy**:
- New features and screens: MUST use MVVM + Riverpod
- Existing screens: Can use StatefulWidget + setState temporarily
- When modifying existing screens: Refactor to MVVM + Riverpod if time permits
- Critical/complex screens: Prioritize refactoring to MVVM for better testability

Changes to this constitution require:
1. Explicit approval from project stakeholders
2. Documentation of rationale
3. Semantic version bump (MAJOR.MINOR.PATCH)
4. Update to all dependent documentation (CLAUDE.md, templates, quickstart.md)

**Version**: 2.1.0 | **Ratified**: 2025-10-18 | **Last Amended**: 2025-10-20
