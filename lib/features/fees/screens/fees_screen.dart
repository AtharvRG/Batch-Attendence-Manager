import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dance_class_tracker/core/models/batch.dart'; // Batch model for display
import 'package:dance_class_tracker/core/widgets/loading_indicator.dart';
import 'package:dance_class_tracker/core/widgets/empty_placeholder.dart';
import 'package:dance_class_tracker/features/fees/providers/fee_providers.dart'; // Fee specific providers
import 'package:dance_class_tracker/features/fees/widgets/student_fee_list_item.dart'; // Widget for student row

// Screen displaying fee status grouped by batch for a navigatable month.
class FeesScreen extends ConsumerWidget {
  const FeesScreen({super.key});

  // Handler for the "Previous Month" button press.
  void _previousMonth(WidgetRef ref) {
    // Read the current displayed month's DateTime value.
    final currentMonth = ref.read(displayedFeeMonthProvider);
    // Calculate the first day of the previous month.
    final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    // Update the StateProvider with the new DateTime value.
    ref.read(displayedFeeMonthProvider.notifier).state = previousMonth;
    print("--- FeesScreen: Navigated to previous month: $previousMonth");
    // Optionally, invalidate the grouped data provider if explicit refresh is desired.
    // ref.invalidate(feesGroupedDataProvider);
  }

  // Handler for the "Next Month" button press.
  void _nextMonth(WidgetRef ref) {
    final currentMonth = ref.read(displayedFeeMonthProvider);
    // Calculate the first day of the next month.
    final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    // Update the StateProvider.
    ref.read(displayedFeeMonthProvider.notifier).state = nextMonth;
    print("--- FeesScreen: Navigated to next month: $nextMonth");
    // ref.invalidate(feesGroupedDataProvider); // Optional invalidation
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Access theme data.
    // Watch the provider that fetches and groups the fee data.
    // This will be an AsyncValue<FeesGroupedData>.
    final groupedDataAsync = ref.watch(feesGroupedDataProvider);
    // Watch the provider for the currently displayed month.
    final displayedMonth = ref.watch(displayedFeeMonthProvider);
    // Format the displayed month for the AppBar title.
    final displayedMonthName = DateFormat('MMMM yyyy').format(displayedMonth);

    return Scaffold(
      appBar: AppBar(
        // Display the relevant month in the title.
        title: Text('Fee Status ($displayedMonthName)'),
        // Add month navigation buttons.
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous Month',
            onPressed: () => _previousMonth(ref), // Call handler.
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next Month',
            onPressed: () => _nextMonth(ref), // Call handler.
          ),
          const SizedBox(width: 8), // Add spacing.
        ],
      ),
      // Use AsyncValue.when to build the UI based on the state of groupedDataAsync.
      body: groupedDataAsync.when(
        // --- Data State ---
        data: (groupedData) {
          final groupedMap = groupedData.groupedStudents; // Get the map of grouped students.

          // If no students/batches exist, show an empty state message.
          if (groupedMap.isEmpty) {
            return const EmptyPlaceholder(
              icon: Icons.receipt_long_outlined,
              message: 'No student or batch data found.\nPlease add batches and students first.',
            );
          }

          // Prepare sorted list of keys (Batch? objects) for the ListView.
          // Sort 'No Batch' group (null key) to the end.
          final sortedBatchKeys = groupedMap.keys.toList()
            ..sort((a, b) {
              if (a == null) return 1; // nulls last
              if (b == null) return -1; // nulls last
              return a.name.toLowerCase().compareTo(b.name.toLowerCase()); // sort by name otherwise
            });

          // Build the list of ExpansionTiles, one for each batch group.
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0), // Avoid FAB overlap
            itemCount: sortedBatchKeys.length,
            itemBuilder: (context, index) {
              final Batch? batchKey = sortedBatchKeys[index]; // The key (Batch? object)
              final studentsInGroup = groupedMap[batchKey] ?? []; // List of students for this key
              final batchName = batchKey?.name ?? 'No Batch Assigned'; // Display name

              // Optional: Hide empty assigned batches (keep 'No Batch' group even if empty for clarity)
              // if (studentsInGroup.isEmpty && batchKey != null) {
              //   return const SizedBox.shrink();
              // }

              // Display each group within a Card and ExpansionTile.
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                elevation: 1.0,
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  // Use PageStorageKey to preserve expanded/collapsed state during scrolls/rebuilds.
                  key: PageStorageKey(batchKey?.id ?? 'no-batch-assigned-group'),
                  // Header of the tile: Batch name and student count.
                  title: Text(batchName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('${studentsInGroup.length} Student${studentsInGroup.length == 1 ? '' : 's'}'),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  initiallyExpanded: true, // Keep tiles expanded by default.
                  // Subtle background color when expanded.
                  backgroundColor: theme.colorScheme.surfaceContainerLowest.withOpacity(0.5),
                  // Generate the list of student fee items within the expanded tile.
                  children: studentsInGroup.isEmpty
                  // Show a message if a group happens to be empty (e.g., "No Batch Assigned" group).
                      ? [ const ListTile(dense: true, title: Center(child: Text("No students in this group."))) ]
                  // Map each student in the group to a StudentFeeListItem widget.
                      : studentsInGroup.map((student) => StudentFeeListItem(
                    key: ValueKey(student.id), // Use student ID as key.
                    student: student,
                  )).toList(),
                ),
              );
            },
          );
        },
        // --- Loading State ---
        loading: () => const LoadingIndicator(), // Show standard loading indicator.
        // --- Error State ---
        error: (error, stack) {
          print("--- FeesScreen: Error loading fees data: $error\n$stack");
          // Display error message centered on the screen.
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column( // Added column for better layout
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text( "Error loading fee data:", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text("$error", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              )
          );
        },
      ),
    );
  }
}