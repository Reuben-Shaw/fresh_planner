import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_planner/ui/pages/login_page.dart';
import '../database/database_calendar_test.dart';
import '../database/database_ingredients_test.dart';
import '../database/database_user_test.dart';

void main() {
  late Widget testPage;

  setUp(() {
    testPage = MaterialApp(
      home: LoginPage(
        title: 'Fresh Planner Test',
        userDB: DatabaseUserTest(),
        ingredientDB: DatabaseIngredientsTest(),
        calendarDB: DatabaseCalendarTest(),
      ),
    );
  });
  
  testWidgets('Test Blank Input', (tester) async {   
    await tester.pumpWidget(testPage); 
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text('Please ensure all data is filled'), findsOneWidget);
  });

  testWidgets('Test Wrong Input', (tester) async {
    await tester.pumpWidget(testPage); 
    
    await tester.enterText(find.byKey(const Key('email_textfield')), 'wrongemail@test.com');
    await tester.enterText(find.byKey(const Key('password_textfield')), 'wrongpassword');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text('Email or password is incorrect'), findsOneWidget);
  });

  testWidgets('Test Correct Input', (tester) async {
    await tester.pumpWidget(testPage); 
    
    await tester.enterText(find.byKey(const Key('email_textfield')), 'correctemail@test.com');
    await tester.enterText(find.byKey(const Key('password_textfield')), 'correctPassword');
    await tester.pump();
    // await tester.tap(find.byKey(Key("login_button")));
    // await tester.pump();
    expect(find.text('Email or password is incorrect'), findsNothing);
    
    final userDB = DatabaseUserTest();
    expect((await userDB.loginUser('correctemail@test.com', 'correctPassword')).$1, true);
  });

  testWidgets('Test Signup With Existing Email', (tester) async {
    await tester.pumpWidget(testPage); 
    
    await tester.tap(find.byKey(const Key('register_text')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email_textfield')), 'existingemail@test.com');
    await tester.enterText(find.byKey(const Key('username_textfield')), 'testUser');
    await tester.enterText(find.byKey(const Key('password_textfield')), 'password');
    await tester.enterText(find.byKey(const Key('reenter_password_textfield')), 'password');
    await tester.pump();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    expect(find.text('This email has already been registered'), findsOneWidget);
  });

  testWidgets('Test Signup With Non-Matching Passwords', (tester) async {
    await tester.pumpWidget(testPage); 
    
    await tester.tap(find.byKey(const Key('register_text')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email_textfield')), 'validemail@test.com');
    await tester.enterText(find.byKey(const Key('username_textfield')), 'testUser');
    await tester.enterText(find.byKey(const Key('password_textfield')), 'password');
    await tester.enterText(find.byKey(const Key('reenter_password_textfield')), 'wrongPassword');
    await tester.pump();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    expect(find.text('Please ensure passwords match'), findsOneWidget);
  });

  testWidgets('Test Signup Correct', (tester) async {
    await tester.pumpWidget(testPage); 
    
    await tester.tap(find.byKey(const Key('register_text')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('email_textfield')), 'validemail@test.com');
    await tester.enterText(find.byKey(const Key('username_textfield')), 'testUser');
    await tester.enterText(find.byKey(const Key('password_textfield')), 'password');
    await tester.enterText(find.byKey(const Key('reenter_password_textfield')), 'password');
    await tester.pump();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text(''), findsOneWidget);
  });
}
