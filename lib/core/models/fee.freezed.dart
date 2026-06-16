// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeeHead _$FeeHeadFromJson(Map<String, dynamic> json) {
  return _FeeHead.fromJson(json);
}

/// @nodoc
mixin _$FeeHead {
  String get head => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  FeeStatus get status => throw _privateConstructorUsedError;

  /// Serializes this FeeHead to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeHead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeHeadCopyWith<FeeHead> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeHeadCopyWith<$Res> {
  factory $FeeHeadCopyWith(FeeHead value, $Res Function(FeeHead) then) =
      _$FeeHeadCopyWithImpl<$Res, FeeHead>;
  @useResult
  $Res call({String head, double amount, DateTime dueDate, FeeStatus status});
}

/// @nodoc
class _$FeeHeadCopyWithImpl<$Res, $Val extends FeeHead>
    implements $FeeHeadCopyWith<$Res> {
  _$FeeHeadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeHead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? head = null,
    Object? amount = null,
    Object? dueDate = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            head: null == head
                ? _value.head
                : head // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FeeStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeHeadImplCopyWith<$Res> implements $FeeHeadCopyWith<$Res> {
  factory _$$FeeHeadImplCopyWith(
    _$FeeHeadImpl value,
    $Res Function(_$FeeHeadImpl) then,
  ) = __$$FeeHeadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String head, double amount, DateTime dueDate, FeeStatus status});
}

/// @nodoc
class __$$FeeHeadImplCopyWithImpl<$Res>
    extends _$FeeHeadCopyWithImpl<$Res, _$FeeHeadImpl>
    implements _$$FeeHeadImplCopyWith<$Res> {
  __$$FeeHeadImplCopyWithImpl(
    _$FeeHeadImpl _value,
    $Res Function(_$FeeHeadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeHead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? head = null,
    Object? amount = null,
    Object? dueDate = null,
    Object? status = null,
  }) {
    return _then(
      _$FeeHeadImpl(
        head: null == head
            ? _value.head
            : head // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FeeStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeHeadImpl implements _FeeHead {
  const _$FeeHeadImpl({
    required this.head,
    required this.amount,
    required this.dueDate,
    this.status = FeeStatus.PENDING,
  });

  factory _$FeeHeadImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeHeadImplFromJson(json);

  @override
  final String head;
  @override
  final double amount;
  @override
  final DateTime dueDate;
  @override
  @JsonKey()
  final FeeStatus status;

  @override
  String toString() {
    return 'FeeHead(head: $head, amount: $amount, dueDate: $dueDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeHeadImpl &&
            (identical(other.head, head) || other.head == head) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, head, amount, dueDate, status);

  /// Create a copy of FeeHead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeHeadImplCopyWith<_$FeeHeadImpl> get copyWith =>
      __$$FeeHeadImplCopyWithImpl<_$FeeHeadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeHeadImplToJson(this);
  }
}

abstract class _FeeHead implements FeeHead {
  const factory _FeeHead({
    required final String head,
    required final double amount,
    required final DateTime dueDate,
    final FeeStatus status,
  }) = _$FeeHeadImpl;

  factory _FeeHead.fromJson(Map<String, dynamic> json) = _$FeeHeadImpl.fromJson;

  @override
  String get head;
  @override
  double get amount;
  @override
  DateTime get dueDate;
  @override
  FeeStatus get status;

  /// Create a copy of FeeHead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeHeadImplCopyWith<_$FeeHeadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  String get paymentId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  PaymentMode get mode => throw _privateConstructorUsedError;
  DateTime get paidAt => throw _privateConstructorUsedError;
  String get recordedBy => throw _privateConstructorUsedError;
  String get transactionRef => throw _privateConstructorUsedError;

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call({
    String paymentId,
    double amount,
    PaymentMode mode,
    DateTime paidAt,
    String recordedBy,
    String transactionRef,
  });
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? amount = null,
    Object? mode = null,
    Object? paidAt = null,
    Object? recordedBy = null,
    Object? transactionRef = null,
  }) {
    return _then(
      _value.copyWith(
            paymentId: null == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as PaymentMode,
            paidAt: null == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            recordedBy: null == recordedBy
                ? _value.recordedBy
                : recordedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            transactionRef: null == transactionRef
                ? _value.transactionRef
                : transactionRef // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
    _$PaymentImpl value,
    $Res Function(_$PaymentImpl) then,
  ) = __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String paymentId,
    double amount,
    PaymentMode mode,
    DateTime paidAt,
    String recordedBy,
    String transactionRef,
  });
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
    _$PaymentImpl _value,
    $Res Function(_$PaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? amount = null,
    Object? mode = null,
    Object? paidAt = null,
    Object? recordedBy = null,
    Object? transactionRef = null,
  }) {
    return _then(
      _$PaymentImpl(
        paymentId: null == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as PaymentMode,
        paidAt: null == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        recordedBy: null == recordedBy
            ? _value.recordedBy
            : recordedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        transactionRef: null == transactionRef
            ? _value.transactionRef
            : transactionRef // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl({
    required this.paymentId,
    required this.amount,
    required this.mode,
    required this.paidAt,
    required this.recordedBy,
    this.transactionRef = '',
  });

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  @override
  final String paymentId;
  @override
  final double amount;
  @override
  final PaymentMode mode;
  @override
  final DateTime paidAt;
  @override
  final String recordedBy;
  @override
  @JsonKey()
  final String transactionRef;

  @override
  String toString() {
    return 'Payment(paymentId: $paymentId, amount: $amount, mode: $mode, paidAt: $paidAt, recordedBy: $recordedBy, transactionRef: $transactionRef)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.recordedBy, recordedBy) ||
                other.recordedBy == recordedBy) &&
            (identical(other.transactionRef, transactionRef) ||
                other.transactionRef == transactionRef));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    paymentId,
    amount,
    mode,
    paidAt,
    recordedBy,
    transactionRef,
  );

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(this);
  }
}

