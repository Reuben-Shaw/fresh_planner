import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class DatabaseIngredientsTest extends DatabaseIngredients {
  @override
  Future<List<Ingredient>?> getAllIngredients(String uid) async {
    return [];
  }

  @override
  Future<bool> removeIngredient(String uid, String ingredientID) async {
    return true;
  }

  @override
  Future<(bool, String?)> addIngredient(String uid, Ingredient ingredient) async {
    debugPrint('Database adding test');
    await Future.delayed(const Duration(milliseconds: 10));
    debugPrint('Ready to return');
    return (true, 'testID');
  }
} 
