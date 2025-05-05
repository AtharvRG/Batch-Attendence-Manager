// Constants related to the database structure

// Database Name
const String dbName = 'dance_tracker.db';
const int dbVersion = 1; // Increment this when schema changes require migration

// Table Names
const String tableBatches = 'batches';
const String tableStudents = 'students';
const String tableAttendance = 'attendance_records';
const String tableSettings = 'settings'; // For storing simple key-value settings

// Common Column Names used across tables
const String colId = 'id'; // TEXT PRIMARY KEY (usually UUID stored as TEXT)
const String colName = 'name'; // TEXT NOT NULL (for Batch, Student names)

// Batches Table Specific Columns
// Uses colId, colName

// Students Table Specific Columns
const String colDob = 'dob';                 // TEXT (Stores date as ISO8601 string: "YYYY-MM-DDTHH:mm:ss.sssZ")
const String colParentName = 'parentName';   // TEXT NOT NULL
const String colMobile1 = 'mobile1';         // TEXT NOT NULL
const String colMobile2 = 'mobile2';         // TEXT (Nullable)
const String colWhatsapp = 'whatsappNumber'; // TEXT (Nullable)
const String colBatchId = 'batchId';         // TEXT (Foreign Key to batches.id, Nullable)
const String colFeeStatus = 'monthlyFeeStatus'; // TEXT (Stores a JSON encoded Map<String, bool>)

// Attendance Table Specific Columns
const String colDate = 'date';               // TEXT (Stores date as "YYYY-MM-DD" string)
const String colStudentId = 'studentId';     // TEXT NOT NULL (Foreign Key to students.id)
// Also uses colBatchId                     // TEXT NOT NULL (Foreign Key to batches.id at the time of attendance)
const String colIsPresent = 'isPresent';     // INTEGER NOT NULL (Stores 1 for true, 0 for false)

// Settings Table Specific Columns
const String colSettingKey = 'key';         // TEXT PRIMARY KEY
const String colSettingValue = 'value';     // TEXT NOT NULL

// Specific Setting Keys stored in the Settings Table
const String settingThemeMode = 'themeMode';       // Stores ThemeMode index as string
const String settingColorSeed = 'colorSeedValue'; // Stores Color integer value as string