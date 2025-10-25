import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_service.dart';
import 'screens/registration_list_screen.dart';
import 'screens/new_registration_screen.dart';
import 'screens/map_screen.dart';
import 'screens/compass_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseService().initialize();

  // Wrap app with ProviderScope for Riverpod (Constitution v2.0.0)
  runApp(
    const ProviderScope(
      child: AshimukerenApp(),
    ),
  );
}

class AshimukerenApp extends StatelessWidget {
  const AshimukerenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あしむけれん',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set home screen to RegistrationListScreen
      home: const RegistrationListScreen(),
      // Define named routes for navigation
      routes: {
        '/new-registration': (context) => const NewRegistrationScreen(),
        '/map': (context) => const MapScreen(),
        '/compass': (context) => const CompassScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
