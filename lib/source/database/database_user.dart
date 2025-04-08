import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_user.dart';
import 'package:fresh_planner/source/objects/user.dart';

class DatabaseUser {
  final _database = DatabaseHelperUser();

  Future<(bool, User?)> loginUser(String email, String password) async {
    try {
      debugPrint("Attempting login");
      final response = await _database.loginUserAPI(email, password);

      bool success = response['success'] ?? false;
      if (success == true) {
        debugPrint("Login successful: ${response['message']}");

        final userData = response['user'];
        final User user = User.fromJson(userData);
        return (success, user);
      } else {
        debugPrint("Login failed: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
      }
      return (success, null);
    } catch (e) {
      debugPrint("Login data caused a crash: $e");
      return (false, null);
    }
  }

  Future<(bool, bool)> checkEmailExists(String email) async {
    try {
      debugPrint("Checking email");
      final response = await _database.checkEmailExistsAPI(email);

      bool success = response['success'] ?? false;
      if (success == true) {
        debugPrint("Check was successful: ${response['message']}");
        return (success, response['exists'] as bool);
      } else {
        debugPrint("Check failed: ${response['error'] ?? "!!NO ERROR!!"}");
      }
      return (success, false);
    } catch (e) {
      debugPrint("Email check data caused a crash: $e");
      return (false, false);
    }
  }

  Future<bool> addNewUser(String email, String username, String password) async {
    try {
      debugPrint("Adding new user");
      final response = await _database.addUserAPI(email, username, password);

      (bool, String) success = response['success'] ?? response['error'] ?? (false, "!!NO ERROR!!");
      return success.$1;
    } catch (e) {
      debugPrint("Adding new user caused a crash: $e");
      return false;
    }
  }
}