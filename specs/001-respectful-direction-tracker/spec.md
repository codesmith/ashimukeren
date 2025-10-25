# Feature Specification: Respectful Direction Tracker

**Feature Branch**: `001-respectful-direction-tracker`
**Created**: 2025-10-18
**Status**: Draft
**Input**: User description: "以下のようなモバイルアプリを作成したい。現状のビール検定用のアプリは削除してもらって構わない。・「足を向けられない人」の\"名前\"と\"住所\"を登録・表示できるアプリです。・登録一覧画面では、登録した方角の一覧をリスト形式で表示できます。・Google Map画面で、登録した方角をGoogle Map上で表示できます。その時、複数の赤いピンとして表示されます。・登録一覧画面には新規登録ボタンがあり、そのボタンを押すと新規登録画面に遷移します。・新規登録画面では、新しく「足を向けられない人」の名前と住所を登録できます。・新規登録画面では、名前と住所を登録する入力フィールドと「登録」ボタンがあります。・新規登録画面で「登録」ボタンを押すと、その時登録した「足を向けられない人」と既に登録されている「足を向けられない人」が登録一覧画面に表示されます。・コンパス画面は、地面に対してスマホを水平にして使用します。・コンパス画面では、東西南北の他に、「足を向けられない人」の方角も表示されます。・コンパス画面を表示した状態で、スマホの上部を「足を向けられない人」に向けると画面が赤くなり警告が表示されます。逆に「足を向けられない人」がいない方角をスマホの上部を向けると画面が緑色になります。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Register Respectful Person (Priority: P1)

A user wants to register a person they must show respect to (such as a parent, teacher, or honored individual) by recording their name and location address. This allows the app to calculate and track the direction to that person.

**Why this priority**: This is the foundation of the entire application. Without the ability to register people and their locations, no other functionality can work. This represents the core data entry that enables all downstream features.

**Independent Test**: Can be fully tested by opening the app, navigating to the registration screen, entering a name and address, submitting the form, and verifying the person appears in the list view. Delivers immediate value by allowing users to maintain a record of important people and their locations.

**Acceptance Scenarios**:

1. **Given** I am on the registration list screen, **When** I tap the "New Registration" button, **Then** I am navigated to the new registration screen with empty name and address input fields and a "Register" button
2. **Given** I am on the new registration screen, **When** I enter a name and address and tap the "Register" button, **Then** the person is saved and I am returned to the registration list screen showing the newly registered person along with any previously registered people
3. **Given** I am on the new registration screen, **When** I tap the "Register" button without entering required information, **Then** I see appropriate validation messages indicating which fields are required
4. **Given** I have registered multiple people, **When** I view the registration list screen, **Then** I see all registered people displayed in a list format with their names visible

---

### User Story 2 - View Registered Locations on Map (Priority: P2)

A user wants to visualize all registered people's locations on a map to understand their geographic distribution and spatial relationship to the user's current position.

**Why this priority**: After registering people (P1), the map view provides essential spatial context. It helps users understand the geographic layout of registered locations and is a prerequisite for the direction-aware compass functionality.

**Independent Test**: Can be fully tested by registering one or more people with valid addresses, navigating to the map screen, and verifying that red pins appear at the correct locations on the map. Delivers value by providing geographic visualization of registered locations.

**Acceptance Scenarios**:

1. **Given** I have registered one or more people with addresses, **When** I navigate to the Google Map screen, **Then** I see the map displaying red pins at each registered person's location
2. **Given** I am viewing the map with multiple pins, **When** I interact with the map, **Then** I can zoom, pan, and view all registered locations
3. **Given** I have registered no people yet, **When** I navigate to the Google Map screen, **Then** I see an empty map centered at a default location with no pins displayed
4. **Given** I tap on a red pin on the map, **When** the pin is selected, **Then** I see information about that person (such as their name)
5. **Given** I am on the registration list screen viewing multiple registered people, **When** I tap on a specific person's list item, **Then** I am navigated to the Google Map screen with the map centered on that person's location and showing a red pin at their address

---

### User Story 3 - Use Direction-Aware Compass (Priority: P3)

A user wants to use their phone as a compass that alerts them when they are pointing toward a registered person's direction, helping them avoid pointing their feet in a disrespectful direction while sleeping or resting.

**Why this priority**: This is the unique value proposition of the app, but it depends on having registered locations (P1) and understanding their geographic positions (P2). It's the final integration that brings cultural respect into daily practice.

**Independent Test**: Can be fully tested by registering at least one person, navigating to the compass screen, holding the phone horizontally, and rotating to point toward and away from registered directions. Delivers value by providing real-time directional awareness with visual feedback.

