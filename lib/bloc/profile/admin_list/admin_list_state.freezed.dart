// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AdminListState()';
}


}

/// @nodoc
class $AdminListStateCopyWith<$Res>  {
$AdminListStateCopyWith(AdminListState _, $Res Function(AdminListState) __);
}


/// Adds pattern-matching-related methods to [AdminListState].
extension AdminListStatePatterns on AdminListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AdminListLoading value)?  loading,TResult Function( AdminListLoaded value)?  loaded,TResult Function( AdminListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AdminListLoading() when loading != null:
return loading(_that);case AdminListLoaded() when loaded != null:
return loaded(_that);case AdminListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AdminListLoading value)  loading,required TResult Function( AdminListLoaded value)  loaded,required TResult Function( AdminListError value)  error,}){
final _that = this;
switch (_that) {
case AdminListLoading():
return loading(_that);case AdminListLoaded():
return loaded(_that);case AdminListError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AdminListLoading value)?  loading,TResult? Function( AdminListLoaded value)?  loaded,TResult? Function( AdminListError value)?  error,}){
final _that = this;
switch (_that) {
case AdminListLoading() when loading != null:
return loading(_that);case AdminListLoaded() when loaded != null:
return loaded(_that);case AdminListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<AdminUser> admins,  String? removingUid)?  loaded,TResult Function( Exception error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AdminListLoading() when loading != null:
return loading();case AdminListLoaded() when loaded != null:
return loaded(_that.admins,_that.removingUid);case AdminListError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<AdminUser> admins,  String? removingUid)  loaded,required TResult Function( Exception error)  error,}) {final _that = this;
switch (_that) {
case AdminListLoading():
return loading();case AdminListLoaded():
return loaded(_that.admins,_that.removingUid);case AdminListError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<AdminUser> admins,  String? removingUid)?  loaded,TResult? Function( Exception error)?  error,}) {final _that = this;
switch (_that) {
case AdminListLoading() when loading != null:
return loading();case AdminListLoaded() when loaded != null:
return loaded(_that.admins,_that.removingUid);case AdminListError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AdminListLoading implements AdminListState {
  const AdminListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AdminListState.loading()';
}


}




/// @nodoc


class AdminListLoaded implements AdminListState {
  const AdminListLoaded({required final  List<AdminUser> admins, this.removingUid}): _admins = admins;
  

 final  List<AdminUser> _admins;
 List<AdminUser> get admins {
  if (_admins is EqualUnmodifiableListView) return _admins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_admins);
}

 final  String? removingUid;

/// Create a copy of AdminListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminListLoadedCopyWith<AdminListLoaded> get copyWith => _$AdminListLoadedCopyWithImpl<AdminListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminListLoaded&&const DeepCollectionEquality().equals(other._admins, _admins)&&(identical(other.removingUid, removingUid) || other.removingUid == removingUid));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_admins),removingUid);

@override
String toString() {
  return 'AdminListState.loaded(admins: $admins, removingUid: $removingUid)';
}


}

/// @nodoc
abstract mixin class $AdminListLoadedCopyWith<$Res> implements $AdminListStateCopyWith<$Res> {
  factory $AdminListLoadedCopyWith(AdminListLoaded value, $Res Function(AdminListLoaded) _then) = _$AdminListLoadedCopyWithImpl;
@useResult
$Res call({
 List<AdminUser> admins, String? removingUid
});




}
/// @nodoc
class _$AdminListLoadedCopyWithImpl<$Res>
    implements $AdminListLoadedCopyWith<$Res> {
  _$AdminListLoadedCopyWithImpl(this._self, this._then);

  final AdminListLoaded _self;
  final $Res Function(AdminListLoaded) _then;

/// Create a copy of AdminListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? admins = null,Object? removingUid = freezed,}) {
  return _then(AdminListLoaded(
admins: null == admins ? _self._admins : admins // ignore: cast_nullable_to_non_nullable
as List<AdminUser>,removingUid: freezed == removingUid ? _self.removingUid : removingUid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AdminListError implements AdminListState {
  const AdminListError({required this.error});
  

 final  Exception error;

/// Create a copy of AdminListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminListErrorCopyWith<AdminListError> get copyWith => _$AdminListErrorCopyWithImpl<AdminListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminListError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'AdminListState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $AdminListErrorCopyWith<$Res> implements $AdminListStateCopyWith<$Res> {
  factory $AdminListErrorCopyWith(AdminListError value, $Res Function(AdminListError) _then) = _$AdminListErrorCopyWithImpl;
@useResult
$Res call({
 Exception error
});




}
/// @nodoc
class _$AdminListErrorCopyWithImpl<$Res>
    implements $AdminListErrorCopyWith<$Res> {
  _$AdminListErrorCopyWithImpl(this._self, this._then);

  final AdminListError _self;
  final $Res Function(AdminListError) _then;

/// Create a copy of AdminListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AdminListError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

// dart format on
