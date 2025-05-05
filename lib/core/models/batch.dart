import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'batch.g.dart'; // ONLY for json_serializable now

// REMOVED: @HiveType(typeId: 0)
@JsonSerializable()
class Batch { // REMOVED: extends HiveObject
  // REMOVED: @HiveField(0)
  final String id; // NOTE: Keep @override final String id; if you used it for JsonKey in previous step, else remove override
  // REMOVED: @HiveField(1)
  String name;

  Batch({required this.name, String? id}) : id = id ?? const Uuid().v4();

  // --- SQL Mapping ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
  factory Batch.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['name'] == null) { throw const FormatException("Batch.fromMap: Missing required fields."); }
    return Batch(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  // --- JSON Serialization ---
  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);
  Map<String, dynamic> toJson() => _$BatchToJson(this);

  // --- CopyWith ---
  Batch copyWith({String? name}) {
    return Batch(
      id: id, // Keep original ID
      name: name ?? this.name,
    );
  }
}