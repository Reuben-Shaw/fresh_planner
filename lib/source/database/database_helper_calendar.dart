import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:http/http.dart' as http;

class DatabaseHelperCalendar {
  static const String _standardUrl = "-mueafkqufq-nw.a.run.app";
  static const String _addRecipeUrl = "addrecipe";
  static const String _getAllRecipesUrl = "getallrecipes";
  static const String _addMealUrl = "addmeal";
  static const String _getAllMealsUrl = "getallmeals";
  static const String _deleteMealUrl = "deletemeal";
  
  Future<Map<String, dynamic>> addRecipeAPI(String uid, Recipe recipe) async {
    try {
      final Uri url = Uri.parse("https://$_addRecipeUrl$_standardUrl");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'recipe' : recipe.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final id = data['id'] as String?;
        if (id != null) {
          return {"success": true, "message": "New recipe added successfully", "id": id};
        } else {
          return {"error": "ID not found in the response"};
        }
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> getAllRecipesAPI(String uid) async {
    try {
      final Uri url = Uri.parse("https://$_getAllRecipesUrl$_standardUrl?uid=$uid");
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        debugPrint("Body is : $body");
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {"error": "Unexpected response format"};
        }
      } else {
        return {"error": "Request failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }
  
  Future<Map<String, dynamic>> addMealAPI(String uid, Meal meal) async {
    try {
      final Uri url = Uri.parse("https://$_addMealUrl$_standardUrl");
      final response = await http.post(
        url,
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'uid': uid,
          'meal': meal.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "id": data['id'],
          "message": data['result'],
        };
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> getAllMealsAPI(String uid) async {
    try {
      final Uri url = Uri.parse("https://$_getAllMealsUrl$_standardUrl?uid=$uid");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body is Map<String, dynamic> ? body : {"error": "Unexpected format"};
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }
  
  Future<Map<String, dynamic>> deleteMealAPI(String uid, String mealID) async {
    try {
      final Uri url = Uri.parse("https://$_deleteMealUrl$_standardUrl");
      final response = await http.post(
        url,
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'uid': uid,
          'mealID': mealID,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": data['result'],
        };
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }
}
