// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Pack {

 String get id; String get name; int get flashcardsCount; int get dueCount; int get newCount; int get learningCount; Map<String, int> get tagCounts; bool get isPaid;/// The pack this one is shown inside, if any.
 String? get parentId;/// Every pack inside this one (all levels). Studying this pack also
/// studies their cards.
 List<Pack> get subPacks;
/// Create a copy of Pack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackCopyWith<Pack> get copyWith => _$PackCopyWithImpl<Pack>(this as Pack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pack&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.flashcardsCount, flashcardsCount) || other.flashcardsCount == flashcardsCount)&&(identical(other.dueCount, dueCount) || other.dueCount == dueCount)&&(identical(other.newCount, newCount) || other.newCount == newCount)&&(identical(other.learningCount, learningCount) || other.learningCount == learningCount)&&const DeepCollectionEquality().equals(other.tagCounts, tagCounts)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&const DeepCollectionEquality().equals(other.subPacks, subPacks));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,flashcardsCount,dueCount,newCount,learningCount,const DeepCollectionEquality().hash(tagCounts),isPaid,parentId,const DeepCollectionEquality().hash(subPacks));

@override
String toString() {
  return 'Pack(id: $id, name: $name, flashcardsCount: $flashcardsCount, dueCount: $dueCount, newCount: $newCount, learningCount: $learningCount, tagCounts: $tagCounts, isPaid: $isPaid, parentId: $parentId, subPacks: $subPacks)';
}


}

/// @nodoc
abstract mixin class $PackCopyWith<$Res>  {
  factory $PackCopyWith(Pack value, $Res Function(Pack) _then) = _$PackCopyWithImpl;
@useResult
$Res call({
 String id, String name, int flashcardsCount, int dueCount, int newCount, int learningCount, Map<String, int> tagCounts, bool isPaid, String? parentId, List<Pack> subPacks
});




}
/// @nodoc
class _$PackCopyWithImpl<$Res>
    implements $PackCopyWith<$Res> {
  _$PackCopyWithImpl(this._self, this._then);

  final Pack _self;
  final $Res Function(Pack) _then;

/// Create a copy of Pack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? flashcardsCount = null,Object? dueCount = null,Object? newCount = null,Object? learningCount = null,Object? tagCounts = null,Object? isPaid = null,Object? parentId = freezed,Object? subPacks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,flashcardsCount: null == flashcardsCount ? _self.flashcardsCount : flashcardsCount // ignore: cast_nullable_to_non_nullable
as int,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,newCount: null == newCount ? _self.newCount : newCount // ignore: cast_nullable_to_non_nullable
as int,learningCount: null == learningCount ? _self.learningCount : learningCount // ignore: cast_nullable_to_non_nullable
as int,tagCounts: null == tagCounts ? _self.tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,subPacks: null == subPacks ? _self.subPacks : subPacks // ignore: cast_nullable_to_non_nullable
as List<Pack>,
  ));
}

}


