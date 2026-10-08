// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackDto {

@JsonKey(includeToJson: false) String? get id; String get name; int get flashcardsCount; Map<String, int> get tagCounts; List<String> get tags; bool get isPaid;/// Only some users (and admins) may see the pack. Set by the
/// setPackAccess function only.
@JsonKey(includeToJson: false) bool get restricted;/// The pack this one is shown inside (a sub-pack, like Anki subdecks).
/// Set by admins with setPackParent only.
@JsonKey(includeToJson: false) String? get parentId;
/// Create a copy of PackDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackDtoCopyWith<PackDto> get copyWith => _$PackDtoCopyWithImpl<PackDto>(this as PackDto, _$identity);

  /// Serializes this PackDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.flashcardsCount, flashcardsCount) || other.flashcardsCount == flashcardsCount)&&const DeepCollectionEquality().equals(other.tagCounts, tagCounts)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.restricted, restricted) || other.restricted == restricted)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,flashcardsCount,const DeepCollectionEquality().hash(tagCounts),const DeepCollectionEquality().hash(tags),isPaid,restricted,parentId);

@override
String toString() {
  return 'PackDto(id: $id, name: $name, flashcardsCount: $flashcardsCount, tagCounts: $tagCounts, tags: $tags, isPaid: $isPaid, restricted: $restricted, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $PackDtoCopyWith<$Res>  {
  factory $PackDtoCopyWith(PackDto value, $Res Function(PackDto) _then) = _$PackDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String name, int flashcardsCount, Map<String, int> tagCounts, List<String> tags, bool isPaid,@JsonKey(includeToJson: false) bool restricted,@JsonKey(includeToJson: false) String? parentId
});




}
/// @nodoc
class _$PackDtoCopyWithImpl<$Res>
    implements $PackDtoCopyWith<$Res> {
  _$PackDtoCopyWithImpl(this._self, this._then);

  final PackDto _self;
  final $Res Function(PackDto) _then;

/// Create a copy of PackDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? flashcardsCount = null,Object? tagCounts = null,Object? tags = null,Object? isPaid = null,Object? restricted = null,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,flashcardsCount: null == flashcardsCount ? _self.flashcardsCount : flashcardsCount // ignore: cast_nullable_to_non_nullable
as int,tagCounts: null == tagCounts ? _self.tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,restricted: null == restricted ? _self.restricted : restricted // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackDto].
extension PackDtoPatterns on PackDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackDto value)  $default,){
final _that = this;
switch (_that) {
case _PackDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackDto value)?  $default,){
final _that = this;
switch (_that) {
case _PackDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String name,  int flashcardsCount,  Map<String, int> tagCounts,  List<String> tags,  bool isPaid, @JsonKey(includeToJson: false)  bool restricted, @JsonKey(includeToJson: false)  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackDto() when $default != null:
return $default(_that.id,_that.name,_that.flashcardsCount,_that.tagCounts,_that.tags,_that.isPaid,_that.restricted,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String name,  int flashcardsCount,  Map<String, int> tagCounts,  List<String> tags,  bool isPaid, @JsonKey(includeToJson: false)  bool restricted, @JsonKey(includeToJson: false)  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _PackDto():
return $default(_that.id,_that.name,_that.flashcardsCount,_that.tagCounts,_that.tags,_that.isPaid,_that.restricted,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String? id,  String name,  int flashcardsCount,  Map<String, int> tagCounts,  List<String> tags,  bool isPaid, @JsonKey(includeToJson: false)  bool restricted, @JsonKey(includeToJson: false)  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _PackDto() when $default != null:
return $default(_that.id,_that.name,_that.flashcardsCount,_that.tagCounts,_that.tags,_that.isPaid,_that.restricted,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackDto implements PackDto {
  const _PackDto({@JsonKey(includeToJson: false) required this.id, required this.name, required this.flashcardsCount, final  Map<String, int> tagCounts = const {}, final  List<String> tags = const [], this.isPaid = false, @JsonKey(includeToJson: false) this.restricted = false, @JsonKey(includeToJson: false) this.parentId}): _tagCounts = tagCounts,_tags = tags;
  factory _PackDto.fromJson(Map<String, dynamic> json) => _$PackDtoFromJson(json);

@override@JsonKey(includeToJson: false) final  String? id;
@override final  String name;
@override final  int flashcardsCount;
 final  Map<String, int> _tagCounts;
@override@JsonKey() Map<String, int> get tagCounts {
  if (_tagCounts is EqualUnmodifiableMapView) return _tagCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tagCounts);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isPaid;
/// Only some users (and admins) may see the pack. Set by the
/// setPackAccess function only.
@override@JsonKey(includeToJson: false) final  bool restricted;
/// The pack this one is shown inside (a sub-pack, like Anki subdecks).
/// Set by admins with setPackParent only.
@override@JsonKey(includeToJson: false) final  String? parentId;

/// Create a copy of PackDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackDtoCopyWith<_PackDto> get copyWith => __$PackDtoCopyWithImpl<_PackDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.flashcardsCount, flashcardsCount) || other.flashcardsCount == flashcardsCount)&&const DeepCollectionEquality().equals(other._tagCounts, _tagCounts)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.restricted, restricted) || other.restricted == restricted)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,flashcardsCount,const DeepCollectionEquality().hash(_tagCounts),const DeepCollectionEquality().hash(_tags),isPaid,restricted,parentId);

@override
String toString() {
  return 'PackDto(id: $id, name: $name, flashcardsCount: $flashcardsCount, tagCounts: $tagCounts, tags: $tags, isPaid: $isPaid, restricted: $restricted, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$PackDtoCopyWith<$Res> implements $PackDtoCopyWith<$Res> {
  factory _$PackDtoCopyWith(_PackDto value, $Res Function(_PackDto) _then) = __$PackDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String name, int flashcardsCount, Map<String, int> tagCounts, List<String> tags, bool isPaid,@JsonKey(includeToJson: false) bool restricted,@JsonKey(includeToJson: false) String? parentId
});




}
/// @nodoc
class __$PackDtoCopyWithImpl<$Res>
    implements _$PackDtoCopyWith<$Res> {
  __$PackDtoCopyWithImpl(this._self, this._then);

  final _PackDto _self;
  final $Res Function(_PackDto) _then;

/// Create a copy of PackDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? flashcardsCount = null,Object? tagCounts = null,Object? tags = null,Object? isPaid = null,Object? restricted = null,Object? parentId = freezed,}) {
  return _then(_PackDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,flashcardsCount: null == flashcardsCount ? _self.flashcardsCount : flashcardsCount // ignore: cast_nullable_to_non_nullable
as int,tagCounts: null == tagCounts ? _self._tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,restricted: null == restricted ? _self.restricted : restricted // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
