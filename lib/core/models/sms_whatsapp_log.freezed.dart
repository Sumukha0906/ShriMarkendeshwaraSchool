// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sms_whatsapp_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SmsSender _$SmsSenderFromJson(Map<String, dynamic> json) {
  return _SmsSender.fromJson(json);
}

/// @nodoc
mixin _$SmsSender {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this SmsSender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmsSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmsSenderCopyWith<SmsSender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmsSenderCopyWith<$Res> {
  factory $SmsSenderCopyWith(SmsSender value, $Res Function(SmsSender) then) =
      _$SmsSenderCopyWithImpl<$Res, SmsSender>;
  @useResult
  $Res call({String uid, String name, String role});
}

/// @nodoc
class _$SmsSenderCopyWithImpl<$Res, $Val extends SmsSender>
    implements $SmsSenderCopyWith<$Res> {
  _$SmsSenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmsSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null, Object? role = null}) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmsSenderImplCopyWith<$Res>
    implements $SmsSenderCopyWith<$Res> {
  factory _$$SmsSenderImplCopyWith(
    _$SmsSenderImpl value,
    $Res Function(_$SmsSenderImpl) then,
  ) = __$$SmsSenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uid, String name, String role});
}

/// @nodoc
class __$$SmsSenderImplCopyWithImpl<$Res>
    extends _$SmsSenderCopyWithImpl<$Res, _$SmsSenderImpl>
    implements _$$SmsSenderImplCopyWith<$Res> {
  __$$SmsSenderImplCopyWithImpl(
    _$SmsSenderImpl _value,
    $Res Function(_$SmsSenderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmsSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null, Object? role = null}) {
    return _then(
      _$SmsSenderImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmsSenderImpl extends _SmsSender {
  const _$SmsSenderImpl({
    required this.uid,
    required this.name,
    required this.role,
  }) : super._();

  factory _$SmsSenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmsSenderImplFromJson(json);

  @override
  final String uid;
  @override
  final String name;
  @override
  final String role;

  @override
  String toString() {
    return 'SmsSender(uid: $uid, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmsSenderImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, name, role);

  /// Create a copy of SmsSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmsSenderImplCopyWith<_$SmsSenderImpl> get copyWith =>
      __$$SmsSenderImplCopyWithImpl<_$SmsSenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmsSenderImplToJson(this);
  }
}

abstract class _SmsSender extends SmsSender {
  const factory _SmsSender({
    required final String uid,
    required final String name,
    required final String role,
  }) = _$SmsSenderImpl;
  const _SmsSender._() : super._();

  factory _SmsSender.fromJson(Map<String, dynamic> json) =
      _$SmsSenderImpl.fromJson;

  @override
  String get uid;
  @override
  String get name;
  @override
  String get role;

  /// Create a copy of SmsSender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmsSenderImplCopyWith<_$SmsSenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SmsRecipient _$SmsRecipientFromJson(Map<String, dynamic> json) {
  return _SmsRecipient.fromJson(json);
}

/// @nodoc
mixin _$SmsRecipient {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  /// Serializes this SmsRecipient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmsRecipient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmsRecipientCopyWith<SmsRecipient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmsRecipientCopyWith<$Res> {
  factory $SmsRecipientCopyWith(
    SmsRecipient value,
    $Res Function(SmsRecipient) then,
  ) = _$SmsRecipientCopyWithImpl<$Res, SmsRecipient>;
  @useResult
  $Res call({String uid, String name, String phone});
}

/// @nodoc
class _$SmsRecipientCopyWithImpl<$Res, $Val extends SmsRecipient>
    implements $SmsRecipientCopyWith<$Res> {
  _$SmsRecipientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmsRecipient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null, Object? phone = null}) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmsRecipientImplCopyWith<$Res>
    implements $SmsRecipientCopyWith<$Res> {
  factory _$$SmsRecipientImplCopyWith(
    _$SmsRecipientImpl value,
    $Res Function(_$SmsRecipientImpl) then,
  ) = __$$SmsRecipientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uid, String name, String phone});
}

