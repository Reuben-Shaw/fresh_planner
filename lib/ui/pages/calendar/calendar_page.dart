import 'dart:math';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/calendar/add_meal_page.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/calendar_cell.dart';

class CalendarPage extends ParentPage {
  const CalendarPage({super.key, required super.user, required super.ingredients, required this.recipes,});

  final List<Recipe> recipes;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> { 
  DateTime currentDay = DateTime.now();
	int currentMonth = 4;
	int currentYear = 2025;

  TimeOfDay timeOfDay = TimeOfDay.lunch;
  

  List<GestureDetector> createCalendar() {
    final List<Meal> meals = [
      Meal(name: "Chorizo Carbonara", colour: Colors.red),
      Meal(name: "Lemon Chicken Tacos", colour: Colors.lime),
      Meal(name: "Salmon Pasta", colour: Colors.pink[200]!),
      Meal(name: "Creamy Mushroom Pasta", colour: Colors.orange),
    ];

    final List<GestureDetector> cells = [];

    final int monthStartDay;
		final int monthLength;

		int priorMonth = currentMonth - 1;
		int priorYear = currentYear;
		int nextMonth = currentMonth + 1;
		int nextYear = currentYear;
		final int priorMonthLength;

    monthStartDay = (DateTime(currentYear, currentMonth, 1).weekday + 6) % 7;
    monthLength = getDaysInMonth(currentYear, currentMonth);

    if (currentMonth == 1) {
			priorMonth = 12;
			priorYear = currentYear - 1;
		}
		else if (currentMonth == 12) {
			nextMonth = 1;
			nextYear = currentYear + 1;
		}

    priorMonthLength = getDaysInMonth(priorYear, priorMonth);

    int numberAfterAdded = 0;
    Random rnd = Random();

    for (int week = 0; week < 6; week++) {
			for (int day = 0; day < 7; day++) {
				final int offsetIndex = (week * 7) + day + 1;

				CalendarCell cell;

        int randomSelect = rnd.nextInt(meals.length + 1);
        Meal? randomMeal = randomSelect > meals.length - 1 ? null : meals[randomSelect];

				// Logic for adding the days before the start of the month
				if (offsetIndex < monthStartDay + 1) {
					cell = CalendarCell(date: DateTime(priorYear, priorMonth, priorMonthLength - monthStartDay + offsetIndex), meal: randomMeal);
				}
				// Logic for adding the days after the end of the month
				else if (offsetIndex > monthLength + monthStartDay) {
					cell = CalendarCell(date: DateTime(nextYear, nextMonth, offsetIndex - (monthLength + monthStartDay)), meal: randomMeal);
          numberAfterAdded++;
				}
				// Logic for adding days in the month
				else {
          final DateTime day = DateTime(currentYear, currentMonth, offsetIndex - monthStartDay);
					cell = CalendarCell(date: day, meal: randomMeal, isCurrentDay: day == DateUtils.dateOnly(currentDay));
				}

        final gestureCell = GestureDetector(
          onTap:() async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMealPage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, day: cell.date, time: timeOfDay,)),
            );
          }, 
          child: cell
        );
        cells.add(gestureCell);
			}
		}

    if (numberAfterAdded > 6) {
      cells.length = cells.length - 7;
    }

    return cells;
  }

  int getDaysInMonth(int year, int month) {
    final firstDayOfNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title:  Text(
          DateFormat("MMMM").format(DateTime(currentYear, currentMonth, 1)),
          style: AppTextStyles.mainTitle,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget> [
                Expanded(
                  child: Text('M', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('T', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('W', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('T', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('F', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('S', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('S', textAlign: TextAlign.center),
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              childAspectRatio: 0.5,
              children: <Widget> [
                ...createCalendar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
