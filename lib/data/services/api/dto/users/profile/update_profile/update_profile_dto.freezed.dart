// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateProfileDto {

 String? get name; String? get surname; String? get username; String? get email; String? get phoneNumber; EducationLevel? get educationLevel; UpdateProfileSettingsDto? get profileSettings; Streak? get streak;
/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProfileDtoCopyWith<UpdateProfileDto> get copyWith => _$UpdateProfileDtoCopyWithImpl<UpdateProfileDto>(this as UpdateProfileDto, _$identity);

  /// Serializes this UpdateProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProfileDto&&(identical(other.name, name) || other.name == name)&&(identical(other.surname, surname) || other.surname == surname)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.educationLevel, educationLevel) || other.educationLevel == educationLevel)&&(identical(other.profileSettings, profileSettings) || other.profileSettings == profileSettings)&&(identical(other.streak, streak) || other.streak == streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,surname,username,email,phoneNumber,educationLevel,profileSettings,streak);

@override
String toString() {
  return 'UpdateProfileDto(name: $name, surname: $surname, username: $username, email: $email, phoneNumber: $phoneNumber, educationLevel: $educationLevel, profileSettings: $profileSettings, streak: $streak)';
}


}

/// @nodoc
abstract mixin class $UpdateProfileDtoCopyWith<$Res>  {
  factory $UpdateProfileDtoCopyWith(UpdateProfileDto value, $Res Function(UpdateProfileDto) _then) = _$UpdateProfileDtoCopyWithImpl;
@useResult
$Res call({
 String? name, String? surname, String? username, String? email, String? phoneNumber, EducationLevel? educationLevel, UpdateProfileSettingsDto? profileSettings, Streak? streak
});


$UpdateProfileSettingsDtoCopyWith<$Res>? get profileSettings;$StreakCopyWith<$Res>? get streak;

}
/// @nodoc
class _$UpdateProfileDtoCopyWithImpl<$Res>
    implements $UpdateProfileDtoCopyWith<$Res> {
  _$UpdateProfileDtoCopyWithImpl(this._self, this._then);

  final UpdateProfileDto _self;
  final $Res Function(UpdateProfileDto) _then;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? surname = freezed,Object? username = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? educationLevel = freezed,Object? profileSettings = freezed,Object? streak = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,surname: freezed == surname ? _self.surname : surname // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,educationLevel: freezed == educationLevel ? _self.educationLevel : educationLevel // ignore: cast_nullable_to_non_nullable
as EducationLevel?,profileSettings: freezed == profileSettings ? _self.profileSettings : profileSettings // ignore: cast_nullable_to_non_nullable
as UpdateProfileSettingsDto?,streak: freezed == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as Streak?,
  ));
}
/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateProfileSettingsDtoCopyWith<$Res>? get profileSettings {
    if (_self.profileSettings == null) {
    return null;
  }

  return $UpdateProfileSettingsDtoCopyWith<$Res>(_self.profileSettings!, (value) {
    return _then(_self.copyWith(profileSettings: value));
  });
}/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakCopyWith<$Res>? get streak {
    if (_self.streak == null) {
    return null;
  }

  return $StreakCopyWith<$Res>(_self.streak!, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateProfileDto].
extension UpdateProfileDtoPatterns on UpdateProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? surname,  String? username,  String? email,  String? phoneNumber,  EducationLevel? educationLevel,  UpdateProfileSettingsDto? profileSettings,  Streak? streak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
return $default(_that.name,_that.surname,_that.username,_that.email,_that.phoneNumber,_that.educationLevel,_that.profileSettings,_that.streak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? surname,  String? username,  String? email,  String? phoneNumber,  EducationLevel? educationLevel,  UpdateProfileSettingsDto? profileSettings,  Streak? streak)  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileDto():
return $default(_that.name,_that.surname,_that.username,_that.email,_that.phoneNumber,_that.educationLevel,_that.profileSettings,_that.streak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? surname,  String? username,  String? email,  String? phoneNumber,  EducationLevel? educationLevel,  UpdateProfileSettingsDto? profileSettings,  Streak? streak)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileDto() when $default != null:
return $default(_that.name,_that.surname,_that.username,_that.email,_that.phoneNumber,_that.educationLevel,_that.profileSettings,_that.streak);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class _UpdateProfileDto implements UpdateProfileDto {
  const _UpdateProfileDto({this.name, this.surname, this.username, this.email, this.phoneNumber, this.educationLevel, this.profileSettings, this.streak});
  factory _UpdateProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateProfileDtoFromJson(json);

@override final  String? name;
@override final  String? surname;
@override final  String? username;
@override final  String? email;
@override final  String? phoneNumber;
@override final  EducationLevel? educationLevel;
@override final  UpdateProfileSettingsDto? profileSettings;
@override final  Streak? streak;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProfileDtoCopyWith<_UpdateProfileDto> get copyWith => __$UpdateProfileDtoCopyWithImpl<_UpdateProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProfileDto&&(identical(other.name, name) || other.name == name)&&(identical(other.surname, surname) || other.surname == surname)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.educationLevel, educationLevel) || other.educationLevel == educationLevel)&&(identical(other.profileSettings, profileSettings) || other.profileSettings == profileSettings)&&(identical(other.streak, streak) || other.streak == streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,surname,username,email,phoneNumber,educationLevel,profileSettings,streak);

@override
String toString() {
  return 'UpdateProfileDto(name: $name, surname: $surname, username: $username, email: $email, phoneNumber: $phoneNumber, educationLevel: $educationLevel, profileSettings: $profileSettings, streak: $streak)';
}


}

/// @nodoc
abstract mixin class _$UpdateProfileDtoCopyWith<$Res> implements $UpdateProfileDtoCopyWith<$Res> {
  factory _$UpdateProfileDtoCopyWith(_UpdateProfileDto value, $Res Function(_UpdateProfileDto) _then) = __$UpdateProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? surname, String? username, String? email, String? phoneNumber, EducationLevel? educationLevel, UpdateProfileSettingsDto? profileSettings, Streak? streak
});


@override $UpdateProfileSettingsDtoCopyWith<$Res>? get profileSettings;@override $StreakCopyWith<$Res>? get streak;

}
/// @nodoc
class __$UpdateProfileDtoCopyWithImpl<$Res>
    implements _$UpdateProfileDtoCopyWith<$Res> {
  __$UpdateProfileDtoCopyWithImpl(this._self, this._then);

  final _UpdateProfileDto _self;
  final $Res Function(_UpdateProfileDto) _then;

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? surname = freezed,Object? username = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? educationLevel = freezed,Object? profileSettings = freezed,Object? streak = freezed,}) {
  return _then(_UpdateProfileDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,surname: freezed == surname ? _self.surname : surname // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,educationLevel: freezed == educationLevel ? _self.educationLevel : educationLevel // ignore: cast_nullable_to_non_nullable
as EducationLevel?,profileSettings: freezed == profileSettings ? _self.profileSettings : profileSettings // ignore: cast_nullable_to_non_nullable
as UpdateProfileSettingsDto?,streak: freezed == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as Streak?,
  ));
}

/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateProfileSettingsDtoCopyWith<$Res>? get profileSettings {
    if (_self.profileSettings == null) {
    return null;
  }

  return $UpdateProfileSettingsDtoCopyWith<$Res>(_self.profileSettings!, (value) {
    return _then(_self.copyWith(profileSettings: value));
  });
}/// Create a copy of UpdateProfileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakCopyWith<$Res>? get streak {
    if (_self.streak == null) {
    return null;
  }

  return $StreakCopyWith<$Res>(_self.streak!, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}

// dart format on
