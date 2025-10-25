import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/registration_viewmodel.dart';
import 'services_providers.dart';

/// Provider for RegistrationViewModel
///
/// Manages state for both registration list and new registration screens.
/// Automatically loads persons on initialization.
final registrationViewModelProvider =
    StateNotifierProvider<RegistrationViewModel, RegistrationListState>((ref) {
  final personRepository = ref.watch(personRepositoryProvider);
  final geocodingService = ref.watch(geocodingServiceProvider);
  return RegistrationViewModel(personRepository, geocodingService);
});

/// Provider for accessing NewRegistrationState
///
/// This is a workaround to access newRegistrationState from the ViewModel.
/// In the future, consider splitting into separate ViewModels.
final newRegistrationStateProvider = Provider<NewRegistrationState>((ref) {
  final viewModel = ref.watch(registrationViewModelProvider.notifier);
  // Trigger rebuild when main state changes (workaround)
  ref.watch(registrationViewModelProvider);
  return viewModel.newRegistrationState;
});
