import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/widgets/flexi_box.dart';

class CalendarCell extends StatelessWidget {
  final int day;
  final bool isCurrentDay;

  const CalendarCell({
    super.key,
    this.day = 0,
    this.isCurrentDay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        border: Border.all(color: (Colors.green[900])!)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: isCurrentDay,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green[900],
                        ),
                      ),
                    ),
                    Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        color: isCurrentDay ? Colors.white : Colors.green[900], 
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
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            FlexiBox(
              heightFactor: 0.3,
            ),
            Text(
              "Salmon and Pasta"
            ),
          ],
        ),
      ),
    );
  }
}
