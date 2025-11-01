import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/respectful_person.dart';
import '../repositories/person_repository.dart';
import '../services/geocoding_service.dart';
import '../providers/map_providers.dart';

/// State for Registration List Screen
class RegistrationListState {
  final List<RespectfulPerson> persons;
  final bool isLoading;
  final String? errorMessage;

  const RegistrationListState({
    this.persons = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RegistrationListState copyWith({
    List<RespectfulPerson>? persons,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RegistrationListState(
      persons: persons ?? this.persons,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  RegistrationListState clearError() {
    return RegistrationListState(
      persons: persons,
      isLoading: isLoading,
      errorMessage: null,
    );
  }
}

/// State for New Registration Screen
class NewRegistrationState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const NewRegistrationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  NewRegistrationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return NewRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  NewRegistrationState idle() {
    return const NewRegistrationState();
  }
}

/// ViewModel for Registration screens (List and New Registration)
///
/// Manages state for both registration list and new registration flows.
/// Follows MVVM architecture pattern (Constitution v2.0.0).
class RegistrationViewModel extends StateNotifier<RegistrationListState> {
  final PersonRepository _personRepository;
  final GeocodingService _geocodingService;
  final Ref _ref;

  // Separate state for new registration screen
  NewRegistrationState _newRegistrationState = const NewRegistrationState();
  NewRegistrationState get newRegistrationState => _newRegistrationState;

  RegistrationViewModel(
    this._personRepository,
    this._geocodingService,
    this._ref,
  ) : super(const RegistrationListState()) {
    // Load persons on initialization
    loadPersons();
  }

  /// Load all registered persons from database
  Future<void> loadPersons() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final persons = await _personRepository.getAllPersons();
      state = state.copyWith(
        persons: persons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '恩人さんの読み込みに失敗しました: $e',
      );
    }
  }

  /// Delete a person by ID
  Future<void> deletePerson(int id) async {
    try {
      await _personRepository.deletePerson(id);
      // Invalidate MapViewModel to trigger reload
      _ref.invalidate(mapViewModelProvider);
      // Reload the list after deletion
      await loadPersons();
    } catch (e) {
      state = state.copyWith(
        errorMessage: '削除に失敗しました: $e',
      );
    }
  }

  /// Refresh the list (same as loadPersons, but explicit intent)
  Future<void> refresh() async {
    await loadPersons();
  }

  /// Register a new person with name and address
  ///
  /// This method geocodes the address and saves to database.
  /// Updates newRegistrationState to reflect loading/success/error.
  Future<void> registerPerson(String name, String address) async {
    _newRegistrationState = _newRegistrationState.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
    _notifyNewRegistrationListeners();

    try {
      // Geocode the address
      final geocodingResult =
          await _geocodingService.geocodeAddress(address);

      // Create person with geocoded coordinates (or null if failed)
      final person = RespectfulPerson(
        name: name,
        address: address,
        latitude: geocodingResult.latitude,
        longitude: geocodingResult.longitude,
        createdAt: DateTime.now(),
      );

      // Save to database
      await _personRepository.insertPerson(person);

      // Invalidate MapViewModel to trigger reload
      _ref.invalidate(mapViewModelProvider);

      // Update state to success
      _newRegistrationState = _newRegistrationState.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      _notifyNewRegistrationListeners();

      // Reload the list to show new person
      await loadPersons();
    } catch (e) {
      _newRegistrationState = _newRegistrationState.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: '登録に失敗しました: $e',
      );
      _notifyNewRegistrationListeners();
    }
  }

  /// Reset new registration state to idle
  void resetNewRegistrationState() {
    _newRegistrationState = _newRegistrationState.idle();
    _notifyNewRegistrationListeners();
  }

  /// Clear error message in list state
  void clearError() {
    state = state.clearError();
  }

  // Helper to notify listeners when new registration state changes
  // Since we can't have multiple StateNotifiers in one class,
  // we use this workaround for now. In future, consider splitting into separate ViewModels.
  void _notifyNewRegistrationListeners() {
    // Force state update to trigger rebuilds
    state = state.copyWith();
  }
}
