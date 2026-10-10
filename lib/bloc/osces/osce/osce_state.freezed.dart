// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'osce_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OsceState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OsceState()';
}


}

/// @nodoc
class $OsceStateCopyWith<$Res>  {
$OsceStateCopyWith(OsceState _, $Res Function(OsceState) __);
}


/// Adds pattern-matching-related methods to [OsceState].
extension OsceStatePatterns on OsceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OsceInitial value)?  initial,TResult Function( OsceLoading value)?  loading,TResult Function( OsceShowcase value)?  osceShowcase,TResult Function( OsceLoaded value)?  loaded,TResult Function( OsceError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OsceInitial() when initial != null:
return initial(_that);case OsceLoading() when loading != null:
return loading(_that);case OsceShowcase() when osceShowcase != null:
return osceShowcase(_that);case OsceLoaded() when loaded != null:
return loaded(_that);case OsceError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OsceInitial value)  initial,required TResult Function( OsceLoading value)  loading,required TResult Function( OsceShowcase value)  osceShowcase,required TResult Function( OsceLoaded value)  loaded,required TResult Function( OsceError value)  error,}){
final _that = this;
switch (_that) {
case OsceInitial():
return initial(_that);case OsceLoading():
return loading(_that);case OsceShowcase():
return osceShowcase(_that);case OsceLoaded():
return loaded(_that);case OsceError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OsceInitial value)?  initial,TResult? Function( OsceLoading value)?  loading,TResult? Function( OsceShowcase value)?  osceShowcase,TResult? Function( OsceLoaded value)?  loaded,TResult? Function( OsceError value)?  error,}){
final _that = this;
switch (_that) {
case OsceInitial() when initial != null:
return initial(_that);case OsceLoading() when loading != null:
return loading(_that);case OsceShowcase() when osceShowcase != null:
return osceShowcase(_that);case OsceLoaded() when loaded != null:
return loaded(_that);case OsceError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Osce osce,  bool? tutorialSeen)?  osceShowcase,TResult Function( OsceStatus status,  Osce osce,  int currentQuestionIndex,  Map<String, bool> revealedQuestions,  bool reviewingChecklist,  Exception? error)?  loaded,TResult Function( Exception error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OsceInitial() when initial != null:
return initial();case OsceLoading() when loading != null:
return loading();case OsceShowcase() when osceShowcase != null:
return osceShowcase(_that.osce,_that.tutorialSeen);case OsceLoaded() when loaded != null:
return loaded(_that.status,_that.osce,_that.currentQuestionIndex,_that.revealedQuestions,_that.reviewingChecklist,_that.error);case OsceError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Osce osce,  bool? tutorialSeen)  osceShowcase,required TResult Function( OsceStatus status,  Osce osce,  int currentQuestionIndex,  Map<String, bool> revealedQuestions,  bool reviewingChecklist,  Exception? error)  loaded,required TResult Function( Exception error)  error,}) {final _that = this;
switch (_that) {
case OsceInitial():
return initial();case OsceLoading():
return loading();case OsceShowcase():
return osceShowcase(_that.osce,_that.tutorialSeen);case OsceLoaded():
return loaded(_that.status,_that.osce,_that.currentQuestionIndex,_that.revealedQuestions,_that.reviewingChecklist,_that.error);case OsceError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Osce osce,  bool? tutorialSeen)?  osceShowcase,TResult? Function( OsceStatus status,  Osce osce,  int currentQuestionIndex,  Map<String, bool> revealedQuestions,  bool reviewingChecklist,  Exception? error)?  loaded,TResult? Function( Exception error)?  error,}) {final _that = this;
switch (_that) {
case OsceInitial() when initial != null:
return initial();case OsceLoading() when loading != null:
return loading();case OsceShowcase() when osceShowcase != null:
return osceShowcase(_that.osce,_that.tutorialSeen);case OsceLoaded() when loaded != null:
return loaded(_that.status,_that.osce,_that.currentQuestionIndex,_that.revealedQuestions,_that.reviewingChecklist,_that.error);case OsceError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class OsceInitial implements OsceState {
  const OsceInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OsceState.initial()';
}


}




/// @nodoc


class OsceLoading implements OsceState {
  const OsceLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OsceState.loading()';
}


}




/// @nodoc


class OsceShowcase implements OsceState {
  const OsceShowcase({required this.osce, this.tutorialSeen});
  

 final  Osce osce;
/// it reads local storage to see if the osce tutorial has been seen or not
 final  bool? tutorialSeen;

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OsceShowcaseCopyWith<OsceShowcase> get copyWith => _$OsceShowcaseCopyWithImpl<OsceShowcase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceShowcase&&(identical(other.osce, osce) || other.osce == osce)&&(identical(other.tutorialSeen, tutorialSeen) || other.tutorialSeen == tutorialSeen));
}


@override
int get hashCode => Object.hash(runtimeType,osce,tutorialSeen);

@override
String toString() {
  return 'OsceState.osceShowcase(osce: $osce, tutorialSeen: $tutorialSeen)';
}


}

