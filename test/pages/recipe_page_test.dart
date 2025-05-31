import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_planner/main.dart';
import 'package:fresh_planner/source/database/database_user.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/calendar/calendar_page.dart';
import 'package:fresh_planner/ui/pages/login_page.dart';
import 'package:fresh_planner/ui/pages/shared/recipe_page.dart';
import '../database/database_calendar_test.dart';
import '../database/database_ingredients_test.dart';
import '../database/database_user_test.dart';

void main() {
  late Widget testPage;

  setUp(() {
    final ingredients = [
      Ingredient(name: "pasta", metric: IngredientMetric.grams, cost: 1.27, costAmount: 800, amount: 100,),
      Ingredient(name: "salmon", metric: IngredientMetric.item, cost: 3.66, costAmount: 1, amount: 1,),
      Ingredient(name: "olive oil", metric: IngredientMetric.ml, cost: 8.50, costAmount: 1000,),
      Ingredient(name: "frozen peas", metric: IngredientMetric.percentage, cost: 2.30, costAmount: 800, amount: 8,),
    ];

    testPage = MaterialApp(
      home: RecipePage(
        calendarDB: DatabaseCalendarTest(),
        user: User(uid: "testID", email: "test@email.com", username: "testUser"),
        ingredients: ingredients,
        recipes: [
          Recipe(name: "salmon pasta", ingredients: ingredients, colour: Colors.red)
        ],
        ingredientsInRecipe: ingredients,
      ),
    );
  });
  
  testWidgets("Test Blank Input", (tester) async {   
    await tester.pumpWidget(testPage); 
    await tester.tap(find.byKey(Key("create_button")));
    await tester.pump();
    expect(find.text("Ensure all required values are filled"), findsOneWidget);
  });

  testWidgets("Test Repeated Name", (tester) async {   
    await tester.pumpWidget(testPage); 
    await tester.enterText(find.byKey(Key("name_textfield")), "Salmon Pasta");
    await tester.pump();
    await tester.tap(find.byKey(Key("create_button")));
    await tester.pump();
    expect(find.text("Recipe with that name already exists"), findsOneWidget);
  });
}
