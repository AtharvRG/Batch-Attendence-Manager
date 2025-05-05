// lib/features/attendance/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/widgets/empty_placeholder.dart'; // Placeholder widget

// TODO: Implement Attendance History screen

// Placeholder Provider (replace with actual data provider later)
final attendanceHistoryProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  // Replace with actual logic to fetch history data
  // Example: Could fetch by student, by batch, by date range
  return const AsyncValue.loading(); // Start with loading
});

class AttendanceHistoryScreen extends ConsumerWidget {
  // Pass necessary parameters like studentId or batchId if needed
  // final String? studentId;
  // final String? batchId;

  const AttendanceHistoryScreen({
    super.key,
    // this.studentId,
    // this.batchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyData = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        // Add filtering options later (Date Range, Student, Batch)
      ),
      body: Center(
        // Use .when for state handling when provider is implemented
          child: historyData.when(
            data: (data) => const EmptyPlaceholder(
              icon: Icons.history_outlined,
              message: 'Attendance History Feature Not Implemented Yet.',
            ),
            loading: () => const CircularProgressIndicator.adaptive(),
            error: (e,s) => Text("Error loading history: $e"),
          )

      ),
    );
  }
}