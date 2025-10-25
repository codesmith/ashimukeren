import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/respectful_person.dart';
import '../providers/registration_providers.dart';
import '../widgets/person_list_item.dart';
import 'new_registration_screen.dart';
import 'map_screen.dart';
import 'compass_screen.dart';

/// Screen for displaying the list of registered people
///
/// Shows all registered people in a scrollable list with delete functionality.
/// Refactored to use MVVM + Riverpod (Constitution v2.0.0).
class RegistrationListScreen extends ConsumerWidget {
  const RegistrationListScreen({super.key});

  /// Navigate to new registration screen
  Future<void> _navigateToNewRegistration(
      BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const NewRegistrationScreen(),
      ),
    );

    // Reload list if a person was added
    if (result == true) {
      ref.read(registrationViewModelProvider.notifier).refresh();
    }
  }

  /// Delete a person from the database
  Future<void> _deletePerson(
      BuildContext context, WidgetRef ref, RespectfulPerson person) async {
    // Call ViewModel to delete
    await ref.read(registrationViewModelProvider.notifier).deletePerson(person.id!);

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${person.name}を削除しました'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ViewModel state
    final state = ref.watch(registrationViewModelProvider);

    // Show error message if there is one
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          // Clear error after showing
          ref.read(registrationViewModelProvider.notifier).clearError();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('恩人さん一覧'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
            },
            tooltip: '地図を表示',
          ),
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CompassScreen(),
                ),
              );
            },
            tooltip: 'コンパスを表示',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(registrationViewModelProvider.notifier).refresh(),
            tooltip: '更新',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.persons.isEmpty
              ? _buildEmptyState(context, ref)
              : RefreshIndicator(
                  onRefresh: () => ref.read(registrationViewModelProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: state.persons.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final person = state.persons[index];
                      return PersonListItem(
                        person: person,
                        onDelete: () => _deletePerson(context, ref, person),
                        onTap: person.hasValidCoordinates
                            ? () {
                                // Navigate to map screen focused on this person
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                      focusPersonId: person.id,
                                    ),
                                  ),
                                );
                              }
                            : null, // Disable tap if no coordinates
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewRegistration(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新規登録'),
        tooltip: '新しい人を登録',
      ),
    );
  }

  /// Build empty state widget when no persons are registered
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'まだ登録されていません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '下のボタンをタップして最初の人を登録しましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _navigateToNewRegistration(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('最初の人を登録'),
            ),
          ],
        ),
      ),
    );
  }
}
