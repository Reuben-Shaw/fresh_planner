import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/database/database_helper_calendar.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

class DatabaseCalendar {
  final _database = DatabaseHelperCalendar();

  Future<(bool, String?)> addRecipe(String uid, Recipe recipe) async {
    try {
      debugPrint('Adding new recipe with ${recipe.ingredients.length} ingredients');
      final response = await _database.addRecipeAPI(uid, recipe);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('New recipe added successfully with id ${response['id'] as String}');
        return (true, response['id'] as String);
      } else {
        debugPrint('Adding new recipe failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
        return (false, null);
      }
    } catch (e) {
      debugPrint('Adding new recipe caused a crash: $e');
      return (false, null);
    }
  }

  Future<List<Recipe>?> getAllRecipes(String uid) async {
    try {
      debugPrint('Getting recipes');
      final response = await _database.getAllRecipesAPI(uid);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Got recipes');
        final List<dynamic> recipesData = response['recipes'];

        return recipesData.map((ingredientJson) {
          return Recipe.fromJson(ingredientJson);
        }).toList();
      } else {
        debugPrint('Failed to get recipes: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      return null;
    }
  }

  Future<(bool, String?)> addMeal(String uid, Meal meal) async {
    try {
      final response = await _database.addMealAPI(uid, meal);
      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Meal added with id ${response['id']}');
        return (true, response['id'] as String?);
      } else {
        debugPrint('Add meal failed: ${response['error'] ?? response['message']}');
        return (false, null);
      }
    } catch (e) {
      debugPrint('Crash in addMeal: $e');
      return (false, null);
    }
  }

  Future<Map<TimeOfDay, List<Meal>>?> getAllMeals(String uid) async {
    try {
      final response = await _database.getAllMealsAPI(uid);
      if (response['success'] == true) {
        debugPrint('Got meals');
        final List<dynamic> mealsData = response['meals'];
        final List<Meal> returnedMeals = mealsData.map((m) => Meal.fromJson(m)).toList();

        final Map<TimeOfDay, List<Meal>> mealsByTime = {
          TimeOfDay.breakfast: [],
          TimeOfDay.lunch: [],
          TimeOfDay.dinner: [],
        };
        for (final meal in returnedMeals) {
          mealsByTime[meal.time]!.add(meal);
        }
        return mealsByTime;
      } else {
        debugPrint('Get meals failed: ${response['error'] ?? response['message']}');
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      return null;
    }
  }

  Future<bool> deleteMeal(String uid, Meal meal) async {
    if (meal.id == null) return false;
    try {
      final response = await _database.deleteMealAPI(uid, meal.id!);
      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Meal deleted with id ${meal.id!}');
        return true;
      } else {
        debugPrint('Deleting meal failed: ${response['error'] ?? response['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Crash in deleteMeal: $e');
      return false;
    }
  }

  Future<bool> deleteRecipe(String uid, Recipe recipe) async {
    if (recipe.id == null) return false;
    try {
      final response = await _database.deleteRecipeAPI(uid, recipe.id!);
      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Recipe deleted with id ${recipe.id!}');
        return true;
      } else {
        debugPrint('Deleting recipe failed: ${response['error'] ?? response['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Crash in deleterecipe: $e');
      return false;
    }
  }
} 
