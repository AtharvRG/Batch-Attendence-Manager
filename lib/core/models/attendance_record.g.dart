// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      date: json['date'] as String,
      studentId: json['studentId'] as String,
      batchId: json['batchId'] as String,
      isPresent: json['isPresent'] as bool,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'studentId': instance.studentId,
      'batchId': instance.batchId,
      'isPresent': instance.isPresent,
    };
