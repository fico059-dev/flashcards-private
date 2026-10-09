// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FlashcardDto {

@JsonKey(includeToJson: false) String? get id; String get packId; String get question; String get answer; bool get isPaid; String? get questionImageUrl; String? get answerImageUrl; List<String> get tags;@JsonKey(includeIfNull: false) String? get sourceKey;@JsonKey(includeIfNull: false) String? get sourceImages;
/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlashcardDtoCopyWith<FlashcardDto> get copyWith => _$FlashcardDtoCopyWithImpl<FlashcardDto>(this as FlashcardDto, _$identity);

  /// Serializes this FlashcardDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlashcardDto&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.questionImageUrl, questionImageUrl) || other.questionImageUrl == questionImageUrl)&&(identical(other.answerImageUrl, answerImageUrl) || other.answerImageUrl == answerImageUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.sourceKey, sourceKey) || other.sourceKey == sourceKey)&&(identical(other.sourceImages, sourceImages) || other.sourceImages == sourceImages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,question,answer,isPaid,questionImageUrl,answerImageUrl,const DeepCollectionEquality().hash(tags),sourceKey,sourceImages);

@override
String toString() {
  return 'FlashcardDto(id: $id, packId: $packId, question: $question, answer: $answer, isPaid: $isPaid, questionImageUrl: $questionImageUrl, answerImageUrl: $answerImageUrl, tags: $tags, sourceKey: $sourceKey, sourceImages: $sourceImages)';
}


}

/// @nodoc
abstract mixin class $FlashcardDtoCopyWith<$Res>  {
  factory $FlashcardDtoCopyWith(FlashcardDto value, $Res Function(FlashcardDto) _then) = _$FlashcardDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String packId, String question, String answer, bool isPaid, String? questionImageUrl, String? answerImageUrl, List<String> tags,@JsonKey(includeIfNull: false) String? sourceKey,@JsonKey(includeIfNull: false) String? sourceImages
});




}
/// @nodoc
class _$FlashcardDtoCopyWithImpl<$Res>
    implements $FlashcardDtoCopyWith<$Res> {
  _$FlashcardDtoCopyWithImpl(this._self, this._then);

  final FlashcardDto _self;
  final $Res Function(FlashcardDto) _then;

/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? packId = null,Object? question = null,Object? answer = null,Object? isPaid = null,Object? questionImageUrl = freezed,Object? answerImageUrl = freezed,Object? tags = null,Object? sourceKey = freezed,Object? sourceImages = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,questionImageUrl: freezed == questionImageUrl ? _self.questionImageUrl : questionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,answerImageUrl: freezed == answerImageUrl ? _self.answerImageUrl : answerImageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,sourceImages: freezed == sourceImages ? _self.sourceImages : sourceImages // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlashcardDto].
extension FlashcardDtoPatterns on FlashcardDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlashcardDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlashcardDto value)  $default,){
final _that = this;
switch (_that) {
case _FlashcardDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlashcardDto value)?  $default,){
final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String packId,  String question,  String answer,  bool isPaid,  String? questionImageUrl,  String? answerImageUrl,  List<String> tags, @JsonKey(includeIfNull: false)  String? sourceKey, @JsonKey(includeIfNull: false)  String? sourceImages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String? id,  String packId,  String question,  String answer,  bool isPaid,  String? questionImageUrl,  String? answerImageUrl,  List<String> tags, @JsonKey(includeIfNull: false)  String? sourceKey, @JsonKey(includeIfNull: false)  String? sourceImages)  $default,) {final _that = this;
switch (_that) {
case _FlashcardDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String? id,  String packId,  String question,  String answer,  bool isPaid,  String? questionImageUrl,  String? answerImageUrl,  List<String> tags, @JsonKey(includeIfNull: false)  String? sourceKey, @JsonKey(includeIfNull: false)  String? sourceImages)?  $default,) {final _that = this;
switch (_that) {
case _FlashcardDto() when $default != null:
return $default(_that.id,_that.packId,_that.question,_that.answer,_that.isPaid,_that.questionImageUrl,_that.answerImageUrl,_that.tags,_that.sourceKey,_that.sourceImages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FlashcardDto implements FlashcardDto {
  const _FlashcardDto({@JsonKey(includeToJson: false) this.id, required this.packId, required this.question, required this.answer, required this.isPaid, this.questionImageUrl = null, this.answerImageUrl = null, final  List<String> tags = const [], @JsonKey(includeIfNull: false) this.sourceKey, @JsonKey(includeIfNull: false) this.sourceImages}): _tags = tags;
  factory _FlashcardDto.fromJson(Map<String, dynamic> json) => _$FlashcardDtoFromJson(json);

@override@JsonKey(includeToJson: false) final  String? id;
@override final  String packId;
@override final  String question;
@override final  String answer;
@override final  bool isPaid;
@override@JsonKey() final  String? questionImageUrl;
@override@JsonKey() final  String? answerImageUrl;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(includeIfNull: false) final  String? sourceKey;
@override@JsonKey(includeIfNull: false) final  String? sourceImages;

/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlashcardDtoCopyWith<_FlashcardDto> get copyWith => __$FlashcardDtoCopyWithImpl<_FlashcardDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlashcardDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlashcardDto&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.questionImageUrl, questionImageUrl) || other.questionImageUrl == questionImageUrl)&&(identical(other.answerImageUrl, answerImageUrl) || other.answerImageUrl == answerImageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.sourceKey, sourceKey) || other.sourceKey == sourceKey)&&(identical(other.sourceImages, sourceImages) || other.sourceImages == sourceImages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,question,answer,isPaid,questionImageUrl,answerImageUrl,const DeepCollectionEquality().hash(_tags),sourceKey,sourceImages);

@override
String toString() {
  return 'FlashcardDto(id: $id, packId: $packId, question: $question, answer: $answer, isPaid: $isPaid, questionImageUrl: $questionImageUrl, answerImageUrl: $answerImageUrl, tags: $tags, sourceKey: $sourceKey, sourceImages: $sourceImages)';
}


}

/// @nodoc
abstract mixin class _$FlashcardDtoCopyWith<$Res> implements $FlashcardDtoCopyWith<$Res> {
  factory _$FlashcardDtoCopyWith(_FlashcardDto value, $Res Function(_FlashcardDto) _then) = __$FlashcardDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String? id, String packId, String question, String answer, bool isPaid, String? questionImageUrl, String? answerImageUrl, List<String> tags,@JsonKey(includeIfNull: false) String? sourceKey,@JsonKey(includeIfNull: false) String? sourceImages
});




}
/// @nodoc
class __$FlashcardDtoCopyWithImpl<$Res>
    implements _$FlashcardDtoCopyWith<$Res> {
  __$FlashcardDtoCopyWithImpl(this._self, this._then);

  final _FlashcardDto _self;
  final $Res Function(_FlashcardDto) _then;

/// Create a copy of FlashcardDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? packId = null,Object? question = null,Object? answer = null,Object? isPaid = null,Object? questionImageUrl = freezed,Object? answerImageUrl = freezed,Object? tags = null,Object? sourceKey = freezed,Object? sourceImages = freezed,}) {
  return _then(_FlashcardDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,questionImageUrl: freezed == questionImageUrl ? _self.questionImageUrl : questionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,answerImageUrl: freezed == answerImageUrl ? _self.answerImageUrl : answerImageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,sourceImages: freezed == sourceImages ? _self.sourceImages : sourceImages // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
