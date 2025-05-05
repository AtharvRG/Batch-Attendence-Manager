import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed Hive import: import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
// Core
import 'package:dance_class_tracker/core/database/database_service.dart'; // Use sqflite service
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/core/models/batch.dart';
// Features
import 'package:dance_class_tracker/features/batches/providers/batch_providers.dart'; // Use sqflite batch provider


// State Notifier for Students List
class StudentListNotifier extends StateNotifier<AsyncValue<List<Student>>> {
  final DatabaseService _dbService;
  StudentListNotifier(this._dbService) : super(const AsyncValue.loading()) { _fetchStudents(); }
  Future<void> _fetchStudents() async { if (state is! AsyncLoading) { state = const AsyncValue.loading(); } try { final students = await _dbService.getAllStudents(); students.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())); if(mounted) { state = AsyncValue.data(students); print("--- StudentListNotifier: Fetched ${students.length} students."); } } catch(e, s) { print("--- StudentListNotifier: Error fetching students: $e\n$s"); if(mounted){ state = AsyncValue.error(e, s); } } }
  Future<void> addStudent(Student student) async { try { await _dbService.insertStudent(student); await _fetchStudents(); } catch (e) { print("--- StudentListNotifier: Error adding student: $e"); rethrow; } }
  Future<void> updateStudent(Student student) async { try { await _dbService.updateStudent(student); await _fetchStudents(); } catch (e) { print("--- StudentListNotifier: Error updating student: $e"); rethrow; } }
  Future<void> deleteStudent(String studentId) async { try { await _dbService.deleteStudent(studentId); await _fetchStudents(); } catch (e) { print("--- StudentListNotifier: Error deleting student: $e"); rethrow; } }
  Future<void> refresh() async { print("--- StudentListNotifier: Manual refresh requested."); await _fetchStudents(); }
}

// StateNotifierProvider for the students list
final studentListProvider = StateNotifierProvider<StudentListNotifier, AsyncValue<List<Student>>>((ref) {
  return StudentListNotifier(DatabaseService());
});


// Provider to get students filtered by Batch ID
final studentsByBatchProvider = Provider.family<AsyncValue<List<Student>>, String?>((ref, batchId) {
  final allStudentsAsync = ref.watch(studentListProvider); // Watch the main list provider
  return allStudentsAsync.when(
    data: (allStudents) {
      print("--- studentsByBatchProvider (Batch ID: $batchId): Filtering ${allStudents.length} students.");
      List<Student> filtered = (batchId == null)
          ? allStudents.where((s) => s.batchId == null).toList()
          : allStudents.where((s) => s.batchId == batchId).toList();
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      print("--- studentsByBatchProvider (Batch ID: $batchId): Returning ${filtered.length} students.");
      return AsyncValue.data(filtered); // Return filtered data
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});



// --- Providers for Add/Edit Student Form State ---
final editingStudentProvider = StateProvider<Student?>((ref) => null);
final studentNameControllerProvider = Provider.autoDispose<TextEditingController>((ref) { final student = ref.watch(editingStudentProvider); final controller = TextEditingController(text: student?.name ?? ''); ref.onDispose(controller.dispose); return controller; });
final studentParentNameControllerProvider = Provider.autoDispose<TextEditingController>((ref) { final student = ref.watch(editingStudentProvider); final controller = TextEditingController(text: student?.parentName ?? ''); ref.onDispose(controller.dispose); return controller; });
final studentMobile1ControllerProvider = Provider.autoDispose<TextEditingController>((ref) { final student = ref.watch(editingStudentProvider); final controller = TextEditingController(text: student?.mobile1 ?? ''); ref.onDispose(controller.dispose); return controller; });
final studentMobile2ControllerProvider = Provider.autoDispose<TextEditingController>((ref) { final student = ref.watch(editingStudentProvider); final controller = TextEditingController(text: student?.mobile2 ?? ''); ref.onDispose(controller.dispose); return controller; });
final studentWhatsappControllerProvider = Provider.autoDispose<TextEditingController>((ref) { final student = ref.watch(editingStudentProvider); final controller = TextEditingController(text: student?.whatsappNumber ?? ''); ref.onDispose(controller.dispose); return controller; });
final studentDobProvider = StateProvider.autoDispose<DateTime?>((ref) { final student = ref.watch(editingStudentProvider); return student?.dob; });
final studentIsWhatsappSameProvider = StateProvider.autoDispose<bool>((ref) { final student = ref.watch(editingStudentProvider); final mobile1 = student?.mobile1 ?? ''; final whatsapp = student?.whatsappNumber ?? ''; return mobile1.isNotEmpty && mobile1 == whatsapp; });
// Use the NON-STREAM batch list provider for the initial dropdown value
final studentSelectedBatchIdProvider = StateProvider.autoDispose<String?>((ref) {
  final student = ref.watch(editingStudentProvider);
  // Use batchListProvider here
  final availableBatches = ref.read(batchListProvider).valueOrNull ?? [];
  final existingBatchId = student?.batchId;
  if (existingBatchId != null && availableBatches.any((b) => b.id == existingBatchId)) { return existingBatchId; }
  return null;
});