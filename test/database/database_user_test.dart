import 'package:fresh_planner/source/database/database_user.dart';
import 'package:fresh_planner/source/objects/user.dart';

class DatabaseUserTest extends DatabaseUser {
  @override
  Future<(bool, User?)> loginUser(String email, String password) async {
    if (email == 'correctemail@test.com' && password == 'correctPassword') {
      return (true, User(email: email, username: 'TestUser', password: password, uid: 'testUID'));
    } else {
      return (false, null);
    }
  }

  @override
  Future<(bool, bool)> checkEmailExists(String email) async {
    if (email == 'existingemail@test.com') {
      return (true, true);
    } else {
      return (true, false);
    }
  }

  @override
  Future<(bool, String?)> addNewUser(String email, String username, String password) async {
    return (true, 'testUID');
  }

  @override
  Future<bool> addDefaultIngredients(String uid) async {
    return true;
  }
}