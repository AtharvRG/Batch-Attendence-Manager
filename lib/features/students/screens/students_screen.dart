import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/widgets/empty_placeholder.dart';
import 'package:dance_class_tracker/core/widgets/loading_indicator.dart';
// Use the sqflite student list provider
import 'package:dance_class_tracker/features/students/providers/student_providers.dart';
// Import the widget used to display each student item
import 'package:dance_class_tracker/features/students/widgets/student_list_item.dart';
// Import the screen used for adding/editing students
import 'package:dance_class_tracker/features/students/screens/add_edit_student_screen.dart';

// Screen widget displaying the list of all students.
class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state of the student list provider (AsyncValue<List<Student>>).
    final studentsAsyncValue = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          // Refresh Button: Allows manually reloading the student list.
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh Students',
            // Call the refresh method on the StateNotifier.
            onPressed: () {
              print("--- StudentsScreen: Refresh button tapped.");
              ref.read(studentListProvider.notifier).refresh();
            },
          ),
          // Placeholder for future actions like Search or Filter.
          // IconButton(icon: Icon(Icons.search), onPressed: (){ /* TODO */ }),
          // IconButton(icon: Icon(Icons.filter_list), onPressed: (){ /* TODO */ }),
        ],
      ),
      // Use AsyncValue.when for robust handling of different data states.
      body: studentsAsyncValue.when(
        // State when the student list data is successfully loaded.
        data: (studentList) {
          // If the list is empty, show the custom placeholder widget.
          if (studentList.isEmpty) {
            return const EmptyPlaceholder(
              icon: Icons.person_search_outlined, // Icon suggesting searching or adding
              message: 'No students found.\nTap the button below to add a student.',
            );
          }
          // If data exists, display it in a ListView using RefreshIndicator.
          return RefreshIndicator.adaptive( // Enable pull-to-refresh
            onRefresh: () => ref.read(studentListProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // Ensure scrolling
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                // Get the student object for the current index.
                final student = studentList[index];
                // Use the StudentListItem widget to display the student's details.
                // Provide a ValueKey using the student's ID for efficient list updates.
                return StudentListItem(key: ValueKey(student.id), student: student);
              },
            ),
          );
        },
        // State while the data is loading.
        loading: () => const LoadingIndicator(),
        // State when an error occurs loading the data.
        error: (error, stackTrace) {
          print("--- StudentsScreen: Error loading students: $error\n$stackTrace");
          // Display a user-friendly error message with a retry button.
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load students', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('$error', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon( // Retry button
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => ref.read(studentListProvider.notifier).refresh(),
                  )
                ],
              ),
            ),
          );
        },
      ),
      // Floating Action Button to navigate to the Add Student screen.
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_students', // Unique tag for Hero animations if needed.
        icon: const Icon(Icons.person_add_alt_1), // Specific icon for adding a person.
        label: const Text('Add Student'),
        tooltip: 'Add New Student',
        onPressed: () {
          // Reset the editing state provider before navigating.
          ref.read(editingStudentProvider.notifier).state = null;
          // Push the Add/Edit screen onto the navigation stack in 'add' mode.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditStudentScreen(isEditMode: false)),
          );
        },
      ),
    );
  }
}