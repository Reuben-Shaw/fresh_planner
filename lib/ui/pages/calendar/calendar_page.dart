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
  const CalendarPage({super.key, required super.user, required super.ingredients, required this.recipes, required this.meals});

  final List<Recipe> recipes;
  final List<Meal> meals;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> { 
  DateTime currentDay = DateTime.now();
	int currentMonth = 4;
	int currentYear = 2025;

  TimeOfDay timeOfDay = TimeOfDay.lunch;

  

  List<GestureDetector> createCalendar() {
    final List<GestureDetector> cells = [];

    final int monthStartDay;
		final int monthLength;

		int priorMonth = currentMonth - 1;
		int priorYear = currentYear;
		int nextMonth = currentMonth + 1;
		int nextYear = currentYear;
		final int priorMonthLength;

    monthStartDay = britishWeekday(DateTime(currentYear, currentMonth, 1));
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
    Map<DateTime, CalendarCell?> cellMap = {};

    for (int week = 0; week < 6; week++) {
			for (int day = 0; day < 7; day++) {
				final int offsetIndex = (week * 7) + day + 1;

				// Logic for adding the days before the start of the month
				if (offsetIndex < monthStartDay + 1) {
          final day = DateTime(priorYear, priorMonth, priorMonthLength - monthStartDay + offsetIndex);
					cellMap[day] = CalendarCell(date: day);
				}
				// Logic for adding the days after the end of the month
				else if (offsetIndex > monthLength + monthStartDay) {
          final day = DateTime(nextYear, nextMonth, offsetIndex - (monthLength + monthStartDay));
					cellMap[day] = CalendarCell(date: day);
          numberAfterAdded++;
				}
				// Logic for adding days in the month
				else {
          final day = DateTime(currentYear, currentMonth, offsetIndex - monthStartDay);
					cellMap[day] = CalendarCell(date: day);
				}
			}
		}

    for (Meal m in widget.meals) {
      if (m.isRepeatingWeek()) {
        final startDate = getFirstInstanceOfDay(m.repeatFromWeek!, monthStartDay, priorYear, priorMonth, priorMonthLength); 
        for(int i = 0; i < 6; i++) {
          final newDate = startDate.add(Duration(days: i * 7));
          cellMap[newDate] = CalendarCell(date: newDate, meal: m,);
        }
      }
      else if (m.isRepeatingOtherWeek()) {
        final firstInstanceOfDay = getFirstInstanceOfDay(britishWeekday(m.repeatFromOtherWeek!), monthStartDay, priorYear, priorMonth, priorMonthLength);

        final difference = m.repeatFromOtherWeek!.difference(firstInstanceOfDay).inDays.abs() + 1;
        final offset = difference % 14;

        for(int i = 0; i < 3; i++)
        {
          final newDate = firstInstanceOfDay.add(Duration(days: (i * 14) + offset));
          cellMap[newDate] = CalendarCell(date: newDate, meal: m,);
        }
      }
      else if (m.isRepeatingDay()) {
        final currentDate = DateTime(currentYear, currentMonth, m.repeatFromDay!);
        cellMap[currentDate] = CalendarCell(date: currentDate, meal: m,);
        
        final priorDate = DateTime(priorYear, priorMonth, m.repeatFromDay!);
        if (cellMap.containsKey(priorDate)) cellMap[priorDate] = CalendarCell(date: priorDate, meal: m,);

        final nextDate = DateTime(nextYear, nextMonth, m.repeatFromDay!);
        if (cellMap.containsKey(nextDate)) cellMap[nextDate] = CalendarCell(date: nextDate, meal: m,);
      }
      else if (m.isSingleDay()) {
        cellMap[m.day!] = CalendarCell(date: m.day!, meal: m,);
      }
    }

    cellMap.forEach((key, value) {
      final gestureCell = GestureDetector(
        onTap:() async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMealPage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, day: key, time: timeOfDay,)),
          );
        }, 
        child: value
      );
      cells.add(gestureCell);
    });
    

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

  int britishWeekday(DateTime date) {
    return (date.weekday + 6) % 7;
  }

  DateTime getFirstInstanceOfDay(int dayOfWeek, int monthStartDay, int priorYear, int priorMonth, int priorMonthLength) {
    return dayOfWeek >= monthStartDay ? 
      DateTime(currentYear, currentMonth, (dayOfWeek - monthStartDay + 1)) : 
      DateTime(priorYear, priorMonth, (priorMonthLength - ((britishWeekday(DateTime(priorYear, priorMonth, dayOfWeek)) + 1) % monthStartDay)));
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
