import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_ingredients.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class DatabaseIngredients {
  final _database = DatabaseHelperIngredients();

  Future<List<Ingredient>?> getAllIngredients(String uid) async {
    try {
      debugPrint('Getting ingredients');
      final response = await _database.getAllIngredientsAPI(uid);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Got ingredients');
        final List<dynamic> ingredientsData = response['ingredients'];

        return ingredientsData.map((ingredientJson) {
          return Ingredient.fromJson(ingredientJson);
        }).toList();
      } else {
        debugPrint('Failed to get ingredients: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching ingredients: $e');
      return [];
    }
  }

  Future<bool> removeIngredient(String uid, String ingredientID) async {
    try {
      debugPrint('Attempting to remove ingredient ID: $ingredientID from uid: $uid');
      final response = await _database.removeIngredientAPI(uid, ingredientID);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Ingredient removed successfully');
        return true;
      } else {
        debugPrint('Ingredient removal failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
      }
      return false;
    } catch (e) {
      debugPrint('Error removing ingredient: $e');
      return false;
    }
  }

  Future<(bool, String?)> addIngredient(String uid, Ingredient ingredient) async {
    try {
      debugPrint('Adding new ingredient');
      final response = await _database.addIngredientAPI(uid, ingredient);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('New ingredient added successfully with id ${response['id'] as String}');
        return (true, response['id'] as String);
      } else {
        debugPrint('Adding new ingredient failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
        return (false, null);
      }
    } catch (e) {
      debugPrint('Adding new ingredient caused a crash: $e');
      return (false, null);
    }
  }
} 
