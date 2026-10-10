// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Flashcard {

 String get id; String get packId; String get question; String get answer; bool get isPaid; String? get questionImageUrl; String? get answerImageUrl; List<Tag> get tags;/// The Anki note the card was imported from (e.g. "anki:<guid>"), so
/// importing the deck again updates the card instead of duplicating it.
 String? get sourceKey;/// The Anki image names the card was imported with.
 String? get sourceImages;
/// Create a copy of Flashcard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlashcardCopyWith<Flashcard> get copyWith => _$FlashcardCopyWithImpl<Flashcard>(this as Flashcard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Flashcard&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.questionImageUrl, questionImageUrl) || other.questionImageUrl == questionImageUrl)&&(identical(other.answerImageUrl, answerImageUrl) || other.answerImageUrl == answerImageUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.sourceKey, sourceKey) || other.sourceKey == sourceKey)&&(identical(other.sourceImages, sourceImages) || other.sourceImages == sourceImages));
}


@override
int get hashCode => Object.hash(runtimeType,id,packId,question,answer,isPaid,questionImageUrl,answerImageUrl,const DeepCollectionEquality().hash(tags),sourceKey,sourceImages);

@override
String toString() {
  return 'Flashcard(id: $id, packId: $packId, question: $question, answer: $answer, isPaid: $isPaid, questionImageUrl: $questionImageUrl, answerImageUrl: $answerImageUrl, tags: $tags, sourceKey: $sourceKey, sourceImages: $sourceImages)';
}


}

/// @nodoc
abstract mixin class $FlashcardCopyWith<$Res>  {
  factory $FlashcardCopyWith(Flashcard value, $Res Function(Flashcard) _then) = _$FlashcardCopyWithImpl;
@useResult
$Res call({
 String id, String packId, String question, String answer, bool isPaid, String? questionImageUrl, String? answerImageUrl, List<Tag> tags, String? sourceKey, String? sourceImages
});




}
/// @nodoc
class _$FlashcardCopyWithImpl<$Res>
    implements $FlashcardCopyWith<$Res> {
  _$FlashcardCopyWithImpl(this._self, this._then);

  final Flashcard _self;
  final $Res Function(Flashcard) _then;

/// Create a copy of Flashcard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? packId = null,Object? question = null,Object? answer = null,Object? isPaid = null,Object? questionImageUrl = freezed,Object? answerImageUrl = freezed,Object? tags = null,Object? sourceKey = freezed,Object? sourceImages = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,questionImageUrl: freezed == questionImageUrl ? _self.questionImageUrl : questionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,answerImageUrl: freezed == answerImageUrl ? _self.answerImageUrl : answerImageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,sourceImages: freezed == sourceImages ? _self.sourceImages : sourceImages // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Flashcard].
extension FlashcardPatterns on Flashcard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Flashcard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Flashcard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Flashcard value)  $default,){
final _that = this;
switch (_that) {
case _Flashcard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Flashcard value)?  $default,){
final _that = this;
switch (_that) {
case _Flashcard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String packId,  String question,  String answer,  bool isPaid,  String? questionImageUrl,  String? answerImageUrl,  List<Tag> tags,  String? sourceKey,  String? sourceImages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Flashcard() when $default != null:
return $default(_that.id,_that.packId,_that.question,_that.answer,_that.isPaid,_that.questionImageUrl,_that.answerImageUrl,_that.tags,_that.sourceKey,_that.sourceImages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String packId,  String question,  String answer,  bool isPaid,  String? questionImageUrl,  String? answerImageUrl,  List<Tag> tags,  String? sourceKey,  String? sourceImages)  $default,) {final _that = this;
switch (_that) {
case _Flashcard():
return $default(_that.id,_that.packId,_that.question,_that.answer,_that.isPaid,_that.questionImageUrl,_that.answerImageUrl,_that.tags,_that.sourceKey,_that.sourceImages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String packId,  String question,  String answer,  bool isPaid,  String? questionImageUrl,  String? answerImageUrl,  List<Tag> tags,  String? sourceKey,  String? sourceImages)?  $default,) {final _that = this;
switch (_that) {
case _Flashcard() when $default != null:
return $default(_that.id,_that.packId,_that.question,_that.answer,_that.isPaid,_that.questionImageUrl,_that.answerImageUrl,_that.tags,_that.sourceKey,_that.sourceImages);case _:
  return null;

}
}

}

/// @nodoc


class _Flashcard implements Flashcard {
  const _Flashcard({required this.id, required this.packId, required this.question, required this.answer, this.isPaid = false, this.questionImageUrl, this.answerImageUrl, required final  List<Tag> tags, this.sourceKey, this.sourceImages}): _tags = tags;
  

@override final  String id;
@override final  String packId;
@override final  String question;
@override final  String answer;
@override@JsonKey() final  bool isPaid;
@override final  String? questionImageUrl;
@override final  String? answerImageUrl;
 final  List<Tag> _tags;
@override List<Tag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// The Anki note the card was imported from (e.g. "anki:<guid>"), so
/// importing the deck again updates the card instead of duplicating it.
@override final  String? sourceKey;
/// The Anki image names the card was imported with.
@override final  String? sourceImages;

/// Create a copy of Flashcard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlashcardCopyWith<_Flashcard> get copyWith => __$FlashcardCopyWithImpl<_Flashcard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Flashcard&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.questionImageUrl, questionImageUrl) || other.questionImageUrl == questionImageUrl)&&(identical(other.answerImageUrl, answerImageUrl) || other.answerImageUrl == answerImageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.sourceKey, sourceKey) || other.sourceKey == sourceKey)&&(identical(other.sourceImages, sourceImages) || other.sourceImages == sourceImages));
}


@override
int get hashCode => Object.hash(runtimeType,id,packId,question,answer,isPaid,questionImageUrl,answerImageUrl,const DeepCollectionEquality().hash(_tags),sourceKey,sourceImages);

@override
String toString() {
  return 'Flashcard(id: $id, packId: $packId, question: $question, answer: $answer, isPaid: $isPaid, questionImageUrl: $questionImageUrl, answerImageUrl: $answerImageUrl, tags: $tags, sourceKey: $sourceKey, sourceImages: $sourceImages)';
}


}

/// @nodoc
abstract mixin class _$FlashcardCopyWith<$Res> implements $FlashcardCopyWith<$Res> {
  factory _$FlashcardCopyWith(_Flashcard value, $Res Function(_Flashcard) _then) = __$FlashcardCopyWithImpl;
@override @useResult
$Res call({
 String id, String packId, String question, String answer, bool isPaid, String? questionImageUrl, String? answerImageUrl, List<Tag> tags, String? sourceKey, String? sourceImages
});




}
/// @nodoc
class __$FlashcardCopyWithImpl<$Res>
    implements _$FlashcardCopyWith<$Res> {
  __$FlashcardCopyWithImpl(this._self, this._then);

  final _Flashcard _self;
  final $Res Function(_Flashcard) _then;

/// Create a copy of Flashcard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? packId = null,Object? question = null,Object? answer = null,Object? isPaid = null,Object? questionImageUrl = freezed,Object? answerImageUrl = freezed,Object? tags = null,Object? sourceKey = freezed,Object? sourceImages = freezed,}) {
  return _then(_Flashcard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,questionImageUrl: freezed == questionImageUrl ? _self.questionImageUrl : questionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,answerImageUrl: freezed == answerImageUrl ? _self.answerImageUrl : answerImageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,sourceImages: freezed == sourceImages ? _self.sourceImages : sourceImages // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
