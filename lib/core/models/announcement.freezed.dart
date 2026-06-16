// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) {
  return _Announcement.fromJson(json);
}

/// @nodoc
mixin _$Announcement {
  String get announcementId => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get createdByName => throw _privateConstructorUsedError;
  AnnouncementAudience get audience => throw _privateConstructorUsedError;
  String get targetClassId => throw _privateConstructorUsedError;
  String get targetClassName => throw _privateConstructorUsedError;
  bool get requiresAck => throw _privateConstructorUsedError;
  List<String> get ackedBy => throw _privateConstructorUsedError;
  String get attachmentUrl => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnouncementCopyWith<Announcement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementCopyWith<$Res> {
  factory $AnnouncementCopyWith(
    Announcement value,
    $Res Function(Announcement) then,
  ) = _$AnnouncementCopyWithImpl<$Res, Announcement>;
  @useResult
  $Res call({
    String announcementId,
    String schoolId,
    String title,
    String body,
    String createdBy,
    String createdByName,
    AnnouncementAudience audience,
    String targetClassId,
    String targetClassName,
    bool requiresAck,
    List<String> ackedBy,
    String attachmentUrl,
    DateTime? publishedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$AnnouncementCopyWithImpl<$Res, $Val extends Announcement>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? announcementId = null,
    Object? schoolId = null,
    Object? title = null,
    Object? body = null,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? audience = null,
    Object? targetClassId = null,
    Object? targetClassName = null,
    Object? requiresAck = null,
    Object? ackedBy = null,
    Object? attachmentUrl = null,
    Object? publishedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            announcementId: null == announcementId
                ? _value.announcementId
                : announcementId // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdByName: null == createdByName
                ? _value.createdByName
                : createdByName // ignore: cast_nullable_to_non_nullable
                      as String,
            audience: null == audience
                ? _value.audience
                : audience // ignore: cast_nullable_to_non_nullable
                      as AnnouncementAudience,
            targetClassId: null == targetClassId
                ? _value.targetClassId
                : targetClassId // ignore: cast_nullable_to_non_nullable
                      as String,
            targetClassName: null == targetClassName
                ? _value.targetClassName
                : targetClassName // ignore: cast_nullable_to_non_nullable
                      as String,
            requiresAck: null == requiresAck
                ? _value.requiresAck
                : requiresAck // ignore: cast_nullable_to_non_nullable
                      as bool,
            ackedBy: null == ackedBy
                ? _value.ackedBy
                : ackedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            attachmentUrl: null == attachmentUrl
                ? _value.attachmentUrl
                : attachmentUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnouncementImplCopyWith<$Res>
    implements $AnnouncementCopyWith<$Res> {
  factory _$$AnnouncementImplCopyWith(
    _$AnnouncementImpl value,
    $Res Function(_$AnnouncementImpl) then,
  ) = __$$AnnouncementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String announcementId,
    String schoolId,
    String title,
    String body,
    String createdBy,
    String createdByName,
    AnnouncementAudience audience,
    String targetClassId,
    String targetClassName,
    bool requiresAck,
    List<String> ackedBy,
    String attachmentUrl,
    DateTime? publishedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$AnnouncementImplCopyWithImpl<$Res>
    extends _$AnnouncementCopyWithImpl<$Res, _$AnnouncementImpl>
    implements _$$AnnouncementImplCopyWith<$Res> {
  __$$AnnouncementImplCopyWithImpl(
    _$AnnouncementImpl _value,
    $Res Function(_$AnnouncementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? announcementId = null,
    Object? schoolId = null,
    Object? title = null,
    Object? body = null,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? audience = null,
    Object? targetClassId = null,
    Object? targetClassName = null,
    Object? requiresAck = null,
    Object? ackedBy = null,
    Object? attachmentUrl = null,
    Object? publishedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AnnouncementImpl(
        announcementId: null == announcementId
            ? _value.announcementId
            : announcementId // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByName: null == createdByName
            ? _value.createdByName
            : createdByName // ignore: cast_nullable_to_non_nullable
                  as String,
        audience: null == audience
            ? _value.audience
            : audience // ignore: cast_nullable_to_non_nullable
                  as AnnouncementAudience,
        targetClassId: null == targetClassId
            ? _value.targetClassId
            : targetClassId // ignore: cast_nullable_to_non_nullable
                  as String,
        targetClassName: null == targetClassName
            ? _value.targetClassName
            : targetClassName // ignore: cast_nullable_to_non_nullable
                  as String,
        requiresAck: null == requiresAck
            ? _value.requiresAck
            : requiresAck // ignore: cast_nullable_to_non_nullable
                  as bool,
        ackedBy: null == ackedBy
            ? _value._ackedBy
            : ackedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        attachmentUrl: null == attachmentUrl
            ? _value.attachmentUrl
            : attachmentUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
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
class _$AnnouncementImpl implements _Announcement {
  const _$AnnouncementImpl({
    required this.announcementId,
    required this.schoolId,
    required this.title,
    required this.body,
    required this.createdBy,
    this.createdByName = '',
    this.audience = AnnouncementAudience.ALL,
    this.targetClassId = '',
    this.targetClassName = '',
    this.requiresAck = false,
    final List<String> ackedBy = const [],
    this.attachmentUrl = '',
    this.publishedAt,
    this.createdAt,
  }) : _ackedBy = ackedBy;

  factory _$AnnouncementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnnouncementImplFromJson(json);

  @override
  final String announcementId;
  @override
  final String schoolId;
  @override
  final String title;
  @override
  final String body;
  @override
  final String createdBy;
  @override
  @JsonKey()
  final String createdByName;
  @override
  @JsonKey()
  final AnnouncementAudience audience;
  @override
  @JsonKey()
  final String targetClassId;
  @override
  @JsonKey()
  final String targetClassName;
  @override
  @JsonKey()
  final bool requiresAck;
  final List<String> _ackedBy;
  @override
  @JsonKey()
  List<String> get ackedBy {
    if (_ackedBy is EqualUnmodifiableListView) return _ackedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ackedBy);
  }

  @override
  @JsonKey()
  final String attachmentUrl;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Announcement(announcementId: $announcementId, schoolId: $schoolId, title: $title, body: $body, createdBy: $createdBy, createdByName: $createdByName, audience: $audience, targetClassId: $targetClassId, targetClassName: $targetClassName, requiresAck: $requiresAck, ackedBy: $ackedBy, attachmentUrl: $attachmentUrl, publishedAt: $publishedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnouncementImpl &&
            (identical(other.announcementId, announcementId) ||
                other.announcementId == announcementId) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName) &&
            (identical(other.audience, audience) ||
                other.audience == audience) &&
            (identical(other.targetClassId, targetClassId) ||
                other.targetClassId == targetClassId) &&
            (identical(other.targetClassName, targetClassName) ||
                other.targetClassName == targetClassName) &&
            (identical(other.requiresAck, requiresAck) ||
                other.requiresAck == requiresAck) &&
            const DeepCollectionEquality().equals(other._ackedBy, _ackedBy) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    announcementId,
    schoolId,
    title,
    body,
    createdBy,
    createdByName,
    audience,
    targetClassId,
    targetClassName,
    requiresAck,
    const DeepCollectionEquality().hash(_ackedBy),
    attachmentUrl,
    publishedAt,
    createdAt,
  );

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnouncementImplCopyWith<_$AnnouncementImpl> get copyWith =>
      __$$AnnouncementImplCopyWithImpl<_$AnnouncementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnnouncementImplToJson(this);
  }
}

abstract class _Announcement implements Announcement {
  const factory _Announcement({
    required final String announcementId,
    required final String schoolId,
    required final String title,
    required final String body,
    required final String createdBy,
    final String createdByName,
    final AnnouncementAudience audience,
    final String targetClassId,
    final String targetClassName,
    final bool requiresAck,
    final List<String> ackedBy,
    final String attachmentUrl,
    final DateTime? publishedAt,
    final DateTime? createdAt,
  }) = _$AnnouncementImpl;

  factory _Announcement.fromJson(Map<String, dynamic> json) =
      _$AnnouncementImpl.fromJson;

  @override
  String get announcementId;
  @override
  String get schoolId;
  @override
  String get title;
  @override
  String get body;
  @override
  String get createdBy;
  @override
  String get createdByName;
  @override
  AnnouncementAudience get audience;
  @override
  String get targetClassId;
  @override
  String get targetClassName;
  @override
  bool get requiresAck;
  @override
  List<String> get ackedBy;
  @override
  String get attachmentUrl;
  @override
  DateTime? get publishedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnouncementImplCopyWith<_$AnnouncementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
