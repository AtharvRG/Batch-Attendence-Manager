import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Using Google Fonts

// Define available theme seed colors as an enum for type safety
enum AppColorSeed {
  base(Color(0xFF1976D2)), // Example: A nice blue
  teal(Colors.teal),
  purple(Colors.purple),
  green(Colors.green),
  orange(Colors.orange),
  pink(Colors.pink);

  const AppColorSeed(this.color);
  final Color color;
}

// Helper class to generate ThemeData based on ColorSchemes
class AppTheme {
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;

  // Constructor requires the light and dark ColorSchemes
  AppTheme({required this.lightColorScheme, required this.darkColorScheme});

  // --- Light Theme ---
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true, // Enable Material 3 features
    colorScheme: lightColorScheme, // Apply the provided light color scheme
    // Define consistent AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.surfaceContainer, // M3 style AppBar
      foregroundColor: lightColorScheme.onSurfaceVariant,
      elevation: 1.0, // Subtle elevation
      centerTitle: false, // Platform default (iOS true, Android false)
      titleTextStyle: GoogleFonts.lato( // Use custom font
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightColorScheme.onSurface,
      ),
    ),
    // Define FAB theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      elevation: 4.0,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Optional shape
    ),
    // Define Card theme
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias, // Ensure content respects shape
      elevation: 1.5, // Subtle elevation for cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Consistent corner radius
        side: BorderSide(color: lightColorScheme.outlineVariant.withOpacity(0.5), width: 0.5), // Subtle border
      ),
    ),
    // Define ListTile theme
    listTileTheme: ListTileThemeData(
      iconColor: lightColorScheme.primary, // Consistent icon color
      // dense: true, // Make lists more compact by default if desired
    ),
    // Apply custom text theme using Google Fonts
    textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme).copyWith(
      // Override specific text styles if needed
      // titleLarge: GoogleFonts.lato(fontWeight: FontWeight.bold),
    ),
    // Define SegmentedButton theme
    segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          // Make segments visually distinct
          side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
            // Add border if not selected
            if (!states.contains(MaterialState.selected)) {
              return BorderSide(color: lightColorScheme.outline);
            }
            return null; // Default side (usually none) if selected
          }),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.selected)) {
              return lightColorScheme.secondaryContainer; // Use secondary container for selected
            }
            return lightColorScheme.surface; // Default background
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states){
            if (states.contains(MaterialState.selected)) {
              return lightColorScheme.onSecondaryContainer;
            }
            return lightColorScheme.onSurfaceVariant; // Color for unselected text/icons
          }),
        )),
    // Define other component themes (InputDecorationTheme, ButtonTheme, etc.) as needed
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.outlineVariant, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 1.5),
      ),
      labelStyle: TextStyle(color: lightColorScheme.onSurfaceVariant),
      hintStyle: TextStyle(color: lightColorScheme.onSurfaceVariant.withOpacity(0.6)),
    ),
  );

  // --- Dark Theme ---
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true, // Enable Material 3 features
    colorScheme: darkColorScheme, // Apply the provided dark color scheme
    // Define consistent AppBar theme for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surfaceContainer, // M3 style
      foregroundColor: darkColorScheme.onSurfaceVariant,
      elevation: 1.0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.lato( // Use custom font
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkColorScheme.onSurface,
      ),
    ),
    // Define FAB theme for dark mode
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.primaryContainer, // Often better contrast
      foregroundColor: darkColorScheme.onPrimaryContainer,
      elevation: 4.0,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    // Define Card theme for dark mode
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0, // Slightly more elevation might look good in dark
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: darkColorScheme.outlineVariant, width: 0.5), // Subtle border
      ),
    ),
    // Define ListTile theme for dark mode
    listTileTheme: ListTileThemeData(
      iconColor: darkColorScheme.primary,
      // dense: true,
    ),
    // Apply custom text theme using Google Fonts, ensuring readability
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: darkColorScheme.onSurface, // Default text color
      displayColor: darkColorScheme.onSurface, // Heading color
    ).copyWith(
      // Override specific styles if needed for dark mode contrast
    ),
    // Define SegmentedButton theme for dark mode
    segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
            if (!states.contains(MaterialState.selected)) {
              return BorderSide(color: darkColorScheme.outline);
            }
            return null;
          }),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.selected)) {
              return darkColorScheme.secondaryContainer;
            }
            return darkColorScheme.surfaceContainerHighest; // Slightly different bg
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states){
            if (states.contains(MaterialState.selected)) {
              return darkColorScheme.onSecondaryContainer;
            }
            return darkColorScheme.onSurfaceVariant;
          }),
        )),
    // Define other component themes for dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surfaceContainerHighest,
      border: OutlineInputBorder( borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none,),
      enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: darkColorScheme.outlineVariant, width: 0.5),),
      focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: darkColorScheme.primary, width: 1.5),),
      labelStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
      hintStyle: TextStyle(color: darkColorScheme.onSurfaceVariant.withOpacity(0.6)),
    ),
  );
}