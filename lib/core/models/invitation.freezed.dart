// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Invitation _$InvitationFromJson(Map<String, dynamic> json) {
  return _Invitation.fromJson(json);
}

/// @nodoc
mixin _$Invitation {
  String get inviteId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  InvitationRole get role => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  InvitationStatus get status => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String get linkedEntityId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String get inviteeName => throw _privateConstructorUsedError;

  /// Serializes this Invitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Invitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvitationCopyWith<Invitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvitationCopyWith<$Res> {
  factory $InvitationCopyWith(
    Invitation value,
    $Res Function(Invitation) then,
  ) = _$InvitationCopyWithImpl<$Res, Invitation>;
  @useResult
  $Res call({
    String inviteId,
    String schoolId,
    InvitationRole role,
    String email,
    String phone,
    InvitationStatus status,
    String token,
    String createdBy,
    DateTime? expiresAt,
    String linkedEntityId,
    DateTime? createdAt,
    String inviteeName,
  });
}

/// @nodoc
class _$InvitationCopyWithImpl<$Res, $Val extends Invitation>
    implements $InvitationCopyWith<$Res> {
  _$InvitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Invitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteId = null,
    Object? schoolId = null,
    Object? role = null,
    Object? email = null,
    Object? phone = null,
    Object? status = null,
    Object? token = null,
    Object? createdBy = null,
    Object? expiresAt = freezed,
    Object? linkedEntityId = null,
    Object? createdAt = freezed,
    Object? inviteeName = null,
  }) {
    return _then(
      _value.copyWith(
            inviteId: null == inviteId
                ? _value.inviteId
                : inviteId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as InvitationRole,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as InvitationStatus,
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            linkedEntityId: null == linkedEntityId
                ? _value.linkedEntityId
                : linkedEntityId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            inviteeName: null == inviteeName
                ? _value.inviteeName
                : inviteeName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvitationImplCopyWith<$Res>
    implements $InvitationCopyWith<$Res> {
  factory _$$InvitationImplCopyWith(
    _$InvitationImpl value,
    $Res Function(_$InvitationImpl) then,
  ) = __$$InvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String inviteId,
    String schoolId,
    InvitationRole role,
    String email,
    String phone,
    InvitationStatus status,
    String token,
    String createdBy,
    DateTime? expiresAt,
    String linkedEntityId,
    DateTime? createdAt,
    String inviteeName,
  });
}

/// @nodoc
class __$$InvitationImplCopyWithImpl<$Res>
    extends _$InvitationCopyWithImpl<$Res, _$InvitationImpl>
    implements _$$InvitationImplCopyWith<$Res> {
  __$$InvitationImplCopyWithImpl(
    _$InvitationImpl _value,
    $Res Function(_$InvitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Invitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteId = null,
    Object? schoolId = null,
    Object? role = null,
    Object? email = null,
    Object? phone = null,
    Object? status = null,
    Object? token = null,
    Object? createdBy = null,
    Object? expiresAt = freezed,
    Object? linkedEntityId = null,
    Object? createdAt = freezed,
    Object? inviteeName = null,
  }) {
    return _then(
      _$InvitationImpl(
        inviteId: null == inviteId
            ? _value.inviteId
            : inviteId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as InvitationRole,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as InvitationStatus,
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        linkedEntityId: null == linkedEntityId
            ? _value.linkedEntityId
            : linkedEntityId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        inviteeName: null == inviteeName
            ? _value.inviteeName
            : inviteeName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvitationImpl implements _Invitation {
  const _$InvitationImpl({
    required this.inviteId,
    required this.schoolId,
    required this.role,
    required this.email,
    this.phone = '',
    this.status = InvitationStatus.PENDING,
    required this.token,
    required this.createdBy,
    this.expiresAt,
    this.linkedEntityId = '',
    this.createdAt,
    this.inviteeName = '',
  });

  factory _$InvitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvitationImplFromJson(json);

  @override
  final String inviteId;
  @override
  final String schoolId;
  @override
  final InvitationRole role;
  @override
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final InvitationStatus status;
  @override
  final String token;
  @override
  final String createdBy;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final String linkedEntityId;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final String inviteeName;

  @override
  String toString() {
    return 'Invitation(inviteId: $inviteId, schoolId: $schoolId, role: $role, email: $email, phone: $phone, status: $status, token: $token, createdBy: $createdBy, expiresAt: $expiresAt, linkedEntityId: $linkedEntityId, createdAt: $createdAt, inviteeName: $inviteeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationImpl &&
            (identical(other.inviteId, inviteId) ||
                other.inviteId == inviteId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.linkedEntityId, linkedEntityId) ||
                other.linkedEntityId == linkedEntityId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.inviteeName, inviteeName) ||
                other.inviteeName == inviteeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    inviteId,
    schoolId,
    role,
    email,
    phone,
    status,
    token,
    createdBy,
    expiresAt,
    linkedEntityId,
    createdAt,
    inviteeName,
  );

  /// Create a copy of Invitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitationImplCopyWith<_$InvitationImpl> get copyWith =>
      __$$InvitationImplCopyWithImpl<_$InvitationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvitationImplToJson(this);
  }
}

abstract class _Invitation implements Invitation {
  const factory _Invitation({
    required final String inviteId,
    required final String schoolId,
    required final InvitationRole role,
    required final String email,
    final String phone,
    final InvitationStatus status,
    required final String token,
    required final String createdBy,
    final DateTime? expiresAt,
    final String linkedEntityId,
    final DateTime? createdAt,
    final String inviteeName,
  }) = _$InvitationImpl;

  factory _Invitation.fromJson(Map<String, dynamic> json) =
      _$InvitationImpl.fromJson;

  @override
  String get inviteId;
  @override
  String get schoolId;
  @override
  InvitationRole get role;
  @override
  String get email;
  @override
  String get phone;
  @override
  InvitationStatus get status;
  @override
  String get token;
  @override
  String get createdBy;
  @override
  DateTime? get expiresAt;
  @override
  String get linkedEntityId;
  @override
  DateTime? get createdAt;
  @override
  String get inviteeName;

  /// Create a copy of Invitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvitationImplCopyWith<_$InvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
