# Data Model: Respectful Direction Tracker

**Feature**: 001-respectful-direction-tracker
**Date**: 2025-10-18
**Purpose**: Define data structures, relationships, and validation rules

## Overview

This document defines the data model for the Respectful Direction Tracker application. The app maintains a local SQLite database with a single primary entity (RespectfulPerson) and uses in-memory models for runtime data (UserLocation, DirectionData).

---

## Entity Definitions

### 1. RespectfulPerson (Persistent)

Represents a person the user must show respect to, with their location information.

**Storage**: SQLite table via sqflite

**Fields**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier for the person |
| name | TEXT | NOT NULL, LENGTH > 0 | Person's name as entered by user |
| address | TEXT | NOT NULL, LENGTH > 0 | Address string as entered by user |
| latitude | REAL | NULLABLE | Geocoded latitude (-90 to +90), null if geocoding failed |
| longitude | REAL | NULLABLE | Geocoded longitude (-180 to +180), null if geocoding failed |
| createdAt | INTEGER | NOT NULL | Unix timestamp (milliseconds) of registration |

**Validation Rules**:
- Name: Required, non-empty string after trimming whitespace
- Address: Required, non-empty string after trimming whitespace
- Latitude: Must be between -90 and +90 if not null
- Longitude: Must be between -180 and +180 if not null
- CreatedAt: Automatically set on creation, immutable

**State Transitions**:
```
[New] → name/address entered → [Pending Geocoding] → geocoding API call
                                       ↓
                          [Geocoded] (lat/lng populated)
                                       ↓
                          [Persisted] (saved to SQLite)
                                       ↓
                          [Deleted] (removed from SQLite)
```

**Business Rules**:
- A person can be saved without successful geocoding (lat/lng remain null)
- If geocoding fails, user is notified but registration is not blocked
- Duplicate names/addresses are allowed (no uniqueness constraint)
- Deletion is permanent (no soft delete)

**Dart Model**:
```dart
class RespectfulPerson {
  final int? id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  RespectfulPerson({
    this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Has valid coordinates for map display and direction calculation
  bool get hasValidCoordinates => latitude != null && longitude != null;

  // Factory constructor from SQLite Map
  factory RespectfulPerson.fromMap(Map<String, dynamic> map) {
    return RespectfulPerson(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
```

---

### 2. UserLocation (Runtime Only)

Represents the current geographic position of the user's device.

**Storage**: In-memory only (not persisted)

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| latitude | double | Current device latitude (-90 to +90) |
| longitude | double | Current device longitude (-180 to +180) |
| accuracy | double | Location accuracy in meters |
| timestamp | DateTime | When this location was obtained |

**Validation Rules**:
- Latitude: Must be between -90 and +90
- Longitude: Must be between -180 and +180
- Accuracy: Must be positive number (meters)
- Timestamp: Should be recent (warn if older than 60 seconds)

**Dart Model**:
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Check if location is still fresh (< 60 seconds old)
  bool get isFresh {
    final age = DateTime.now().difference(timestamp);
    return age.inSeconds < 60;
  }

  // Factory from geolocator Position
  factory UserLocation.fromPosition(Position position) {
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp ?? DateTime.now(),
    );
  }
}
```

---

### 3. DirectionData (Runtime Only)

Represents the calculated direction information from user to a registered person.

**Storage**: In-memory only (computed on demand)

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| personId | int | ID of the RespectfulPerson this direction points to |
| personName | String | Name of the person (for display) |
| bearing | double | Calculated bearing in degrees (0-360, 0=North) |
| distance | double | Distance in meters from user to person |

**Validation Rules**:
- Bearing: Must be between 0 and 360 (inclusive)
- Distance: Must be non-negative

**Dart Model**:
```dart
class DirectionData {
  final int personId;
  final String personName;
  final double bearing;
  final double distance;

  DirectionData({
    required this.personId,
    required this.personName,
    required this.bearing,
    required this.distance,
  });

  // Format bearing as cardinal direction
  String get cardinalDirection {
    if (bearing >= 337.5 || bearing < 22.5) return 'N';
    if (bearing >= 22.5 && bearing < 67.5) return 'NE';
    if (bearing >= 67.5 && bearing < 112.5) return 'E';
    if (bearing >= 112.5 && bearing < 157.5) return 'SE';
    if (bearing >= 157.5 && bearing < 202.5) return 'S';
    if (bearing >= 202.5 && bearing < 247.5) return 'SW';
    if (bearing >= 247.5 && bearing < 292.5) return 'W';
    return 'NW';
  }

