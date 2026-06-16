// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeeHeadImpl _$$FeeHeadImplFromJson(Map<String, dynamic> json) =>
    _$FeeHeadImpl(
      head: json['head'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status:
          $enumDecodeNullable(_$FeeStatusEnumMap, json['status']) ??
          FeeStatus.PENDING,
    );

Map<String, dynamic> _$$FeeHeadImplToJson(_$FeeHeadImpl instance) =>
    <String, dynamic>{
      'head': instance.head,
      'amount': instance.amount,
      'dueDate': instance.dueDate.toIso8601String(),
      'status': _$FeeStatusEnumMap[instance.status]!,
    };

const _$FeeStatusEnumMap = {
  FeeStatus.PAID: 'PAID',
  FeeStatus.PENDING: 'PENDING',
  FeeStatus.PARTIAL: 'PARTIAL',
};

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      paymentId: json['paymentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      mode: $enumDecode(_$PaymentModeEnumMap, json['mode']),
      paidAt: DateTime.parse(json['paidAt'] as String),
      recordedBy: json['recordedBy'] as String,
      transactionRef: json['transactionRef'] as String? ?? '',
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'amount': instance.amount,
      'mode': _$PaymentModeEnumMap[instance.mode]!,
      'paidAt': instance.paidAt.toIso8601String(),
      'recordedBy': instance.recordedBy,
      'transactionRef': instance.transactionRef,
    };

const _$PaymentModeEnumMap = {
  PaymentMode.CASH: 'CASH',
  PaymentMode.CHEQUE: 'CHEQUE',
  PaymentMode.ONLINE: 'ONLINE',
};

_$FeeImpl _$$FeeImplFromJson(Map<String, dynamic> json) => _$FeeImpl(
  feeId: json['feeId'] as String,
  schoolId: json['schoolId'] as String,
  studentId: json['studentId'] as String,
  academicYear: json['academicYear'] as String,
  feeHeads:
      (json['feeHeads'] as List<dynamic>?)
          ?.map((e) => FeeHead.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  feeComponents:
      (json['feeComponents'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
  totalPending: (json['totalPending'] as num?)?.toDouble() ?? 0.0,
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$FeeImplToJson(_$FeeImpl instance) => <String, dynamic>{
  'feeId': instance.feeId,
  'schoolId': instance.schoolId,
  'studentId': instance.studentId,
  'academicYear': instance.academicYear,
  'feeHeads': instance.feeHeads,
  'feeComponents': instance.feeComponents,
  'totalAmount': instance.totalAmount,
  'totalPaid': instance.totalPaid,
  'totalPending': instance.totalPending,
  'payments': instance.payments,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
