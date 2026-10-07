// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminPack {

 String get packId; String get packName; int get flashcardsCount; bool get isPaid; Map<String, int> get tagCounts;/// When not empty, only these users (and admins) see the pack.
 List<String> get allowedEmails;
/// Create a copy of AdminPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminPackCopyWith<AdminPack> get copyWith => _$AdminPackCopyWithImpl<AdminPack>(this as AdminPack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminPack&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.packName, packName) || other.packName == packName)&&(identical(other.flashcardsCount, flashcardsCount) || other.flashcardsCount == flashcardsCount)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&const DeepCollectionEquality().equals(other.tagCounts, tagCounts)&&const DeepCollectionEquality().equals(other.allowedEmails, allowedEmails));
}


@override
int get hashCode => Object.hash(runtimeType,packId,packName,flashcardsCount,isPaid,const DeepCollectionEquality().hash(tagCounts),const DeepCollectionEquality().hash(allowedEmails));

@override
String toString() {
  return 'AdminPack(packId: $packId, packName: $packName, flashcardsCount: $flashcardsCount, isPaid: $isPaid, tagCounts: $tagCounts, allowedEmails: $allowedEmails)';
}


}

/// @nodoc
abstract mixin class $AdminPackCopyWith<$Res>  {
  factory $AdminPackCopyWith(AdminPack value, $Res Function(AdminPack) _then) = _$AdminPackCopyWithImpl;
@useResult
$Res call({
 String packId, String packName, int flashcardsCount, bool isPaid, Map<String, int> tagCounts, List<String> allowedEmails
});




}
/// @nodoc
class _$AdminPackCopyWithImpl<$Res>
    implements $AdminPackCopyWith<$Res> {
  _$AdminPackCopyWithImpl(this._self, this._then);

  final AdminPack _self;
  final $Res Function(AdminPack) _then;

/// Create a copy of AdminPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packId = null,Object? packName = null,Object? flashcardsCount = null,Object? isPaid = null,Object? tagCounts = null,Object? allowedEmails = null,}) {
  return _then(_self.copyWith(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,packName: null == packName ? _self.packName : packName // ignore: cast_nullable_to_non_nullable
as String,flashcardsCount: null == flashcardsCount ? _self.flashcardsCount : flashcardsCount // ignore: cast_nullable_to_non_nullable
as int,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,tagCounts: null == tagCounts ? _self.tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,allowedEmails: null == allowedEmails ? _self.allowedEmails : allowedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminPack].
extension AdminPackPatterns on AdminPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminPack value)  $default,){
final _that = this;
switch (_that) {
case _AdminPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminPack value)?  $default,){
final _that = this;
switch (_that) {
case _AdminPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packId,  String packName,  int flashcardsCount,  bool isPaid,  Map<String, int> tagCounts,  List<String> allowedEmails)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminPack() when $default != null:
return $default(_that.packId,_that.packName,_that.flashcardsCount,_that.isPaid,_that.tagCounts,_that.allowedEmails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packId,  String packName,  int flashcardsCount,  bool isPaid,  Map<String, int> tagCounts,  List<String> allowedEmails)  $default,) {final _that = this;
switch (_that) {
case _AdminPack():
return $default(_that.packId,_that.packName,_that.flashcardsCount,_that.isPaid,_that.tagCounts,_that.allowedEmails);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packId,  String packName,  int flashcardsCount,  bool isPaid,  Map<String, int> tagCounts,  List<String> allowedEmails)?  $default,) {final _that = this;
switch (_that) {
case _AdminPack() when $default != null:
return $default(_that.packId,_that.packName,_that.flashcardsCount,_that.isPaid,_that.tagCounts,_that.allowedEmails);case _:
  return null;

}
}

}

/// @nodoc


class _AdminPack implements AdminPack {
  const _AdminPack({required this.packId, required this.packName, required this.flashcardsCount, required this.isPaid, final  Map<String, int> tagCounts = const {}, final  List<String> allowedEmails = const []}): _tagCounts = tagCounts,_allowedEmails = allowedEmails;
  

@override final  String packId;
@override final  String packName;
@override final  int flashcardsCount;
@override final  bool isPaid;
 final  Map<String, int> _tagCounts;
@override@JsonKey() Map<String, int> get tagCounts {
  if (_tagCounts is EqualUnmodifiableMapView) return _tagCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tagCounts);
}

/// When not empty, only these users (and admins) see the pack.
 final  List<String> _allowedEmails;
/// When not empty, only these users (and admins) see the pack.
@override@JsonKey() List<String> get allowedEmails {
  if (_allowedEmails is EqualUnmodifiableListView) return _allowedEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedEmails);
}


/// Create a copy of AdminPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminPackCopyWith<_AdminPack> get copyWith => __$AdminPackCopyWithImpl<_AdminPack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminPack&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.packName, packName) || other.packName == packName)&&(identical(other.flashcardsCount, flashcardsCount) || other.flashcardsCount == flashcardsCount)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&const DeepCollectionEquality().equals(other._tagCounts, _tagCounts)&&const DeepCollectionEquality().equals(other._allowedEmails, _allowedEmails));
}


@override
int get hashCode => Object.hash(runtimeType,packId,packName,flashcardsCount,isPaid,const DeepCollectionEquality().hash(_tagCounts),const DeepCollectionEquality().hash(_allowedEmails));

@override
String toString() {
  return 'AdminPack(packId: $packId, packName: $packName, flashcardsCount: $flashcardsCount, isPaid: $isPaid, tagCounts: $tagCounts, allowedEmails: $allowedEmails)';
}


}

/// @nodoc
abstract mixin class _$AdminPackCopyWith<$Res> implements $AdminPackCopyWith<$Res> {
  factory _$AdminPackCopyWith(_AdminPack value, $Res Function(_AdminPack) _then) = __$AdminPackCopyWithImpl;
@override @useResult
$Res call({
 String packId, String packName, int flashcardsCount, bool isPaid, Map<String, int> tagCounts, List<String> allowedEmails
});




}
/// @nodoc
class __$AdminPackCopyWithImpl<$Res>
    implements _$AdminPackCopyWith<$Res> {
  __$AdminPackCopyWithImpl(this._self, this._then);

  final _AdminPack _self;
  final $Res Function(_AdminPack) _then;

/// Create a copy of AdminPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packId = null,Object? packName = null,Object? flashcardsCount = null,Object? isPaid = null,Object? tagCounts = null,Object? allowedEmails = null,}) {
  return _then(_AdminPack(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,packName: null == packName ? _self.packName : packName // ignore: cast_nullable_to_non_nullable
as String,flashcardsCount: null == flashcardsCount ? _self.flashcardsCount : flashcardsCount // ignore: cast_nullable_to_non_nullable
as int,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,tagCounts: null == tagCounts ? _self._tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,allowedEmails: null == allowedEmails ? _self._allowedEmails : allowedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
