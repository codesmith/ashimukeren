/// Model representing a person the user must show respect to.
///
/// Contains name, address, and geocoded coordinates (latitude/longitude).
/// This model is persisted in SQLite database.
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

  /// Returns true if this person has valid coordinates for map display and direction calculation
  bool get hasValidCoordinates => latitude != null && longitude != null;

  /// Factory constructor to create a RespectfulPerson from a database Map
  factory RespectfulPerson.fromMap(Map<String, dynamic> map) {
    return RespectfulPerson(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  /// Convert this RespectfulPerson to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy of this person with optional field updates
  RespectfulPerson copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return RespectfulPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'RespectfulPerson{id: $id, name: $name, address: $address, '
        'coordinates: ${latitude != null && longitude != null ? '($latitude, $longitude)' : 'none'}, '
        'createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RespectfulPerson &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      address,
      latitude,
      longitude,
      createdAt,
    );
  }
}
