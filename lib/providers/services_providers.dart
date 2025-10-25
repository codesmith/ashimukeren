import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/compass_service.dart';
import '../services/direction_calculator.dart';
import '../repositories/person_repository.dart';

/// Provider for DatabaseService (singleton)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for GeocodingService
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// Provider for LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provider for CompassService
final compassServiceProvider = Provider<CompassService>((ref) {
  return CompassService();
});

/// Provider for DirectionCalculator
final directionCalculatorProvider = Provider<DirectionCalculator>((ref) {
  return DirectionCalculator();
});

/// Provider for PersonRepository
///
/// Depends on DatabaseService provider
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return PersonRepository(databaseService);
});
