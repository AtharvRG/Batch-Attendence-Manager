import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // <-- Import foundation for describeEnum
// Import DatabaseService and constants
import 'package:dance_class_tracker/core/database/database_service.dart';
import 'package:dance_class_tracker/core/constants/db_constants.dart'; // Use DB constants
import 'package:dance_class_tracker/core/theme/app_theme.dart'; // For AppColorSeed

// --- Provider Setup using DatabaseService ---

// FutureProvider to load initial theme settings from DB
final initialThemeSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  print("--- InitialThemeSettingsProvider: Fetching initial settings from DB...");
  final dbService = DatabaseService(); // Get singleton instance
  final themeModeIndexStr = await dbService.getSetting(settingThemeMode); // Use const key
  final colorSeedValueStr = await dbService.getSetting(settingColorSeed); // Use const key

  // Parse values or use defaults
  final themeModeIndex = int.tryParse(themeModeIndexStr ?? '') ?? ThemeMode.system.index;
  // Ensure index is valid for ThemeMode enum
  final safeThemeModeIndex = themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length ? themeModeIndex : ThemeMode.system.index;
  final defaultColorValue = AppColorSeed.base.color.value; // Default color
  final colorSeedValue = int.tryParse(colorSeedValueStr ?? '') ?? defaultColorValue;

  print("--- InitialThemeSettingsProvider: Loaded mode index=$safeThemeModeIndex, color value=$colorSeedValue");
  // Return a map containing the loaded/default settings
  return {
    'themeMode': ThemeMode.values[safeThemeModeIndex],
    'colorSeed': Color(colorSeedValue),
  };
});

// Theme Mode Provider (depends on initial settings)
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final initialSettings = ref.watch(initialThemeSettingsProvider);
  return initialSettings.when(
      data: (settings) {
        print("--- themeProvider: Initializing ThemeNotifier with mode: ${describeEnum(settings['themeMode'])}"); // Use describeEnum here too
        return ThemeNotifier(settings['themeMode'], DatabaseService());
      },
      loading: () {
        print("--- themeProvider: Initializing ThemeNotifier with default (loading) mode: System");
        return ThemeNotifier(ThemeMode.system, DatabaseService());
      },
      error: (e, s) {
        print("--- themeProvider: Error loading initial theme settings: $e. Initializing ThemeNotifier with default mode: System");
        return ThemeNotifier(ThemeMode.system, DatabaseService());
      }
  );
});

// Color Seed Provider (depends on initial settings)
final colorSeedProvider = StateNotifierProvider<ColorSeedNotifier, Color>((ref) {
  final initialSettings = ref.watch(initialThemeSettingsProvider);
  return initialSettings.when(
      data: (settings) {
        print("--- colorSeedProvider: Initializing ColorSeedNotifier with color: ${settings['colorSeed']}");
        return ColorSeedNotifier(settings['colorSeed'], DatabaseService());
      },
      loading: () {
        final defaultColor = AppColorSeed.base.color;
        print("--- colorSeedProvider: Initializing ColorSeedNotifier with default (loading) color: $defaultColor");
        return ColorSeedNotifier(defaultColor, DatabaseService());
      },
      error: (e, s) {
        final defaultColor = AppColorSeed.base.color;
        print("--- colorSeedProvider: Error loading initial color settings: $e. Initializing ColorSeedNotifier with default color: $defaultColor");
        return ColorSeedNotifier(defaultColor, DatabaseService());
      }
  );
});

// --- Notifiers (Updated to use DatabaseService) ---

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final DatabaseService _dbService;
  ThemeNotifier(super.initialState, this._dbService);

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      final previousState = state; // Store previous state for potential revert on error
      state = mode; // Update state optimistically
      try {
        // --- FIX: Use describeEnum for logging ---
        print("--- ThemeNotifier: Setting theme mode to ${describeEnum(mode)} and attempting save...");
        await _dbService.saveSetting(settingThemeMode, mode.index.toString());
        print("--- ThemeNotifier: Theme mode ${describeEnum(mode)} saved to DB.");
        // --- End FIX ---
      } catch (e) {
        print("--- ThemeNotifier: ERROR saving theme mode setting (${describeEnum(mode)}) to DB: $e");
        // Optionally revert state if save fails
        // state = previousState;
        // Consider showing user feedback about save failure
      }
    } else {
      print("--- ThemeNotifier: Theme mode already ${describeEnum(mode)}. No change.");
    }
  }
}

class ColorSeedNotifier extends StateNotifier<Color> {
  final DatabaseService _dbService;
  ColorSeedNotifier(super.initialState, this._dbService);

  Future<void> setColorSeed(Color color) async {
    if (state.value != color.value) {
      final previousState = state;
      state = color;
      try {
        print("--- ColorSeedNotifier: Setting color seed to ${color.toString()} and attempting save...");
        await _dbService.saveSetting(settingColorSeed, color.value.toString());
        print("--- ColorSeedNotifier: Color seed ${color.toString()} saved to DB.");
      } catch (e) {
        print("--- ColorSeedNotifier: ERROR saving color seed setting (${color.toString()}) to DB: $e");
        // Optionally revert state
        // state = previousState;
      }
    } else {
      print("--- ColorSeedNotifier: Color seed already ${state.toString()}. No change.");
    }
  }
}