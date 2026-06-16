import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'fee.freezed.dart';
part 'fee.g.dart';

enum FeeStatus  { PAID, PENDING, PARTIAL }
enum PaymentMode { CASH, CHEQUE, ONLINE }

@freezed
class FeeHead with _$FeeHead {
  const factory FeeHead({
    required String head,
    required double amount,
    required DateTime dueDate,
    @Default(FeeStatus.PENDING) FeeStatus status,
  }) = _FeeHead;

  factory FeeHead.fromJson(Map<String, dynamic> json) =>
      _$FeeHeadFromJson(json);
}

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String paymentId,
    required double amount,
    required PaymentMode mode,
    required DateTime paidAt,
    required String recordedBy,
    @Default('') String transactionRef,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

@freezed
class Fee with _$Fee {
  const factory Fee({
    required String feeId,
    required String schoolId,
    required String studentId,
    required String academicYear,
    @Default([]) List<FeeHead> feeHeads,
    @Default({}) Map<String, double> feeComponents,
    @Default(0.0) double totalAmount,
    @Default(0.0) double totalPaid,
    @Default(0.0) double totalPending,
    @Default([]) List<Payment> payments,
    DateTime? updatedAt,
  }) = _Fee;

  factory Fee.fromJson(Map<String, dynamic> json) => _$FeeFromJson(json);

  factory Fee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Firestore stores fee breakdown as `components: [{name, amount}]`.
    // Map it to `feeComponents: {name: amount}` for the model.
    Map<String, double> resolvedComponents = {};
    if (data['feeComponents'] is Map) {
      resolvedComponents = Map<String, double>.from(
        (data['feeComponents'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      );
    } else if (data['components'] is List) {
      for (final c in data['components'] as List) {
        if (c is Map && c['name'] != null && c['amount'] != null) {
          resolvedComponents[c['name'].toString()] =
              (c['amount'] as num).toDouble();
        }
      }
    }

    // Sanitize payments — generated fromJson uses unguarded 'as String' casts
    final rawPayments = data['payments'];
    final safePayments = <Map<String, dynamic>>[];
    if (rawPayments is List) {
      for (final p in rawPayments) {
        if (p is Map) {
          final m = Map<String, dynamic>.from(p);
          safePayments.add({
            ...m,
            'paymentId':  m['paymentId']  ?? '',
            'recordedBy': m['recordedBy'] ?? '',
            'paidAt':     m['paidAt'] is Timestamp
                ? (m['paidAt'] as Timestamp).toDate().toIso8601String()
                : (m['paidAt']?.toString() ?? DateTime.now().toIso8601String()),
            'amount':     m['amount']     ?? 0,
            'mode':       m['mode']       ?? 'CASH',
          });
        }
      }
    }

    // Sanitize feeHeads — 'head' and 'dueDate' are required Strings
    final rawFeeHeads = data['feeHeads'];
    final safeFeeHeads = <Map<String, dynamic>>[];
    if (rawFeeHeads is List) {
      for (final h in rawFeeHeads) {
        if (h is Map) {
          final m = Map<String, dynamic>.from(h);
          safeFeeHeads.add({
            ...m,
            'head':    m['head']    ?? '',
            'dueDate': m['dueDate'] is Timestamp
                ? (m['dueDate'] as Timestamp).toDate().toIso8601String()
                : (m['dueDate']?.toString() ?? DateTime.now().toIso8601String()),
            'amount':  m['amount']  ?? 0,
          });
        }
      }
    }

    return Fee.fromJson({
      ...data,
      'feeId':         doc.id,
      'feeComponents': resolvedComponents,
      'updatedAt':     (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'studentId':     data['studentId']   ?? '',
      'academicYear':  data['academicYear'] ?? '',
      'schoolId':      data['schoolId']    ?? '',
      'payments':      safePayments,
      'feeHeads':      safeFeeHeads,
    });
  }
}

extension FeeX on Fee {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('feeId');
    if (updatedAt != null) json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    return json;
  }

  bool get isFullyPaid => totalPending <= 0;
}