// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anki_import_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnkiImportState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AnkiImportState()';
}


}

/// @nodoc
class $AnkiImportStateCopyWith<$Res>  {
$AnkiImportStateCopyWith(AnkiImportState _, $Res Function(AnkiImportState) __);
}


/// Adds pattern-matching-related methods to [AnkiImportState].
extension AnkiImportStatePatterns on AnkiImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AnkiImportInitial value)?  initial,TResult Function( AnkiImportReading value)?  reading,TResult Function( AnkiImportPreview value)?  preview,TResult Function( AnkiImportImporting value)?  importing,TResult Function( AnkiImportDone value)?  done,TResult Function( AnkiImportError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AnkiImportInitial() when initial != null:
return initial(_that);case AnkiImportReading() when reading != null:
return reading(_that);case AnkiImportPreview() when preview != null:
return preview(_that);case AnkiImportImporting() when importing != null:
return importing(_that);case AnkiImportDone() when done != null:
return done(_that);case AnkiImportError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AnkiImportInitial value)  initial,required TResult Function( AnkiImportReading value)  reading,required TResult Function( AnkiImportPreview value)  preview,required TResult Function( AnkiImportImporting value)  importing,required TResult Function( AnkiImportDone value)  done,required TResult Function( AnkiImportError value)  error,}){
final _that = this;
switch (_that) {
case AnkiImportInitial():
return initial(_that);case AnkiImportReading():
return reading(_that);case AnkiImportPreview():
return preview(_that);case AnkiImportImporting():
return importing(_that);case AnkiImportDone():
return done(_that);case AnkiImportError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AnkiImportInitial value)?  initial,TResult? Function( AnkiImportReading value)?  reading,TResult? Function( AnkiImportPreview value)?  preview,TResult? Function( AnkiImportImporting value)?  importing,TResult? Function( AnkiImportDone value)?  done,TResult? Function( AnkiImportError value)?  error,}){
final _that = this;
switch (_that) {
case AnkiImportInitial() when initial != null:
return initial(_that);case AnkiImportReading() when reading != null:
return reading(_that);case AnkiImportPreview() when preview != null:
return preview(_that);case AnkiImportImporting() when importing != null:
return importing(_that);case AnkiImportDone() when done != null:
return done(_that);case AnkiImportError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( String fileName)?  reading,TResult Function( String fileName,  AnkiParseResult result)?  preview,TResult Function( int processed,  int total)?  importing,TResult Function( FlashcardImportSummary summary)?  done,TResult Function( Object error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AnkiImportInitial() when initial != null:
return initial();case AnkiImportReading() when reading != null:
return reading(_that.fileName);case AnkiImportPreview() when preview != null:
return preview(_that.fileName,_that.result);case AnkiImportImporting() when importing != null:
return importing(_that.processed,_that.total);case AnkiImportDone() when done != null:
return done(_that.summary);case AnkiImportError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( String fileName)  reading,required TResult Function( String fileName,  AnkiParseResult result)  preview,required TResult Function( int processed,  int total)  importing,required TResult Function( FlashcardImportSummary summary)  done,required TResult Function( Object error)  error,}) {final _that = this;
switch (_that) {
case AnkiImportInitial():
return initial();case AnkiImportReading():
return reading(_that.fileName);case AnkiImportPreview():
return preview(_that.fileName,_that.result);case AnkiImportImporting():
return importing(_that.processed,_that.total);case AnkiImportDone():
return done(_that.summary);case AnkiImportError():
return error(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( String fileName)?  reading,TResult? Function( String fileName,  AnkiParseResult result)?  preview,TResult? Function( int processed,  int total)?  importing,TResult? Function( FlashcardImportSummary summary)?  done,TResult? Function( Object error)?  error,}) {final _that = this;
switch (_that) {
case AnkiImportInitial() when initial != null:
return initial();case AnkiImportReading() when reading != null:
return reading(_that.fileName);case AnkiImportPreview() when preview != null:
return preview(_that.fileName,_that.result);case AnkiImportImporting() when importing != null:
return importing(_that.processed,_that.total);case AnkiImportDone() when done != null:
return done(_that.summary);case AnkiImportError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AnkiImportInitial implements AnkiImportState {
  const AnkiImportInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AnkiImportState.initial()';
}


}




/// @nodoc


class AnkiImportReading implements AnkiImportState {
  const AnkiImportReading({required this.fileName});
  

 final  String fileName;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnkiImportReadingCopyWith<AnkiImportReading> get copyWith => _$AnkiImportReadingCopyWithImpl<AnkiImportReading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportReading&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,fileName);

@override
String toString() {
  return 'AnkiImportState.reading(fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $AnkiImportReadingCopyWith<$Res> implements $AnkiImportStateCopyWith<$Res> {
  factory $AnkiImportReadingCopyWith(AnkiImportReading value, $Res Function(AnkiImportReading) _then) = _$AnkiImportReadingCopyWithImpl;
@useResult
$Res call({
 String fileName
});




}
/// @nodoc
class _$AnkiImportReadingCopyWithImpl<$Res>
    implements $AnkiImportReadingCopyWith<$Res> {
  _$AnkiImportReadingCopyWithImpl(this._self, this._then);

  final AnkiImportReading _self;
  final $Res Function(AnkiImportReading) _then;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileName = null,}) {
  return _then(AnkiImportReading(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AnkiImportPreview implements AnkiImportState {
  const AnkiImportPreview({required this.fileName, required this.result});
  

 final  String fileName;
 final  AnkiParseResult result;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnkiImportPreviewCopyWith<AnkiImportPreview> get copyWith => _$AnkiImportPreviewCopyWithImpl<AnkiImportPreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportPreview&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,result);

@override
String toString() {
  return 'AnkiImportState.preview(fileName: $fileName, result: $result)';
}


}

/// @nodoc
abstract mixin class $AnkiImportPreviewCopyWith<$Res> implements $AnkiImportStateCopyWith<$Res> {
  factory $AnkiImportPreviewCopyWith(AnkiImportPreview value, $Res Function(AnkiImportPreview) _then) = _$AnkiImportPreviewCopyWithImpl;
@useResult
$Res call({
 String fileName, AnkiParseResult result
});




}
/// @nodoc
class _$AnkiImportPreviewCopyWithImpl<$Res>
    implements $AnkiImportPreviewCopyWith<$Res> {
  _$AnkiImportPreviewCopyWithImpl(this._self, this._then);

  final AnkiImportPreview _self;
  final $Res Function(AnkiImportPreview) _then;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? result = null,}) {
  return _then(AnkiImportPreview(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as AnkiParseResult,
  ));
}


}

/// @nodoc


class AnkiImportImporting implements AnkiImportState {
  const AnkiImportImporting({required this.processed, required this.total});
  

 final  int processed;
 final  int total;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnkiImportImportingCopyWith<AnkiImportImporting> get copyWith => _$AnkiImportImportingCopyWithImpl<AnkiImportImporting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportImporting&&(identical(other.processed, processed) || other.processed == processed)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,processed,total);

@override
String toString() {
  return 'AnkiImportState.importing(processed: $processed, total: $total)';
}


}

/// @nodoc
abstract mixin class $AnkiImportImportingCopyWith<$Res> implements $AnkiImportStateCopyWith<$Res> {
  factory $AnkiImportImportingCopyWith(AnkiImportImporting value, $Res Function(AnkiImportImporting) _then) = _$AnkiImportImportingCopyWithImpl;
@useResult
$Res call({
 int processed, int total
});




}
/// @nodoc
class _$AnkiImportImportingCopyWithImpl<$Res>
    implements $AnkiImportImportingCopyWith<$Res> {
  _$AnkiImportImportingCopyWithImpl(this._self, this._then);

  final AnkiImportImporting _self;
  final $Res Function(AnkiImportImporting) _then;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? processed = null,Object? total = null,}) {
  return _then(AnkiImportImporting(
processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class AnkiImportDone implements AnkiImportState {
  const AnkiImportDone({required this.summary});
  

 final  FlashcardImportSummary summary;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnkiImportDoneCopyWith<AnkiImportDone> get copyWith => _$AnkiImportDoneCopyWithImpl<AnkiImportDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportDone&&(identical(other.summary, summary) || other.summary == summary));
}


@override
int get hashCode => Object.hash(runtimeType,summary);

@override
String toString() {
  return 'AnkiImportState.done(summary: $summary)';
}


}

/// @nodoc
abstract mixin class $AnkiImportDoneCopyWith<$Res> implements $AnkiImportStateCopyWith<$Res> {
  factory $AnkiImportDoneCopyWith(AnkiImportDone value, $Res Function(AnkiImportDone) _then) = _$AnkiImportDoneCopyWithImpl;
@useResult
$Res call({
 FlashcardImportSummary summary
});




}
/// @nodoc
class _$AnkiImportDoneCopyWithImpl<$Res>
    implements $AnkiImportDoneCopyWith<$Res> {
  _$AnkiImportDoneCopyWithImpl(this._self, this._then);

  final AnkiImportDone _self;
  final $Res Function(AnkiImportDone) _then;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? summary = null,}) {
  return _then(AnkiImportDone(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as FlashcardImportSummary,
  ));
}


}

/// @nodoc


class AnkiImportError implements AnkiImportState {
  const AnkiImportError({required this.error});
  

 final  Object error;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnkiImportErrorCopyWith<AnkiImportError> get copyWith => _$AnkiImportErrorCopyWithImpl<AnkiImportError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnkiImportError&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'AnkiImportState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $AnkiImportErrorCopyWith<$Res> implements $AnkiImportStateCopyWith<$Res> {
  factory $AnkiImportErrorCopyWith(AnkiImportError value, $Res Function(AnkiImportError) _then) = _$AnkiImportErrorCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class _$AnkiImportErrorCopyWithImpl<$Res>
    implements $AnkiImportErrorCopyWith<$Res> {
  _$AnkiImportErrorCopyWithImpl(this._self, this._then);

  final AnkiImportError _self;
  final $Res Function(AnkiImportError) _then;

/// Create a copy of AnkiImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AnkiImportError(
error: null == error ? _self.error : error ,
  ));
}


}

// dart format on