/// @nodoc
abstract mixin class $OsceShowcaseCopyWith<$Res> implements $OsceStateCopyWith<$Res> {
  factory $OsceShowcaseCopyWith(OsceShowcase value, $Res Function(OsceShowcase) _then) = _$OsceShowcaseCopyWithImpl;
@useResult
$Res call({
 Osce osce, bool? tutorialSeen
});


$OsceCopyWith<$Res> get osce;

}
/// @nodoc
class _$OsceShowcaseCopyWithImpl<$Res>
    implements $OsceShowcaseCopyWith<$Res> {
  _$OsceShowcaseCopyWithImpl(this._self, this._then);

  final OsceShowcase _self;
  final $Res Function(OsceShowcase) _then;

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? osce = null,Object? tutorialSeen = freezed,}) {
  return _then(OsceShowcase(
osce: null == osce ? _self.osce : osce // ignore: cast_nullable_to_non_nullable
as Osce,tutorialSeen: freezed == tutorialSeen ? _self.tutorialSeen : tutorialSeen // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OsceCopyWith<$Res> get osce {
  
  return $OsceCopyWith<$Res>(_self.osce, (value) {
    return _then(_self.copyWith(osce: value));
  });
}
}

/// @nodoc


class OsceLoaded implements OsceState {
  const OsceLoaded({this.status = OsceStatus.initial, required this.osce, this.currentQuestionIndex = 0, final  Map<String, bool> revealedQuestions = const {}, this.reviewingChecklist = false, this.error}): _revealedQuestions = revealedQuestions;
  

@JsonKey() final  OsceStatus status;
 final  Osce osce;
@JsonKey() final  int currentQuestionIndex;
 final  Map<String, bool> _revealedQuestions;
@JsonKey() Map<String, bool> get revealedQuestions {
  if (_revealedQuestions is EqualUnmodifiableMapView) return _revealedQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_revealedQuestions);
}

/// True once the questions are done and the user is ticking the
/// checklist of every question to get their score.
@JsonKey() final  bool reviewingChecklist;
 final  Exception? error;

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OsceLoadedCopyWith<OsceLoaded> get copyWith => _$OsceLoadedCopyWithImpl<OsceLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceLoaded&&(identical(other.status, status) || other.status == status)&&(identical(other.osce, osce) || other.osce == osce)&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&const DeepCollectionEquality().equals(other._revealedQuestions, _revealedQuestions)&&(identical(other.reviewingChecklist, reviewingChecklist) || other.reviewingChecklist == reviewingChecklist)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,osce,currentQuestionIndex,const DeepCollectionEquality().hash(_revealedQuestions),reviewingChecklist,error);

@override
String toString() {
  return 'OsceState.loaded(status: $status, osce: $osce, currentQuestionIndex: $currentQuestionIndex, revealedQuestions: $revealedQuestions, reviewingChecklist: $reviewingChecklist, error: $error)';
}


}

/// @nodoc
abstract mixin class $OsceLoadedCopyWith<$Res> implements $OsceStateCopyWith<$Res> {
  factory $OsceLoadedCopyWith(OsceLoaded value, $Res Function(OsceLoaded) _then) = _$OsceLoadedCopyWithImpl;
@useResult
$Res call({
 OsceStatus status, Osce osce, int currentQuestionIndex, Map<String, bool> revealedQuestions, bool reviewingChecklist, Exception? error
});


$OsceCopyWith<$Res> get osce;

}
/// @nodoc
class _$OsceLoadedCopyWithImpl<$Res>
    implements $OsceLoadedCopyWith<$Res> {
  _$OsceLoadedCopyWithImpl(this._self, this._then);

  final OsceLoaded _self;
  final $Res Function(OsceLoaded) _then;

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,Object? osce = null,Object? currentQuestionIndex = null,Object? revealedQuestions = null,Object? reviewingChecklist = null,Object? error = freezed,}) {
  return _then(OsceLoaded(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OsceStatus,osce: null == osce ? _self.osce : osce // ignore: cast_nullable_to_non_nullable
as Osce,currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,revealedQuestions: null == revealedQuestions ? _self._revealedQuestions : revealedQuestions // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,reviewingChecklist: null == reviewingChecklist ? _self.reviewingChecklist : reviewingChecklist // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Exception?,
  ));
}

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OsceCopyWith<$Res> get osce {
  
  return $OsceCopyWith<$Res>(_self.osce, (value) {
    return _then(_self.copyWith(osce: value));
  });
}
}

/// @nodoc


class OsceError implements OsceState {
  const OsceError({required this.error});
  

 final  Exception error;

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OsceErrorCopyWith<OsceError> get copyWith => _$OsceErrorCopyWithImpl<OsceError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OsceError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'OsceState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $OsceErrorCopyWith<$Res> implements $OsceStateCopyWith<$Res> {
  factory $OsceErrorCopyWith(OsceError value, $Res Function(OsceError) _then) = _$OsceErrorCopyWithImpl;
@useResult
$Res call({
 Exception error
});




}
/// @nodoc
class _$OsceErrorCopyWithImpl<$Res>
    implements $OsceErrorCopyWith<$Res> {
  _$OsceErrorCopyWithImpl(this._self, this._then);

  final OsceError _self;
  final $Res Function(OsceError) _then;

/// Create a copy of OsceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(OsceError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

// dart format on
