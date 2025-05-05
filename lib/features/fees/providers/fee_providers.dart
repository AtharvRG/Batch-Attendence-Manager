import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dance_class_tracker/core/models/batch.dart';
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/core/database/database_service.dart';
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart';
import 'package:dance_class_tracker/features/students/providers/student_providers.dart';
import 'package:dance_class_tracker/core/services/url_launcher_service.dart';

// --- Displayed Month Providers (Unchanged) ---
final displayedFeeMonthProvider = StateProvider<DateTime>((ref) => DateTime(DateTime.now().year, DateTime.now().month, 1));
final displayedMonthKeyProvider = Provider<String>((ref) => DateFormat('yyyy-MM').format(ref.watch(displayedFeeMonthProvider)));

// --- FeesGroupedData Class (Unchanged) ---
class FeesGroupedData {
  final Map<Batch?, List<Student>> groupedStudents;
  FeesGroupedData(this.groupedStudents);
}

// --- Corrected feesGroupedDataProvider ---
final feesGroupedDataProvider = Provider<AsyncValue<FeesGroupedData>>((ref) {
  print("--- feesGroupedDataProvider: Recalculating...");
  final batchesAsync = ref.watch(batchListProvider);
  final studentsAsync = ref.watch(studentListProvider);

  // Handle loading states first
  if (batchesAsync is AsyncLoading || studentsAsync is AsyncLoading) {
    print("--- feesGroupedDataProvider: Batches or Students are loading.");
    return const AsyncValue.loading();
  }

  // --- FIX: Handle Error States Correctly ---
  // Check for error in batches provider
  if (batchesAsync is AsyncError) {
    print("--- feesGroupedDataProvider: Error in batchListProvider.");
    // Provide a default Exception if batchesAsync.error is somehow null
    final error = batchesAsync.error ?? Exception("Unknown error loading batches");
    final stackTrace = batchesAsync.stackTrace ?? StackTrace.current;
    return AsyncValue.error(error, stackTrace);
  }
  // Check for error in students provider
  if (studentsAsync is AsyncError) {
    print("--- feesGroupedDataProvider: Error in studentListProvider.");
    // Provide a default Exception if studentsAsync.error is somehow null
    final error = studentsAsync.error ?? Exception("Unknown error loading students");
    final stackTrace = studentsAsync.stackTrace ?? StackTrace.current;
    return AsyncValue.error(error, stackTrace);
  }
  // --- End FIX ---

  // If we reach here, both batchesAsync and studentsAsync contain data
  final List<Batch> batches = batchesAsync.requireValue;
  final List<Student> students = studentsAsync.requireValue;

  print("--- feesGroupedDataProvider: Grouping data using ${batches.length} batches and ${students.length} students.");

  // Grouping logic (remains the same)
  final Map<Batch?, List<Student>> grouped = {};
  final batchMap = {for (var b in batches) b.id: b};
  for (final student in students) {
    final batch = batchMap[student.batchId];
    if (!grouped.containsKey(batch)) { grouped[batch] = []; }
    grouped[batch]!.add(student);
  }
  grouped.forEach((batch, studentList) {
    studentList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  });

  print("--- feesGroupedDataProvider: Grouping complete. Found ${grouped.length} groups.");
  // Return success state with the grouped data
  return AsyncValue.data(FeesGroupedData(grouped));
});


// --- Fee Status Notifier & Provider (Unchanged) ---
class FeeStatusNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref; final DatabaseService _dbService;
  FeeStatusNotifier(this.ref, this._dbService) : super(const AsyncValue.data(null));
  Future<void> toggleFeeStatus(Student student, String monthKey) async { state = const AsyncValue.loading(); try { final currentStatus = student.monthlyFeeStatus[monthKey] ?? false; final newStatus = !currentStatus; final updatedStatusMap = Map<String, bool>.from(student.monthlyFeeStatus); updatedStatusMap[monthKey] = newStatus; final updatedStudent = student.copyWith(monthlyFeeStatus: updatedStatusMap); await _dbService.updateStudent(updatedStudent); print("Toggled fee status for ${student.name} for month $monthKey to $newStatus"); ref.invalidate(studentListProvider); ref.invalidate(feesGroupedDataProvider); if(mounted) { state = const AsyncValue.data(null); } } catch (e, s) { print("Error toggling fee status for month $monthKey: $e\n$s"); if(mounted) { state = AsyncValue.error(e, s); } } }
}
final feeStatusToggleProvider = StateNotifierProvider<FeeStatusNotifier, AsyncValue<void>>((ref) {
  return FeeStatusNotifier(ref, DatabaseService());
});

// --- Send Fee Reminder Function (Unchanged) ---
Future<void> sendFeeReminder(WidgetRef ref, Student student) async {
  final urlService = ref.read(urlLauncherServiceProvider); final whatsAppNumber = student.whatsappNumber ?? student.mobile1; if (whatsAppNumber.isEmpty) { throw Exception("No WhatsApp number available for ${student.name}"); } final displayedMonth = ref.read(displayedFeeMonthProvider); final monthName = DateFormat('MMMM yyyy').format(displayedMonth); final message = "Hi ${student.parentName},\nJust a friendly reminder that the dance class fees for ${student.name} for $monthName are pending. Please arrange for the payment at your earliest convenience.\nThank you!"; final success = await urlService.launchWhatsApp(whatsAppNumber, message); if (!success) { throw Exception("Could not open WhatsApp. Is it installed?"); }
}