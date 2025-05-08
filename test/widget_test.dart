// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

import 'package:fresh_planner/main.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
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
