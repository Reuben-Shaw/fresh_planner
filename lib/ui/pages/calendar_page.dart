import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/calendar_cell.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> { 
  DateTime currentDay = DateTime.now();
	int currentMonth = 4;
	int currentYear = 2025;
  

  List<CalendarCell> createCalendar() {
    final List<CalendarCell> cells = [];

    final int monthStartDay;
		final int monthLength;

		int priorMonth = currentMonth - 1;
		int priorYear = currentYear;
		int nextMonth = currentMonth + 1;
		int nextYear = currentYear;
		final int priorMonthLength;

    monthStartDay = (DateTime(currentYear, currentMonth, 1).weekday + 6) % 7;
    monthLength = getDaysInMonth(currentYear, currentMonth);

    if (currentMonth == 1)
		{
			priorMonth = 12;
			priorYear = currentYear - 1;
		}
		else if (currentMonth == 12)
		{
			nextMonth = 1;
			nextYear = currentYear + 1;
		}

    priorMonthLength = getDaysInMonth(priorYear, priorMonth);

    int numberAfterAdded = 0;

    for (int week = 0; week < 6; week++)
		{
			for (int day = 0; day < 7; day++)
			{
				int offsetIndex = (week * 7) + day + 1;

				CalendarCell cell;

				// Logic for adding the days before the start of the month
				if (offsetIndex < monthStartDay + 1)
				{
					cell = CalendarCell(day: priorMonthLength - monthStartDay + offsetIndex);
				}
				// Logic for adding the days after the end of the month
				else if (offsetIndex > monthLength + monthStartDay)
				{
					cell = CalendarCell(day: offsetIndex - (monthLength + monthStartDay));
          numberAfterAdded++;
				}
				// Logic for adding days in the month
				else
				{
          int day = offsetIndex - monthStartDay;
					cell = CalendarCell(day: day, isCurrentDay: day == currentDay.day,);
				}
        cells.add(cell);
			}
		}

    if (numberAfterAdded > 6) 
    {
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
