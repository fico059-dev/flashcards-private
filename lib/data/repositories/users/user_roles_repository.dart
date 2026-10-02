import 'package:flashcards/data/services/api/users/user_roles_service.dart';
import 'package:flashcards/domain/models/profile/admin_user/admin_user.dart';
import 'package:flashcards/utils/result.dart';

class UserRolesRepository {
  final UserRolesService _userRolesService;

  UserRolesRepository({required UserRolesService userRolesService})
    : _userRolesService = userRolesService;

  Future<Result<void>> setAdminRole(String email) async {
    return await _userRolesService.setAdminRole(email);
  }

  Future<Result<List<AdminUser>>> getAdmins() async {
    return await _userRolesService.getAdmins();
  }

  Future<Result<void>> removeAdminRole(String uid) async {
    return await _userRolesService.removeAdminRole(uid);
  }
}
