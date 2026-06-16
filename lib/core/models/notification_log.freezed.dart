// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationActor _$NotificationActorFromJson(Map<String, dynamic> json) {
  return _NotificationActor.fromJson(json);
}

/// @nodoc
mixin _$NotificationActor {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this NotificationActor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationActor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationActorCopyWith<NotificationActor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationActorCopyWith<$Res> {
  factory $NotificationActorCopyWith(
    NotificationActor value,
    $Res Function(NotificationActor) then,
  ) = _$NotificationActorCopyWithImpl<$Res, NotificationActor>;
  @useResult
  $Res call({String uid, String name, String role});
}

/// @nodoc
class _$NotificationActorCopyWithImpl<$Res, $Val extends NotificationActor>
    implements $NotificationActorCopyWith<$Res> {
  _$NotificationActorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationActor
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
abstract class _$$NotificationActorImplCopyWith<$Res>
    implements $NotificationActorCopyWith<$Res> {
  factory _$$NotificationActorImplCopyWith(
    _$NotificationActorImpl value,
    $Res Function(_$NotificationActorImpl) then,
  ) = __$$NotificationActorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uid, String name, String role});
}

/// @nodoc
class __$$NotificationActorImplCopyWithImpl<$Res>
    extends _$NotificationActorCopyWithImpl<$Res, _$NotificationActorImpl>
    implements _$$NotificationActorImplCopyWith<$Res> {
  __$$NotificationActorImplCopyWithImpl(
    _$NotificationActorImpl _value,
    $Res Function(_$NotificationActorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationActor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uid = null, Object? name = null, Object? role = null}) {
    return _then(
      _$NotificationActorImpl(
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
class _$NotificationActorImpl extends _NotificationActor {
  const _$NotificationActorImpl({
    required this.uid,
    required this.name,
    required this.role,
  }) : super._();

  factory _$NotificationActorImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationActorImplFromJson(json);

  @override
  final String uid;
  @override
  final String name;
  @override
  final String role;

  @override
  String toString() {
    return 'NotificationActor(uid: $uid, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationActorImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, name, role);

  /// Create a copy of NotificationActor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationActorImplCopyWith<_$NotificationActorImpl> get copyWith =>
      __$$NotificationActorImplCopyWithImpl<_$NotificationActorImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationActorImplToJson(this);
  }
}

abstract class _NotificationActor extends NotificationActor {
  const factory _NotificationActor({
    required final String uid,
    required final String name,
    required final String role,
  }) = _$NotificationActorImpl;
  const _NotificationActor._() : super._();

  factory _NotificationActor.fromJson(Map<String, dynamic> json) =
      _$NotificationActorImpl.fromJson;

  @override
  String get uid;
  @override
  String get name;
  @override
  String get role;

  /// Create a copy of NotificationActor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationActorImplCopyWith<_$NotificationActorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationAudience _$NotificationAudienceFromJson(Map<String, dynamic> json) {
  return _NotificationAudience.fromJson(json);
}

/// @nodoc
mixin _$NotificationAudience {
  NotificationAudienceType get type => throw _privateConstructorUsedError;
  String get classId => throw _privateConstructorUsedError;
  List<String> get targetUids => throw _privateConstructorUsedError;
  int get recipientCount => throw _privateConstructorUsedError;

  /// Serializes this NotificationAudience to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAudience
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationAudienceCopyWith<NotificationAudience> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationAudienceCopyWith<$Res> {
  factory $NotificationAudienceCopyWith(
    NotificationAudience value,
    $Res Function(NotificationAudience) then,
  ) = _$NotificationAudienceCopyWithImpl<$Res, NotificationAudience>;
  @useResult
  $Res call({
    NotificationAudienceType type,
    String classId,
    List<String> targetUids,
    int recipientCount,
  });
}

/// @nodoc
class _$NotificationAudienceCopyWithImpl<
  $Res,
  $Val extends NotificationAudience
>
    implements $NotificationAudienceCopyWith<$Res> {
  _$NotificationAudienceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAudience
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? classId = null,
    Object? targetUids = null,
    Object? recipientCount = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationAudienceType,
            classId: null == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String,
            targetUids: null == targetUids
                ? _value.targetUids
                : targetUids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            recipientCount: null == recipientCount
                ? _value.recipientCount
                : recipientCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationAudienceImplCopyWith<$Res>
    implements $NotificationAudienceCopyWith<$Res> {
  factory _$$NotificationAudienceImplCopyWith(
    _$NotificationAudienceImpl value,
    $Res Function(_$NotificationAudienceImpl) then,
  ) = __$$NotificationAudienceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    NotificationAudienceType type,
    String classId,
    List<String> targetUids,
    int recipientCount,
  });
}

/// @nodoc
class __$$NotificationAudienceImplCopyWithImpl<$Res>
    extends _$NotificationAudienceCopyWithImpl<$Res, _$NotificationAudienceImpl>
    implements _$$NotificationAudienceImplCopyWith<$Res> {
  __$$NotificationAudienceImplCopyWithImpl(
    _$NotificationAudienceImpl _value,
    $Res Function(_$NotificationAudienceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationAudience
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? classId = null,
    Object? targetUids = null,
    Object? recipientCount = null,
  }) {
    return _then(
      _$NotificationAudienceImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationAudienceType,
        classId: null == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String,
        targetUids: null == targetUids
            ? _value._targetUids
            : targetUids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        recipientCount: null == recipientCount
            ? _value.recipientCount
            : recipientCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationAudienceImpl extends _NotificationAudience {
  const _$NotificationAudienceImpl({
    required this.type,
    this.classId = '',
    final List<String> targetUids = const [],
    this.recipientCount = 0,
  }) : _targetUids = targetUids,
       super._();

  factory _$NotificationAudienceImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationAudienceImplFromJson(json);

  @override
  final NotificationAudienceType type;
  @override
  @JsonKey()
  final String classId;
  final List<String> _targetUids;
  @override
  @JsonKey()
  List<String> get targetUids {
    if (_targetUids is EqualUnmodifiableListView) return _targetUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetUids);
  }

  @override
  @JsonKey()
  final int recipientCount;

  @override
  String toString() {
    return 'NotificationAudience(type: $type, classId: $classId, targetUids: $targetUids, recipientCount: $recipientCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationAudienceImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            const DeepCollectionEquality().equals(
              other._targetUids,
              _targetUids,
            ) &&
            (identical(other.recipientCount, recipientCount) ||
                other.recipientCount == recipientCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    classId,
    const DeepCollectionEquality().hash(_targetUids),
    recipientCount,
  );

  /// Create a copy of NotificationAudience
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationAudienceImplCopyWith<_$NotificationAudienceImpl>
  get copyWith =>
      __$$NotificationAudienceImplCopyWithImpl<_$NotificationAudienceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationAudienceImplToJson(this);
  }
}

abstract class _NotificationAudience extends NotificationAudience {
  const factory _NotificationAudience({
    required final NotificationAudienceType type,
    final String classId,
    final List<String> targetUids,
    final int recipientCount,
  }) = _$NotificationAudienceImpl;
  const _NotificationAudience._() : super._();

  factory _NotificationAudience.fromJson(Map<String, dynamic> json) =
      _$NotificationAudienceImpl.fromJson;

  @override
  NotificationAudienceType get type;
  @override
  String get classId;
  @override
  List<String> get targetUids;
  @override
  int get recipientCount;

  /// Create a copy of NotificationAudience
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationAudienceImplCopyWith<_$NotificationAudienceImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DeliveryStats _$DeliveryStatsFromJson(Map<String, dynamic> json) {
  return _DeliveryStats.fromJson(json);
}

/// @nodoc
mixin _$DeliveryStats {
  int get sent => throw _privateConstructorUsedError;
  int get failed => throw _privateConstructorUsedError;
  int get opened => throw _privateConstructorUsedError;

  /// Serializes this DeliveryStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryStatsCopyWith<DeliveryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryStatsCopyWith<$Res> {
  factory $DeliveryStatsCopyWith(
    DeliveryStats value,
    $Res Function(DeliveryStats) then,
  ) = _$DeliveryStatsCopyWithImpl<$Res, DeliveryStats>;
  @useResult
  $Res call({int sent, int failed, int opened});
}

/// @nodoc
class _$DeliveryStatsCopyWithImpl<$Res, $Val extends DeliveryStats>
    implements $DeliveryStatsCopyWith<$Res> {
  _$DeliveryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sent = null,
    Object? failed = null,
    Object? opened = null,
  }) {
    return _then(
      _value.copyWith(
            sent: null == sent
                ? _value.sent
                : sent // ignore: cast_nullable_to_non_nullable
                      as int,
            failed: null == failed
                ? _value.failed
                : failed // ignore: cast_nullable_to_non_nullable
                      as int,
            opened: null == opened
                ? _value.opened
                : opened // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryStatsImplCopyWith<$Res>
    implements $DeliveryStatsCopyWith<$Res> {
  factory _$$DeliveryStatsImplCopyWith(
    _$DeliveryStatsImpl value,
    $Res Function(_$DeliveryStatsImpl) then,
  ) = __$$DeliveryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int sent, int failed, int opened});
}

/// @nodoc
class __$$DeliveryStatsImplCopyWithImpl<$Res>
    extends _$DeliveryStatsCopyWithImpl<$Res, _$DeliveryStatsImpl>
    implements _$$DeliveryStatsImplCopyWith<$Res> {
  __$$DeliveryStatsImplCopyWithImpl(
    _$DeliveryStatsImpl _value,
    $Res Function(_$DeliveryStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sent = null,
    Object? failed = null,
    Object? opened = null,
  }) {
    return _then(
      _$DeliveryStatsImpl(
        sent: null == sent
            ? _value.sent
            : sent // ignore: cast_nullable_to_non_nullable
                  as int,
        failed: null == failed
            ? _value.failed
            : failed // ignore: cast_nullable_to_non_nullable
                  as int,
        opened: null == opened
            ? _value.opened
            : opened // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryStatsImpl extends _DeliveryStats {
  const _$DeliveryStatsImpl({this.sent = 0, this.failed = 0, this.opened = 0})
    : super._();

  factory _$DeliveryStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryStatsImplFromJson(json);

  @override
  @JsonKey()
  final int sent;
  @override
  @JsonKey()
  final int failed;
  @override
  @JsonKey()
  final int opened;

  @override
  String toString() {
    return 'DeliveryStats(sent: $sent, failed: $failed, opened: $opened)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryStatsImpl &&
            (identical(other.sent, sent) || other.sent == sent) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.opened, opened) || other.opened == opened));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sent, failed, opened);

  /// Create a copy of DeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryStatsImplCopyWith<_$DeliveryStatsImpl> get copyWith =>
      __$$DeliveryStatsImplCopyWithImpl<_$DeliveryStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryStatsImplToJson(this);
  }
}

abstract class _DeliveryStats extends DeliveryStats {
  const factory _DeliveryStats({
    final int sent,
    final int failed,
    final int opened,
  }) = _$DeliveryStatsImpl;
  const _DeliveryStats._() : super._();

  factory _DeliveryStats.fromJson(Map<String, dynamic> json) =
      _$DeliveryStatsImpl.fromJson;

  @override
  int get sent;
  @override
  int get failed;
  @override
  int get opened;

  /// Create a copy of DeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryStatsImplCopyWith<_$DeliveryStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationLog _$NotificationLogFromJson(Map<String, dynamic> json) {
  return _NotificationLog.fromJson(json);
}

/// @nodoc
mixin _$NotificationLog {
  String get logId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  NotificationActor? get triggeredBy => throw _privateConstructorUsedError;
  bool get isSystemTriggered => throw _privateConstructorUsedError;
  NotificationType get notificationType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  NotificationAudience get audience => throw _privateConstructorUsedError;
  String get linkedEntityId => throw _privateConstructorUsedError;
  String get linkedEntityType => throw _privateConstructorUsedError;
  DeliveryStats get deliveryStats => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationLogCopyWith<NotificationLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationLogCopyWith<$Res> {
  factory $NotificationLogCopyWith(
    NotificationLog value,
    $Res Function(NotificationLog) then,
  ) = _$NotificationLogCopyWithImpl<$Res, NotificationLog>;
  @useResult
  $Res call({
    String logId,
    String schoolId,
    NotificationActor? triggeredBy,
    bool isSystemTriggered,
    NotificationType notificationType,
    String title,
    String body,
    NotificationAudience audience,
    String linkedEntityId,
    String linkedEntityType,
    DeliveryStats deliveryStats,
    DateTime? sentAt,
    DateTime? createdAt,
  });

  $NotificationActorCopyWith<$Res>? get triggeredBy;
  $NotificationAudienceCopyWith<$Res> get audience;
  $DeliveryStatsCopyWith<$Res> get deliveryStats;
}

/// @nodoc
class _$NotificationLogCopyWithImpl<$Res, $Val extends NotificationLog>
    implements $NotificationLogCopyWith<$Res> {
  _$NotificationLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? schoolId = null,
    Object? triggeredBy = freezed,
    Object? isSystemTriggered = null,
    Object? notificationType = null,
    Object? title = null,
    Object? body = null,
    Object? audience = null,
    Object? linkedEntityId = null,
    Object? linkedEntityType = null,
    Object? deliveryStats = null,
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
            triggeredBy: freezed == triggeredBy
                ? _value.triggeredBy
                : triggeredBy // ignore: cast_nullable_to_non_nullable
                      as NotificationActor?,
            isSystemTriggered: null == isSystemTriggered
                ? _value.isSystemTriggered
                : isSystemTriggered // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationType: null == notificationType
                ? _value.notificationType
                : notificationType // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            audience: null == audience
                ? _value.audience
                : audience // ignore: cast_nullable_to_non_nullable
                      as NotificationAudience,
            linkedEntityId: null == linkedEntityId
                ? _value.linkedEntityId
                : linkedEntityId // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedEntityType: null == linkedEntityType
                ? _value.linkedEntityType
                : linkedEntityType // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryStats: null == deliveryStats
                ? _value.deliveryStats
                : deliveryStats // ignore: cast_nullable_to_non_nullable
                      as DeliveryStats,
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

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationActorCopyWith<$Res>? get triggeredBy {
    if (_value.triggeredBy == null) {
      return null;
    }

    return $NotificationActorCopyWith<$Res>(_value.triggeredBy!, (value) {
      return _then(_value.copyWith(triggeredBy: value) as $Val);
    });
  }

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationAudienceCopyWith<$Res> get audience {
    return $NotificationAudienceCopyWith<$Res>(_value.audience, (value) {
      return _then(_value.copyWith(audience: value) as $Val);
    });
  }

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryStatsCopyWith<$Res> get deliveryStats {
    return $DeliveryStatsCopyWith<$Res>(_value.deliveryStats, (value) {
      return _then(_value.copyWith(deliveryStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationLogImplCopyWith<$Res>
    implements $NotificationLogCopyWith<$Res> {
  factory _$$NotificationLogImplCopyWith(
    _$NotificationLogImpl value,
    $Res Function(_$NotificationLogImpl) then,
  ) = __$$NotificationLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String logId,
    String schoolId,
    NotificationActor? triggeredBy,
    bool isSystemTriggered,
    NotificationType notificationType,
    String title,
    String body,
    NotificationAudience audience,
    String linkedEntityId,
    String linkedEntityType,
    DeliveryStats deliveryStats,
    DateTime? sentAt,
    DateTime? createdAt,
  });

  @override
  $NotificationActorCopyWith<$Res>? get triggeredBy;
  @override
  $NotificationAudienceCopyWith<$Res> get audience;
  @override
  $DeliveryStatsCopyWith<$Res> get deliveryStats;
}

/// @nodoc
class __$$NotificationLogImplCopyWithImpl<$Res>
    extends _$NotificationLogCopyWithImpl<$Res, _$NotificationLogImpl>
    implements _$$NotificationLogImplCopyWith<$Res> {
  __$$NotificationLogImplCopyWithImpl(
    _$NotificationLogImpl _value,
    $Res Function(_$NotificationLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
    Object? schoolId = null,
    Object? triggeredBy = freezed,
    Object? isSystemTriggered = null,
    Object? notificationType = null,
    Object? title = null,
    Object? body = null,
    Object? audience = null,
    Object? linkedEntityId = null,
    Object? linkedEntityType = null,
    Object? deliveryStats = null,
    Object? sentAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$NotificationLogImpl(
        logId: null == logId
            ? _value.logId
            : logId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        triggeredBy: freezed == triggeredBy
            ? _value.triggeredBy
            : triggeredBy // ignore: cast_nullable_to_non_nullable
                  as NotificationActor?,
        isSystemTriggered: null == isSystemTriggered
            ? _value.isSystemTriggered
            : isSystemTriggered // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationType: null == notificationType
            ? _value.notificationType
            : notificationType // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        audience: null == audience
            ? _value.audience
            : audience // ignore: cast_nullable_to_non_nullable
                  as NotificationAudience,
        linkedEntityId: null == linkedEntityId
            ? _value.linkedEntityId
            : linkedEntityId // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedEntityType: null == linkedEntityType
            ? _value.linkedEntityType
            : linkedEntityType // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryStats: null == deliveryStats
            ? _value.deliveryStats
            : deliveryStats // ignore: cast_nullable_to_non_nullable
                  as DeliveryStats,
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
class _$NotificationLogImpl extends _NotificationLog {
  const _$NotificationLogImpl({
    required this.logId,
    required this.schoolId,
    this.triggeredBy,
    this.isSystemTriggered = false,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.audience,
    this.linkedEntityId = '',
    this.linkedEntityType = '',
    this.deliveryStats = const DeliveryStats(),
    this.sentAt,
    this.createdAt,
  }) : super._();

  factory _$NotificationLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationLogImplFromJson(json);

  @override
  final String logId;
  @override
  final String schoolId;
  @override
  final NotificationActor? triggeredBy;
  @override
  @JsonKey()
  final bool isSystemTriggered;
  @override
  final NotificationType notificationType;
  @override
  final String title;
  @override
  final String body;
  @override
  final NotificationAudience audience;
  @override
  @JsonKey()
  final String linkedEntityId;
  @override
  @JsonKey()
  final String linkedEntityType;
  @override
  @JsonKey()
  final DeliveryStats deliveryStats;
  @override
  final DateTime? sentAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'NotificationLog(logId: $logId, schoolId: $schoolId, triggeredBy: $triggeredBy, isSystemTriggered: $isSystemTriggered, notificationType: $notificationType, title: $title, body: $body, audience: $audience, linkedEntityId: $linkedEntityId, linkedEntityType: $linkedEntityType, deliveryStats: $deliveryStats, sentAt: $sentAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationLogImpl &&
            (identical(other.logId, logId) || other.logId == logId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.triggeredBy, triggeredBy) ||
                other.triggeredBy == triggeredBy) &&
            (identical(other.isSystemTriggered, isSystemTriggered) ||
                other.isSystemTriggered == isSystemTriggered) &&
            (identical(other.notificationType, notificationType) ||
                other.notificationType == notificationType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.audience, audience) ||
                other.audience == audience) &&
            (identical(other.linkedEntityId, linkedEntityId) ||
                other.linkedEntityId == linkedEntityId) &&
            (identical(other.linkedEntityType, linkedEntityType) ||
                other.linkedEntityType == linkedEntityType) &&
            (identical(other.deliveryStats, deliveryStats) ||
                other.deliveryStats == deliveryStats) &&
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
    triggeredBy,
    isSystemTriggered,
    notificationType,
    title,
    body,
    audience,
    linkedEntityId,
    linkedEntityType,
    deliveryStats,
    sentAt,
    createdAt,
  );

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationLogImplCopyWith<_$NotificationLogImpl> get copyWith =>
      __$$NotificationLogImplCopyWithImpl<_$NotificationLogImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationLogImplToJson(this);
  }
}

abstract class _NotificationLog extends NotificationLog {
  const factory _NotificationLog({
    required final String logId,
    required final String schoolId,
    final NotificationActor? triggeredBy,
    final bool isSystemTriggered,
    required final NotificationType notificationType,
    required final String title,
    required final String body,
    required final NotificationAudience audience,
    final String linkedEntityId,
    final String linkedEntityType,
    final DeliveryStats deliveryStats,
    final DateTime? sentAt,
    final DateTime? createdAt,
  }) = _$NotificationLogImpl;
  const _NotificationLog._() : super._();

  factory _NotificationLog.fromJson(Map<String, dynamic> json) =
      _$NotificationLogImpl.fromJson;

  @override
  String get logId;
  @override
  String get schoolId;
  @override
  NotificationActor? get triggeredBy;
  @override
  bool get isSystemTriggered;
  @override
  NotificationType get notificationType;
  @override
  String get title;
  @override
  String get body;
  @override
  NotificationAudience get audience;
  @override
  String get linkedEntityId;
  @override
  String get linkedEntityType;
  @override
  DeliveryStats get deliveryStats;
  @override
  DateTime? get sentAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of NotificationLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationLogImplCopyWith<_$NotificationLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
