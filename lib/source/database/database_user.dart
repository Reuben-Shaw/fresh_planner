import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_user.dart';
import 'package:fresh_planner/source/objects/user.dart';

class DatabaseUser {
  final _database = DatabaseHelperUser();

  Future<(bool, User?)> loginUser(String email, String password) async {
    try {
      debugPrint("Attempting login");
      final response = await _database.loginUserAPI(email, password);

      bool success = response['success'] as bool? ?? false;
      if (success) {
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

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint("Check was successful: ${response['message']}");
        return (success, response['exists'] as bool);
      } else {
        debugPrint("Check failed: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
      }
      return (success, false);
    } catch (e) {
      debugPrint("Email check data caused a crash: $e");
      return (false, false);
    }
  }

  Future<(bool, String?)> addNewUser(String email, String username, String password) async {
    try {
      debugPrint("Adding new user");
      final response = await _database.addUserAPI(email, username, password);
      
      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint("User added successfully: ${response['message']}");
        return (true, response['uid'] as String?);
      } else {
        debugPrint("User addition failed: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
      }

      return (false, null);
    } catch (e) {
      debugPrint("Adding new user caused a crash: $e");
      return (false, null);
    }
  }

  Future<bool> addDefaultIngredients(String uid) async {
    try {
      debugPrint("Adding default ingredients");

      String json = r'{"uid":"'"$uid"r'","ingredients":[{"name":"flour","metric":"grams","type":"baking"}, {"name":"white sugar","metric":"grams","type":"baking"}, {"name":"baking powder","metric":"grams","type":"baking"}, {"name":"milk","metric":"ml","type":"dairy"}]}';

      final response = await _database.addIngredientJSONAPI(json);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint("Default ingredients added successfully");
        return true;
      } else {
        debugPrint("Adding default ingredients failed: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
        return false;
      }
    } catch (e) {
      debugPrint("Adding default ingredients caused a crash: $e");
      return false;
    }
  }
}