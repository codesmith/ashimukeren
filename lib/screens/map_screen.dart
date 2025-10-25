import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/respectful_person.dart';
import '../providers/map_providers.dart';

/// Screen for displaying registered people's locations on Google Maps
///
/// Shows red pins for each person with valid coordinates.
/// Refactored to use MVVM + Riverpod (Constitution v2.0.0).
class MapScreen extends ConsumerStatefulWidget {
  /// Optional person ID to focus on when opening the map
  final int? focusPersonId;

  const MapScreen({super.key, this.focusPersonId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Fit all markers in view by adjusting camera bounds
  void _fitMarkersInView(List<RespectfulPerson> persons) {
    if (persons.isEmpty || _mapController == null) return;

    // Calculate bounds
    double minLat = persons.first.latitude!;
    double maxLat = persons.first.latitude!;
    double minLng = persons.first.longitude!;
    double maxLng = persons.first.longitude!;

    for (final person in persons) {
      if (person.latitude! < minLat) minLat = person.latitude!;
      if (person.latitude! > maxLat) maxLat = person.latitude!;
      if (person.longitude! < minLng) minLng = person.longitude!;
      if (person.longitude! > maxLng) maxLng = person.longitude!;
    }

    // Add padding
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Fit markers in view after map is created
    final state = ref.read(mapViewModelProvider);

    if (widget.focusPersonId != null) {
      // Focus on specific person if ID is provided
      Future.delayed(const Duration(milliseconds: 500), () {
        _focusOnPerson(widget.focusPersonId!);
      });
    } else if (state.persons.isNotEmpty) {
      // Otherwise fit all markers in view
      Future.delayed(const Duration(milliseconds: 500), () {
        _fitMarkersInView(state.persons);
      });
    }
  }

  /// Focus camera on a specific person's location
  void _focusOnPerson(int personId) {
    if (_mapController == null) return;

    final state = ref.read(mapViewModelProvider);
    final person = state.persons.where((p) => p.id == personId).firstOrNull;

    if (person != null && person.hasValidCoordinates) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(person.latitude!, person.longitude!),
          15.0, // Zoom level for focused view
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel state
    final state = ref.watch(mapViewModelProvider);

    // Show error if present
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '再試行',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(mapViewModelProvider.notifier).refresh();
                },
              ),
            ),
          );
          // Clear error after showing
          ref.read(mapViewModelProvider.notifier).clearError();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('地図'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(mapViewModelProvider.notifier).refresh();
            },
            tooltip: '更新',
          ),
          if (state.persons.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.fit_screen),
              onPressed: () => _fitMarkersInView(state.persons),
              tooltip: '全体を表示',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.persons.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: state.initialPosition,
                        zoom: 12.0,
                      ),
                      markers: state.markers,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: true,
                    ),
                    // Info card at the top
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${state.persons.length}人を地図上に表示',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  /// Build empty state when no persons with coordinates are registered
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '表示できる位置情報がありません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '有効な住所で人を登録すると地図上に表示されます',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
