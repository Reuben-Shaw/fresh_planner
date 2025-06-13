import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/add_ingredient_page.dart';
import '../database/database_ingredients_test.dart';

void main() {
  late Widget testPage;

  setUp(() async {
    final db = DatabaseIngredientsTest();
    testPage = MaterialApp(
      home: AddIngredientPage(
        user: User(email: 'correctemail@test.com', username: 'testUser', uid: 'testID'),
        ingredients: (await db.getAllIngredients('testUID'))!,
        ingredientDB: db,
        recipes: const [],
      ),
    );
  });

  testWidgets('Test Empty Input', (tester) async {
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();
    expect(find.text('Ensure all required values are filled'), findsOneWidget);
  });

  testWidgets('Test Empty Amount Filled Cost', (tester) async {
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('name_textfield')), 'testIngredient');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cost_textfield')), '3');

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();

    expect(find.text('Please ensure an amount per cost is provided'), findsOneWidget);
  });

  testWidgets('Test Non-Numeric Cost', (tester) async {
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('name_textfield')), 'testIngredient');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cost_textfield')), 'bad');
    await tester.enterText(find.byKey(const Key('amount_textfield')), '3');

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();

    expect(find.text('Cost is not numeric'), findsOneWidget);
  });

  testWidgets('Test Non-Numeric Amount', (tester) async {
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('name_textfield')), 'testIngredient');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cost_textfield')), '3');
    await tester.enterText(find.byKey(const Key('amount_textfield')), 'bad');

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();

    expect(find.text('Amount per cost is not numeric'), findsOneWidget);
  });

  testWidgets('Test Non-Integer Amount', (tester) async {
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('name_textfield')), 'testIngredient');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cost_textfield')), '3');
    await tester.enterText(find.byKey(const Key('amount_textfield')), '5.5');

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();

    expect(find.text('Amount per cost is not numeric'), findsOneWidget);
  });

  testWidgets('Test Negative Cost and Amount', (tester) async {
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('name_textfield')), 'testIngredient');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cost_textfield')), '-3');
    await tester.enterText(find.byKey(const Key('amount_textfield')), '-3');

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();

    expect(find.text('Pricing cannot use negative numbers'), findsOneWidget);
  });

  testWidgets('Test Metric Updates Symbol', (tester) async {
    await tester.pumpWidget(testPage); 

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();
    expect(find.text('g'), findsOneWidget);

    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Items').last);
    await tester.pumpAndSettle();
    expect(find.text('item'), findsNothing);

    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Millilitres').last);
    await tester.pumpAndSettle();
    expect(find.text('ml'), findsOneWidget);

    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Percentage').last);
    await tester.pumpAndSettle();
    expect(find.text('%'), findsOneWidget);
  });

  testWidgets('Test Duplicate name check shows error', (tester) async {
    await tester.pumpWidget(testPage);
    await tester.enterText(find.byKey(const Key('name_textfield')), 'apples');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Items').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pump();

    expect(find.text('Ingredient with the same name already exists'), findsOneWidget);
  });

  testWidgets('Test Ensures Ingredient is Correctly Created', (tester) async {
    Ingredient? ingredient;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => testPage),
                );
                if (result is! Ingredient) {
                  debugPrint('Not Ingredient');
                  return;
                } 
                ingredient = result;
                debugPrint('Popped with $result');
                final expectedReturn = Ingredient(
                  id: 'testID',
                  name: 'testingredient',
                  metric: IngredientMetric.grams,
                  cost: 3,
                  amount: 1,
                  type: IngredientType.herbSpice,
                );

                expect(result, isNotNull);
                expect(ingredient, equals(expectedReturn));
              },
              child: const Text('Open Login'),
            ),
          );
        },
      ),
    ));

    await tester.tap(find.text('Open Login'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('name_textfield')), 'testIngredient');

    final metricDropdown = find.byKey(const ValueKey('metric_dropdown'));
    await tester.tap(metricDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Grams').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cost_textfield')), '3');
    await tester.enterText(find.byKey(const Key('amount_textfield')), '1');

    final typeDropdown = find.byKey(const ValueKey('type_dropdown'));
    await tester.tap(typeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('   Herbs & Spices').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pumpAndSettle();
  });
}