/// Adds pattern-matching-related methods to [Pack].
extension PackPatterns on Pack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pack value)  $default,){
final _that = this;
switch (_that) {
case _Pack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pack value)?  $default,){
final _that = this;
switch (_that) {
case _Pack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int flashcardsCount,  int dueCount,  int newCount,  int learningCount,  Map<String, int> tagCounts,  bool isPaid,  String? parentId,  List<Pack> subPacks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pack() when $default != null:
return $default(_that.id,_that.name,_that.flashcardsCount,_that.dueCount,_that.newCount,_that.learningCount,_that.tagCounts,_that.isPaid,_that.parentId,_that.subPacks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int flashcardsCount,  int dueCount,  int newCount,  int learningCount,  Map<String, int> tagCounts,  bool isPaid,  String? parentId,  List<Pack> subPacks)  $default,) {final _that = this;
switch (_that) {
case _Pack():
return $default(_that.id,_that.name,_that.flashcardsCount,_that.dueCount,_that.newCount,_that.learningCount,_that.tagCounts,_that.isPaid,_that.parentId,_that.subPacks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int flashcardsCount,  int dueCount,  int newCount,  int learningCount,  Map<String, int> tagCounts,  bool isPaid,  String? parentId,  List<Pack> subPacks)?  $default,) {final _that = this;
switch (_that) {
case _Pack() when $default != null:
return $default(_that.id,_that.name,_that.flashcardsCount,_that.dueCount,_that.newCount,_that.learningCount,_that.tagCounts,_that.isPaid,_that.parentId,_that.subPacks);case _:
  return null;

}
}

}

/// @nodoc


class _Pack implements Pack {
  const _Pack({required this.id, required this.name, required this.flashcardsCount, required this.dueCount, required this.newCount, required this.learningCount, final  Map<String, int> tagCounts = const {}, this.isPaid = false, this.parentId, final  List<Pack> subPacks = const []}): _tagCounts = tagCounts,_subPacks = subPacks;
  

@override final  String id;
@override final  String name;
@override final  int flashcardsCount;
@override final  int dueCount;
@override final  int newCount;
@override final  int learningCount;
 final  Map<String, int> _tagCounts;
@override@JsonKey() Map<String, int> get tagCounts {
  if (_tagCounts is EqualUnmodifiableMapView) return _tagCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tagCounts);
}

@override@JsonKey() final  bool isPaid;
/// The pack this one is shown inside, if any.
@override final  String? parentId;
/// Every pack inside this one (all levels). Studying this pack also
/// studies their cards.
 final  List<Pack> _subPacks;
/// Every pack inside this one (all levels). Studying this pack also
/// studies their cards.
@override@JsonKey() List<Pack> get subPacks {
  if (_subPacks is EqualUnmodifiableListView) return _subPacks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subPacks);
}


/// Create a copy of Pack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackCopyWith<_Pack> get copyWith => __$PackCopyWithImpl<_Pack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pack&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.flashcardsCount, flashcardsCount) || other.flashcardsCount == flashcardsCount)&&(identical(other.dueCount, dueCount) || other.dueCount == dueCount)&&(identical(other.newCount, newCount) || other.newCount == newCount)&&(identical(other.learningCount, learningCount) || other.learningCount == learningCount)&&const DeepCollectionEquality().equals(other._tagCounts, _tagCounts)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&const DeepCollectionEquality().equals(other._subPacks, _subPacks));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,flashcardsCount,dueCount,newCount,learningCount,const DeepCollectionEquality().hash(_tagCounts),isPaid,parentId,const DeepCollectionEquality().hash(_subPacks));

@override
String toString() {
  return 'Pack(id: $id, name: $name, flashcardsCount: $flashcardsCount, dueCount: $dueCount, newCount: $newCount, learningCount: $learningCount, tagCounts: $tagCounts, isPaid: $isPaid, parentId: $parentId, subPacks: $subPacks)';
}


}

/// @nodoc
abstract mixin class _$PackCopyWith<$Res> implements $PackCopyWith<$Res> {
  factory _$PackCopyWith(_Pack value, $Res Function(_Pack) _then) = __$PackCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int flashcardsCount, int dueCount, int newCount, int learningCount, Map<String, int> tagCounts, bool isPaid, String? parentId, List<Pack> subPacks
});




}
/// @nodoc
class __$PackCopyWithImpl<$Res>
    implements _$PackCopyWith<$Res> {
  __$PackCopyWithImpl(this._self, this._then);

  final _Pack _self;
  final $Res Function(_Pack) _then;

/// Create a copy of Pack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? flashcardsCount = null,Object? dueCount = null,Object? newCount = null,Object? learningCount = null,Object? tagCounts = null,Object? isPaid = null,Object? parentId = freezed,Object? subPacks = null,}) {
  return _then(_Pack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,flashcardsCount: null == flashcardsCount ? _self.flashcardsCount : flashcardsCount // ignore: cast_nullable_to_non_nullable
as int,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,newCount: null == newCount ? _self.newCount : newCount // ignore: cast_nullable_to_non_nullable
as int,learningCount: null == learningCount ? _self.learningCount : learningCount // ignore: cast_nullable_to_non_nullable
as int,tagCounts: null == tagCounts ? _self._tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,subPacks: null == subPacks ? _self._subPacks : subPacks // ignore: cast_nullable_to_non_nullable
as List<Pack>,
  ));
}


}

// dart format on
