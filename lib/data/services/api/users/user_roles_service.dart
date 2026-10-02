import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/domain/models/profile/admin_user/admin_user.dart';
import 'package:flashcards/utils/result.dart';

class UserRolesService {
  final CloudFunctionService _functions;

  UserRolesService({required CloudFunctionService functions})
    : _functions = functions;

  Future<Result<void>> setAdminRole(String email) async {
    try {
      await _functions.setAdminRole(email);

      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<List<AdminUser>>> getAdmins() async {
    try {
      final admins = await _functions.listAdmins();
      return Result.ok(admins.map(AdminUser.fromMap).toList());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> removeAdminRole(String uid) async {
    try {
      await _functions.removeAdminRole(uid);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
