import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the screen widgets for each tab
import 'package:dance_class_tracker/features/batches/screens/batches_screen.dart';
import 'package:dance_class_tracker/features/students/screens/students_screen.dart';
import 'package:dance_class_tracker/features/fees/screens/fees_screen.dart';
import 'package:dance_class_tracker/features/attendance/screens/attendance_screen.dart';
import 'package:dance_class_tracker/features/settings/screens/settings_screen.dart';
// Import the provider for managing the selected index
import 'package:dance_class_tracker/features/home/providers/home_providers.dart';

// The main screen widget that holds the BottomNavigationBar and switches between feature screens.
class HomeScreen extends ConsumerWidget {
  // Use a non-const constructor if fields are not const.
  HomeScreen({super.key});

  // Define the list of screen widgets corresponding to each bottom navigation item.
  // The order MUST match the order of the BottomNavigationBarItems.
  final List<Widget> _screens = [
    const BatchesScreen(),    // Index 0
    const StudentsScreen(),   // Index 1
    const FeesScreen(),       // Index 2
    const AttendanceScreen(), // Index 3
    const SettingsScreen(),   // Index 4
  ];

  // Define the items for the BottomNavigationBar.
  final List<BottomNavigationBarItem> _navBarItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.group_work_outlined), activeIcon: Icon(Icons.group_work), label: 'Batches'),
    const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Students'),
    const BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), activeIcon: Icon(Icons.payment), label: 'Fees'),
    const BottomNavigationBarItem(icon: Icon(Icons.checklist_rtl_outlined), activeIcon: Icon(Icons.checklist_rtl), label: 'Attendance'),
    const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the currently selected navigation index.
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final theme = Theme.of(context);

    return Scaffold(
      // The body displays the screen corresponding to the selected index.
      // IndexedStack keeps the state of inactive screens alive.
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      // Configure the bottom navigation bar.
      bottomNavigationBar: BottomNavigationBar(
        // Set type to fixed to prevent items from shifting when selected. Recommended for 4+ items.
        type: BottomNavigationBarType.fixed,
        // Set the current index based on the provider's state.
        currentIndex: selectedIndex,
        // Update the provider's state when a different item is tapped.
        onTap: (index) => ref.read(selectedNavIndexProvider.notifier).state = index,
        // Provide the list of navigation bar items.
        items: _navBarItems,
        // Optional: Customize appearance using theme colors. Usually handled well by default.
        selectedItemColor: theme.colorScheme.primary, // Color for selected item
        unselectedItemColor: theme.colorScheme.onSurfaceVariant, // Color for unselected items
        // selectedFontSize: 12, // Slightly smaller font if needed
        // unselectedFontSize: 12,
        // showUnselectedLabels: true, // Ensure labels are always visible
      ),
    );
  }
}