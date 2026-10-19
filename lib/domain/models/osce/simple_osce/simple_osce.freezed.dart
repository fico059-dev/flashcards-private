// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simple_osce.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SimpleOsce {

 String get id; String get name; String get scenario; bool get isPaid;/// Speciality folder; null when the station isn't in a folder.
 String? get folderId;/// Image shown with the description (scenario).
 String? get scenarioImageUrl;
/// Create a copy of SimpleOsce
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimpleOsceCopyWith<SimpleOsce> get copyWith => _$SimpleOsceCopyWithImpl<SimpleOsce>(this as SimpleOsce, _$identity);

  /// Serializes this SimpleOsce to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimpleOsce&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.scenarioImageUrl, scenarioImageUrl) || other.scenarioImageUrl == scenarioImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,scenario,isPaid,folderId,scenarioImageUrl);

@override
String toString() {
  return 'SimpleOsce(id: $id, name: $name, scenario: $scenario, isPaid: $isPaid, folderId: $folderId, scenarioImageUrl: $scenarioImageUrl)';
}


}

/// @nodoc
abstract mixin class $SimpleOsceCopyWith<$Res>  {
  factory $SimpleOsceCopyWith(SimpleOsce value, $Res Function(SimpleOsce) _then) = _$SimpleOsceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String scenario, bool isPaid, String? folderId, String? scenarioImageUrl
});




}
/// @nodoc
class _$SimpleOsceCopyWithImpl<$Res>
    implements $SimpleOsceCopyWith<$Res> {
  _$SimpleOsceCopyWithImpl(this._self, this._then);

  final SimpleOsce _self;
  final $Res Function(SimpleOsce) _then;

/// Create a copy of SimpleOsce
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? scenario = null,Object? isPaid = null,Object? folderId = freezed,Object? scenarioImageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,scenarioImageUrl: freezed == scenarioImageUrl ? _self.scenarioImageUrl : scenarioImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SimpleOsce].
extension SimpleOscePatterns on SimpleOsce {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimpleOsce value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimpleOsce() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimpleOsce value)  $default,){
final _that = this;
switch (_that) {
case _SimpleOsce():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimpleOsce value)?  $default,){
final _that = this;
switch (_that) {
case _SimpleOsce() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String scenario,  bool isPaid,  String? folderId,  String? scenarioImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimpleOsce() when $default != null:
return $default(_that.id,_that.name,_that.scenario,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String scenario,  bool isPaid,  String? folderId,  String? scenarioImageUrl)  $default,) {final _that = this;
switch (_that) {
case _SimpleOsce():
return $default(_that.id,_that.name,_that.scenario,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String scenario,  bool isPaid,  String? folderId,  String? scenarioImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _SimpleOsce() when $default != null:
return $default(_that.id,_that.name,_that.scenario,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimpleOsce implements SimpleOsce {
  const _SimpleOsce({required this.id, required this.name, required this.scenario, required this.isPaid, this.folderId, this.scenarioImageUrl});
  factory _SimpleOsce.fromJson(Map<String, dynamic> json) => _$SimpleOsceFromJson(json);

@override final  String id;
@override final  String name;
@override final  String scenario;
@override final  bool isPaid;
/// Speciality folder; null when the station isn't in a folder.
@override final  String? folderId;
/// Image shown with the description (scenario).
@override final  String? scenarioImageUrl;

/// Create a copy of SimpleOsce
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimpleOsceCopyWith<_SimpleOsce> get copyWith => __$SimpleOsceCopyWithImpl<_SimpleOsce>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimpleOsceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimpleOsce&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.scenarioImageUrl, scenarioImageUrl) || other.scenarioImageUrl == scenarioImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,scenario,isPaid,folderId,scenarioImageUrl);

@override
String toString() {
  return 'SimpleOsce(id: $id, name: $name, scenario: $scenario, isPaid: $isPaid, folderId: $folderId, scenarioImageUrl: $scenarioImageUrl)';
}


}

/// @nodoc
abstract mixin class _$SimpleOsceCopyWith<$Res> implements $SimpleOsceCopyWith<$Res> {
  factory _$SimpleOsceCopyWith(_SimpleOsce value, $Res Function(_SimpleOsce) _then) = __$SimpleOsceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String scenario, bool isPaid, String? folderId, String? scenarioImageUrl
});




}
/// @nodoc
class __$SimpleOsceCopyWithImpl<$Res>
    implements _$SimpleOsceCopyWith<$Res> {
  __$SimpleOsceCopyWithImpl(this._self, this._then);

  final _SimpleOsce _self;
  final $Res Function(_SimpleOsce) _then;

/// Create a copy of SimpleOsce
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? scenario = null,Object? isPaid = null,Object? folderId = freezed,Object? scenarioImageUrl = freezed,}) {
  return _then(_SimpleOsce(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,scenarioImageUrl: freezed == scenarioImageUrl ? _self.scenarioImageUrl : scenarioImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
