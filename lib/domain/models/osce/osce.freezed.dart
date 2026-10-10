// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'osce.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Osce {

 String get id; String get name; String get scenario; List<Question> get questions; bool get isPaid; String? get folderId; String? get scenarioImageUrl;
/// Create a copy of Osce
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OsceCopyWith<Osce> get copyWith => _$OsceCopyWithImpl<Osce>(this as Osce, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Osce&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.scenarioImageUrl, scenarioImageUrl) || other.scenarioImageUrl == scenarioImageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,scenario,const DeepCollectionEquality().hash(questions),isPaid,folderId,scenarioImageUrl);

@override
String toString() {
  return 'Osce(id: $id, name: $name, scenario: $scenario, questions: $questions, isPaid: $isPaid, folderId: $folderId, scenarioImageUrl: $scenarioImageUrl)';
}


}

/// @nodoc
abstract mixin class $OsceCopyWith<$Res>  {
  factory $OsceCopyWith(Osce value, $Res Function(Osce) _then) = _$OsceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String scenario, List<Question> questions, bool isPaid, String? folderId, String? scenarioImageUrl
});




}
/// @nodoc
class _$OsceCopyWithImpl<$Res>
    implements $OsceCopyWith<$Res> {
  _$OsceCopyWithImpl(this._self, this._then);

  final Osce _self;
  final $Res Function(Osce) _then;

/// Create a copy of Osce
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? scenario = null,Object? questions = null,Object? isPaid = null,Object? folderId = freezed,Object? scenarioImageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,scenarioImageUrl: freezed == scenarioImageUrl ? _self.scenarioImageUrl : scenarioImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Osce].
extension OscePatterns on Osce {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Osce value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Osce() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Osce value)  $default,){
final _that = this;
switch (_that) {
case _Osce():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Osce value)?  $default,){
final _that = this;
switch (_that) {
case _Osce() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String scenario,  List<Question> questions,  bool isPaid,  String? folderId,  String? scenarioImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Osce() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String scenario,  List<Question> questions,  bool isPaid,  String? folderId,  String? scenarioImageUrl)  $default,) {final _that = this;
switch (_that) {
case _Osce():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String scenario,  List<Question> questions,  bool isPaid,  String? folderId,  String? scenarioImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Osce() when $default != null:
return $default(_that.id,_that.name,_that.scenario,_that.questions,_that.isPaid,_that.folderId,_that.scenarioImageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Osce implements Osce {
  const _Osce({required this.id, required this.name, required this.scenario, required final  List<Question> questions, this.isPaid = false, this.folderId, this.scenarioImageUrl}): _questions = questions;
  

@override final  String id;
@override final  String name;
@override final  String scenario;
 final  List<Question> _questions;
@override List<Question> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override@JsonKey() final  bool isPaid;
@override final  String? folderId;
@override final  String? scenarioImageUrl;

/// Create a copy of Osce
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OsceCopyWith<_Osce> get copyWith => __$OsceCopyWithImpl<_Osce>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Osce&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.scenarioImageUrl, scenarioImageUrl) || other.scenarioImageUrl == scenarioImageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,scenario,const DeepCollectionEquality().hash(_questions),isPaid,folderId,scenarioImageUrl);

@override
String toString() {
  return 'Osce(id: $id, name: $name, scenario: $scenario, questions: $questions, isPaid: $isPaid, folderId: $folderId, scenarioImageUrl: $scenarioImageUrl)';
}


}

/// @nodoc
abstract mixin class _$OsceCopyWith<$Res> implements $OsceCopyWith<$Res> {
  factory _$OsceCopyWith(_Osce value, $Res Function(_Osce) _then) = __$OsceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String scenario, List<Question> questions, bool isPaid, String? folderId, String? scenarioImageUrl
});




}
/// @nodoc
class __$OsceCopyWithImpl<$Res>
    implements _$OsceCopyWith<$Res> {
  __$OsceCopyWithImpl(this._self, this._then);

  final _Osce _self;
  final $Res Function(_Osce) _then;

/// Create a copy of Osce
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? scenario = null,Object? questions = null,Object? isPaid = null,Object? folderId = freezed,Object? scenarioImageUrl = freezed,}) {
  return _then(_Osce(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,scenarioImageUrl: freezed == scenarioImageUrl ? _self.scenarioImageUrl : scenarioImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
