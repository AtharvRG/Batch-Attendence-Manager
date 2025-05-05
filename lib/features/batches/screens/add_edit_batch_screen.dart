import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import provider for notifier actions and editing state
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart';
// --- FIX: Ensure this import statement is present ---
import 'package:dance_class_tracker/features/batches/widgets/batch_form.dart';
// --- End FIX ---
// Import Batch model (required for the editingBatch variable type)
import 'package:dance_class_tracker/core/models/batch.dart';

// Screen for adding a new batch or editing an existing one.
// Uses the BatchForm widget for the input field.
class AddEditBatchScreen extends ConsumerWidget {
  final bool isEditMode; // Flag to determine mode (Add vs Edit)

  const AddEditBatchScreen({super.key, this.isEditMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the editing state to get the original batch object if editing
    final Batch? editingBatch = ref.watch(editingBatchProvider); // Explicitly type Batch?

    // Form key for validation, specific to this screen instance.
    final formKey = GlobalKey<FormState>();

    // Function to handle saving the batch data, called by BatchForm or AppBar action
    Future<void> _saveBatch() async {
      // Validate the form using the key potentially passed to BatchForm
      if (formKey.currentState != null && formKey.currentState!.validate()) {
        // Read the current name from the controller managed by batchNameControllerProvider
        final name = ref.read(batchNameControllerProvider).text.trim();
        try {
          // Get the notifier for the batch list
          final notifier = ref.read(batchListProvider.notifier);

          // Handle UPDATE
          if (isEditMode && editingBatch != null) {
            print("--- AddEditBatchScreen: Updating batch ID: ${editingBatch.id}");
            // Create an updated Batch object using copyWith (preserves ID)
            final updatedBatch = editingBatch.copyWith(name: name);
            // Call the notifier's update method
            await notifier.updateBatch(updatedBatch);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Batch "${updatedBatch.name}" updated.')) );
            }
          }
          // Handle ADD
          else {
            print("--- AddEditBatchScreen: Adding new batch with name: $name");
            // Create a new Batch object (ID will be auto-generated)
            final newBatch = Batch(name: name);
            // Call the notifier's add method
            await notifier.addBatch(newBatch);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Batch "${newBatch.name}" added.')) );
            }
          }

          // Post-save cleanup and navigation
          if (context.mounted) {
            ref.read(editingBatchProvider.notifier).state = null; // Reset editing state
            Navigator.of(context).pop(); // Close the screen
          }
        } catch (e) { // Error handling during save
          print("--- AddEditBatchScreen: Error saving batch: $e");
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error saving batch: $e'), backgroundColor: Theme.of(context).colorScheme.error) );
          }
        }
      } else {
        print("--- AddEditBatchScreen: Form validation failed.");
      }
    }

    // Build UI
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Batch' : 'Add New Batch'),
        // Close Button
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(editingBatchProvider.notifier).state = null; // Reset state
            Navigator.of(context).pop(); // Close screen
          },
          tooltip: 'Cancel',
        ),
        // Save Button
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Batch',
            onPressed: _saveBatch, // Trigger save logic
          ),
        ],
      ),
      // Use Padding for spacing around the form
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // --- Use the imported BatchForm widget ---
        child: BatchForm( // Ensure BatchForm is correctly referenced
          formKey: formKey, // Pass the key for validation
          onSave: _saveBatch, // Pass the save function for keyboard 'done' action
        ),
        // --- End BatchForm Widget Usage ---
      ),
    );
  }
}