**Acceptance Scenarios**:

1. **Given** I have registered one or more people, **When** I navigate to the compass screen and hold my phone horizontally (parallel to the ground), **Then** I see a compass display showing cardinal directions (North, South, East, West) and the directions to each registered person
2. **Given** I am viewing the compass screen with my phone horizontal, **When** I point the top of my phone toward a registered person's direction, **Then** the screen turns red and displays a warning message indicating I am pointing toward a respectful direction
3. **Given** I am viewing the compass screen with my phone horizontal, **When** I point the top of my phone away from all registered people's directions, **Then** the screen turns green indicating the direction is safe
4. **Given** I am viewing the compass screen, **When** I hold the phone at a non-horizontal angle, **Then** the app indicates the phone should be held horizontally for accurate compass readings
5. **Given** I have no registered people, **When** I navigate to the compass screen, **Then** I see cardinal directions but no specific person directions, and the screen remains in a neutral state

---

### Edge Cases

- What happens when a user enters an invalid or non-existent address during registration?
- How does the system handle situations where the user's device location services are disabled or unavailable?
- What happens when the device does not have compass/magnetometer sensors available?
- How does the app behave when there are many registered people (e.g., 50+ entries) in terms of performance and display?
- What happens if the user is at the exact same location as a registered person (zero distance)?
- How does the compass determine the "danger zone" angle threshold when pointing toward a registered direction (e.g., ±15 degrees, ±30 degrees)?
- What happens when the phone is rotated between landscape and portrait orientations on different screens?
- How does the app handle addresses in different countries or coordinate systems?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to register a person by entering their name and address
- **FR-002**: System MUST validate that name and address fields are not empty before allowing registration
- **FR-003**: System MUST convert address strings to geographic coordinates (latitude/longitude) for map display and direction calculation
- **FR-004**: System MUST persist all registered people and their information locally on the device so data is retained between app sessions
- **FR-005**: System MUST display all registered people in a scrollable list format on the registration list screen
- **FR-006**: System MUST provide a "New Registration" button on the registration list screen that navigates to the new registration screen
- **FR-007**: System MUST display a Google Map with red pin markers at each registered person's location on the map screen
- **FR-008**: System MUST support standard map interactions including zoom, pan, and pin selection
- **FR-009**: System MUST provide a compass screen that displays cardinal directions (N, S, E, W)
- **FR-010**: System MUST calculate and display the direction (bearing) from the user's current location to each registered person on the compass screen
- **FR-011**: System MUST access device sensors (magnetometer, accelerometer, gyroscope) to determine phone orientation and heading
- **FR-012**: System MUST access device location services to determine the user's current geographic position for direction calculations
- **FR-013**: System MUST change the compass screen background to red when the phone's top edge points toward a registered person's direction (within a tolerance angle of ±5 degrees, refined from original ±15 degrees for accuracy)
- **FR-014**: System MUST display a warning message "警告：足を向けてはいけない方向です" and the person's name when the screen turns red on the compass screen
- **FR-015**: System MUST change the compass screen background to green when the phone's top edge points away from all registered people's directions, and display a safe direction message "足を向けて寝ることができる方角です！"
- **FR-016**: System MUST provide navigation between the registration list screen, new registration screen, map screen, and compass screen
- **FR-017**: System MUST handle cases where address geocoding fails and provide appropriate user feedback
- **FR-018**: System MUST allow users to delete registered people from the list
- **FR-019**: System MUST allow users to tap on a person's list item in the registration list screen to navigate to the map screen with the map centered on that specific person's location

### Key Entities

- **Respectful Person**: Represents a person the user must show respect to. Contains a name (text string) and an address (text string). The address is geocoded to coordinates (latitude, longitude) for direction calculation and map display. Each person represents a direction that should be avoided when sleeping or resting.
- **User Location**: Represents the current geographic position of the user's device. Used as the origin point for calculating directions to registered people. Obtained through device location services.
- **Direction/Bearing**: Represents the angular direction from the user's current location to a registered person's location, measured in degrees from North (0-360°). Used by the compass screen to determine warning states.

### Security Requirements

**API Key Management Strategy**: Pattern A - Direct Embedding with API Restrictions (Industry Standard)

This app adopts the industry-standard approach (used by 80-90% of mobile apps including Uber, Airbnb) for Google Maps API key management:

#### Core Security Principle

**Reality**: API keys MUST be embedded in the mobile app binary (APK/IPA). Complete hiding is impossible. Google's official stance: *"Treat client devices as compromised. API keys will exist somewhere in binary code. Defending against knowledgeable attackers is impossible, but we can make their lives harder."*

