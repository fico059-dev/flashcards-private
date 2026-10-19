// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'algolia_flashcard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlgoliaFlashcard {

 String get objectID; String get question; String get answer; bool get isPaid; List<String> get tags;/// The pack the card is in, for searching one pack.
 String get packId;
/// Create a copy of AlgoliaFlashcard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlgoliaFlashcardCopyWith<AlgoliaFlashcard> get copyWith => _$AlgoliaFlashcardCopyWithImpl<AlgoliaFlashcard>(this as AlgoliaFlashcard, _$identity);

  /// Serializes this AlgoliaFlashcard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlgoliaFlashcard&&(identical(other.objectID, objectID) || other.objectID == objectID)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.packId, packId) || other.packId == packId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectID,question,answer,isPaid,const DeepCollectionEquality().hash(tags),packId);

@override
String toString() {
  return 'AlgoliaFlashcard(objectID: $objectID, question: $question, answer: $answer, isPaid: $isPaid, tags: $tags, packId: $packId)';
}


}

/// @nodoc
abstract mixin class $AlgoliaFlashcardCopyWith<$Res>  {
  factory $AlgoliaFlashcardCopyWith(AlgoliaFlashcard value, $Res Function(AlgoliaFlashcard) _then) = _$AlgoliaFlashcardCopyWithImpl;
@useResult
$Res call({
 String objectID, String question, String answer, bool isPaid, List<String> tags, String packId
});




}
/// @nodoc
class _$AlgoliaFlashcardCopyWithImpl<$Res>
    implements $AlgoliaFlashcardCopyWith<$Res> {
  _$AlgoliaFlashcardCopyWithImpl(this._self, this._then);

  final AlgoliaFlashcard _self;
  final $Res Function(AlgoliaFlashcard) _then;

/// Create a copy of AlgoliaFlashcard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectID = null,Object? question = null,Object? answer = null,Object? isPaid = null,Object? tags = null,Object? packId = null,}) {
  return _then(_self.copyWith(
objectID: null == objectID ? _self.objectID : objectID // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AlgoliaFlashcard].
extension AlgoliaFlashcardPatterns on AlgoliaFlashcard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlgoliaFlashcard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlgoliaFlashcard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlgoliaFlashcard value)  $default,){
final _that = this;
switch (_that) {
case _AlgoliaFlashcard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlgoliaFlashcard value)?  $default,){
final _that = this;
switch (_that) {
case _AlgoliaFlashcard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectID,  String question,  String answer,  bool isPaid,  List<String> tags,  String packId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlgoliaFlashcard() when $default != null:
return $default(_that.objectID,_that.question,_that.answer,_that.isPaid,_that.tags,_that.packId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectID,  String question,  String answer,  bool isPaid,  List<String> tags,  String packId)  $default,) {final _that = this;
switch (_that) {
case _AlgoliaFlashcard():
return $default(_that.objectID,_that.question,_that.answer,_that.isPaid,_that.tags,_that.packId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectID,  String question,  String answer,  bool isPaid,  List<String> tags,  String packId)?  $default,) {final _that = this;
switch (_that) {
case _AlgoliaFlashcard() when $default != null:
return $default(_that.objectID,_that.question,_that.answer,_that.isPaid,_that.tags,_that.packId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlgoliaFlashcard implements AlgoliaFlashcard {
  const _AlgoliaFlashcard({required this.objectID, required this.question, required this.answer, required this.isPaid, required final  List<String> tags, this.packId = ''}): _tags = tags;
  factory _AlgoliaFlashcard.fromJson(Map<String, dynamic> json) => _$AlgoliaFlashcardFromJson(json);

@override final  String objectID;
@override final  String question;
@override final  String answer;
@override final  bool isPaid;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// The pack the card is in, for searching one pack.
@override@JsonKey() final  String packId;

/// Create a copy of AlgoliaFlashcard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlgoliaFlashcardCopyWith<_AlgoliaFlashcard> get copyWith => __$AlgoliaFlashcardCopyWithImpl<_AlgoliaFlashcard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlgoliaFlashcardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlgoliaFlashcard&&(identical(other.objectID, objectID) || other.objectID == objectID)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.packId, packId) || other.packId == packId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectID,question,answer,isPaid,const DeepCollectionEquality().hash(_tags),packId);

@override
String toString() {
  return 'AlgoliaFlashcard(objectID: $objectID, question: $question, answer: $answer, isPaid: $isPaid, tags: $tags, packId: $packId)';
}


}

/// @nodoc
abstract mixin class _$AlgoliaFlashcardCopyWith<$Res> implements $AlgoliaFlashcardCopyWith<$Res> {
  factory _$AlgoliaFlashcardCopyWith(_AlgoliaFlashcard value, $Res Function(_AlgoliaFlashcard) _then) = __$AlgoliaFlashcardCopyWithImpl;
@override @useResult
$Res call({
 String objectID, String question, String answer, bool isPaid, List<String> tags, String packId
});




}
/// @nodoc
class __$AlgoliaFlashcardCopyWithImpl<$Res>
    implements _$AlgoliaFlashcardCopyWith<$Res> {
  __$AlgoliaFlashcardCopyWithImpl(this._self, this._then);

  final _AlgoliaFlashcard _self;
  final $Res Function(_AlgoliaFlashcard) _then;

/// Create a copy of AlgoliaFlashcard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectID = null,Object? question = null,Object? answer = null,Object? isPaid = null,Object? tags = null,Object? packId = null,}) {
  return _then(_AlgoliaFlashcard(
objectID: null == objectID ? _self.objectID : objectID // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
