import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_record.g.dart'; // ONLY for json_serializable now

// REMOVED: @HiveType(typeId: 2)
@JsonSerializable()
class AttendanceRecord { // REMOVED: extends HiveObject
  // REMOVED: @HiveField(0)
  final String id;
  // REMOVED: @HiveField(1)
  final String date;
  // REMOVED: @HiveField(2)
  final String studentId;
  // REMOVED: @HiveField(3)
  final String batchId;
  // REMOVED: @HiveField(4)
  bool isPresent;

  AttendanceRecord({
    required this.date, required this.studentId, required this.batchId, required this.isPresent,
    String? id,
  }) : id = id ?? const Uuid().v4();

  // SQL Mapping
  Map<String, dynamic> toMap() { return { 'id': id, 'date': date, 'studentId': studentId, 'batchId': batchId, 'isPresent': isPresent ? 1 : 0, }; }
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) { if (map['id'] == null || map['date'] == null || map['studentId'] == null || map['batchId'] == null || map['isPresent'] == null) { throw const FormatException("AttendanceRecord.fromMap: Missing required fields."); } return AttendanceRecord( id: map['id'] as String, date: map['date'] as String, studentId: map['studentId'] as String, batchId: map['batchId'] as String, isPresent: (map['isPresent'] as int) == 1, ); }

  // JSON Serialization
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);

  // Helper Key Generator
  static String generateLookupKey(String date, String studentId) { return '${date}_$studentId'; }
}