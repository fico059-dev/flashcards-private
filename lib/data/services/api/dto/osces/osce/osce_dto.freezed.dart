// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'osce_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OsceDto {

@JsonKey(includeToJson: false) String? get id; String get name; String get scenario; List<dynamic> get questions; bool get isPaid;/// Set by the setOsceFolder / setOsceScenarioImage functions only.
@JsonKey(includeToJson: false) String? get folderId;@JsonKey(includeToJson: false) String? get scenarioImageUrl;
/// Create a copy of OsceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OsceDtoCopyWith<OsceDto> get copyWith => _$OsceDtoCopyWithImpl<OsceDto>(this as OsceDto, _$identity);

  /// Serializes this OsceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.scenarioImageUrl, scenarioImageUrl) || other.scenarioImageUrl == scenarioImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,scenario,const DeepCollectionEquality().hash(questions),isPaid,folderId,scenarioImageUrl);

@override
String toString() {
  return 'OsceDto(id: $id, name: $name, scenario: $scenario, questions: $questions, isPaid: $isPaid, folderId: $folderId, scenarioImageUrl: $scenarioImageUrl)';
}


}

/// @nodoc
abstract mixin class $OsceDtoCopyWith<$Res>  {
  factory $OsceDtoCopyWith(OsceDto value, $Res Function(OsceDto) _then) = _$OsceDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String name, String scenario, List<dynamic> questions, bool isPaid,@JsonKey(includeToJson: false) String? folderId,@JsonKey(includeToJson: false) String? scenarioImageUrl
});




}
/// @nodoc
class _$OsceDtoCopyWithImpl<$Res>
    implements $OsceDtoCopyWith<$Res> {
  _$OsceDtoCopyWithImpl(this._self, this._then);

  final OsceDto _self;
  final $Res Function(OsceDto) _then;

/// Create a copy of OsceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? scenario = null,Object? questions = null,Object? isPaid = null,Object? folderId = freezed,Object? scenarioImageUrl = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,scenarioImageUrl: freezed == scenarioImageUrl ? _self.scenarioImageUrl : scenarioImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OsceDto].
extension OsceDtoPatterns on OsceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OsceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OsceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OsceDto value)  $default,){
final _that = this;
switch (_that) {
case _OsceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OsceDto value)?  $default,){
final _that = this;
switch (_that) {
case _OsceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String name,  String scenario,  List<dynamic> questions,  bool isPaid, @JsonKey(includeToJson: false)  String? folderId, @JsonKey(includeToJson: false)  String? scenarioImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OsceDto() when $default != null:
return $default(_that.id,_that.name,_that.scenario,_that.questions,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String name,  String scenario,  List<dynamic> questions,  bool isPaid, @JsonKey(includeToJson: false)  String? folderId, @JsonKey(includeToJson: false)  String? scenarioImageUrl)  $default,) {final _that = this;
switch (_that) {
case _OsceDto():
return $default(_that.id,_that.name,_that.scenario,_that.questions,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String? id,  String name,  String scenario,  List<dynamic> questions,  bool isPaid, @JsonKey(includeToJson: false)  String? folderId, @JsonKey(includeToJson: false)  String? scenarioImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _OsceDto() when $default != null:
return $default(_that.id,_that.name,_that.scenario,_that.questions,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OsceDto implements OsceDto {
  const _OsceDto({@JsonKey(includeToJson: false) required this.id, required this.name, required this.scenario, final  List<dynamic> questions = const <dynamic>[], this.isPaid = false, @JsonKey(includeToJson: false) this.folderId, @JsonKey(includeToJson: false) this.scenarioImageUrl}): _questions = questions;
  factory _OsceDto.fromJson(Map<String, dynamic> json) => _$OsceDtoFromJson(json);

@override@JsonKey(includeToJson: false) final  String? id;
@override final  String name;
@override final  String scenario;
 final  List<dynamic> _questions;
@override@JsonKey() List<dynamic> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override@JsonKey() final  bool isPaid;
/// Set by the setOsceFolder / setOsceScenarioImage functions only.
@override@JsonKey(includeToJson: false) final  String? folderId;
@override@JsonKey(includeToJson: false) final  String? scenarioImageUrl;

/// Create a copy of OsceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OsceDtoCopyWith<_OsceDto> get copyWith => __$OsceDtoCopyWithImpl<_OsceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OsceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OsceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.scenarioImageUrl, scenarioImageUrl) || other.scenarioImageUrl == scenarioImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,scenario,const DeepCollectionEquality().hash(_questions),isPaid,folderId,scenarioImageUrl);

@override
String toString() {
  return 'OsceDto(id: $id, name: $name, scenario: $scenario, questions: $questions, isPaid: $isPaid, folderId: $folderId, scenarioImageUrl: $scenarioImageUrl)';
}


}

/// @nodoc
abstract mixin class _$OsceDtoCopyWith<$Res> implements $OsceDtoCopyWith<$Res> {
  factory _$OsceDtoCopyWith(_OsceDto value, $Res Function(_OsceDto) _then) = __$OsceDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String name, String scenario, List<dynamic> questions, bool isPaid,@JsonKey(includeToJson: false) String? folderId,@JsonKey(includeToJson: false) String? scenarioImageUrl
});




}
/// @nodoc
class __$OsceDtoCopyWithImpl<$Res>
    implements _$OsceDtoCopyWith<$Res> {
  __$OsceDtoCopyWithImpl(this._self, this._then);

  final _OsceDto _self;
  final $Res Function(_OsceDto) _then;

/// Create a copy of OsceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? scenario = null,Object? questions = null,Object? isPaid = null,Object? folderId = freezed,Object? scenarioImageUrl = freezed,}) {
  return _then(_OsceDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,scenarioImageUrl: freezed == scenarioImageUrl ? _self.scenarioImageUrl : scenarioImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