abstract class _Payment implements Payment {
  const factory _Payment({
    required final String paymentId,
    required final double amount,
    required final PaymentMode mode,
    required final DateTime paidAt,
    required final String recordedBy,
    final String transactionRef,
  }) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  @override
  String get paymentId;
  @override
  double get amount;
  @override
  PaymentMode get mode;
  @override
  DateTime get paidAt;
  @override
  String get recordedBy;
  @override
  String get transactionRef;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Fee _$FeeFromJson(Map<String, dynamic> json) {
  return _Fee.fromJson(json);
}

/// @nodoc
mixin _$Fee {
  String get feeId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get academicYear => throw _privateConstructorUsedError;
  List<FeeHead> get feeHeads => throw _privateConstructorUsedError;
  Map<String, double> get feeComponents => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  double get totalPaid => throw _privateConstructorUsedError;
  double get totalPending => throw _privateConstructorUsedError;
  List<Payment> get payments => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Fee to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Fee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeCopyWith<Fee> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeCopyWith<$Res> {
  factory $FeeCopyWith(Fee value, $Res Function(Fee) then) =
      _$FeeCopyWithImpl<$Res, Fee>;
  @useResult
  $Res call({
    String feeId,
    String schoolId,
    String studentId,
    String academicYear,
    List<FeeHead> feeHeads,
    Map<String, double> feeComponents,
    double totalAmount,
    double totalPaid,
    double totalPending,
    List<Payment> payments,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$FeeCopyWithImpl<$Res, $Val extends Fee> implements $FeeCopyWith<$Res> {
  _$FeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Fee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeId = null,
    Object? schoolId = null,
    Object? studentId = null,
    Object? academicYear = null,
    Object? feeHeads = null,
    Object? feeComponents = null,
    Object? totalAmount = null,
    Object? totalPaid = null,
    Object? totalPending = null,
    Object? payments = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            feeId: null == feeId
                ? _value.feeId
                : feeId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            academicYear: null == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String,
            feeHeads: null == feeHeads
                ? _value.feeHeads
                : feeHeads // ignore: cast_nullable_to_non_nullable
                      as List<FeeHead>,
            feeComponents: null == feeComponents
                ? _value.feeComponents
                : feeComponents // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPaid: null == totalPaid
                ? _value.totalPaid
                : totalPaid // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPending: null == totalPending
                ? _value.totalPending
                : totalPending // ignore: cast_nullable_to_non_nullable
                      as double,
            payments: null == payments
                ? _value.payments
                : payments // ignore: cast_nullable_to_non_nullable
                      as List<Payment>,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeeImplCopyWith<$Res> implements $FeeCopyWith<$Res> {
  factory _$$FeeImplCopyWith(_$FeeImpl value, $Res Function(_$FeeImpl) then) =
      __$$FeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String feeId,
    String schoolId,
    String studentId,
    String academicYear,
    List<FeeHead> feeHeads,
    Map<String, double> feeComponents,
    double totalAmount,
    double totalPaid,
    double totalPending,
    List<Payment> payments,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$FeeImplCopyWithImpl<$Res> extends _$FeeCopyWithImpl<$Res, _$FeeImpl>
    implements _$$FeeImplCopyWith<$Res> {
  __$$FeeImplCopyWithImpl(_$FeeImpl _value, $Res Function(_$FeeImpl) _then)
    : super(_value, _then);

  /// Create a copy of Fee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeId = null,
    Object? schoolId = null,
    Object? studentId = null,
    Object? academicYear = null,
    Object? feeHeads = null,
    Object? feeComponents = null,
    Object? totalAmount = null,
    Object? totalPaid = null,
    Object? totalPending = null,
    Object? payments = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$FeeImpl(
        feeId: null == feeId
            ? _value.feeId
            : feeId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        academicYear: null == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String,
        feeHeads: null == feeHeads
            ? _value._feeHeads
            : feeHeads // ignore: cast_nullable_to_non_nullable
                  as List<FeeHead>,
        feeComponents: null == feeComponents
            ? _value._feeComponents
            : feeComponents // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPaid: null == totalPaid
            ? _value.totalPaid
            : totalPaid // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPending: null == totalPending
            ? _value.totalPending
            : totalPending // ignore: cast_nullable_to_non_nullable
                  as double,
        payments: null == payments
            ? _value._payments
            : payments // ignore: cast_nullable_to_non_nullable
                  as List<Payment>,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeeImpl implements _Fee {
  const _$FeeImpl({
    required this.feeId,
    required this.schoolId,
    required this.studentId,
    required this.academicYear,
    final List<FeeHead> feeHeads = const [],
    final Map<String, double> feeComponents = const {},
    this.totalAmount = 0.0,
    this.totalPaid = 0.0,
    this.totalPending = 0.0,
    final List<Payment> payments = const [],
    this.updatedAt,
  }) : _feeHeads = feeHeads,
       _feeComponents = feeComponents,
       _payments = payments;

  factory _$FeeImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeImplFromJson(json);

  @override
  final String feeId;
  @override
  final String schoolId;
  @override
  final String studentId;
  @override
  final String academicYear;
  final List<FeeHead> _feeHeads;
  @override
  @JsonKey()
  List<FeeHead> get feeHeads {
    if (_feeHeads is EqualUnmodifiableListView) return _feeHeads;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feeHeads);
  }

  final Map<String, double> _feeComponents;
  @override
  @JsonKey()
  Map<String, double> get feeComponents {
    if (_feeComponents is EqualUnmodifiableMapView) return _feeComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_feeComponents);
  }

  @override
  @JsonKey()
  final double totalAmount;
  @override
  @JsonKey()
  final double totalPaid;
  @override
  @JsonKey()
  final double totalPending;
  final List<Payment> _payments;
  @override
  @JsonKey()
  List<Payment> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Fee(feeId: $feeId, schoolId: $schoolId, studentId: $studentId, academicYear: $academicYear, feeHeads: $feeHeads, feeComponents: $feeComponents, totalAmount: $totalAmount, totalPaid: $totalPaid, totalPending: $totalPending, payments: $payments, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeImpl &&
            (identical(other.feeId, feeId) || other.feeId == feeId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            const DeepCollectionEquality().equals(other._feeHeads, _feeHeads) &&
            const DeepCollectionEquality().equals(
              other._feeComponents,
              _feeComponents,
            ) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.totalPaid, totalPaid) ||
                other.totalPaid == totalPaid) &&
            (identical(other.totalPending, totalPending) ||
                other.totalPending == totalPending) &&
            const DeepCollectionEquality().equals(other._payments, _payments) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    feeId,
    schoolId,
    studentId,
    academicYear,
    const DeepCollectionEquality().hash(_feeHeads),
    const DeepCollectionEquality().hash(_feeComponents),
    totalAmount,
    totalPaid,
    totalPending,
    const DeepCollectionEquality().hash(_payments),
    updatedAt,
  );

  /// Create a copy of Fee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeImplCopyWith<_$FeeImpl> get copyWith =>
      __$$FeeImplCopyWithImpl<_$FeeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeImplToJson(this);
  }
}

abstract class _Fee implements Fee {
  const factory _Fee({
    required final String feeId,
    required final String schoolId,
    required final String studentId,
    required final String academicYear,
    final List<FeeHead> feeHeads,
    final Map<String, double> feeComponents,
    final double totalAmount,
    final double totalPaid,
    final double totalPending,
    final List<Payment> payments,
    final DateTime? updatedAt,
  }) = _$FeeImpl;

  factory _Fee.fromJson(Map<String, dynamic> json) = _$FeeImpl.fromJson;

  @override
  String get feeId;
  @override
  String get schoolId;
  @override
  String get studentId;
  @override
  String get academicYear;
  @override
  List<FeeHead> get feeHeads;
  @override
  Map<String, double> get feeComponents;
  @override
  double get totalAmount;
  @override
  double get totalPaid;
  @override
  double get totalPending;
  @override
  List<Payment> get payments;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Fee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeImplCopyWith<_$FeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
