import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import the NEW DatabaseService
import 'package:dance_class_tracker/core/database/database_service.dart';
import 'package:dance_class_tracker/app.dart'; // Your root app widget

Future<void> main() async {
  // Ensure bindings are initialized FIRST
  WidgetsFlutterBinding.ensureInitialized();
  print("--- main(): WidgetsFlutterBinding ensured.");

  // --- Initialize DatabaseService ---
  // Get the singleton instance and ensure the database is opened
  print("--- main(): Initializing DatabaseService...");
  try {
    // Accessing the getter triggers initialization if needed
    await DatabaseService().database;
    print("--- main(): DatabaseService initialized successfully.");
  } catch (e, s) {
    print("--- main(): CRITICAL ERROR initializing DatabaseService: $e\n$s");
    // Consider showing an error screen or preventing app launch
  }
  // --- End DatabaseService Init ---

  print("--- main(): Calling runApp()...");
  runApp(
    // ProviderScope needed for Riverpod state management
    const ProviderScope(
      child: DanceClassApp(),
    ),
  );
  print("--- main(): runApp() finished.");
}