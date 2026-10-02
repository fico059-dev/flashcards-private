import 'package:flashcards/bloc/profile/admin_list/admin_list_state.dart';
import 'package:flashcards/data/repositories/users/user_roles_repository.dart';
import 'package:flashcards/domain/models/profile/admin_user/admin_user.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminListCubit extends Cubit<AdminListState> {
  final UserRolesRepository _userRolesRepo;

  AdminListCubit({required UserRolesRepository userRolesRepo})
    : _userRolesRepo = userRolesRepo,
      super(const AdminListLoading());

  Future<void> loadAdmins() async {
    emit(const AdminListLoading());
    final result = await _userRolesRepo.getAdmins();
    if (isClosed) return;
    switch (result) {
      case Error<List<AdminUser>>(:final error):
        emit(AdminListError(error: error));
      case Ok<List<AdminUser>>(:final value):
        emit(AdminListLoaded(admins: value));
    }
  }

  /// Removes the admin role from [admin]. Returns the error if it failed.
  Future<Exception?> removeAdmin(AdminUser admin) async {
    final current = state;
    if (current is! AdminListLoaded) return null;

    emit(current.copyWith(removingUid: admin.uid));
    final result = await _userRolesRepo.removeAdminRole(admin.uid);
    if (isClosed) return null;
    switch (result) {
      case Error<void>(:final error):
        emit(current.copyWith(removingUid: null));
        return error;
      case Ok<void>():
        emit(
          AdminListLoaded(
            admins: current.admins.where((a) => a.uid != admin.uid).toList(),
          ),
        );
        return null;
    }
  }
}
