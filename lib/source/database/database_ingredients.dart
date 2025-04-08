import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_ingredients.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';

class DatabaseIngredients {
  final _database = DatabaseHelperIngredients();

  Future<List<Ingredient>?> getAllIngredients(String uid) async {
    try {
      debugPrint("Getting ingredients");
      final response = await _database.getAllIngredientsAPI(uid);

      if (response['success'] == true) {
        debugPrint("Got ingredients");
        final List<dynamic> ingredientsData = response['ingredients'];

        return ingredientsData.map((ingredientJson) {
          return Ingredient.fromJson(ingredientJson);
        }).toList();
      } else {
        debugPrint("Failed to get ingredients: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching ingredients: $e");
      return [];
    }
  }
} 