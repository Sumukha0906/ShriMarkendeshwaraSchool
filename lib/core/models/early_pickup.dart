import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'early_pickup.freezed.dart';
part 'early_pickup.g.dart';

enum PickupStatus { PENDING, APPROVED, REJECTED, COMPLETED }

@freezed
class CollectorDetails with _$CollectorDetails {
  const CollectorDetails._();
  const factory CollectorDetails({
    required String name,
    required String relation,
    required String phone,
    @Default('') String photoUrl,
  }) = _CollectorDetails;

  factory CollectorDetails.fromJson(Map<String, dynamic> json) =>
      _$CollectorDetailsFromJson(json);
}

@freezed
class EarlyPickup with _$EarlyPickup {
  const EarlyPickup._();
  const factory EarlyPickup({
    required String requestId,
    required String schoolId,
    required String classId,
    required String studentId,
    required String parentUid,
    @Default('') String studentName,
    required DateTime pickupTime,
    required String reason,
    required CollectorDetails collectorDetails,
    @Default(PickupStatus.PENDING) PickupStatus status,
    @Default('') String approvedBy,
    DateTime? approvedAt,
    DateTime? exitLoggedAt,
    DateTime? createdAt,
  }) = _EarlyPickup;

  factory EarlyPickup.fromJson(Map<String, dynamic> json) =>
      _$EarlyPickupFromJson(json);

  factory EarlyPickup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EarlyPickup.fromJson({
      ...data,
      'requestId':    doc.id,
      'pickupTime':   (data['pickupTime']   as Timestamp).toDate().toIso8601String(),
      'approvedAt':   (data['approvedAt']   as Timestamp?)?.toDate().toIso8601String(),
      'exitLoggedAt': (data['exitLoggedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt':    (data['createdAt']    as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('requestId');
    json['collectorDetails'] = collectorDetails.toJson(); // explicit fix
    json['pickupTime'] = Timestamp.fromDate(pickupTime);
    if (approvedAt != null)   json['approvedAt']   = Timestamp.fromDate(approvedAt!);
    if (exitLoggedAt != null) json['exitLoggedAt'] = Timestamp.fromDate(exitLoggedAt!);
    if (createdAt != null)    json['createdAt']    = Timestamp.fromDate(createdAt!);
    return json;
  }
}