  // Format distance for display
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }
}
```

---

## Data Relationships

```
┌─────────────────────┐
│  RespectfulPerson   │
│  (SQLite Table)     │
│                     │
│  - id               │
│  - name             │
│  - address          │
│  - latitude         │
│  - longitude        │
│  - createdAt        │
└──────────┬──────────┘
           │
           │ 1:N (runtime calculation)
           │
           ▼
┌─────────────────────┐         ┌──────────────────┐
│   DirectionData     │◄────────│  UserLocation    │
│   (Runtime)         │ uses    │  (Runtime)       │
│                     │         │                  │
│  - personId         │         │  - latitude      │
│  - personName       │         │  - longitude     │
│  - bearing          │         │  - accuracy      │
│  - distance         │         │  - timestamp     │
└─────────────────────┘         └──────────────────┘
```

**Relationships**:
- Each `RespectfulPerson` can have 0 or 1 `DirectionData` at any given moment (calculated when compass screen is active)
- `DirectionData` is computed from `RespectfulPerson` coordinates and current `UserLocation`
- No foreign key relationships (SQLite only stores RespectfulPerson)

---

## Database Schema

### SQLite Table: `respectful_persons`

```sql
CREATE TABLE respectful_persons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  createdAt INTEGER NOT NULL
);

CREATE INDEX idx_createdAt ON respectful_persons(createdAt DESC);
```

**Indexes**:
- `idx_createdAt`: Supports sorting list by registration date (most recent first)

**Migration Strategy**:
- v1: Initial schema (no migrations needed for first release)
- Future versions: Use sqflite migration patterns (onUpgrade callback)

---

## Data Access Patterns

### 1. Registration Flow (P1)
```
User Input → Validation → Geocoding (async) → Create RespectfulPerson → Insert to SQLite → Refresh List
```

**Operations**:
- `INSERT INTO respectful_persons (name, address, latitude, longitude, createdAt) VALUES (?, ?, ?, ?, ?)`
- Query all after insert: `SELECT * FROM respectful_persons ORDER BY createdAt DESC`

### 2. List Display (P1)
```
App Start → Load from SQLite → Display in ListView
```

**Operations**:
- `SELECT * FROM respectful_persons ORDER BY createdAt DESC`

### 3. Map Display (P2)
```
Navigate to Map → Load from SQLite → Filter hasValidCoordinates → Create Markers
```

**Operations**:
- `SELECT * FROM respectful_persons WHERE latitude IS NOT NULL AND longitude IS NOT NULL`

### 4. Compass Display (P3)
```
Navigate to Compass → Get User Location → Load from SQLite → Calculate DirectionData for each person → Display + Monitor heading
```

**Operations**:
- `SELECT * FROM respectful_persons WHERE latitude IS NOT NULL AND longitude IS NOT NULL`
- Calculate bearing for each result using haversine formula

### 5. Delete Person
```
User Swipe/Tap Delete → Confirm → Delete from SQLite → Refresh List
```

**Operations**:
- `DELETE FROM respectful_persons WHERE id = ?`
- Query all after delete: `SELECT * FROM respectful_persons ORDER BY createdAt DESC`

---

## Validation Summary

### Registration Form Validation (NewRegistrationScreen)

**Name Field**:
- ✅ Non-empty after trim
- ✅ Show error: "Name is required" if empty
- ✅ No length limit (reasonable names up to 100 chars)

**Address Field**:
- ✅ Non-empty after trim
- ✅ Show error: "Address is required" if empty
- ✅ No format validation (geocoding service handles parsing)

**Form Submission**:
- ✅ Disable "Register" button until both fields valid
- ✅ Show loading indicator during geocoding
- ✅ On geocoding failure: Show Snackbar but still save record (lat/lng = null)
- ✅ On success: Navigate back to list with success message

---

## Performance Considerations

**Database Operations**:
- All queries expected to complete in <50ms for 100 records
- Use batch operations if bulk deletes needed in future
- Index on `createdAt` supports efficient sorting

**Memory Usage**:
- Load all RespectfulPerson records into memory (acceptable for 100 records ≈ 10 KB)
- DirectionData calculated on-demand (only for compass screen)
- Location updates throttled to 1 Hz to reduce memory churn

**Geocoding**:
- Only called during registration (not on every app launch)
- Results cached in SQLite (never re-geocode existing addresses)
- Network dependency acceptable for new registrations only

---

## Summary

The data model consists of:
1. **RespectfulPerson**: Persistent entity in SQLite with name, address, and geocoded coordinates
2. **UserLocation**: Runtime model for device GPS position
3. **DirectionData**: Computed model for bearing and distance calculations

All validation rules and state transitions are clearly defined. Database schema is optimized for the expected access patterns. Ready to proceed to contracts generation.
