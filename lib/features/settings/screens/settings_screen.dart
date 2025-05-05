import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import Settings Widgets
import 'package:dance_class_tracker/features/settings/widgets/theme_mode_selector.dart';
import 'package:dance_class_tracker/features/settings/widgets/color_seed_selector.dart';
import 'package:dance_class_tracker/features/settings/widgets/data_management_section.dart';
// Import Settings Providers
import 'package:dance_class_tracker/features/settings/providers/settings_providers.dart'; // Contains isDataProcessingProvider
// Import Services/Dialogs
import 'package:dance_class_tracker/core/services/export_import_service.dart';
import 'package:dance_class_tracker/core/widgets/confirm_dialog.dart';
// Optional: For App Version display
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../batches/providers/batch_providers.dart';
import '../../fees/providers/fee_providers.dart';
import '../../students/providers/student_providers.dart'; // Add package: package_info_plus

// Provider to fetch app version info (optional)
final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});


// Main Settings Screen Widget
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch app info provider (handle states)
    final appInfoAsync = ref.watch(appInfoProvider);

    // --- Export Handler ---
    // Moved logic inside build or use separate methods for clarity
    Future<void> _handleExport() async {
      // Read processing state without watching (inside button callback)
      if (ref.read(isDataProcessingProvider)) return;

      ref.read(isDataProcessingProvider.notifier).state = true; // Start loading
      final messenger = ScaffoldMessenger.of(context);

      try {
        // Call export service
        final success = await ref.read(exportImportServiceProvider).exportDataToFile();
        // UI Feedback is handled by share sheet result implicitly mostly
        if (success) {
          print("--- SettingsScreen: Export initiated successfully.");
        } else {
          // Show feedback if share failed or was cancelled
          if (context.mounted) {
            messenger.showSnackBar(const SnackBar(content: Text('Data export cancelled or unavailable.')));
          }
        }
      } catch (e) {
        print("--- SettingsScreen: Export Error: $e");
        if (context.mounted) {
          messenger.showSnackBar( SnackBar(content: Text('Export Error: $e'), backgroundColor: theme.colorScheme.error),);
        }
      } finally {
        // Ensure loading state is always reset
        if (ref.context.mounted) { // Check provider context validity too
          ref.read(isDataProcessingProvider.notifier).state = false;
        }
      }
    }

    // --- Import Handler ---
    Future<void> _handleImport() async {
      if (ref.read(isDataProcessingProvider)) return;

      // Show confirmation dialog first
      final confirm = await showConfirmDialog(
        context,
        title: 'Import Data?',
        content: 'WARNING!\nThis will completely replace all current app data (Batches, Students, Attendance, Fees) with the data from the selected backup file.\n\nThis action cannot be undone. Proceed with caution!',
        confirmText: 'Replace All Data',
        isDestructiveAction: true,
      );

      if (confirm && context.mounted) {
        ref.read(isDataProcessingProvider.notifier).state = true; // Start processing
        final messenger = ScaffoldMessenger.of(context);
        bool success = false;
        String message = '';

        try {
          // Call import service
          success = await ref.read(exportImportServiceProvider).importDataFromFile();
          message = success ? 'Data imported successfully! App may need refresh.' : 'Import cancelled or failed.';

          // --- Invalidate all data providers after successful import ---
          // This forces all lists/views to reload the newly imported data.
          if (success) {
            ref.invalidate(batchListProvider);
            ref.invalidate(studentListProvider);
            ref.invalidate(attendanceListProvider); // Might depend on selection though
            ref.invalidate(feesGroupedDataProvider);
            // Possibly invalidate theme providers if settings were part of backup (they aren't currently)
            // ref.invalidate(initialThemeSettingsProvider);
            print("--- SettingsScreen: Invalidated data providers after successful import.");
          }

        } catch (e) {
          print("--- SettingsScreen: Import Error caught in UI: $e");
          success = false;
          message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'An unexpected error occurred during import.';
        } finally {
          if(context.mounted) {
            messenger.showSnackBar( SnackBar( content: Text(message), backgroundColor: success ? Colors.green : theme.colorScheme.error, duration: Duration(seconds: success ? 3 : 5), behavior: SnackBarBehavior.floating,),);
          }
          // Ensure loading state is reset
          if(ref.context.mounted) {
            ref.read(isDataProcessingProvider.notifier).state = false;
          }
        }
      } else if (context.mounted){
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Import cancelled.'), duration: Duration(seconds: 2)),);
      }
    }

    // --- Build UI using ListView and extracted widgets ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          // --- Appearance Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text( 'Appearance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: const Text('Theme Mode'),
            subtitle: const Text('Choose light, dark, or system default'),
            trailing: const Padding( // Wrap selector for consistent padding
              padding: EdgeInsets.only(left: 8.0),
              child: ThemeModeSelector(),
            ),
            visualDensity: VisualDensity.compact, // Reduce vertical space
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: const Text('Theme Color'),
            subtitle: const Text('Select the base color for the theme'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: ColorSeedSelector(), // Use the extracted widget
          ),

          const Divider(height: 24, thickness: 1), // Section separator

          // --- Data Management Section ---
          // Use the extracted DataManagementSection widget
          DataManagementSection(
            onExport: _handleExport, // Pass the export handler
            onImport: _handleImport, // Pass the import handler
          ),

          const Divider(height: 24, thickness: 1), // Section separator

          // --- About Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text( 'About', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),),
          ),
          // Display App Version dynamically
          appInfoAsync.when(
            data: (info) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: Text('${info.version} (Build ${info.buildNumber})'),
              onTap: () => showLicensePage(context: context, applicationName: appTitle, applicationVersion: info.version),
            ),
            loading: () => const ListTile(leading: Icon(Icons.info_outline), title: Text('App Version'), subtitle: Text('Loading...')),
            error: (e, s) => ListTile(leading: Icon(Icons.info_outline), title: const Text('App Version'), subtitle: Text('Error loading version', style: TextStyle(color: theme.colorScheme.error))),
          ),
          // Add more ListTiles for Privacy Policy, etc. if needed
        ],
      ),
    );
  }
}