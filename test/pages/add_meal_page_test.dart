import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/calendar/add_meal_page.dart';
import '../database/database_calendar_test.dart';

void main() {
  late Widget testPage;

  setUp(() {
    final ingredients = [
      Ingredient(name: 'pasta', metric: IngredientMetric.grams, cost: 1.27, costAmount: 800, amount: 100,),
      Ingredient(name: 'salmon', metric: IngredientMetric.item, cost: 3.66, costAmount: 1, amount: 1,),
      Ingredient(name: 'olive oil', metric: IngredientMetric.ml, cost: 8.50, costAmount: 1000,),
      Ingredient(name: 'frozen peas', metric: IngredientMetric.grams, cost: 2.30, costAmount: 800, amount: 80,),
    ];
    testPage = MaterialApp(
      home: AddMealPage(
        user: User(email: 'correctemail@test.com', username: 'testUser', uid: 'testID'),
        calendarDB: DatabaseCalendarTest(),
        ingredients: ingredients,
        recipes: [
          Recipe(name: 'salmon pasta', link: 'linkAddress', ingredients: ingredients, colour: Colors.red),
        ],
        day: DateTime(2025, 05, 06),
        time: TimeOfDay.lunch,
        currentMeal: null,
        meals: const{},
      ),
    );
  });

  testWidgets('Test Mising Recipe', (tester) async {
    await tester.pumpWidget(testPage); 
    
    final addButton = find.byKey(const Key('add_button'));
    await tester.ensureVisible(addButton);
    
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Please ensure a recipe is selected'), findsOneWidget);
  });

  testWidgets('Test Recipe Info', (tester) async {
    await tester.pumpWidget(testPage); 
    
    final recipeDropdown = find.byKey(const Key('recipe_dropdown'));
    await tester.tap(recipeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   salmon pasta').last);
    await tester.pumpAndSettle();
    
    expect(find.text('linkAddress'), findsOneWidget);
    expect(find.text('£4.05'), findsOneWidget);
    expect(find.text('• pasta - 100g'), findsOneWidget);
    expect(find.text('• salmon - 1 Items'), findsOneWidget);
    expect(find.text('• olive oil'), findsOneWidget);
    expect(find.text('• frozen peas - 80g'), findsOneWidget);
  });

  testWidgets('Test Time of Day Display', (tester) async {
    final testPageBreakfast = MaterialApp(
      home: AddMealPage(
        user: User(email: 'correctemail@test.com', username: 'testUser', uid: 'testID'),
        calendarDB: DatabaseCalendarTest(),
        ingredients: const [],
        recipes: const [],
        day: DateTime(2025, 05, 06),
        time: TimeOfDay.breakfast,
        currentMeal: null,
        meals: const{},
      ),
    );
    
    await tester.pumpWidget(testPageBreakfast); 
    await tester.pumpAndSettle();
    Icon timeDisplay = tester.widget<Icon>(find.byKey(const Key('time_icon')));
    expect(timeDisplay.icon, Icons.sunny_snowing);
    
    final testPageLunch = MaterialApp(
      home: AddMealPage(
        user: User(email: 'correctemail@test.com', username: 'testUser', uid: 'testID'),
        calendarDB: DatabaseCalendarTest(),
        ingredients: const [],
        recipes: const [],
        day: DateTime(2025, 05, 06),
        time: TimeOfDay.lunch,
        currentMeal: null,
        meals: const{},
      ),
    );
    
    await tester.pumpWidget(testPageLunch); 
    await tester.pumpAndSettle();
    timeDisplay = tester.widget<Icon>(find.byKey(const Key('time_icon')));
    expect(timeDisplay.icon, Icons.sunny);

    final testPageDinner = MaterialApp(
      home: AddMealPage(
        user: User(email: 'correctemail@test.com', username: 'testUser', uid: 'testID'),
        calendarDB: DatabaseCalendarTest(),
        ingredients: const [],
        recipes: const [],
        day: DateTime(2025, 05, 06),
        time: TimeOfDay.dinner,
        currentMeal: null,
        meals: const{},
      ),
    );
    
    await tester.pumpWidget(testPageDinner); 
    timeDisplay = tester.widget<Icon>(find.byKey(const Key('time_icon')));
    expect(timeDisplay.icon, Icons.nightlight);
  });
  
  testWidgets('Test Displaying Existing Meal', (tester) async {
    final ingredients = [
      Ingredient(name: 'pasta', metric: IngredientMetric.grams, cost: 1.27, costAmount: 800, amount: 100,),
      Ingredient(name: 'salmon', metric: IngredientMetric.item, cost: 3.66, costAmount: 1, amount: 1,),
      Ingredient(name: 'olive oil', metric: IngredientMetric.ml, cost: 8.50, costAmount: 1000,),
      Ingredient(name: 'frozen peas', metric: IngredientMetric.grams, cost: 2.30, costAmount: 800, amount: 80,),
    ];
    final recipe = Recipe(name: 'salmon pasta', link: 'linkAddress', ingredients: ingredients, colour: Colors.red);
    final testPageExistingMeal = MaterialApp(
      home: AddMealPage(
        user: User(email: 'correctemail@test.com', username: 'testUser', uid: 'testID'),
        calendarDB: DatabaseCalendarTest(),
        ingredients: ingredients,
        recipes: [
          recipe,
        ],
        day: DateTime(2025, 05, 06),
        time: TimeOfDay.lunch,
        currentMeal: Meal(recipe: recipe, time: TimeOfDay.lunch, cookedFresh: false),
        meals: const{},
      ),
    );
    
    await tester.pumpWidget(testPageExistingMeal); 
    
    expect(find.byKey(const Key('delete_button')), findsOneWidget);
    expect(find.byKey(const Key('add_button')), findsNothing);
  });
}
