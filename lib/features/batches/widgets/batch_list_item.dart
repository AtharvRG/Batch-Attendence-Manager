import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart'; // Notifier Provider
import 'package:dance_class_tracker/core/models/batch.dart'; // Batch Model
import 'package:dance_class_tracker/core/widgets/confirm_dialog.dart'; // Confirmation Dialog
import 'package:dance_class_tracker/features/batches/screens/add_edit_batch_screen.dart'; // Add/Edit Screen

// Widget to display a single batch in a list with edit/delete actions.
class BatchListItem extends ConsumerWidget {
  final Batch batch; // The batch data for this list item

  const BatchListItem({super.key, required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Get theme for styling

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      // elevation: 1, // Keep default card theme elevation
      child: ListTile(
        // Batch Name
        title: Text(batch.name, style: theme.textTheme.titleMedium),
        // Optional Subtitle (e.g., number of students - requires fetching student count)
        // subtitle: Text('ID: ${batch.id}'), // Example subtitle
        // Trailing icons for actions
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Keep row tight
          children: [
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary), // Outlined icon
              tooltip: 'Edit Batch',
              onPressed: () {
                print("--- BatchListItem: Edit tapped for ID=${batch.id}");
                // Set the batch to be edited in the state provider
                ref.read(editingBatchProvider.notifier).state = batch;
                // Navigate to the Add/Edit screen in edit mode
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditBatchScreen(isEditMode: true),
                  ),
                );
              },
            ),
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'Delete Batch',
              onPressed: () async {
                print("--- BatchListItem: Delete tapped for ID=${batch.id}");
                // Show confirmation dialog before deleting
                final confirm = await showConfirmDialog(
                  context,
                  title: 'Delete Batch?',
                  content: 'Are you sure you want to delete the batch "${batch.name}"?\n\nThis will also delete related attendance records and unassign students currently in this batch.',
                  confirmText: 'Delete',
                  isDestructiveAction: true, // Indicate destructive action
                );

                // Proceed only if confirmed and the widget is still mounted
                if (confirm && context.mounted) {
                  try {
                    print("--- BatchListItem: Confirmed delete for ID=${batch.id}. Calling notifier...");
                    // Call the delete method on the batch list notifier
                    await ref.read(batchListProvider.notifier).deleteBatch(batch.id);
                    // Show success message (optional, list updates visually)
                    if (context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Batch "${batch.name}" deleted.'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2), ), );
                    }
                  } catch (e) { // Handle potential errors during deletion
                    print("--- BatchListItem: Error calling deleteBatch for ID=${batch.id}: $e");
                    if (context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Error deleting batch: $e'), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating, ), );
                    }
                  }
                } else if (context.mounted) {
                  print("--- BatchListItem: Delete cancelled for ID=${batch.id}");
                  // Optionally show cancellation message
                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deletion cancelled.')));
                }
              },
            ),
          ],
        ),
        // Make the entire tile tappable for editing (alternative to icon)
        onTap: () {
          print("--- BatchListItem: Tile tapped for edit ID=${batch.id}");
          ref.read(editingBatchProvider.notifier).state = batch;
          Navigator.push( context, MaterialPageRoute( builder: (context) => const AddEditBatchScreen(isEditMode: true), ), );
        },
        // visualDensity: VisualDensity.compact, // Make tile more compact if desired
      ),
    );
  }
}