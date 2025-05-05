import 'dart:async';
import 'dart:io'; // Used for database path operations
import 'package:path/path.dart'; // For joining path components
import 'package:path_provider/path_provider.dart'; // To find the app's documents directory
// Import sqflite, hiding the 'Batch' class to avoid naming conflicts with our model
import 'package:sqflite/sqflite.dart' hide Batch;

// Import Project Models
import 'package:dance_class_tracker/core/models/batch.dart'; // Our Batch model
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/core/models/attendance_record.dart';
// Import Database Constants
import 'package:dance_class_tracker/core/constants/db_constants.dart';

// Service class to manage all SQLite database interactions
class DatabaseService {
  // Singleton pattern: Ensures only one instance of the database service exists.
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal(); // Private constructor for singleton

  // Static variable to cache the database instance once opened.
  static Database? _database;

  // Getter for the database instance. Initializes the database if it hasn't been already.
  Future<Database> get database async {
    if (_database != null) return _database!; // Return cached instance if available
    _database = await _initDatabase(); // Initialize if not cached
    return _database!;
  }

  // Initializes the SQLite database. Finds the path, opens the connection,
  // and creates/upgrades tables as needed.
  Future<Database> _initDatabase() async {
    print("--- DatabaseService: Initializing database '$dbName' version $dbVersion...");
    // Get the directory path for storing the database file.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName); // Construct the full path
    print("--- DatabaseService: Database path set to: $path");

    // --- Development Debugging Aid ---
    // Uncomment the following lines to delete the DB file on every app start
    // during development, ensuring a clean state. DO NOT use in production.
    // if (await File(path).exists()) {
    //   print("--- DatabaseService (DEBUG): DELETING existing database file.");
    //   await deleteDatabase(path);
    // }
    // --- End Debugging Aid ---

    // Open the database. If it doesn't exist, `onCreate` is called.
    // If it exists and version > current DB version, `onUpgrade` is called.
    return await openDatabase(
      path,
      version: dbVersion, // Set the database version for migration handling
      onCreate: _onCreate, // Function to run when DB is first created
      onUpgrade: _onUpgrade, // Function to run when DB version increases
      // onConfigure: _onConfigure, // Optional: Run config before onCreate/onUpgrade
    );
  }

  // Optional: Configure database connection (e.g., enable foreign keys)
  // Future<void> _onConfigure(Database db) async {
  //   print("--- DatabaseService: Configuring database (enabling foreign keys)...");
  //   await db.execute('PRAGMA foreign_keys = ON');
  // }

  // Called when the database is created for the first time.
  // Defines the schema by creating necessary tables.
  Future<void> _onCreate(Database db, int version) async {
    print("--- DatabaseService: Running _onCreate for database version $version...");
    // Use Batch operations for efficiency during creation
    var dbBatch = db.batch(); // Corrected: Get batch from 'db' instance

    // Create Batches Table
    dbBatch.execute('''
      CREATE TABLE $tableBatches (
        $colId TEXT PRIMARY KEY,
        $colName TEXT NOT NULL
      )
    ''');
    print("--- DatabaseService: SQL prepared for '$tableBatches'.");

    // Create Students Table with Foreign Key to Batches
    dbBatch.execute('''
      CREATE TABLE $tableStudents (
        $colId TEXT PRIMARY KEY,
        $colName TEXT NOT NULL,
        $colDob TEXT,
        $colParentName TEXT NOT NULL,
        $colMobile1 TEXT NOT NULL,
        $colMobile2 TEXT,
        $colWhatsapp TEXT,
        $colBatchId TEXT,
        $colFeeStatus TEXT,
        FOREIGN KEY ($colBatchId) REFERENCES $tableBatches($colId) ON DELETE SET NULL
      )
    ''');
    // ON DELETE SET NULL: If a batch is deleted, set student's batchId to NULL.
    print("--- DatabaseService: SQL prepared for '$tableStudents'.");

    // Create Attendance Records Table with Foreign Keys and UNIQUE constraint
    dbBatch.execute('''
      CREATE TABLE $tableAttendance (
        $colId TEXT PRIMARY KEY,
        $colDate TEXT NOT NULL,
        $colStudentId TEXT NOT NULL,
        $colBatchId TEXT NOT NULL,
        $colIsPresent INTEGER NOT NULL,
        FOREIGN KEY ($colStudentId) REFERENCES $tableStudents($colId) ON DELETE CASCADE,
        FOREIGN KEY ($colBatchId) REFERENCES $tableBatches($colId) ON DELETE CASCADE,
        UNIQUE ($colDate, $colStudentId)
      )
    ''');
    // ON DELETE CASCADE: If a student or batch is deleted, related attendance records are also deleted.
    // UNIQUE constraint: Prevents multiple attendance entries for the same student on the same day.
    print("--- DatabaseService: SQL prepared for '$tableAttendance'.");

    // Create Settings Table (Simple Key-Value)
    dbBatch.execute('''
       CREATE TABLE $tableSettings (
         $colSettingKey TEXT PRIMARY KEY,
         $colSettingValue TEXT NOT NULL
       )
     ''');
    print("--- DatabaseService: SQL prepared for '$tableSettings'.");

    // Commit all table creation statements in the batch
    await dbBatch.commit(noResult: true); // Use noResult: true for efficiency if results aren't needed
    print("--- DatabaseService: Database tables created successfully.");
  }

