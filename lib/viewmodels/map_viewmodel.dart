import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/respectful_person.dart';
import '../repositories/person_repository.dart';

/// State for Map Screen
class MapState {
  final List<RespectfulPerson> persons;
  final Set<Marker> markers;
  final bool isLoading;
  final LatLng initialPosition;
  final String? errorMessage;

  // Tokyo as default position
  static const LatLng defaultPosition = LatLng(35.6762, 139.6503);

  const MapState({
    this.persons = const [],
    this.markers = const {},
    this.isLoading = false,
    this.initialPosition = defaultPosition,
    this.errorMessage,
  });

  MapState copyWith({
    List<RespectfulPerson>? persons,
    Set<Marker>? markers,
    bool? isLoading,
    LatLng? initialPosition,
    String? errorMessage,
  }) {
    return MapState(
      persons: persons ?? this.persons,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      initialPosition: initialPosition ?? this.initialPosition,
      errorMessage: errorMessage,
    );
  }

  MapState clearError() {
    return MapState(
      persons: persons,
      markers: markers,
      isLoading: isLoading,
      initialPosition: initialPosition,
      errorMessage: null,
    );
  }
}

/// ViewModel for Map screen
///
/// Manages state for displaying persons on Google Maps with markers.
/// Follows MVVM architecture pattern (Constitution v2.0.0).
class MapViewModel extends StateNotifier<MapState> {
  final PersonRepository _personRepository;

  MapViewModel(this._personRepository) : super(const MapState()) {
    // Load persons on initialization
    loadPersonsForMap();
  }

  /// Load all persons with valid coordinates and create markers
  Future<void> loadPersonsForMap() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Get all persons with valid coordinates
      final persons = await _personRepository.getPersonsWithCoordinates();

      // Create markers for each person
      final markers = _createMarkers(persons);

      // Determine initial position (first person or default)
      LatLng initialPosition = MapState.defaultPosition;
      if (persons.isNotEmpty && persons.first.hasValidCoordinates) {
        initialPosition = LatLng(
          persons.first.latitude!,
          persons.first.longitude!,
        );
      }

      state = state.copyWith(
        persons: persons,
        markers: markers,
        initialPosition: initialPosition,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '位置情報の読み込みエラー: $e',
      );
    }
  }

  /// Create map markers from persons list
  Set<Marker> _createMarkers(List<RespectfulPerson> persons) {
    return persons
        .where((person) => person.hasValidCoordinates)
        .map((person) {
      return Marker(
        markerId: MarkerId('person_${person.id}'),
        position: LatLng(person.latitude!, person.longitude!),
        infoWindow: InfoWindow(
          title: person.name,
          snippet: person.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();
  }

  /// Calculate camera bounds to fit all markers in view
  /// Returns null if there are no persons
  LatLngBounds? calculateCameraBounds() {
    if (state.persons.isEmpty) return null;

    final persons = state.persons
        .where((p) => p.hasValidCoordinates)
        .toList();

    if (persons.isEmpty) return null;

    double? minLat, maxLat, minLng, maxLng;

    for (final person in persons) {
      final lat = person.latitude!;
      final lng = person.longitude!;

      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Refresh the map data
  Future<void> refresh() async {
    await loadPersonsForMap();
  }

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }
}
