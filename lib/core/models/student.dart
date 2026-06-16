import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    required String name,
    required String phone,
    @Default('') String relation,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}

@freezed
class MedicalHistory with _$MedicalHistory {
  const factory MedicalHistory({
    @Default('') String bloodGroup,
    @Default([]) List<String> allergies,
    @Default([]) List<String> conditions,
    @Default('') String vaccinationNotes,
    EmergencyContact? emergencyContact,
  }) = _MedicalHistory;

  factory MedicalHistory.fromJson(Map<String, dynamic> json) =>
      _$MedicalHistoryFromJson(json);
}

@freezed
class Student with _$Student {
  const factory Student({
    required String studentId,
    required String schoolId,
    required String classId,
    required String name,
    @Default('') String rollNo,
    @Default('') String admissionNo,
    @Default('') String dob,
    @Default('') String gender,
    @Default('') String address,
    @Default('') String photoUrl,
    required String parentUid,
    @Default(MedicalHistory()) MedicalHistory medicalHistory,
    @Default('2026-27') String academicYear,
    @Default(true) bool isActive,
    /// Free-text class label entered at registration (e.g. "Class 5A").
    @Default('') String admissionClass,
    DateTime? createdAt,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student.fromJson({
      ...data,
      'studentId': doc.id,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension StudentX on Student {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('studentId');
    if (createdAt != null) json['createdAt'] = Timestamp.fromDate(createdAt!);

    // The generated code (missing explicitToJson:true) does NOT call .toJson()
    // on nested Freezed objects — fix both levels manually here.
    final medJson = medicalHistory.toJson();
    if (medicalHistory.emergencyContact != null) {
      medJson['emergencyContact'] =
          medicalHistory.emergencyContact!.toJson();
    } else {
      medJson.remove('emergencyContact');
    }
    json['medicalHistory'] = medJson;

    return json;
  }
}