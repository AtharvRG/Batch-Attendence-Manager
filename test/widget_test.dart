// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dance_class_tracker/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // --- FIX: Import ProviderScope ---

// --- FIX: Import your main app file ---
import 'package:dance_class_tracker/app.dart'; // Adjust path if your app file is elsewhere

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // --- FIX: Replace MyApp with DanceClassApp and wrap in ProviderScope ---
    await tester.pumpWidget(const ProviderScope(child: DanceClassApp()));

    // Verify that our counter starts at 0. (This part of the default test will fail as there's no counter)
    // You should adapt this test later for your actual UI.
    // For now, we just check if the app loads without crashing.
    expect(find.byType(HomeScreen), findsOneWidget); // Example: Check if HomeScreen is present initially

    // --- Default counter test logic (REMOVE OR COMMENT OUT) ---
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
    // --- End Default counter test logic ---
  });
}