import 'dart:convert'; // For jsonEncode/Decode
import 'dart:io'; // For File handling
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Provider for provider definition
import 'package:intl/intl.dart'; // For filename timestamp
import 'package:path_provider/path_provider.dart'; // To find storage paths
import 'package:share_plus/share_plus.dart'; // To share the exported file
import 'package:file_picker/file_picker.dart'; // To pick import file
// Use DatabaseService now
import 'package:dance_class_tracker/core/database/database_service.dart';
import 'package:dance_class_tracker/core/models/batch.dart';
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/core/models/attendance_record.dart';

// Data structure for combined export/import data
class ExportData {
  final DateTime exportTimestamp;
  final List<Map<String, dynamic>> batches;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> attendanceRecords;
  final int schemaVersion; // Add schema version for future compatibility

  ExportData({
    required this.exportTimestamp,
    required this.batches,
    required this.students,
    required this.attendanceRecords,
    this.schemaVersion = 1, // Current schema version
  });

  // Convert this object to a JSON map for encoding
  Map<String, dynamic> toJson() => {
    'exportTimestamp': exportTimestamp.toIso8601String(),
    'schemaVersion': schemaVersion, // Include version in export
    'batches': batches,
    'students': students,
    'attendanceRecords': attendanceRecords,
  };

  // Factory constructor to create ExportData from JSON map (used during import)
  factory ExportData.fromJson(Map<String, dynamic> json) {
    // --- Input Validation ---
    final requiredKeys = {'exportTimestamp', 'batches', 'students', 'attendanceRecords'};
    final missingKeys = requiredKeys.difference(json.keys.toSet());
    if (missingKeys.isNotEmpty) {
      throw FormatException("Invalid backup file structure: Missing required top-level keys: ${missingKeys.join(', ')}.");
    }
    if (json['batches'] is! List || json['students'] is! List || json['attendanceRecords'] is! List) {
      throw FormatException("Invalid backup file structure: 'batches', 'students', and 'attendanceRecords' must be lists.");
    }
    // --- End Validation ---

    try {
      // Safely cast lists and their elements
      final batchesList = (json['batches'] as List).map((item) => item as Map<String, dynamic>).toList();
      final studentsList = (json['students'] as List).map((item) => item as Map<String, dynamic>).toList();
      final attendanceList = (json['attendanceRecords'] as List).map((item) => item as Map<String, dynamic>).toList();

      return ExportData(
        exportTimestamp: DateTime.parse(json['exportTimestamp'] as String),
        schemaVersion: (json['schemaVersion'] as int?) ?? 1, // Default to 1 if missing
        batches: batchesList,
        students: studentsList,
        attendanceRecords: attendanceList,
      );
    } on TypeError catch (e) { // Catch errors during type casting
      throw FormatException("Invalid backup file data type. Check list contents. Details: $e");
    } on FormatException catch (e) { // Catch errors from DateTime.parse etc.
      throw FormatException("Invalid backup file data format: ${e.message}");
    } catch (e) { // Catch any other parsing errors
      throw FormatException("Error parsing backup file content: $e");
    }
  }
}

// Service class for handling data export and import operations
class ExportImportService {
  // Get singleton DB service instance
  final DatabaseService _dbService = DatabaseService();

