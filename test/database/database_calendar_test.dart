import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

class DatabaseCalendarTest extends DatabaseCalendar{
  @override
  Future<(bool, String?)> addRecipe(String uid, Recipe recipe) async {
    return (true, 'testID');
  }

  @override
  Future<List<Recipe>?> getAllRecipes(String uid) async {
    return [];
  }

  @override
  Future<(bool, String?)> addMeal(String uid, Meal meal) async {
    return (true, 'testID');
  }

  @override
  Future<Map<TimeOfDay, List<Meal>>?> getAllMeals(String uid) async {
    return {};
  }

  @override
  Future<bool> deleteMeal(String uid, Meal meal) async {
    return true;
  }
} 
