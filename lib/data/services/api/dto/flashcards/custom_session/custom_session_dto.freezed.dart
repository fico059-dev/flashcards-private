// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_session_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomSessionDto {

 String? get id; String get profileId; int get currentIndex; bool get isPaid;/// Number of flashcards answered right
 int get correctCount; int get cardCount;@DatetimeTimestampConverter() DateTime get createdAt;/// Set by the student, older sessions don't have one.
 String? get name;
/// Create a copy of CustomSessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomSessionDtoCopyWith<CustomSessionDto> get copyWith => _$CustomSessionDtoCopyWithImpl<CustomSessionDto>(this as CustomSessionDto, _$identity);

  /// Serializes this CustomSessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomSessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profileId,currentIndex,isPaid,correctCount,cardCount,createdAt,name);

@override
String toString() {
  return 'CustomSessionDto(id: $id, profileId: $profileId, currentIndex: $currentIndex, isPaid: $isPaid, correctCount: $correctCount, cardCount: $cardCount, createdAt: $createdAt, name: $name)';
}


}

/// @nodoc
abstract mixin class $CustomSessionDtoCopyWith<$Res>  {
  factory $CustomSessionDtoCopyWith(CustomSessionDto value, $Res Function(CustomSessionDto) _then) = _$CustomSessionDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String profileId, int currentIndex, bool isPaid, int correctCount, int cardCount,@DatetimeTimestampConverter() DateTime createdAt, String? name
});




}
/// @nodoc
class _$CustomSessionDtoCopyWithImpl<$Res>
    implements $CustomSessionDtoCopyWith<$Res> {
  _$CustomSessionDtoCopyWithImpl(this._self, this._then);

  final CustomSessionDto _self;
  final $Res Function(CustomSessionDto) _then;

/// Create a copy of CustomSessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? profileId = null,Object? currentIndex = null,Object? isPaid = null,Object? correctCount = null,Object? cardCount = null,Object? createdAt = null,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomSessionDto].
extension CustomSessionDtoPatterns on CustomSessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomSessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomSessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomSessionDto value)  $default,){
final _that = this;
switch (_that) {
case _CustomSessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomSessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _CustomSessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String profileId,  int currentIndex,  bool isPaid,  int correctCount,  int cardCount, @DatetimeTimestampConverter()  DateTime createdAt,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomSessionDto() when $default != null:
return $default(_that.id,_that.profileId,_that.currentIndex,_that.isPaid,_that.correctCount,_that.cardCount,_that.createdAt,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String profileId,  int currentIndex,  bool isPaid,  int correctCount,  int cardCount, @DatetimeTimestampConverter()  DateTime createdAt,  String? name)  $default,) {final _that = this;
switch (_that) {
case _CustomSessionDto():
return $default(_that.id,_that.profileId,_that.currentIndex,_that.isPaid,_that.correctCount,_that.cardCount,_that.createdAt,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String profileId,  int currentIndex,  bool isPaid,  int correctCount,  int cardCount, @DatetimeTimestampConverter()  DateTime createdAt,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _CustomSessionDto() when $default != null:
return $default(_that.id,_that.profileId,_that.currentIndex,_that.isPaid,_that.correctCount,_that.cardCount,_that.createdAt,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomSessionDto implements CustomSessionDto {
  const _CustomSessionDto({this.id, required this.profileId, required this.currentIndex, required this.isPaid, required this.correctCount, required this.cardCount, @DatetimeTimestampConverter() required this.createdAt, this.name});
  factory _CustomSessionDto.fromJson(Map<String, dynamic> json) => _$CustomSessionDtoFromJson(json);

@override final  String? id;
@override final  String profileId;
@override final  int currentIndex;
@override final  bool isPaid;
/// Number of flashcards answered right
@override final  int correctCount;
@override final  int cardCount;
@override@DatetimeTimestampConverter() final  DateTime createdAt;
/// Set by the student, older sessions don't have one.
@override final  String? name;

/// Create a copy of CustomSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomSessionDtoCopyWith<_CustomSessionDto> get copyWith => __$CustomSessionDtoCopyWithImpl<_CustomSessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomSessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomSessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profileId,currentIndex,isPaid,correctCount,cardCount,createdAt,name);

@override
String toString() {
  return 'CustomSessionDto(id: $id, profileId: $profileId, currentIndex: $currentIndex, isPaid: $isPaid, correctCount: $correctCount, cardCount: $cardCount, createdAt: $createdAt, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CustomSessionDtoCopyWith<$Res> implements $CustomSessionDtoCopyWith<$Res> {
  factory _$CustomSessionDtoCopyWith(_CustomSessionDto value, $Res Function(_CustomSessionDto) _then) = __$CustomSessionDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String profileId, int currentIndex, bool isPaid, int correctCount, int cardCount,@DatetimeTimestampConverter() DateTime createdAt, String? name
});




}
/// @nodoc
class __$CustomSessionDtoCopyWithImpl<$Res>
    implements _$CustomSessionDtoCopyWith<$Res> {
  __$CustomSessionDtoCopyWithImpl(this._self, this._then);

  final _CustomSessionDto _self;
  final $Res Function(_CustomSessionDto) _then;

/// Create a copy of CustomSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? profileId = null,Object? currentIndex = null,Object? isPaid = null,Object? correctCount = null,Object? cardCount = null,Object? createdAt = null,Object? name = freezed,}) {
  return _then(_CustomSessionDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
