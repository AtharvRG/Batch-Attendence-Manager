// lib/features/settings/widgets/theme_mode_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/theme/theme_provider.dart'; // Import theme provider

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);

    return SegmentedButton<ThemeMode>(
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
      ],
      selected: {currentMode}, // Needs to be a Set
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        // Update the provider with the selected mode (it's always a single selection)
        ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
      },
      // Style adjustments if needed
      showSelectedIcon: false, // Keep it cleaner maybe
      style: SegmentedButton.styleFrom(
        // visualDensity: VisualDensity.compact,
        // minimumSize: Size(double.infinity, 40), // Adjust size
      ),
    );
  }
}