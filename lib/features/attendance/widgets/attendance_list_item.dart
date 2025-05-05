// lib/features/attendance/widgets/attendance_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/features/attendance/providers/attendance_providers.dart';

class AttendanceListItem extends ConsumerWidget {
  final StudentAttendanceStatus status;

  const AttendanceListItem({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(attendanceUpdateProvider);
    final isUpdating = updateState is AsyncLoading;

    return CheckboxListTile(
      title: Text(status.student.name),
      value: status.isPresent,
      onChanged: isUpdating ? null : (bool? newValue) { // Disable while updating
        if (newValue != null) {
          // Call the notifier method to update the attendance
          ref.read(attendanceUpdateProvider.notifier)
              .updateAttendance(status.student, newValue)
              .catchError((e){
            // Show error SnackBar if update fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update attendance: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          });
        }
      },
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
      // Optional: Change secondary icon or visual cue based on status
      // secondary: isUpdating ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
    );
  }
}