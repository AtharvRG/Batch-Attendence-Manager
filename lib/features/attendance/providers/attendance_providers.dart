import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dance_class_tracker/core/database/database_service.dart';
import 'package:dance_class_tracker/core/models/attendance_record.dart';
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/features/students/providers/student_providers.dart'; // Correct student provider

// --- State/Derived Providers (Unchanged) ---
final selectedAttendanceDateProvider = StateProvider<DateTime>((ref) => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
final formattedSelectedDateProvider = Provider<String>((ref) => DateFormat('yyyy-MM-dd').format(ref.watch(selectedAttendanceDateProvider)));
final selectedAttendanceBatchIdProvider = StateProvider<String?>((ref) => null);

// --- Data Structure (Unchanged) ---
class StudentAttendanceStatus {
  final Student student;
  final bool isPresent;
  StudentAttendanceStatus({required this.student, required this.isPresent});
}

// --- Corrected attendanceListProvider ---
final attendanceListProvider = FutureProvider<List<StudentAttendanceStatus>>((ref) async {
  print("--- attendanceListProvider: Recalculating attendance list...");
  final selectedDateStr = ref.watch(formattedSelectedDateProvider);
  final selectedBatchId = ref.watch(selectedAttendanceBatchIdProvider);

  if (selectedBatchId == null) {
    print("--- attendanceListProvider: No batch selected, returning empty list.");
    return [];
  }

  // Watch the state (AsyncValue) of the student list provider.
  final studentsAsyncValue = ref.watch(studentListProvider);

  // Handle the async state of the student list.
  List<Student> allStudents; // Declare variable to hold student list

  try {
    allStudents = await studentsAsyncValue.when(
        data: (students) => students, // Use data directly
        loading: () async {
          print("--- attendanceListProvider: studentListProvider is loading. Returning empty list temporarily.");
          // --- FIX: Don't await future here. Return empty or throw if you want loading state. ---
          // For simplicity, return empty list now. This provider will re-run when students load.
          return <Student>[]; // Return empty list while student data loads
          // Alternative: throw specific loading error if needed by UI .when()
          // throw Error.throwWithStackTrace('Students loading', StackTrace.current);
        },
        error: (e, s) {
          print("--- attendanceListProvider: Error in studentListProvider: $e. Rethrowing.");
          // Rethrow the error to propagate it to the UI.
          throw Exception("Failed to load student list: $e");
        }
    );
  } catch (e) {
    // If the .when threw an error (e.g., from the error handler or hypothetical loading throw)
    print("--- attendanceListProvider: Caught error during student list resolution: $e");
    // Returning empty list on error state as well, UI should handle main provider error.
    return []; // Or rethrow? Returning empty might be safer UI-wise.
  }


  // --- Proceed only if we have students (might be empty if loading returned empty) ---
  final studentsInBatch = allStudents.where((s) => s.batchId == selectedBatchId).toList();

  if (studentsInBatch.isEmpty) {
    // This can now happen if the student list was loading OR if the batch is genuinely empty
    print("--- attendanceListProvider: No students found for Batch ID $selectedBatchId (or students are still loading).");
    return [];
  }

  // Sort students alphabetically.
  studentsInBatch.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  // Fetch attendance records for the specific date.
  final recordsForDate = await DatabaseService().getAttendanceForDate(selectedDateStr);
  final attendanceMap = { for (var r in recordsForDate) r.studentId : r.isPresent };
  print("--- attendanceListProvider: Found ${recordsForDate.length} attendance records for $selectedDateStr.");

  // Combine student data with attendance status.
  final statusList = studentsInBatch.map((student) {
    final isPresent = attendanceMap[student.id] ?? false;
    return StudentAttendanceStatus(student: student, isPresent: isPresent);
  }).toList();

  print("--- attendanceListProvider: Returning ${statusList.length} student statuses for Date: $selectedDateStr / Batch ID: $selectedBatchId.");
  return statusList; // Return the final list.
});


// --- Attendance Update Notifier (Unchanged) ---
class AttendanceUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final DatabaseService _dbService;
  AttendanceUpdateNotifier(this.ref, this._dbService) : super(const AsyncValue.data(null));
  Future<void> updateAttendance(Student student, bool newPresentStatus) async {
    state = const AsyncValue.loading();
    final selectedDateStr = ref.read(formattedSelectedDateProvider);
    final selectedBatchId = ref.read(selectedAttendanceBatchIdProvider);
    if (selectedBatchId == null) { state = AsyncValue.error(ArgumentError("No batch selected"), StackTrace.current); return; }
    try {
      final record = AttendanceRecord( date: selectedDateStr, studentId: student.id, batchId: selectedBatchId, isPresent: newPresentStatus );
      await _dbService.saveAttendance(record);
      ref.invalidate(attendanceListProvider); // Trigger refresh
      if(mounted){ state = const AsyncValue.data(null); }
    } catch (e, s) { print("Error updating attendance: $e\n$s"); if(mounted){ state = AsyncValue.error(e, s); } }
  }
}

// Provider for Notifier (Unchanged)
final attendanceUpdateProvider = StateNotifierProvider<AttendanceUpdateNotifier, AsyncValue<void>>((ref) {
  return AttendanceUpdateNotifier(ref, DatabaseService());
});