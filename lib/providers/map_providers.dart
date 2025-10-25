import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/map_viewmodel.dart';
import 'services_providers.dart';

/// Provider for MapViewModel
///
/// Manages state for map screen display.
/// Automatically loads persons with coordinates on initialization.
final mapViewModelProvider =
    StateNotifierProvider<MapViewModel, MapState>((ref) {
  final personRepository = ref.watch(personRepositoryProvider);
  return MapViewModel(personRepository);
});
