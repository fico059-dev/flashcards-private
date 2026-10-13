// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlashcardState {

 FlashcardStatus get status; TestType? get testType; Pack? get pack; int? get cardsPerSession; bool get answerVisible; bool get hintVisible; List<StatRecord> get statRecords; int get currentCardIndex; int get currentBatch;/// Cards of today's target already studied in this pack before the
/// pack was opened this time, so the count continues.
 int get sessionDone; Flashcard? get flashcard; bool? get hasCards;/// it reads local storage to see if the flashcards tutorial has been seen or not
 bool? get tutorialSeen;/// used to communicate with profile bloc to update the state locally
 Streak? get newStreak; String? get errorMessage;
/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlashcardStateCopyWith<FlashcardState> get copyWith => _$FlashcardStateCopyWithImpl<FlashcardState>(this as FlashcardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlashcardState&&(identical(other.status, status) || other.status == status)&&(identical(other.testType, testType) || other.testType == testType)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.cardsPerSession, cardsPerSession) || other.cardsPerSession == cardsPerSession)&&(identical(other.answerVisible, answerVisible) || other.answerVisible == answerVisible)&&(identical(other.hintVisible, hintVisible) || other.hintVisible == hintVisible)&&const DeepCollectionEquality().equals(other.statRecords, statRecords)&&(identical(other.currentCardIndex, currentCardIndex) || other.currentCardIndex == currentCardIndex)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.sessionDone, sessionDone) || other.sessionDone == sessionDone)&&(identical(other.flashcard, flashcard) || other.flashcard == flashcard)&&(identical(other.hasCards, hasCards) || other.hasCards == hasCards)&&(identical(other.tutorialSeen, tutorialSeen) || other.tutorialSeen == tutorialSeen)&&(identical(other.newStreak, newStreak) || other.newStreak == newStreak)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,testType,pack,cardsPerSession,answerVisible,hintVisible,const DeepCollectionEquality().hash(statRecords),currentCardIndex,currentBatch,sessionDone,flashcard,hasCards,tutorialSeen,newStreak,errorMessage);

