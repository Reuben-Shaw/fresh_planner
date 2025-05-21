import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/meal.dart';

class CalendarCell extends StatelessWidget {
  final DateTime date;
  final Meal? meal;
  final bool isCurrentDay;

  const CalendarCell({
    super.key,
    required this.date,
    this.meal,
    this.isCurrentDay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF26693C))
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF26693C),
                        ),
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        color: isCurrentDay ? Colors.white : Color(0xFF26693C), 
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
                    meal == null ? "" : (meal?.recipe.name)!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Center(
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
    );
  }
}
