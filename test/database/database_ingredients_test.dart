import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class DatabaseIngredientsTest extends DatabaseIngredients {
  @override
  Future<List<Ingredient>?> getAllIngredients(String uid) async {
    return [
    Ingredient(
      id: 'baking_1',
      name: 'All-Purpose Flour',
      metric: IngredientMetric.grams,
      cost: 1.50,
      costAmount: 1000,
      type: IngredientType.baking,
    ),
    Ingredient(
      id: 'baking_2',
      name: 'Baking Powder',
      metric: IngredientMetric.ml,
      cost: 2.00,
      costAmount: 300,
      type: IngredientType.baking,
    ),
    Ingredient(
      id: 'dairy_1',
      name: 'Whole Milk',
      metric: IngredientMetric.ml,
      cost: 3.20,
      costAmount: 2,
      type: IngredientType.dairy,
    ),
    Ingredient(
      id: 'dairy_2',
      name: 'Cheddar Cheese',
      metric: IngredientMetric.grams,
      cost: 4.50,
      costAmount: 200,
      type: IngredientType.dairy,
    ),
    Ingredient(
      id: 'dried_1',
      name: 'Pasta',
      metric: IngredientMetric.grams,
      cost: 1.80,
      costAmount: 500,
      type: IngredientType.driedGood,
    ),
    Ingredient(
      id: 'dried_2',
      name: 'Lentils',
      metric: IngredientMetric.grams,
      cost: 3.00,
      costAmount: 1000,
      type: IngredientType.driedGood,
    ),
    Ingredient(
      id: 'frozen_1',
      name: 'Mixed Vegetables',
      metric: IngredientMetric.grams,
      cost: 2.50,
      costAmount: 750,
      type: IngredientType.frozen,
    ),
    Ingredient(
      id: 'frozen_2',
      name: 'Ice Cream',
      metric: IngredientMetric.ml,
      cost: 5.00,
      costAmount: 1,
      type: IngredientType.frozen,
    ),
    Ingredient(
      id: 'fruit_1',
      name: 'Apples',
      metric: IngredientMetric.item,
      cost: 3.00,
      costAmount: 6,
      type: IngredientType.fruitNut,
    ),
    Ingredient(
      id: 'fruit_2',
      name: 'Almonds',
      metric: IngredientMetric.grams,
      cost: 7.00,
      costAmount: 200,
      type: IngredientType.fruitNut,
    ),
    Ingredient(
      id: 'spice_1',
      name: 'Basil',
      metric: IngredientMetric.grams,
      cost: 1.50,
      costAmount: 50,
      type: IngredientType.herbSpice,
    ),
    Ingredient(
      id: 'spice_2',
      name: 'Cumin',
      metric: IngredientMetric.grams,
      cost: 2.00,
      costAmount: 50,
      type: IngredientType.herbSpice,
    ),
    Ingredient(
      id: 'liquid_1',
      name: 'Olive Oil',
      metric: IngredientMetric.ml,
      cost: 6.00,
      costAmount: 500,
      type: IngredientType.liquid,
    ),
    Ingredient(
      id: 'liquid_2',
      name: 'Vinegar',
      metric: IngredientMetric.ml,
      cost: 2.50,
      costAmount: 500,
      type: IngredientType.liquid,
    ),
    Ingredient(
      id: 'meat_1',
      name: 'Chicken Breast',
      metric: IngredientMetric.item,
      cost: 8.00,
      costAmount: 4,
      type: IngredientType.meat,
    ),
    Ingredient(
      id: 'meat_2',
      name: 'Ground Beef',
      metric: IngredientMetric.grams,
      cost: 6.50,
      costAmount: 500,
      type: IngredientType.meat,
    ),
    Ingredient(
      id: 'preserve_1',
      name: 'Strawberry Jam',
      metric: IngredientMetric.item,
      cost: 3.50,
      costAmount: 1,
      type: IngredientType.preserve,
    ),
    Ingredient(
      id: 'preserve_2',
      name: 'Pickles',
      metric: IngredientMetric.item,
      cost: 2.80,
      costAmount: 1,
      type: IngredientType.preserve,
    ),
    Ingredient(
      id: 'snack_1',
      name: 'Potato Chips',
      metric: IngredientMetric.item,
      cost: 2.00,
      costAmount: 1,
      type: IngredientType.snack,
    ),
    Ingredient(
      id: 'snack_2',
      name: 'Chocolate Bar',
      metric: IngredientMetric.item,
      cost: 1.50,
      costAmount: 1,
      type: IngredientType.snack,
    ),
    Ingredient(
      id: 'veg_1',
      name: 'Carrots',
      metric: IngredientMetric.item,
      cost: 1.80,
      costAmount: 8,
      type: IngredientType.vegetable,
    ),
    Ingredient(
      id: 'veg_2',
      name: 'Tomatoes',
      metric: IngredientMetric.item,
      cost: 2.50,
      costAmount: 6,
      type: IngredientType.vegetable,
    ),
    Ingredient(
      id: 'misc_1',
      name: 'Soy Sauce',
      metric: IngredientMetric.item,
      cost: 3.00,
      costAmount: 1,
      type: IngredientType.misc,
    ),
    Ingredient(
      id: 'misc_2',
      name: 'Sweet Potato',
      metric: IngredientMetric.item,
      type: null,
    ),
  ];
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
