import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

import 'package:fresh_planner/main.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

void main() {
  test("Check if meal sorting works", () {
    final r1 = Recipe(name: "TestRecipe1", ingredients: [], colour: Colors.red);
    final r2 = Recipe(name: "TestRecipe2", ingredients: [], colour: Colors.red);
    final r3 = Recipe(name: "TestRecipe3", ingredients: [], colour: Colors.red);
    final r4 = Recipe(name: "TestRecipe4", ingredients: [], colour: Colors.red);
    final r5 = Recipe(name: "TestRecipe5", ingredients: [], colour: Colors.red);

    final m1 = Meal(recipe: r1, time: TimeOfDay.lunch, day: DateTime(2025, 5, 7));
    final m2 = Meal(recipe: r2, time: TimeOfDay.lunch, repeatFromOtherWeek: DateTime(2025, 3, 2));
    final m3 = Meal(recipe: r3, time: TimeOfDay.lunch, day: DateTime(2025, 5, 3));
    final m4 = Meal(recipe: r4, time: TimeOfDay.lunch, repeatFromWeek: 6);
    final m5 = Meal(recipe: r5, time: TimeOfDay.lunch, repeatFromDay: 27);
    final List<Meal> meals = [m1, m2, m3, m4, m5,];

    expect(meals, [m1, m2, m3, m4, m5]);
    meals.sort();

    expect(meals, [m4, m2, m5, m3, m1]);

    for (Meal m in meals) {
      printOnFailure(m.recipe.name);
    }
  });
}