  // Called when the database version is increased during `openDatabase`.
  // Used for schema migrations (updating table structures).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("--- DatabaseService: Running _onUpgrade from version $oldVersion to $newVersion...");
    // Implement migration steps sequentially based on version changes
    // Example: If upgrading from version 1 to 2
    if (oldVersion < 2) {
      print("--- DatabaseService: Applying migration for v2...");
      // Example: Add a 'notes' column to the students table
      // await db.execute("ALTER TABLE $tableStudents ADD COLUMN notes TEXT;");
      print("--- DatabaseService: v2 migration applied (example).");
    }
    // Add more 'if (oldVersion < X)' blocks for subsequent versions
    print("--- DatabaseService: Database upgrade process complete.");
  }

  // Close the database connection.
  Future<void> close() async {
    final db = _database; // Reference the cached instance
    if (db != null && db.isOpen) {
      await db.close();
      _database = null; // Clear the cache upon closing
      print("--- DatabaseService: Database connection closed.");
    } else {
      print("--- DatabaseService: Database already closed or not initialized.");
    }
  }

  // ===========================================
  // CRUD Methods Implementation
  // ===========================================

  // --- Batches ---
  Future<int> insertBatch(Batch batch) async { final db = await database; print("--- DatabaseService: Inserting Batch ID: ${batch.id}, Name: ${batch.name}"); return await db.insert( tableBatches, batch.toMap(), conflictAlgorithm: ConflictAlgorithm.replace, ); }
  Future<List<Batch>> getAllBatches() async { final db = await database; final List<Map<String, dynamic>> maps = await db.query(tableBatches, orderBy: '$colName COLLATE NOCASE'); print("--- DatabaseService: Fetched ${maps.length} batches."); return List.generate(maps.length, (i) => Batch.fromMap(maps[i])); }
  Future<int> updateBatch(Batch batch) async { final db = await database; print("--- DatabaseService: Updating Batch ID: ${batch.id}, New Name: ${batch.name}"); return await db.update( tableBatches, batch.toMap(), where: '$colId = ?', whereArgs: [batch.id],); }
  Future<int> deleteBatch(String id) async { final db = await database; print("--- DatabaseService: Deleting Batch ID: $id"); int count = await db.delete( tableBatches, where: '$colId = ?', whereArgs: [id], ); print("--- DatabaseService: Deleted $count batch record(s) for ID: $id."); return count; }

  // --- Students ---
  Future<int> insertStudent(Student student) async { final db = await database; print("--- DatabaseService: Inserting Student ID: ${student.id}, Name: ${student.name}, BatchID: ${student.batchId}"); return await db.insert( tableStudents, student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace, ); }
  Future<List<Student>> getAllStudents() async { final db = await database; final List<Map<String, dynamic>> maps = await db.query(tableStudents, orderBy: '$colName COLLATE NOCASE'); print("--- DatabaseService: Fetched ${maps.length} students."); return List.generate(maps.length, (i) => Student.fromMap(maps[i])); }
  Future<int> updateStudent(Student student) async { final db = await database; print("--- DatabaseService: Updating Student ID: ${student.id}, Name: ${student.name}, BatchID: ${student.batchId}"); return await db.update( tableStudents, student.toMap(), where: '$colId = ?', whereArgs: [student.id],); }
  Future<int> deleteStudent(String id) async { final db = await database; print("--- DatabaseService: Deleting Student ID: $id (Cascade should delete related attendance)"); int count = await db.delete( tableStudents, where: '$colId = ?', whereArgs: [id], ); print("--- DatabaseService: Deleted $count student record(s) for ID: $id."); return count; }

  // --- Attendance ---
  Future<void> saveAttendance(AttendanceRecord record) async { final db = await database; print("--- DatabaseService: Saving Attendance - Date: ${record.date}, Student: ${record.studentId}, Present: ${record.isPresent}"); try { await db.insert( tableAttendance, record.toMap(), conflictAlgorithm: ConflictAlgorithm.fail, ); print("--- DatabaseService: Inserted new attendance record ID: ${record.id}."); } on DatabaseException catch (e) { if (e.isUniqueConstraintError()) { print("--- DatabaseService: Attendance record exists for Date/Student. Updating presence..."); await db.update( tableAttendance, {colIsPresent: record.isPresent ? 1 : 0}, where: '$colDate = ? AND $colStudentId = ?', whereArgs: [record.date, record.studentId], ); print("--- DatabaseService: Updated existing attendance record."); } else { print("--- DatabaseService: Database error saving attendance: $e"); rethrow; } } }
  Future<List<AttendanceRecord>> getAttendanceForDate(String date) async { final db = await database; final List<Map<String, dynamic>> maps = await db.query( tableAttendance, where: '$colDate = ?', whereArgs: [date], ); print("--- DatabaseService: Fetched ${maps.length} attendance records for Date: $date."); return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i])); }
  Future<List<AttendanceRecord>> getAttendanceForStudent(String studentId) async { final db = await database; final List<Map<String, dynamic>> maps = await db.query( tableAttendance, where: '$colStudentId = ?', whereArgs: [studentId], orderBy: '$colDate DESC', ); print("--- DatabaseService: Fetched ${maps.length} attendance records for Student: $studentId."); return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i])); }
  Future<List<AttendanceRecord>> getAllAttendanceRecords() async { final db = await database; final List<Map<String, dynamic>> maps = await db.query(tableAttendance, orderBy: '$colDate DESC, $colStudentId ASC'); print("--- DatabaseService: Fetched ${maps.length} total attendance records."); return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i])); }

  // --- Settings ---
  Future<void> saveSetting(String key, String value) async { final db = await database; print("--- DatabaseService: Saving Setting Key: $key, Value: $value"); await db.insert( tableSettings, {colSettingKey: key, colSettingValue: value}, conflictAlgorithm: ConflictAlgorithm.replace,); }
  Future<String?> getSetting(String key) async { final db = await database; final List<Map<String, dynamic>> maps = await db.query( tableSettings, columns: [colSettingValue], where: '$colSettingKey = ?', whereArgs: [key], limit: 1, ); if (maps.isNotEmpty) { final value = maps.first[colSettingValue] as String?; print("--- DatabaseService: Fetched Setting Key: $key, Value: $value"); return value; } print("--- DatabaseService: Setting Key: $key not found."); return null; }

  // --- Utility: Clear All Data ---
  Future<void> clearAllData() async { final db = await database; print("--- DatabaseService: WARNING - Clearing all data from tables..."); await db.delete(tableAttendance); await db.delete(tableStudents); await db.delete(tableBatches); await db.delete(tableSettings); print("--- DatabaseService: All app data cleared from DB."); }
}