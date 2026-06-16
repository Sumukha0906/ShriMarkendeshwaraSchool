import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'school.freezed.dart';
part 'school.g.dart';

@freezed
class School with _$School {
  const factory School({
    required String schoolId,
    required String name,
    @Default('') String address,
    @Default('') String logoUrl,
    @Default('#065F46') String primaryColor,
    @Default('') String phone,
    @Default('') String email,
    @Default(true) bool isActive,
    @Default('2026-27') String academicYear,
    @Default('PREMIUM') String plan,
    DateTime? createdAt,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) =>
      _$SchoolFromJson(json);

  factory School.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return School.fromJson({
      ...data,
      'schoolId': doc.id,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension SchoolX on School {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('schoolId');
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    return json;
  }
}