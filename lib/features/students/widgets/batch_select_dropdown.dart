// lib/features/students/widgets/batch_select_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/models/batch.dart'; // Batch model
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart'; // Batch list provider
// Note: Selected ID state is managed by the *parent* screen's provider (studentSelectedBatchIdProvider)

// Reusable Dropdown widget for selecting a Batch
class BatchSelectDropdown extends ConsumerWidget {
  // The currently selected Batch ID (can be null for 'No Batch')
  final String? selectedBatchId;
  // Callback function to execute when a new batch is selected
  final ValueChanged<String?> onChanged;
  // Optional label for the dropdown field
  final String labelText;

  const BatchSelectDropdown({
    super.key,
    required this.selectedBatchId,
    required this.onChanged,
    this.labelText = 'Batch Assignment', // Default label
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch the batch list provider to get the available options
    final batchesAsync = ref.watch(batchListProvider);

    return batchesAsync.when(
      // When batch data is loaded successfully
      data: (batches) {
        // Validate that the current selectedBatchId still exists in the loaded batches
        final validBatchIds = batches.map((b) => b.id).toSet();
        final currentDropdownValue = (selectedBatchId != null && validBatchIds.contains(selectedBatchId))
            ? selectedBatchId
            : null; // Default to null if selected ID is invalid

        return DropdownButtonFormField<String?>(
          value: currentDropdownValue, // Set the current selection
          hint: const Text('Select Batch (Optional)'), // Placeholder text
          isExpanded: true, // Allow dropdown to take full width
          decoration: InputDecoration(
            labelText: labelText, // Use provided label
            prefixIcon: const Icon(Icons.group_work_outlined),
            border: const OutlineInputBorder(), // Add border for clarity
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust padding
          ),
          // Generate dropdown items
          items: [
            // Add the "No Batch Assigned" option first
            const DropdownMenuItem<String?>(
              value: null, // Value representing no selection
              child: Text('No Batch Assigned', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
            // Map the loaded Batch objects to DropdownMenuItems
            ...batches.map<DropdownMenuItem<String?>>((Batch batch) {
              return DropdownMenuItem<String?>(
                value: batch.id, // The value associated with this item
                child: Text(batch.name), // The text displayed for this item
              );
            }).toList(),
          ],
          // Call the onChanged callback when a selection is made
          onChanged: onChanged,
          // Optional validation (e.g., make selection required)
          // validator: (value) => value == null && batches.isNotEmpty ? 'Please select a batch' : null,
        );
      },
      // State while loading the list of batches
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0), // Add padding
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
          SizedBox(width: 16),
          Text('Loading batches...')
        ]),
      ),
      // State if an error occurred loading batches
      error: (err, stack) => TextFormField( // Show disabled field on error
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(Icons.error_outline),
          border: const OutlineInputBorder(),
          hintText: 'Error loading batches',
          hintStyle: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}