// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_custom_session_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateCustomSessionRequestDto {

 String get profileId; PackSelectedFilter get filter; List<String> get tags; List<String> get packIds; int get sessionSize; String? get name;
/// Create a copy of CreateCustomSessionRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCustomSessionRequestDtoCopyWith<CreateCustomSessionRequestDto> get copyWith => _$CreateCustomSessionRequestDtoCopyWithImpl<CreateCustomSessionRequestDto>(this as CreateCustomSessionRequestDto, _$identity);

  /// Serializes this CreateCustomSessionRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCustomSessionRequestDto&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.packIds, packIds)&&(identical(other.sessionSize, sessionSize) || other.sessionSize == sessionSize)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileId,filter,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(packIds),sessionSize,name);

@override
String toString() {
  return 'CreateCustomSessionRequestDto(profileId: $profileId, filter: $filter, tags: $tags, packIds: $packIds, sessionSize: $sessionSize, name: $name)';
}


}

/// @nodoc
abstract mixin class $CreateCustomSessionRequestDtoCopyWith<$Res>  {
  factory $CreateCustomSessionRequestDtoCopyWith(CreateCustomSessionRequestDto value, $Res Function(CreateCustomSessionRequestDto) _then) = _$CreateCustomSessionRequestDtoCopyWithImpl;
@useResult
$Res call({
 String profileId, PackSelectedFilter filter, List<String> tags, List<String> packIds, int sessionSize, String? name
});




}
/// @nodoc
class _$CreateCustomSessionRequestDtoCopyWithImpl<$Res>
    implements $CreateCustomSessionRequestDtoCopyWith<$Res> {
  _$CreateCustomSessionRequestDtoCopyWithImpl(this._self, this._then);

  final CreateCustomSessionRequestDto _self;
  final $Res Function(CreateCustomSessionRequestDto) _then;

/// Create a copy of CreateCustomSessionRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? filter = null,Object? tags = null,Object? packIds = null,Object? sessionSize = null,Object? name = freezed,}) {
  return _then(_self.copyWith(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as PackSelectedFilter,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,packIds: null == packIds ? _self.packIds : packIds // ignore: cast_nullable_to_non_nullable
as List<String>,sessionSize: null == sessionSize ? _self.sessionSize : sessionSize // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCustomSessionRequestDto].
extension CreateCustomSessionRequestDtoPatterns on CreateCustomSessionRequestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCustomSessionRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCustomSessionRequestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCustomSessionRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateCustomSessionRequestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCustomSessionRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCustomSessionRequestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  PackSelectedFilter filter,  List<String> tags,  List<String> packIds,  int sessionSize,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCustomSessionRequestDto() when $default != null:
return $default(_that.profileId,_that.filter,_that.tags,_that.packIds,_that.sessionSize,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  PackSelectedFilter filter,  List<String> tags,  List<String> packIds,  int sessionSize,  String? name)  $default,) {final _that = this;
switch (_that) {
case _CreateCustomSessionRequestDto():
return $default(_that.profileId,_that.filter,_that.tags,_that.packIds,_that.sessionSize,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  PackSelectedFilter filter,  List<String> tags,  List<String> packIds,  int sessionSize,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _CreateCustomSessionRequestDto() when $default != null:
return $default(_that.profileId,_that.filter,_that.tags,_that.packIds,_that.sessionSize,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCustomSessionRequestDto implements CreateCustomSessionRequestDto {
  const _CreateCustomSessionRequestDto({required this.profileId, required this.filter, required final  List<String> tags, required final  List<String> packIds, required this.sessionSize, this.name}): _tags = tags,_packIds = packIds;
  factory _CreateCustomSessionRequestDto.fromJson(Map<String, dynamic> json) => _$CreateCustomSessionRequestDtoFromJson(json);

@override final  String profileId;
@override final  PackSelectedFilter filter;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _packIds;
@override List<String> get packIds {
  if (_packIds is EqualUnmodifiableListView) return _packIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packIds);
}

@override final  int sessionSize;
@override final  String? name;

/// Create a copy of CreateCustomSessionRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCustomSessionRequestDtoCopyWith<_CreateCustomSessionRequestDto> get copyWith => __$CreateCustomSessionRequestDtoCopyWithImpl<_CreateCustomSessionRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCustomSessionRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCustomSessionRequestDto&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._packIds, _packIds)&&(identical(other.sessionSize, sessionSize) || other.sessionSize == sessionSize)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileId,filter,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_packIds),sessionSize,name);

@override
String toString() {
  return 'CreateCustomSessionRequestDto(profileId: $profileId, filter: $filter, tags: $tags, packIds: $packIds, sessionSize: $sessionSize, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CreateCustomSessionRequestDtoCopyWith<$Res> implements $CreateCustomSessionRequestDtoCopyWith<$Res> {
  factory _$CreateCustomSessionRequestDtoCopyWith(_CreateCustomSessionRequestDto value, $Res Function(_CreateCustomSessionRequestDto) _then) = __$CreateCustomSessionRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String profileId, PackSelectedFilter filter, List<String> tags, List<String> packIds, int sessionSize, String? name
});




}
/// @nodoc
class __$CreateCustomSessionRequestDtoCopyWithImpl<$Res>
    implements _$CreateCustomSessionRequestDtoCopyWith<$Res> {
  __$CreateCustomSessionRequestDtoCopyWithImpl(this._self, this._then);

  final _CreateCustomSessionRequestDto _self;
  final $Res Function(_CreateCustomSessionRequestDto) _then;

/// Create a copy of CreateCustomSessionRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? filter = null,Object? tags = null,Object? packIds = null,Object? sessionSize = null,Object? name = freezed,}) {
  return _then(_CreateCustomSessionRequestDto(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as PackSelectedFilter,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,packIds: null == packIds ? _self._packIds : packIds // ignore: cast_nullable_to_non_nullable
as List<String>,sessionSize: null == sessionSize ? _self.sessionSize : sessionSize // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
