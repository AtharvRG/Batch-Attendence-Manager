import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import the provider for the batch name TextEditingController
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart';

// A reusable widget specifically for the Batch Name input field within a Form.
class BatchForm extends ConsumerWidget {
  // Optional GlobalKey<FormState> passed from the parent screen.
  // If provided, the parent can use this key to validate this specific form field (or the whole form it's part of).
  final GlobalKey<FormState>? formKey;

  // Optional callback function passed from the parent screen.
  // Triggered when the user presses the 'Done' action on the keyboard.
  final VoidCallback? onSave;

  const BatchForm({
    super.key,
    this.formKey, // The key is optional
    this.onSave,  // The save callback is optional
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the specific TextEditingController for the batch name.
    // This ensures the controller's lifecycle is managed correctly (autoDispose).
    final batchNameController = ref.watch(batchNameControllerProvider);

    // Return a Form widget wrapping the TextFormField.
    // If a formKey is provided, assign it to this Form.
    // Note: Often, the entire screen ('AddEditBatchScreen') might have a single Form
    // wrapping multiple fields. In that case, this Form widget here might be redundant,
    // and you'd only return the TextFormField, assuming it's placed inside the parent's Form.
    // However, for full encapsulation including the key, we keep the Form here.
    // If used inside another Form, ensure keys are handled appropriately or remove this Form wrapper.
    return Form(
      key: formKey,
      // The input field itself.
      child: TextFormField(
        controller: batchNameController, // Connect the controller
        autofocus: true, // Automatically focus this field when the widget appears
        decoration: const InputDecoration(
          labelText: 'Batch Name*', // Label indicating what to enter (* for required)
          hintText: 'E.g., Tuesday Advanced Jazz', // Placeholder text
          border: OutlineInputBorder(), // Use a bordered input style
          prefixIcon: Icon(Icons.group_work_outlined), // Relevant icon
        ),
        // Validation logic for the batch name
        validator: (value) {
          final trimmedValue = value?.trim() ?? ''; // Trim whitespace safely
          if (trimmedValue.isEmpty) {
            return 'Please enter a batch name.'; // Error if empty
          }
          if (trimmedValue.length < 3) {
            return 'Batch name must be at least 3 characters long.'; // Length check
          }
          // Add other validation rules here if necessary (e.g., check for duplicates - requires more logic)
          return null; // Return null if input is valid
        },
        textInputAction: TextInputAction.done, // Set the keyboard action button to 'Done'
        textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
        // When the user submits via the keyboard (e.g., presses 'Done'), call the onSave callback if provided.
        onFieldSubmitted: (_) => onSave?.call(),
      ),
    );
  }
}