/// @nodoc
class __$$SmsRecipientImplCopyWithImpl<$Res>
    extends _$SmsRecipientCopyWithImpl<$Res, _$SmsRecipientImpl>
    implements _$$SmsRecipientImplCopyWith<$Res> {
  __$$SmsRecipientImplCopyWithImpl(
    _$SmsRecipientImpl _value,
    $Res Function(_$SmsRecipientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmsRecipient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null, Object? phone = null}) {
    return _then(
      _$SmsRecipientImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmsRecipientImpl extends _SmsRecipient {
  const _$SmsRecipientImpl({
    this.uid = '',
    required this.name,
    required this.phone,
  }) : super._();

  factory _$SmsRecipientImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmsRecipientImplFromJson(json);

  @override
  @JsonKey()
  final String uid;
  @override
  final String name;
  @override
  final String phone;

  @override
  String toString() {
    return 'SmsRecipient(uid: $uid, name: $name, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmsRecipientImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, name, phone);

  /// Create a copy of SmsRecipient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmsRecipientImplCopyWith<_$SmsRecipientImpl> get copyWith =>
      __$$SmsRecipientImplCopyWithImpl<_$SmsRecipientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmsRecipientImplToJson(this);
  }
}

abstract class _SmsRecipient extends SmsRecipient {
  const factory _SmsRecipient({
    final String uid,
    required final String name,
    required final String phone,
  }) = _$SmsRecipientImpl;
  const _SmsRecipient._() : super._();

  factory _SmsRecipient.fromJson(Map<String, dynamic> json) =
      _$SmsRecipientImpl.fromJson;

  @override
  String get uid;
  @override
  String get name;
  @override
  String get phone;

  /// Create a copy of SmsRecipient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmsRecipientImplCopyWith<_$SmsRecipientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SmsWhatsappLog _$SmsWhatsappLogFromJson(Map<String, dynamic> json) {
  return _SmsWhatsappLog.fromJson(json);
}

/// @nodoc
mixin _$SmsWhatsappLog {
  String get logId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  SmsSender get sentBy => throw _privateConstructorUsedError;
  SmsRecipient get recipient => throw _privateConstructorUsedError;
  SmsChannel get channel => throw _privateConstructorUsedError;
  SmsMessageType get messageType => throw _privateConstructorUsedError;
  String get messagePreview => throw _privateConstructorUsedError;
  SmsStatus get status => throw _privateConstructorUsedError;
  String get failureReason => throw _privateConstructorUsedError;
  String get linkedEntityId => throw _privateConstructorUsedError;
  String get linkedEntityType => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SmsWhatsappLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmsWhatsappLogCopyWith<SmsWhatsappLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmsWhatsappLogCopyWith<$Res> {
  factory $SmsWhatsappLogCopyWith(
    SmsWhatsappLog value,
    $Res Function(SmsWhatsappLog) then,
  ) = _$SmsWhatsappLogCopyWithImpl<$Res, SmsWhatsappLog>;
  @useResult
  $Res call({
    String logId,
    String schoolId,
    SmsSender sentBy,
    SmsRecipient recipient,
    SmsChannel channel,
    SmsMessageType messageType,
    String messagePreview,
    SmsStatus status,
    String failureReason,
    String linkedEntityId,
    String linkedEntityType,
    DateTime? sentAt,
    DateTime? createdAt,
  });

  $SmsSenderCopyWith<$Res> get sentBy;
  $SmsRecipientCopyWith<$Res> get recipient;
}

/// @nodoc
class _$SmsWhatsappLogCopyWithImpl<$Res, $Val extends SmsWhatsappLog>
    implements $SmsWhatsappLogCopyWith<$Res> {
  _$SmsWhatsappLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? schoolId = null,
    Object? sentBy = null,
    Object? recipient = null,
    Object? channel = null,
    Object? messageType = null,
    Object? messagePreview = null,
    Object? status = null,
    Object? failureReason = null,
    Object? linkedEntityId = null,
    Object? linkedEntityType = null,
    Object? sentAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            logId: null == logId
                ? _value.logId
                : logId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            sentBy: null == sentBy
                ? _value.sentBy
                : sentBy // ignore: cast_nullable_to_non_nullable
                      as SmsSender,
            recipient: null == recipient
                ? _value.recipient
                : recipient // ignore: cast_nullable_to_non_nullable
                      as SmsRecipient,
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as SmsChannel,
            messageType: null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as SmsMessageType,
            messagePreview: null == messagePreview
                ? _value.messagePreview
                : messagePreview // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SmsStatus,
            failureReason: null == failureReason
                ? _value.failureReason
                : failureReason // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedEntityId: null == linkedEntityId
                ? _value.linkedEntityId
                : linkedEntityId // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedEntityType: null == linkedEntityType
                ? _value.linkedEntityType
                : linkedEntityType // ignore: cast_nullable_to_non_nullable
                      as String,
            sentAt: freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SmsSenderCopyWith<$Res> get sentBy {
    return $SmsSenderCopyWith<$Res>(_value.sentBy, (value) {
      return _then(_value.copyWith(sentBy: value) as $Val);
    });
  }

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SmsRecipientCopyWith<$Res> get recipient {
    return $SmsRecipientCopyWith<$Res>(_value.recipient, (value) {
      return _then(_value.copyWith(recipient: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SmsWhatsappLogImplCopyWith<$Res>
    implements $SmsWhatsappLogCopyWith<$Res> {
  factory _$$SmsWhatsappLogImplCopyWith(
    _$SmsWhatsappLogImpl value,
    $Res Function(_$SmsWhatsappLogImpl) then,
  ) = __$$SmsWhatsappLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String logId,
    String schoolId,
    SmsSender sentBy,
    SmsRecipient recipient,
    SmsChannel channel,
    SmsMessageType messageType,
    String messagePreview,
    SmsStatus status,
    String failureReason,
    String linkedEntityId,
    String linkedEntityType,
    DateTime? sentAt,
    DateTime? createdAt,
  });

  @override
  $SmsSenderCopyWith<$Res> get sentBy;
  @override
  $SmsRecipientCopyWith<$Res> get recipient;
}

/// @nodoc
class __$$SmsWhatsappLogImplCopyWithImpl<$Res>
    extends _$SmsWhatsappLogCopyWithImpl<$Res, _$SmsWhatsappLogImpl>
    implements _$$SmsWhatsappLogImplCopyWith<$Res> {
  __$$SmsWhatsappLogImplCopyWithImpl(
    _$SmsWhatsappLogImpl _value,
    $Res Function(_$SmsWhatsappLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? schoolId = null,
    Object? sentBy = null,
    Object? recipient = null,
    Object? channel = null,
    Object? messageType = null,
    Object? messagePreview = null,
    Object? status = null,
    Object? failureReason = null,
    Object? linkedEntityId = null,
    Object? linkedEntityType = null,
    Object? sentAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SmsWhatsappLogImpl(
        logId: null == logId
            ? _value.logId
            : logId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        sentBy: null == sentBy
            ? _value.sentBy
            : sentBy // ignore: cast_nullable_to_non_nullable
                  as SmsSender,
        recipient: null == recipient
            ? _value.recipient
            : recipient // ignore: cast_nullable_to_non_nullable
                  as SmsRecipient,
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as SmsChannel,
        messageType: null == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as SmsMessageType,
        messagePreview: null == messagePreview
            ? _value.messagePreview
            : messagePreview // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SmsStatus,
        failureReason: null == failureReason
            ? _value.failureReason
            : failureReason // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedEntityId: null == linkedEntityId
            ? _value.linkedEntityId
            : linkedEntityId // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedEntityType: null == linkedEntityType
            ? _value.linkedEntityType
            : linkedEntityType // ignore: cast_nullable_to_non_nullable
                  as String,
        sentAt: freezed == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmsWhatsappLogImpl extends _SmsWhatsappLog {
  const _$SmsWhatsappLogImpl({
    required this.logId,
    required this.schoolId,
    required this.sentBy,
    required this.recipient,
    required this.channel,
    required this.messageType,
    required this.messagePreview,
    this.status = SmsStatus.PENDING,
    this.failureReason = '',
    this.linkedEntityId = '',
    this.linkedEntityType = '',
    this.sentAt,
    this.createdAt,
  }) : super._();

  factory _$SmsWhatsappLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmsWhatsappLogImplFromJson(json);

  @override
  final String logId;
  @override
  final String schoolId;
  @override
  final SmsSender sentBy;
  @override
  final SmsRecipient recipient;
  @override
  final SmsChannel channel;
  @override
  final SmsMessageType messageType;
  @override
  final String messagePreview;
  @override
  @JsonKey()
  final SmsStatus status;
  @override
  @JsonKey()
  final String failureReason;
  @override
  @JsonKey()
  final String linkedEntityId;
  @override
  @JsonKey()
  final String linkedEntityType;
  @override
  final DateTime? sentAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SmsWhatsappLog(logId: $logId, schoolId: $schoolId, sentBy: $sentBy, recipient: $recipient, channel: $channel, messageType: $messageType, messagePreview: $messagePreview, status: $status, failureReason: $failureReason, linkedEntityId: $linkedEntityId, linkedEntityType: $linkedEntityType, sentAt: $sentAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmsWhatsappLogImpl &&
            (identical(other.logId, logId) || other.logId == logId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.sentBy, sentBy) || other.sentBy == sentBy) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.messagePreview, messagePreview) ||
                other.messagePreview == messagePreview) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.linkedEntityId, linkedEntityId) ||
                other.linkedEntityId == linkedEntityId) &&
            (identical(other.linkedEntityType, linkedEntityType) ||
                other.linkedEntityType == linkedEntityType) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    logId,
    schoolId,
    sentBy,
    recipient,
    channel,
    messageType,
    messagePreview,
    status,
    failureReason,
    linkedEntityId,
    linkedEntityType,
    sentAt,
    createdAt,
  );

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmsWhatsappLogImplCopyWith<_$SmsWhatsappLogImpl> get copyWith =>
      __$$SmsWhatsappLogImplCopyWithImpl<_$SmsWhatsappLogImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SmsWhatsappLogImplToJson(this);
  }
}

abstract class _SmsWhatsappLog extends SmsWhatsappLog {
  const factory _SmsWhatsappLog({
    required final String logId,
    required final String schoolId,
    required final SmsSender sentBy,
    required final SmsRecipient recipient,
    required final SmsChannel channel,
    required final SmsMessageType messageType,
    required final String messagePreview,
    final SmsStatus status,
    final String failureReason,
    final String linkedEntityId,
    final String linkedEntityType,
    final DateTime? sentAt,
    final DateTime? createdAt,
  }) = _$SmsWhatsappLogImpl;
  const _SmsWhatsappLog._() : super._();

  factory _SmsWhatsappLog.fromJson(Map<String, dynamic> json) =
      _$SmsWhatsappLogImpl.fromJson;

  @override
  String get logId;
  @override
  String get schoolId;
  @override
  SmsSender get sentBy;
  @override
  SmsRecipient get recipient;
  @override
  SmsChannel get channel;
  @override
  SmsMessageType get messageType;
  @override
  String get messagePreview;
  @override
  SmsStatus get status;
  @override
  String get failureReason;
  @override
  String get linkedEntityId;
  @override
  String get linkedEntityType;
  @override
  DateTime? get sentAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of SmsWhatsappLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmsWhatsappLogImplCopyWith<_$SmsWhatsappLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
