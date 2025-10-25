import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/registration_providers.dart';
import '../viewmodels/registration_viewmodel.dart';

/// Screen for registering a new respectful person
///
/// Allows users to enter name and address, performs geocoding via ViewModel,
/// and saves to the database.
/// Refactored to use MVVM + Riverpod (Constitution v2.0.0).
class NewRegistrationScreen extends ConsumerStatefulWidget {
  const NewRegistrationScreen({super.key});

  @override
  ConsumerState<NewRegistrationScreen> createState() =>
      _NewRegistrationScreenState();
}

class _NewRegistrationScreenState extends ConsumerState<NewRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Reset new registration state when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationViewModelProvider.notifier).resetNewRegistrationState();
    });
  }

  /// Validate and save the person through ViewModel
  Future<void> _savePerson() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    // Call ViewModel to register person
    await ref
        .read(registrationViewModelProvider.notifier)
        .registerPerson(name, address);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the newRegistrationState from ViewModel
    final newRegState = ref.watch(newRegistrationStateProvider);

    // Listen for success/error and show messages
    ref.listen<NewRegistrationState>(newRegistrationStateProvider, (previous, next) {
      if (next.isSuccess && !next.isLoading) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()}を登録しました'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Return to list screen with success result
        Navigator.of(context).pop(true);
      } else if (next.errorMessage != null && !next.isLoading) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '恩人さんの名前と住所を入力して登録します。',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前',
                hintText: '名前を入力してください',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '名前を入力してください';
                }
                return null;
              },
              enabled: !newRegState.isLoading,
            ),
            const SizedBox(height: 16),

            // Address field
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '住所',
                hintText: '住所を入力してください',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '住所を入力してください';
                }
                return null;
              },
              enabled: !newRegState.isLoading,
            ),
            const SizedBox(height: 24),

            // Register button
            FilledButton.icon(
              onPressed: newRegState.isLoading ? null : _savePerson,
              icon: newRegState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(newRegState.isLoading ? '登録中...' : '登録'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Note about geocoding
            if (!newRegState.isLoading)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'アプリは入力された住所の位置情報を自動的に取得します。取得に失敗した場合でも登録は可能ですが、地図やコンパスには表示されません。',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
