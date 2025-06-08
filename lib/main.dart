import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/database/database_user.dart';
import 'package:fresh_planner/ui/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fresh Planner',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      //home: IngredientsPage(user: User(email: "replythisnot@outlook.com", username: "testUser", uid: "wdmdDZ4loXbuJyqPzAoq")),
      home: LoginPage(title: '', userDB: DatabaseUser(), ingredientDB: DatabaseIngredients(), calendarDB: DatabaseCalendar(),)
    );
  }
}
