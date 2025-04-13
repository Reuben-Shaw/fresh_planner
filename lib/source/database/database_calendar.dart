import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_calendar.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

class DatabaseCalendar {
  final _database = DatabaseHelperCalendar();

  Future<(bool, String?)> addRecipe(String uid, Recipe recipe) async {
    try {
      debugPrint("Adding new recipe with ${recipe.ingredients.length} ingredients");
      final response = await _database.addRecipeAPI(uid, recipe);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint("New recipe added successfully with id ${response['id'] as String}");
        return (true, response['id'] as String);
      } else {
        debugPrint("Adding new recipe failed: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
        return (false, null);
      }
    } catch (e) {
      debugPrint("Adding new recipe caused a crash: $e");
      return (false, null);
    }
  }

  Future<List<Recipe>?> getAllRecipes(String uid) async {
    try {
      debugPrint("Getting recipes");
      final response = await _database.getAllRecipesAPI(uid);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint("Got recipes");
        final List<dynamic> recipesData = response['recipes'];

        return recipesData.map((ingredientJson) {
          return Recipe.fromJson(ingredientJson);
        }).toList();
      } else {
        debugPrint("Failed to get recipes: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching recipes: $e");
      return [];
    }
  }
} 