@override
String toString() {
  return 'FlashcardState(status: $status, testType: $testType, pack: $pack, cardsPerSession: $cardsPerSession, answerVisible: $answerVisible, hintVisible: $hintVisible, statRecords: $statRecords, currentCardIndex: $currentCardIndex, currentBatch: $currentBatch, sessionDone: $sessionDone, flashcard: $flashcard, hasCards: $hasCards, tutorialSeen: $tutorialSeen, newStreak: $newStreak, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FlashcardStateCopyWith<$Res>  {
  factory $FlashcardStateCopyWith(FlashcardState value, $Res Function(FlashcardState) _then) = _$FlashcardStateCopyWithImpl;
@useResult
$Res call({
 FlashcardStatus status, TestType? testType, Pack? pack, int? cardsPerSession, bool answerVisible, bool hintVisible, List<StatRecord> statRecords, int currentCardIndex, int currentBatch, int sessionDone, Flashcard? flashcard, bool? hasCards, bool? tutorialSeen, Streak? newStreak, String? errorMessage
});


$PackCopyWith<$Res>? get pack;$FlashcardCopyWith<$Res>? get flashcard;$StreakCopyWith<$Res>? get newStreak;

}
/// @nodoc
class _$FlashcardStateCopyWithImpl<$Res>
    implements $FlashcardStateCopyWith<$Res> {
  _$FlashcardStateCopyWithImpl(this._self, this._then);

  final FlashcardState _self;
  final $Res Function(FlashcardState) _then;

/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? testType = freezed,Object? pack = freezed,Object? cardsPerSession = freezed,Object? answerVisible = null,Object? hintVisible = null,Object? statRecords = null,Object? currentCardIndex = null,Object? currentBatch = null,Object? sessionDone = null,Object? flashcard = freezed,Object? hasCards = freezed,Object? tutorialSeen = freezed,Object? newStreak = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FlashcardStatus,testType: freezed == testType ? _self.testType : testType // ignore: cast_nullable_to_non_nullable
as TestType?,pack: freezed == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as Pack?,cardsPerSession: freezed == cardsPerSession ? _self.cardsPerSession : cardsPerSession // ignore: cast_nullable_to_non_nullable
as int?,answerVisible: null == answerVisible ? _self.answerVisible : answerVisible // ignore: cast_nullable_to_non_nullable
as bool,hintVisible: null == hintVisible ? _self.hintVisible : hintVisible // ignore: cast_nullable_to_non_nullable
as bool,statRecords: null == statRecords ? _self.statRecords : statRecords // ignore: cast_nullable_to_non_nullable
as List<StatRecord>,currentCardIndex: null == currentCardIndex ? _self.currentCardIndex : currentCardIndex // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,sessionDone: null == sessionDone ? _self.sessionDone : sessionDone // ignore: cast_nullable_to_non_nullable
as int,flashcard: freezed == flashcard ? _self.flashcard : flashcard // ignore: cast_nullable_to_non_nullable
as Flashcard?,hasCards: freezed == hasCards ? _self.hasCards : hasCards // ignore: cast_nullable_to_non_nullable
as bool?,tutorialSeen: freezed == tutorialSeen ? _self.tutorialSeen : tutorialSeen // ignore: cast_nullable_to_non_nullable
as bool?,newStreak: freezed == newStreak ? _self.newStreak : newStreak // ignore: cast_nullable_to_non_nullable
as Streak?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackCopyWith<$Res>? get pack {
    if (_self.pack == null) {
    return null;
  }

  return $PackCopyWith<$Res>(_self.pack!, (value) {
    return _then(_self.copyWith(pack: value));
  });
}/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlashcardCopyWith<$Res>? get flashcard {
    if (_self.flashcard == null) {
    return null;
  }

  return $FlashcardCopyWith<$Res>(_self.flashcard!, (value) {
    return _then(_self.copyWith(flashcard: value));
  });
}/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakCopyWith<$Res>? get newStreak {
    if (_self.newStreak == null) {
    return null;
  }

  return $StreakCopyWith<$Res>(_self.newStreak!, (value) {
    return _then(_self.copyWith(newStreak: value));
  });
}
}


