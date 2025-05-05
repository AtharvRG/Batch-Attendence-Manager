// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      name: json['name'] as String,
      dob: Student._dateTimeFromJson(json['dob'] as String?),
      parentName: json['parentName'] as String,
      mobile1: json['mobile1'] as String,
      mobile2: json['mobile2'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      batchId: json['batchId'] as String?,
      id: json['id'] as String?,
    )..monthlyFeeStatus =
        Student._feeStatusFromJson(json['monthlyFeeStatus'] as String?);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dob': Student._dateTimeToJson(instance.dob),
      'parentName': instance.parentName,
      'mobile1': instance.mobile1,
      'mobile2': instance.mobile2,
      'whatsappNumber': instance.whatsappNumber,
      'batchId': instance.batchId,
      'monthlyFeeStatus': Student._feeStatusToJson(instance.monthlyFeeStatus),
    };