  // --- Export Data to JSON File and Share ---
  Future<bool> exportDataToFile() async {
    try {
      print("--- ExportImportService: Starting data export from DB...");
      // 1. Fetch all data from the database service
      final batches = await _dbService.getAllBatches();
      final students = await _dbService.getAllStudents();
      final attendanceRecords = await _dbService.getAllAttendanceRecords(); // Use the new method

      // 2. Convert fetched objects to JSON maps using toJson() methods
      final batchDataMaps = batches.map((b) => b.toJson()).toList();
      final studentDataMaps = students.map((s) => s.toJson()).toList();
      final attendanceDataMaps = attendanceRecords.map((a) => a.toJson()).toList();

      print("--- ExportImportService: Data fetched: ${batchDataMaps.length} batches, ${studentDataMaps.length} students, ${attendanceDataMaps.length} attendance records.");

      // 3. Create the combined export data object (including schema version)
      final exportObject = ExportData(
        exportTimestamp: DateTime.now(),
        schemaVersion: 1, // Current schema version
        batches: batchDataMaps,
        students: studentDataMaps,
        attendanceRecords: attendanceDataMaps,
      );

      // 4. Encode the combined object to a JSON string with indentation
      const jsonEncoder = JsonEncoder.withIndent('  ');
      final jsonString = jsonEncoder.convert(exportObject.toJson());
      print("--- ExportImportService: JSON data encoded.");

      // 5. Write JSON string to a temporary file
      final directory = await getTemporaryDirectory(); // App's temporary cache dir
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'dance_class_backup_v${exportObject.schemaVersion}_$timestamp.json'; // Include version in filename
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);
      print("--- ExportImportService: Data written to temporary file: $filePath");

      // 6. Use share_plus to share the created file
      final xFile = XFile(filePath, mimeType: 'application/json');
      final shareResult = await Share.shareXFiles(
          [xFile],
          subject: 'Dance Class Backup $timestamp' // Subject for email/sharing apps
      );
      print("--- ExportImportService: Share sheet result status: ${shareResult.status}");

      // 7. Clean up the temporary file
      try {
        if (await file.exists()) { await file.delete(); print("--- ExportImportService: Deleted temporary file: $filePath"); }
      } catch (e) { print("--- ExportImportService: Error deleting temporary file: $e"); }

      print("--- ExportImportService: Export process completed.");
      return shareResult.status == ShareResultStatus.success || shareResult.status == ShareResultStatus.dismissed;

    } catch (e, s) { // Catch any errors during the export process
      print("--- ExportImportService: CRITICAL ERROR during data export: $e\n$s");
      return false; // Indicate failure
    }
  }


  // --- Import Data from Selected JSON File ---
  Future<bool> importDataFromFile() async {
    print("--- ExportImportService: Starting data import process...");
    // 1. Pick a single JSON file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Restrict selection to .json files
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      print("--- ExportImportService: File picking cancelled by user.");
      return false; // User cancelled
    }

    File file = File(result.files.single.path!);
    print("--- ExportImportService: File selected for import: ${file.path}");

    // --- CONFIRMATION is handled in UI layer ---

    try {
      // 2. Read File Content
      final String jsonString = await file.readAsString();

      // 3. Decode JSON String into a Dart Map
      final Map<String, dynamic> decodedJson = jsonDecode(jsonString);

      // 4. Validate Structure and Parse using ExportData factory
      final importData = ExportData.fromJson(decodedJson); // Throws FormatException on error
      print("--- ExportImportService: JSON decoded. Backup Version: ${importData.schemaVersion}, Timestamp: ${importData.exportTimestamp}");
      print("Import data contains: ${importData.batches.length} batches, ${importData.students.length} students, ${importData.attendanceRecords.length} attendance records.");

      // --- Optional: Schema Version Check ---
      // if (importData.schemaVersion > currentAppSchemaVersion) {
      //    throw Exception("Cannot import data from a newer app version.");
      // }
      // if (importData.schemaVersion < currentAppSchemaVersion) {
      //    // Handle migration FROM the older version if needed
      //    print("Warning: Importing older schema version. Data structure might differ slightly.");
      // }
      // --- End Schema Check ---

      // 5. Clear Existing Data using DB Service method
      print("--- ExportImportService: Clearing all existing application data...");
      await _dbService.clearAllData(); // This clears batches, students, attendance, settings
      print("--- ExportImportService: Existing data cleared successfully.");

      // 6. Parse and Insert New Data into Database
      print("--- ExportImportService: Parsing and inserting imported data...");

      // Insert Batches
      int batchesInserted = 0;
      for (final batchJson in importData.batches) {
        // Parse JSON map to Batch object, handle potential errors during parsing
        final batch = Batch.fromJson(batchJson);
        await _dbService.insertBatch(batch); // Use DB service to insert
        batchesInserted++;
      }
      print("--- ExportImportService: Inserted $batchesInserted batches.");

      // Insert Students
      int studentsInserted = 0;
      for (final studentJson in importData.students) {
        final student = Student.fromJson(studentJson);
        await _dbService.insertStudent(student);
        studentsInserted++;
      }
      print("--- ExportImportService: Inserted $studentsInserted students.");

      // Insert Attendance Records using the saveAttendance method (handles upsert)
      int attendanceSaved = 0;
      for (final attendanceJson in importData.attendanceRecords) {
        final record = AttendanceRecord.fromJson(attendanceJson);
        // saveAttendance handles potential UNIQUE constraint violations gracefully
        await _dbService.saveAttendance(record);
        attendanceSaved++;
      }
      print("--- ExportImportService: Saved/Updated $attendanceSaved attendance records.");

      // Note: Settings are not typically part of data backup/restore,
      // unless explicitly included in ExportData and handled here.

      // 7. Success
      print("--- ExportImportService: Data import process completed successfully.");
      return true; // Indicate success

    } on FormatException catch (e) { // Catch specific JSON format/parsing errors
      print("--- ExportImportService: Import Error (FormatException): $e");
      // Rethrow a message suitable for the UI
      throw Exception("Import failed due to invalid file format or data. Please check the selected file.\nDetails: $e");
    } catch (e, s) { // Catch any other unexpected errors during import
      print("--- ExportImportService: Import Error (General): $e\n$s");
      throw Exception("Import failed due to an unexpected error: $e");
    }
  }
}

// Riverpod Provider for the service instance
final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  return ExportImportService();
});