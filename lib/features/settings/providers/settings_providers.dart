// lib/features/settings/providers/settings_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider to track if a data processing operation (Export/Import) is in progress.
// Used to disable buttons and show loading indicators in the UI.
final isDataProcessingProvider = StateProvider<bool>((ref) {
  // Initial state is false (not processing).
  return false;
});

// Add other settings-related providers here if needed in the future.
// Example: Provider for fetching app version info
// final appVersionProvider = FutureProvider<String>((ref) async {
//    final packageInfo = await PackageInfo.fromPlatform();
//    return '${packageInfo.version}+${packageInfo.buildNumber}';
// });