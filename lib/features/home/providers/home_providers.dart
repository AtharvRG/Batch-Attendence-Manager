import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple StateProvider to manage the index of the currently selected
// tab in the main BottomNavigationBar. Defaults to 0 (first tab).
final selectedNavIndexProvider = StateProvider<int>((ref) {
  // The initial value is 0, representing the first screen (e.g., Batches)
  return 0;
});