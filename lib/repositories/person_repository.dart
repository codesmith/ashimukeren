import '../models/respectful_person.dart';
import '../services/database_service.dart';

/// Repository for managing RespectfulPerson data access.
///
/// Abstracts database operations from ViewModels, providing a clean API
/// for person-related data operations. This follows the Repository pattern
/// as part of MVVM architecture (Constitution v2.0.0).
class PersonRepository {
  final DatabaseService _databaseService;

  PersonRepository(this._databaseService);

  /// Retrieve all registered people, ordered by creation date (newest first)
  ///
  /// Returns a list of all RespectfulPerson records
  /// Throws DatabaseException if query fails
  Future<List<RespectfulPerson>> getAllPersons() async {
    return await _databaseService.getAllPersons();
  }

  /// Retrieve all people with valid coordinates (for map and compass)
  ///
  /// Returns a list of RespectfulPerson records that have non-null lat/lng
  /// Throws DatabaseException if query fails
  Future<List<RespectfulPerson>> getPersonsWithCoordinates() async {
    return await _databaseService.getPersonsWithCoordinates();
  }

  /// Insert a new person into the database
  ///
  /// Returns the ID of the inserted person
  /// Throws DatabaseException if insert fails
  Future<int> insertPerson(RespectfulPerson person) async {
    return await _databaseService.insertPerson(person);
  }

  /// Delete a person by ID
  ///
  /// Returns the number of rows deleted (0 or 1)
  /// Throws DatabaseException if delete fails
  Future<int> deletePerson(int id) async {
    return await _databaseService.deletePerson(id);
  }

  /// Get a single person by ID
  ///
  /// Returns the RespectfulPerson or null if not found
  /// Throws DatabaseException if query fails
  Future<RespectfulPerson?> getPerson(int id) async {
    return await _databaseService.getPerson(id);
  }

  /// Update an existing person
  ///
  /// Returns the number of rows updated
  /// Throws DatabaseException if update fails
  Future<int> updatePerson(RespectfulPerson person) async {
    return await _databaseService.updatePerson(person);
  }

  /// Get count of all persons
  ///
  /// Returns the total number of registered people
  /// Throws DatabaseException if query fails
  Future<int> getPersonCount() async {
    return await _databaseService.getPersonCount();
  }
}
