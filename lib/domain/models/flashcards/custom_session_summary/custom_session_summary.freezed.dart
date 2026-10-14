// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_session_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomSessionSummary {

 String get id; DateTime get createdAt; bool get isPaid; int get cardCount; int get correctCount; int get currentIndex; String? get name;
/// Create a copy of CustomSessionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomSessionSummaryCopyWith<CustomSessionSummary> get copyWith => _$CustomSessionSummaryCopyWithImpl<CustomSessionSummary>(this as CustomSessionSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomSessionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,isPaid,cardCount,correctCount,currentIndex,name);

@override
String toString() {
  return 'CustomSessionSummary(id: $id, createdAt: $createdAt, isPaid: $isPaid, cardCount: $cardCount, correctCount: $correctCount, currentIndex: $currentIndex, name: $name)';
}


}

/// @nodoc
abstract mixin class $CustomSessionSummaryCopyWith<$Res>  {
  factory $CustomSessionSummaryCopyWith(CustomSessionSummary value, $Res Function(CustomSessionSummary) _then) = _$CustomSessionSummaryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, bool isPaid, int cardCount, int correctCount, int currentIndex, String? name
});




}
/// @nodoc
class _$CustomSessionSummaryCopyWithImpl<$Res>
    implements $CustomSessionSummaryCopyWith<$Res> {
  _$CustomSessionSummaryCopyWithImpl(this._self, this._then);

  final CustomSessionSummary _self;
  final $Res Function(CustomSessionSummary) _then;

/// Create a copy of CustomSessionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? isPaid = null,Object? cardCount = null,Object? correctCount = null,Object? currentIndex = null,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomSessionSummary].
extension CustomSessionSummaryPatterns on CustomSessionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomSeesionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomSeesionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomSeesionSummary value)  $default,){
final _that = this;
switch (_that) {
case _CustomSeesionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomSeesionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CustomSeesionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  bool isPaid,  int cardCount,  int correctCount,  int currentIndex,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomSeesionSummary() when $default != null:
return $default(_that.id,_that.createdAt,_that.isPaid,_that.cardCount,_that.correctCount,_that.currentIndex,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  bool isPaid,  int cardCount,  int correctCount,  int currentIndex,  String? name)  $default,) {final _that = this;
switch (_that) {
case _CustomSeesionSummary():
return $default(_that.id,_that.createdAt,_that.isPaid,_that.cardCount,_that.correctCount,_that.currentIndex,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  bool isPaid,  int cardCount,  int correctCount,  int currentIndex,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _CustomSeesionSummary() when $default != null:
return $default(_that.id,_that.createdAt,_that.isPaid,_that.cardCount,_that.correctCount,_that.currentIndex,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _CustomSeesionSummary implements CustomSessionSummary {
  const _CustomSeesionSummary({required this.id, required this.createdAt, required this.isPaid, required this.cardCount, required this.correctCount, required this.currentIndex, this.name});
  

@override final  String id;
@override final  DateTime createdAt;
@override final  bool isPaid;
@override final  int cardCount;
@override final  int correctCount;
@override final  int currentIndex;
@override final  String? name;

/// Create a copy of CustomSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomSeesionSummaryCopyWith<_CustomSeesionSummary> get copyWith => __$CustomSeesionSummaryCopyWithImpl<_CustomSeesionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomSeesionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,isPaid,cardCount,correctCount,currentIndex,name);

@override
String toString() {
  return 'CustomSessionSummary(id: $id, createdAt: $createdAt, isPaid: $isPaid, cardCount: $cardCount, correctCount: $correctCount, currentIndex: $currentIndex, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CustomSeesionSummaryCopyWith<$Res> implements $CustomSessionSummaryCopyWith<$Res> {
  factory _$CustomSeesionSummaryCopyWith(_CustomSeesionSummary value, $Res Function(_CustomSeesionSummary) _then) = __$CustomSeesionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, bool isPaid, int cardCount, int correctCount, int currentIndex, String? name
});




}
/// @nodoc
class __$CustomSeesionSummaryCopyWithImpl<$Res>
    implements _$CustomSeesionSummaryCopyWith<$Res> {
  __$CustomSeesionSummaryCopyWithImpl(this._self, this._then);

  final _CustomSeesionSummary _self;
  final $Res Function(_CustomSeesionSummary) _then;

/// Create a copy of CustomSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? isPaid = null,Object? cardCount = null,Object? correctCount = null,Object? currentIndex = null,Object? name = freezed,}) {
  return _then(_CustomSeesionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
