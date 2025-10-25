/// Shared mock implementations for testing
///
/// This file provides mock implementations of repositories and services
/// that can be reused across unit tests and widget tests.
library;

import 'package:ashimukeren/models/respectful_person.dart';
import 'package:ashimukeren/repositories/person_repository.dart';
import 'package:ashimukeren/services/geocoding_service.dart';

/// Mock PersonRepository for testing
class MockPersonRepository implements PersonRepository {
  // Public for test access (adding test data)
  final List<RespectfulPerson> persons = [];
  bool shouldThrowError = false;

  @override
  Future<List<RespectfulPerson>> getAllPersons() async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    return List.from(persons);
  }

  @override
  Future<List<RespectfulPerson>> getPersonsWithCoordinates() async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    return persons.where((p) => p.hasValidCoordinates).toList();
  }

  @override
  Future<int> insertPerson(RespectfulPerson person) async {
    if (shouldThrowError) {
      throw Exception('Database insert error');
    }
    final id = persons.length + 1;
    persons.add(person.copyWith(id: id));
    return id;
  }

  @override
  Future<int> deletePerson(int id) async {
    if (shouldThrowError) {
      throw Exception('Database delete error');
    }
    final initialLength = persons.length;
    persons.removeWhere((p) => p.id == id);
    return initialLength - persons.length; // Return number of rows deleted
  }

  @override
  Future<RespectfulPerson?> getPerson(int id) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    try {
      return persons.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updatePerson(RespectfulPerson person) async {
    if (shouldThrowError) {
      throw Exception('Database update error');
    }
    final index = persons.indexWhere((p) => p.id == person.id);
    if (index == -1) {
      return 0; // Not found
    }
    persons[index] = person;
    return 1; // Updated successfully
  }

  @override
  Future<int> getPersonCount() async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    return persons.length;
  }
}

/// Mock GeocodingService for testing
class MockGeocodingService implements GeocodingService {
  bool shouldFail = false;
  GeocodingResult? resultToReturn;

  @override
  Future<GeocodingResult> geocodeAddress(String address) async {
    if (shouldFail) {
      return GeocodingResult.failure(
        errorMessage: 'Geocoding failed',
      );
    }
    return resultToReturn ??
        GeocodingResult.success(
          latitude: 35.6762,
          longitude: 139.6503,
        );
  }

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    if (shouldFail) {
      return null;
    }
    return '東京都渋谷区';
  }
}
