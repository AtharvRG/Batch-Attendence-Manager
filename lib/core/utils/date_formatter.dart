// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

// Utility class for consistent date formatting throughout the app.
class DateFormatter {

  // Example: Format for displaying dates in lists or subtitles (e.g., "Sep 5, 1998")
  static final DateFormat readableDateFormat = DateFormat.yMMMd();

  // Example: Format for storing dates as keys or in DB queries ("YYYY-MM-DD")
  static final DateFormat queryDateFormat = DateFormat('yyyy-MM-dd');

  // Example: Format for displaying month and year ("MMMM yyyy", e.g., "May 2024")
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');

  // Example: Format for database/key storage ("YYYY-MM")
  static final DateFormat yearMonthKeyFormat = DateFormat('yyyy-MM');

  // Example: Format for timestamps in exported filenames ("yyyyMMdd_HHmmss")
  static final DateFormat timestampFilenameFormat = DateFormat('yyyyMMdd_HHmmss');

  // Helper method to safely format a nullable DateTime using a specific formatter.
  // Returns a default string (like 'N/A') if the date is null or formatting fails.
  static String formatReadable(DateTime? date, {String defaultValue = 'N/A'}) {
    if (date == null) return defaultValue;
    try {
      return readableDateFormat.format(date);
    } catch (e) {
      print("Error formatting date with readableDateFormat: $e");
      return 'Invalid Date';
    }
  }

  // Helper method to safely format a nullable DateTime into "YYYY-MM-DD".
  static String formatForQuery(DateTime? date, {String defaultValue = ''}) {
    if (date == null) return defaultValue;
    try {
      return queryDateFormat.format(date);
    } catch (e) {
      print("Error formatting date with queryDateFormat: $e");
      return defaultValue; // Return empty string on error maybe?
    }
  }

  // Helper method to format month and year.
  static String formatMonthYear(DateTime? date, {String defaultValue = 'Unknown Month'}) {
    if (date == null) return defaultValue;
    try {
      return monthYearFormat.format(date);
    } catch (e) {
      print("Error formatting date with monthYearFormat: $e");
      return defaultValue;
    }
  }

// Add more helper methods for other formats as needed...
}