import 'package:flashcards/domain/models/profile/admin_user/admin_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_list_state.freezed.dart';

@freezed
sealed class AdminListState with _$AdminListState {
  const factory AdminListState.loading() = AdminListLoading;

  /// [removingUid] is the admin whose role is currently being removed.
  const factory AdminListState.loaded({
    required List<AdminUser> admins,
    String? removingUid,
  }) = AdminListLoaded;

  const factory AdminListState.error({required Exception error}) =
      AdminListError;
}
