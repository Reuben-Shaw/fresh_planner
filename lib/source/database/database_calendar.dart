import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_calendar.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

class DatabaseCalendar {
  final _database = DatabaseHelperCalendar();

  Future<(bool, String?)> addRecipe(String uid, Recipe r) async {
    try {
      debugPrint("Adding new recipe with ${r.ingredients.length} ingredients");
      
      final List<(String, int)> ingredients = [];
      for (final i in r.ingredients) {
        ingredients.add((i.id!, i.amount));
      }

      final response = await _database.addRecipeAPI(uid, r.name, r.link, ingredients, r.colour);

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
} 