#### Three-Layer Defense Strategy

**Layer 1: Source Control Protection** (Development Practice)
- **FR-020**: System MUST use environment variables (android/local.properties, ios/Flutter/Secrets.xcconfig) to manage API keys during development
- **FR-021**: System MUST exclude API key files from version control (.gitignore) to prevent accidental commits to public repositories
- **Purpose**: Prevent GitHub leaks (operational, not security-focused)

**Layer 2: Google Cloud Console API Restrictions** ⭐ MOST CRITICAL

**Note**: Android and iOS MUST use SEPARATE API keys (1 platform per key)

- **FR-021.1**: System MUST use TWO separate Google Maps API keys:
  - API Key 1 (Android): Restricted to Android app only
  - API Key 2 (iOS): Restricted to iOS app only
  - Reason: Google Cloud Console allows only 1 platform restriction per key
- **FR-022**: Android API key MUST be restricted by Android package name (jp.codesmith.ashimukeren) in Google Cloud Console
- **FR-023**: iOS API key MUST be restricted by iOS bundle ID (jp.codesmith.ashimukeren) in Google Cloud Console
- **FR-024**: Android API key MUST be restricted by SHA-1 certificate fingerprint (release signing key)
- **FR-025**: Each Google Maps API key MUST be restricted to ONLY required APIs for its platform:
  - **Android API key**:
    - ✅ Maps SDK for Android
    - ✅ Geocoding API
    - ❌ Maps SDK for iOS (not needed)
  - **iOS API key**:
    - ✅ Maps SDK for iOS
    - ✅ Geocoding API
    - ❌ Maps SDK for Android (not needed)
  - ❌ ALL other APIs explicitly disabled on BOTH keys (Places, Directions, Distance Matrix, Geolocation, Roads, Street View, Time Zone, Maps JavaScript, Maps Static, Maps Embed, etc.)
- **FR-026**: System MUST set daily quota limits (e.g., 10,000 requests/day for Maps, 1,000 requests/day for Geocoding)
- **FR-027**: System MUST configure billing alerts in Google Cloud Console (e.g., $50/month threshold at 50%, 80%, 90%, 100%)
- **Purpose**: Even if API key is extracted from APK, it cannot be used by other apps or for unauthorized APIs
- **Result**: Stolen API keys are useless without matching package name + SHA-1 signature

**Layer 3: Code Obfuscation** (Android Release Builds)
- **FR-028**: Android release builds MUST enable ProGuard/R8 minification and resource shrinking
- **FR-029**: ProGuard rules MUST preserve Flutter and Google Maps SDK classes while obfuscating app code
- **Purpose**: Make API key discovery more difficult (not foolproof, but raises the bar)

#### Security Trade-offs Accepted

✅ **Accepted**: API keys visible in decompiled APK/IPA (inevitable for mobile apps)
✅ **Accepted**: No backend proxy (adds cost, latency, complexity - unnecessary for this app)
✅ **Mitigated**: API key abuse via package name + SHA-1 + API + quota restrictions
✅ **Monitored**: Usage alerts notify of anomalies before significant billing impact

#### Why Not Use Backend Proxy (Pattern B)?

**Rejected Alternative**: Mobile app → Backend server → Google Maps API
- **Cons**: Requires server infrastructure ($), adds latency (slower UX), increases complexity (maintenance burden)
- **Only Used By**: 10-20% of apps (banks, high-security apps with existing backends)
- **Decision**: Overkill for a personal/small-scale app. Pattern A provides sufficient security with Google's built-in restrictions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully register a new person with name and address in under 1 minute
- **SC-002**: The map screen displays all registered locations with correct pin placement matching the entered addresses with 90%+ accuracy
- **SC-003**: The compass screen provides real-time directional feedback with visual state changes (red/green) occurring within 50 milliseconds of phone orientation change (improved from original 500ms with heading smoothing algorithm)
- **SC-004**: Users can complete the full workflow (register person → view on map → check direction on compass) within 3 minutes on first use
- **SC-005**: The app successfully handles at least 100 registered people without performance degradation (list scrolling remains smooth, map loads within 3 seconds)
- **SC-006**: 95% of address entries are successfully geocoded to valid coordinates
- **SC-007**: The compass accurately indicates registered directions within ±5 degrees of true bearing when the phone is held horizontally, using 10-sample moving average smoothing for stable readings
- **SC-008**: Location services provide immediate feedback using cached position, eliminating timeout errors in indoor environments
