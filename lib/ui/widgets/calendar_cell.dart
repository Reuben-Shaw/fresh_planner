import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/meal.dart';

/// Used to display a single instance of a day on the calendar
class CalendarCell extends StatelessWidget {
  final DateTime date;
  final Meal? meal;
  final bool isCurrentDay;
  final bool isPassed;
  final bool isFaded;

  /// `isFaded` should be used for days that are before and after the currently displayed month (run off and run on days)
  /// as well as days that have passed in the CURRENT month, previous months should not be entirely greyed out as it effects
  /// readability
  /// 
  /// Any days that have passed should always be marked as `isPassed`, which prevents them from being interacted with
  const CalendarCell({
    super.key,
    required this.date,
    this.meal,
    this.isCurrentDay = false,
    this.isPassed = false,
    this.isFaded = false,
  });

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Date is $date\nMeal is ${meal.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF26693C))
      ),
      child: Opacity(
        opacity: isFaded ? 0.33 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Column(
            mainAxisAlignment: meal == null ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: isCurrentDay,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF26693C),
                          ),
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: isCurrentDay ? Colors.white : const Color(0xFF26693C), 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: meal == null ? Colors.transparent : (meal?.recipe.colour)!,
                    ),
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  Visibility(
                    visible: meal != null,
                    child: Text(
                      meal == null ? '' : (meal?.recipe.name)!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: meal == null,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
