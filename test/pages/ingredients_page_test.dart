import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/ingredients_page.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';
import '../database/database_ingredients_test.dart';
void main() {
  late Widget testPage;

  setUp(() async {
    final db = DatabaseIngredientsTest();
    testPage = MaterialApp(
      home: IngredientsPage(
        user: User(uid: 'testID', email: 'test@email.com', username: 'testUser'),
        ingredients: (await db.getAllIngredients('testID'))!,
      ),
    );
  });
  
  testWidgets('Test Widget Expansion', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('Baking_header_tap')));
    await tester.pumpAndSettle();
    await tester.pump();
    expect(find.text('Baking Powder'), findsOneWidget);
  });

  testWidgets('Test Null Values Sorted into Misc', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('Miscellaneous_header_tap')));
    await tester.pumpAndSettle();
    expect(find.text('Sweet Potato'), findsOneWidget);
  });

  testWidgets('Test Blank Search', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('search_textfield')));
    await tester.pumpAndSettle();

    expect(find.text('Baking'), findsOneWidget);
  });

  testWidgets('Test Search with Text', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('search_textfield')), 'pot');
    await tester.pumpAndSettle();

    expect(find.text('Baking'), findsNothing);
    expect(find.text('Potato Chips'), findsOneWidget);
    expect(find.text('Sweet Potato'), findsOneWidget);
  });

  testWidgets('Test Search with Text Varying Case', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('search_textfield')), 'tOMat');
    await tester.pumpAndSettle();

    expect(find.text('Tomatoes'), findsOneWidget);
  });

  testWidgets('Test Search with No Returns', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.enterText(find.byKey(const Key('search_textfield')), '--');
    await tester.pumpAndSettle();

    expect(find.byType(IngredientCard), findsNothing);
  });
  
  testWidgets('Test Setting Amount None Selected', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('amount_tap')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('amount_textfield')), findsNothing);
  });
  
  testWidgets('Test Setting Valid Amount', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('Baking_header_tap')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('Baking Powder_tap')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_tap')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amount_textfield')), '11');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_button')));
    await tester.pumpAndSettle();

    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('Test Setting Invalid Amount', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('Baking_header_tap')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('Baking Powder_tap')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_tap')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amount_textfield')), '-11');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_button')));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Test Setting Amount to Text', (tester) async {   
    await tester.pumpWidget(testPage); 

    await tester.tap(find.byKey(const Key('Baking_header_tap')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('Baking Powder_tap')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_tap')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amount_textfield')), 'incorrect');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('amount_button')));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
  });
}
