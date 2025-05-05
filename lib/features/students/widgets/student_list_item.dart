import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/core/models/batch.dart';
// Use the sqflite-based list and state providers
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart'; // For getting batch names
import 'package:dance_class_tracker/features/students/providers/student_providers.dart'; // For edit/delete actions
// Import necessary widgets/screens
import 'package:dance_class_tracker/core/widgets/confirm_dialog.dart';
import 'package:dance_class_tracker/features/students/screens/add_edit_student_screen.dart';


// Widget to display a single student's information in a list.
// Includes actions for editing and deleting the student.
class StudentListItem extends ConsumerWidget {
  // The student data object for this list item.
  final Student student;

  const StudentListItem({super.key, required this.student});

  // Helper method to safely get the batch name based on the student's batchId.
  // Reads the current state of the batch list provider.
  String _getBatchName(WidgetRef ref, String? batchId) {
    if (batchId == null) return 'No Batch Assigned'; // Return default text if no batch ID
    // Read the latest list of batches synchronously from the provider's state.
    // Use valueOrNull for safe access if the provider might be in loading/error state.
    final batches = ref.read(batchListProvider).valueOrNull ?? [];
    try {
      // Find the batch in the list whose ID matches the student's batchId.
      final batch = batches.firstWhere((b) => b.id == batchId);
      return batch.name; // Return the found batch's name.
    } catch (e) {
      // Handle cases where the batchId exists but the corresponding batch isn't found
      // (e.g., batch was deleted but student record wasn't updated yet).
      print("--- StudentListItem Warning: Batch with ID '$batchId' not found for student '${student.name}'.");
      return 'Unknown Batch'; // Indicate that the batch name couldn't be found.
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Get theme data for styling.
    // Get the displayable batch name using the helper method.
    final batchName = _getBatchName(ref, student.batchId);
    // Calculate age using the getter in the Student model.
    final age = student.age;

    // Log details during build (optional, for debugging)
    // print("--- StudentListItem build: ID=${student.id}, Name=${student.name}, BatchID=${student.batchId}, BatchName=$batchName");

    // Use Card for visual structure and elevation.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1, // Subtle elevation
      child: ListTile(
        // Leading CircleAvatar displaying age or initial.
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiaryContainer, // Use a different container color
          foregroundColor: theme.colorScheme.onTertiaryContainer,
          child: Text(
            age != null
                ? age.toString() // Display age if available
            // Display first letter of name if available, otherwise '?'
                : (student.name.isNotEmpty ? student.name[0].toUpperCase() : '?'),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: age != null ? 16 : 18 // Adjust font size based on content
            ),
          ),
        ),
        // Student's Name.
        title: Text(student.name, style: theme.textTheme.titleMedium),
        // Subtitle showing Batch and Primary Mobile Number.
        subtitle: Text(
          'Batch: $batchName\nMobile: ${student.mobile1}',
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant // Use a subdued color for subtitle
          ),
        ),
        // Ensure enough vertical space for two lines of subtitle.
        isThreeLine: true,
        // Trailing action buttons (Edit, Delete).
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Keep row width tight.
          children: [
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
              tooltip: 'Edit Student Details',
              onPressed: () {
                print("--- StudentListItem: Edit button pressed for ID=${student.id}");
                // Set the student in the editing state provider.
                ref.read(editingStudentProvider.notifier).state = student;
                // Navigate to the Add/Edit screen in edit mode.
                Navigator.push( context, MaterialPageRoute( builder: (context) => const AddEditStudentScreen(isEditMode: true),),);
              },
            ),
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'Delete Student',
              onPressed: () async {
                print("--- StudentListItem: Delete button pressed for student ID=${student.id}, Name=${student.name}");
                // Show confirmation dialog before proceeding.
                final confirm = await showConfirmDialog(
                  context,
                  title: 'Delete Student?',
                  content: 'Are you sure you want to delete "${student.name}"? This action cannot be undone and will remove all associated attendance records.',
                  confirmText: 'Delete Permanently',
                  isDestructiveAction: true, // Style button appropriately
                );

                // If confirmed and widget still exists...
                if (confirm && context.mounted) {
                  try {
                    print("--- StudentListItem: Confirmed delete for ID=${student.id}. Calling studentListProvider notifier...");
                    // Call the delete method on the student list notifier.
                    await ref.read(studentListProvider.notifier).deleteStudent(student.id);
                    // Show success SnackBar (optional, list updates visually)
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Student "${student.name}" deleted.'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2),),);
                    }
                  } catch (e) { // Catch errors during delete operation
                    print("--- StudentListItem: Error calling deleteStudent notifier for ID=${student.id}: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error deleting student: $e'), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating,),);
                    }
                  }
                } else if(context.mounted) {
                  print("--- StudentListItem: Delete cancelled by user for ID=${student.id}");
                  // Optionally show feedback that delete was cancelled
                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deletion cancelled.')));
                }
              },
            ),
          ],
        ),
        // Allow tapping the entire list tile to initiate editing.
        onTap: () {
          print("--- StudentListItem: Tile tapped for edit ID=${student.id}");
          ref.read(editingStudentProvider.notifier).state = student;
          Navigator.push( context, MaterialPageRoute( builder: (context) => const AddEditStudentScreen(isEditMode: true),),);
        },
        // Adjust visual density if desired.
        // visualDensity: VisualDensity.compact,
      ),
    );
  }
}