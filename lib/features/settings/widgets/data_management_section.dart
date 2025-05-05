// lib/features/settings/widgets/data_management_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/features/settings/providers/settings_providers.dart'; // Import provider

// Widget displaying the Export and Import list tiles
class DataManagementSection extends ConsumerWidget {
  final VoidCallback onExport; // Callback function when Export is tapped
  final VoidCallback onImport; // Callback function when Import is tapped

  const DataManagementSection({
    super.key,
    required this.onExport,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch the processing state to update UI
    final isProcessing = ref.watch(isDataProcessingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Text(
            'Data Management',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Export Data'),
          subtitle: const Text('Save all data to a shareable JSON file'),
          trailing: isProcessing
          // Show spinner if processing
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
          // Show chevron otherwise
              : const Icon(Icons.chevron_right),
          // Disable tap when processing, call callback otherwise
          onTap: isProcessing ? null : onExport,
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import Data'),
          subtitle: const Text('Load data from backup file (Replaces current!)'),
          trailing: isProcessing
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
              : const Icon(Icons.chevron_right),
          onTap: isProcessing ? null : onImport, // Disable tap when processing
        ),
      ],
    );
  }
}