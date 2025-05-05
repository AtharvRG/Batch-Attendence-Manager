import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Core theme and navigation
import 'package:dance_class_tracker/core/theme/theme_provider.dart';
import 'package:dance_class_tracker/core/theme/app_theme.dart';
import 'package:dance_class_tracker/features/home/screens/home_screen.dart';

class DanceClassApp extends ConsumerWidget {
  const DanceClassApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("--- DanceClassApp build running ---");

    // Watch theme mode and color seed providers
    final themeMode = ref.watch(themeProvider);
    final colorSeed = ref.watch(colorSeedProvider);
    print("Current ThemeMode: ${themeMode.name}");
    print("Current ColorSeed: ${colorSeed.toString()}");

    // Watch initial theme settings load state (optional, for loading screen perhaps)
    final initialThemeState = ref.watch(initialThemeSettingsProvider);

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          // Determine if using platform dynamic colors or app's seed color
          bool usePlatformSpecificDynamicColor = false; // Force seed color usage

          if (usePlatformSpecificDynamicColor && lightDynamic != null && darkDynamic != null) {
            print("Using PLATFORM dynamic colors (harmonized).");
            lightColorScheme = lightDynamic.harmonized();
            darkColorScheme = darkDynamic.harmonized();
          } else {
            print("Using SEED color (${colorSeed.toString()}) to generate theme.");
            lightColorScheme = ColorScheme.fromSeed(
              seedColor: colorSeed,
              brightness: Brightness.light,
            );
            darkColorScheme = ColorScheme.fromSeed(
              seedColor: colorSeed,
              brightness: Brightness.dark,
            );
          }

          // Create AppTheme helper
          final appTheme = AppTheme(
            lightColorScheme: lightColorScheme,
            darkColorScheme: darkColorScheme,
          );

          print("Generated Light Theme Primary: ${appTheme.lightTheme.colorScheme.primary}");
          print("Generated Dark Theme Primary: ${appTheme.darkTheme.colorScheme.primary}");

          // Build the main app widget
          return MaterialApp(
            title: 'Dance Class Tracker',
            debugShowCheckedModeBanner: false,
            theme: appTheme.lightTheme,
            darkTheme: appTheme.darkTheme,
            themeMode: themeMode,
            home: initialThemeState.when( // Show loading while initial theme loads
              data: (_) => HomeScreen(),
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
              error: (e,s) => Scaffold(body: Center(child: Text("Error loading initial theme:\n$e"))),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
          );
        });
  }
}