/// Adds pattern-matching-related methods to [FlashcardState].
extension FlashcardStatePatterns on FlashcardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlashcardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlashcardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlashcardState value)  $default,){
final _that = this;
switch (_that) {
case _FlashcardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlashcardState value)?  $default,){
final _that = this;
switch (_that) {
case _FlashcardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FlashcardStatus status,  TestType? testType,  Pack? pack,  int? cardsPerSession,  bool answerVisible,  bool hintVisible,  List<StatRecord> statRecords,  int currentCardIndex,  int currentBatch,  int sessionDone,  Flashcard? flashcard,  bool? hasCards,  bool? tutorialSeen,  Streak? newStreak,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlashcardState() when $default != null:
return $default(_that.status,_that.testType,_that.pack,_that.cardsPerSession,_that.answerVisible,_that.hintVisible,_that.statRecords,_that.currentCardIndex,_that.currentBatch,_that.sessionDone,_that.flashcard,_that.hasCards,_that.tutorialSeen,_that.newStreak,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FlashcardStatus status,  TestType? testType,  Pack? pack,  int? cardsPerSession,  bool answerVisible,  bool hintVisible,  List<StatRecord> statRecords,  int currentCardIndex,  int currentBatch,  int sessionDone,  Flashcard? flashcard,  bool? hasCards,  bool? tutorialSeen,  Streak? newStreak,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FlashcardState():
return $default(_that.status,_that.testType,_that.pack,_that.cardsPerSession,_that.answerVisible,_that.hintVisible,_that.statRecords,_that.currentCardIndex,_that.currentBatch,_that.sessionDone,_that.flashcard,_that.hasCards,_that.tutorialSeen,_that.newStreak,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FlashcardStatus status,  TestType? testType,  Pack? pack,  int? cardsPerSession,  bool answerVisible,  bool hintVisible,  List<StatRecord> statRecords,  int currentCardIndex,  int currentBatch,  int sessionDone,  Flashcard? flashcard,  bool? hasCards,  bool? tutorialSeen,  Streak? newStreak,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FlashcardState() when $default != null:
return $default(_that.status,_that.testType,_that.pack,_that.cardsPerSession,_that.answerVisible,_that.hintVisible,_that.statRecords,_that.currentCardIndex,_that.currentBatch,_that.sessionDone,_that.flashcard,_that.hasCards,_that.tutorialSeen,_that.newStreak,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FlashcardState implements FlashcardState {
  const _FlashcardState({this.status = FlashcardStatus.initial, this.testType, this.pack, this.cardsPerSession, this.answerVisible = false, this.hintVisible = false, final  List<StatRecord> statRecords = const [], this.currentCardIndex = 0, this.currentBatch = 0, this.sessionDone = 0, this.flashcard, this.hasCards, this.tutorialSeen, this.newStreak, this.errorMessage}): _statRecords = statRecords;
  

@override@JsonKey() final  FlashcardStatus status;
@override final  TestType? testType;
@override final  Pack? pack;
@override final  int? cardsPerSession;
@override@JsonKey() final  bool answerVisible;
@override@JsonKey() final  bool hintVisible;
 final  List<StatRecord> _statRecords;
@override@JsonKey() List<StatRecord> get statRecords {
  if (_statRecords is EqualUnmodifiableListView) return _statRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statRecords);
}

@override@JsonKey() final  int currentCardIndex;
@override@JsonKey() final  int currentBatch;
/// Cards of today's target already studied in this pack before the
/// pack was opened this time, so the count continues.
@override@JsonKey() final  int sessionDone;
@override final  Flashcard? flashcard;
@override final  bool? hasCards;
/// it reads local storage to see if the flashcards tutorial has been seen or not
@override final  bool? tutorialSeen;
/// used to communicate with profile bloc to update the state locally
@override final  Streak? newStreak;
@override final  String? errorMessage;

/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlashcardStateCopyWith<_FlashcardState> get copyWith => __$FlashcardStateCopyWithImpl<_FlashcardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlashcardState&&(identical(other.status, status) || other.status == status)&&(identical(other.testType, testType) || other.testType == testType)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.cardsPerSession, cardsPerSession) || other.cardsPerSession == cardsPerSession)&&(identical(other.answerVisible, answerVisible) || other.answerVisible == answerVisible)&&(identical(other.hintVisible, hintVisible) || other.hintVisible == hintVisible)&&const DeepCollectionEquality().equals(other._statRecords, _statRecords)&&(identical(other.currentCardIndex, currentCardIndex) || other.currentCardIndex == currentCardIndex)&&(identical(other.currentBatch, currentBatch) || other.currentBatch == currentBatch)&&(identical(other.sessionDone, sessionDone) || other.sessionDone == sessionDone)&&(identical(other.flashcard, flashcard) || other.flashcard == flashcard)&&(identical(other.hasCards, hasCards) || other.hasCards == hasCards)&&(identical(other.tutorialSeen, tutorialSeen) || other.tutorialSeen == tutorialSeen)&&(identical(other.newStreak, newStreak) || other.newStreak == newStreak)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,testType,pack,cardsPerSession,answerVisible,hintVisible,const DeepCollectionEquality().hash(_statRecords),currentCardIndex,currentBatch,sessionDone,flashcard,hasCards,tutorialSeen,newStreak,errorMessage);

@override
String toString() {
  return 'FlashcardState(status: $status, testType: $testType, pack: $pack, cardsPerSession: $cardsPerSession, answerVisible: $answerVisible, hintVisible: $hintVisible, statRecords: $statRecords, currentCardIndex: $currentCardIndex, currentBatch: $currentBatch, sessionDone: $sessionDone, flashcard: $flashcard, hasCards: $hasCards, tutorialSeen: $tutorialSeen, newStreak: $newStreak, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FlashcardStateCopyWith<$Res> implements $FlashcardStateCopyWith<$Res> {
  factory _$FlashcardStateCopyWith(_FlashcardState value, $Res Function(_FlashcardState) _then) = __$FlashcardStateCopyWithImpl;
@override @useResult
$Res call({
 FlashcardStatus status, TestType? testType, Pack? pack, int? cardsPerSession, bool answerVisible, bool hintVisible, List<StatRecord> statRecords, int currentCardIndex, int currentBatch, int sessionDone, Flashcard? flashcard, bool? hasCards, bool? tutorialSeen, Streak? newStreak, String? errorMessage
});


@override $PackCopyWith<$Res>? get pack;@override $FlashcardCopyWith<$Res>? get flashcard;@override $StreakCopyWith<$Res>? get newStreak;

}
/// @nodoc
class __$FlashcardStateCopyWithImpl<$Res>
    implements _$FlashcardStateCopyWith<$Res> {
  __$FlashcardStateCopyWithImpl(this._self, this._then);

  final _FlashcardState _self;
  final $Res Function(_FlashcardState) _then;

/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? testType = freezed,Object? pack = freezed,Object? cardsPerSession = freezed,Object? answerVisible = null,Object? hintVisible = null,Object? statRecords = null,Object? currentCardIndex = null,Object? currentBatch = null,Object? sessionDone = null,Object? flashcard = freezed,Object? hasCards = freezed,Object? tutorialSeen = freezed,Object? newStreak = freezed,Object? errorMessage = freezed,}) {
  return _then(_FlashcardState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FlashcardStatus,testType: freezed == testType ? _self.testType : testType // ignore: cast_nullable_to_non_nullable
as TestType?,pack: freezed == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as Pack?,cardsPerSession: freezed == cardsPerSession ? _self.cardsPerSession : cardsPerSession // ignore: cast_nullable_to_non_nullable
as int?,answerVisible: null == answerVisible ? _self.answerVisible : answerVisible // ignore: cast_nullable_to_non_nullable
as bool,hintVisible: null == hintVisible ? _self.hintVisible : hintVisible // ignore: cast_nullable_to_non_nullable
as bool,statRecords: null == statRecords ? _self._statRecords : statRecords // ignore: cast_nullable_to_non_nullable
as List<StatRecord>,currentCardIndex: null == currentCardIndex ? _self.currentCardIndex : currentCardIndex // ignore: cast_nullable_to_non_nullable
as int,currentBatch: null == currentBatch ? _self.currentBatch : currentBatch // ignore: cast_nullable_to_non_nullable
as int,sessionDone: null == sessionDone ? _self.sessionDone : sessionDone // ignore: cast_nullable_to_non_nullable
as int,flashcard: freezed == flashcard ? _self.flashcard : flashcard // ignore: cast_nullable_to_non_nullable
as Flashcard?,hasCards: freezed == hasCards ? _self.hasCards : hasCards // ignore: cast_nullable_to_non_nullable
as bool?,tutorialSeen: freezed == tutorialSeen ? _self.tutorialSeen : tutorialSeen // ignore: cast_nullable_to_non_nullable
as bool?,newStreak: freezed == newStreak ? _self.newStreak : newStreak // ignore: cast_nullable_to_non_nullable
as Streak?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackCopyWith<$Res>? get pack {
    if (_self.pack == null) {
    return null;
  }

  return $PackCopyWith<$Res>(_self.pack!, (value) {
    return _then(_self.copyWith(pack: value));
  });
}/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlashcardCopyWith<$Res>? get flashcard {
    if (_self.flashcard == null) {
    return null;
  }

  return $FlashcardCopyWith<$Res>(_self.flashcard!, (value) {
    return _then(_self.copyWith(flashcard: value));
  });
}/// Create a copy of FlashcardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakCopyWith<$Res>? get newStreak {
    if (_self.newStreak == null) {
    return null;
  }

  return $StreakCopyWith<$Res>(_self.newStreak!, (value) {
    return _then(_self.copyWith(newStreak: value));
  });
}
}

// dart format on
