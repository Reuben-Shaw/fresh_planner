import 'dart:math';
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/calendar/add_meal_page.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/calendar_cell.dart';

class CalendarPage extends ParentPage {
  const CalendarPage({super.key, required super.user, required super.ingredients, required this.recipes, required this.meals, required this.calendarDB});

  final List<Recipe> recipes;
  final Map<TimeOfDay, List<Meal>> meals;
  final DatabaseCalendar calendarDB;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> { 
  DateTime currentDate = DateTime.now();
	int currentDay = 1;
	int currentMonth = 1;
	int currentYear = 1970;

  TimeOfDay __timeOfDay = TimeOfDay.lunch;
  TimeOfDay get _timeOfDay => __timeOfDay;
  set _timeOfDay(TimeOfDay value) {
    setState(() {
      __timeOfDay = value;
    });
  }

  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  double __upcomingCost = 0;
  double get _upcomingCost => __upcomingCost;
  set _upcomingCost(double value) => setState(() => __upcomingCost = value);

  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();

    DateTime time = DateTime.now();
    DateTime date = DateTime(time.year, time.month, time.day, 0, 0, 0);

    setState(() {
      currentDate = date;
      currentDay = date.day;
      currentMonth = date.month;
      currentYear = date.year;  
    });

    if (date.add(Duration(hours: 14, minutes: 59)).isBefore(time)) {
      debugPrint("Dinner time");
      _timeOfDay = TimeOfDay.dinner;
    } else if (date.add(Duration(hours: 9, minutes: 59)).isBefore(time)) {
      debugPrint("Lunch time");
      _timeOfDay = TimeOfDay.lunch;
    } else {
      debugPrint("Breakfast time");
      _timeOfDay = TimeOfDay.breakfast;
    }
    debugPrint("Time Of Day is $_timeOfDay");
  }
  
  List<GestureDetector> _createCalendar() {
    debugPrint("\n\n\n\n\n\n======$currentMonth======");
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
					cellMap[day] = CalendarCell(date: day, isCurrentDay: day == currentDate,);
				}
			}
		}
    // debugPrint("cellMap length after for: ${cellMap.length} with ${cellMap.keys.last} as last");

    for (Meal m in widget.meals[_timeOfDay]!) {
      if (m.isRepeatingWeek()) {
        final startDate = getFirstInstanceOfDay(m.repeatFromWeek!, cellMap); 
        for(int i = 0; i < 6; i++) {
          final newDate = startDate.add(Duration(days: i * 7));
          cellMap[newDate] = CalendarCell(date: newDate, meal: m,);
        }
      }
      else if (m.isRepeatingOtherWeek()) {
        final firstInstanceOfDay = getFirstInstanceOfDay(britishWeekday(m.repeatFromOtherWeek!), cellMap);
        debugPrint("${m.recipe.name} - First instace of day: $firstInstanceOfDay with ${britishWeekday(m.repeatFromOtherWeek!)}");

        debugPrint("${m.repeatFromOtherWeek!}.difference($firstInstanceOfDay).inDays.abs() = ${m.repeatFromOtherWeek!.difference(firstInstanceOfDay).inDays.abs()}");
        debugPrint("offset = ${(m.repeatFromOtherWeek!.difference(firstInstanceOfDay).inDays.abs()) % 14}");
        int difference = m.repeatFromOtherWeek!.difference(firstInstanceOfDay).inDays.abs();
        // Adding 1 to account for passing through daylight savings
        if (difference % 7 != 0) difference++;
        final offset = difference % 14;

        for(int i = 0; i < 3; i++)
        {
          debugPrint("$firstInstanceOfDay + (($i * 14 = ${i * 14}) + $offset = ${(i * 14) + offset}) = ${addDays(firstInstanceOfDay, (i * 14) + offset)}");
          final newDate = addDays(firstInstanceOfDay, (i * 14) + offset);
          // debugPrint("$newDate is before ${cellMap.keys.last} == ${newDate.isBefore(cellMap.keys.last)}");
          // debugPrint("$newDate != ${cellMap.keys.last} == ${newDate != cellMap.keys.last}");
          // debugPrint("!newDate.isBefore(cellMap.keys.last) && newDate != cellMap.keys.last = ${!newDate.isBefore(cellMap.keys.last) && newDate != cellMap.keys.last}");
          if (!newDate.isBefore(cellMap.keys.last) && newDate != cellMap.keys.last) continue;
          cellMap[newDate] = CalendarCell(date: newDate, meal: m,);
          // debugPrint("cellMap length after: ${cellMap.length}");
        }
        // debugPrint("cellMap length after everything: ${cellMap.length}");
      }
      else if (m.isRepeatingDay()) {
        final currentDate = DateTime(currentYear, currentMonth, m.repeatFromDay!);
        cellMap[currentDate] = CalendarCell(date: currentDate, meal: m,);
        
        final priorDate = DateTime(priorYear, priorMonth, m.repeatFromDay!);
        if (cellMap.containsKey(priorDate)) cellMap[priorDate] = CalendarCell(date: priorDate, meal: m,);

        final nextDate = DateTime(nextYear, nextMonth, m.repeatFromDay!);
        if (cellMap.containsKey(nextDate)) cellMap[nextDate] = CalendarCell(date: nextDate, meal: m,);
      }
      else if (m.isSingleDay() && m.day!.month == currentMonth && m.day!.year == currentYear) {
        cellMap[m.day!] = CalendarCell(date: m.day!, meal: m,);
      }
    }

    cellMap.forEach((key, value) {
      final gestureCell = GestureDetector(
        onTap: () async {
          await _onCellClick(key, value);
        }, 
        onLongPress: () async {
          await _showDeleteDialog(value);
        },
        child: value
      );
      cells.add(gestureCell);
    });

    if (numberAfterAdded > 6) {
      cells.length = cells.length - 7;
    }

    setCostForNextSevenDays(cellMap);

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

  Future<void> _onCellClick(DateTime day, CalendarCell? cell) async {
    _isLoading = true;
    Meal? meal = cell?.meal;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMealPage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, calendarDB: widget.calendarDB, day: day, time: _timeOfDay, currentMeal: meal,)),
    );
    _isLoading = false;
    if (result is Meal) {
      setState(() {
        widget.meals[result.time]!.add(result);
        widget.meals[result.time]!.sort();
        _createCalendar();
      });
    } else if (result is String && result == "delete") {
      widget.meals[_timeOfDay]!.remove(cell!.meal!);
      widget.meals[_timeOfDay]!.sort();
      _createCalendar();
    }
  }

  DateTime getFirstInstanceOfDay(int dayOfWeek, Map<DateTime, CalendarCell?> cellMap) {
    return cellMap.entries.elementAt(dayOfWeek).key;
  }

  void setCostForNextSevenDays(Map<DateTime, CalendarCell?> cellMap) {
    double upcomingCost = 0;
    for (int i = 0; i < 7; i++) {
      DateTime dateCheck = DateTime(currentDate.year, currentDate.month, currentDate.day + i);
      if (cellMap.containsKey(dateCheck)) {
        upcomingCost += cellMap[dateCheck]?.meal?.cost() ?? 0;
      }
    }
    setState(() {
      _upcomingCost = upcomingCost;
    });
  }

  DateTime addDays(DateTime startDate, int numberOfDays) {
    final targetDate = startDate.add(Duration(days: numberOfDays));

    // Ensure the calendar day matches what we expect (in case DST pushes us into previous/next day)
    if (targetDate.day != startDate.day + (numberOfDays % 31)) {
      return DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        startDate.hour,
        startDate.minute,
        startDate.second,
        startDate.millisecond,
        startDate.microsecond,
      );
    }

    // Also correct time if the hour changed due to DST
    if (targetDate.hour != startDate.hour) {
      return DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        startDate.hour,
        startDate.minute,
        startDate.second,
        startDate.millisecond,
        startDate.microsecond,
      );
    }

    return targetDate;
  }

  Future<void> _showDeleteDialog(CalendarCell? cell) async {
    if (cell == null || cell.meal == null) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Meal"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Deleting ${cell.meal?.recipe.name} will remove it from your calendar, and remove any repetition rules attached"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red,),),
              onPressed: () async {
                _isLoading = true;
                final success = await widget.calendarDB.deleteMeal(widget.user.uid!, cell.meal!);
                _isLoading = false;

                if (!mounted) return;
                if (success) {
                  setState(() {
                    widget.meals[_timeOfDay]!.remove(cell.meal!);
                    widget.meals[_timeOfDay]!.sort();
                    _createCalendar();
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("calendar_page"),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back,),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              currentYear == currentDate.year ?
                              "${DateFormat('MMMM').format(DateTime(currentYear, currentMonth))}${currentYear == currentDate.year ? "" : " - $currentYear"}" :
                                "${DateFormat('MMM').format(DateTime(currentYear, currentMonth))}${currentYear == currentDate.year ? "" : " - ${currentYear.toString().substring(2, 4)}"}", 
                              style: AppTextStyles.mainTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(35)),
                              border: Border.all(color: Color(0xFF399E5A), width: 2),
                            ),
                            child: Row(
                              spacing: 4,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.sunny_snowing,
                                    color: _timeOfDay == TimeOfDay.breakfast ? Colors.white : Color(0xFF26693C),
                                  ), 
                                  onPressed: () => { _timeOfDay = TimeOfDay.breakfast }, 
                                  style: ButtonStyle(
                                    backgroundColor: _timeOfDay == TimeOfDay.breakfast ? WidgetStateProperty.all<Color>(Color(0xFF26693C)) : WidgetStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.sunny,
                                    color: _timeOfDay == TimeOfDay.lunch ? Colors.white : Color(0xFF26693C),
                                  ), 
                                  onPressed: () => { _timeOfDay = TimeOfDay.lunch }, 
                                  style: ButtonStyle(
                                    backgroundColor: _timeOfDay == TimeOfDay.lunch ? WidgetStateProperty.all<Color>(Color(0xFF26693C)) : WidgetStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.nightlight,
                                    color: _timeOfDay == TimeOfDay.dinner ? Colors.white : Color(0xFF26693C),
                                  ), 
                                  onPressed: () => { _timeOfDay = TimeOfDay.dinner }, 
                                  style: ButtonStyle(
                                    backgroundColor: _timeOfDay == TimeOfDay.dinner ? WidgetStateProperty.all<Color>(Color(0xFF26693C)) : WidgetStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: <Widget> [
                        Expanded(
                          child: Text('M', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                        Expanded(
                          child: Text('T', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                        Expanded(
                          child: Text('W', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                        Expanded(
                          child: Text('T', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                        Expanded(
                          child: Text('F', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                        Expanded(
                          child: Text('S', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                        Expanded(
                          child: Text('S', textAlign: TextAlign.center, style: AppTextStyles.innerTitle,),
                        ),
                      ],
                    ),
                    SizedBox(height: 4,),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < 0) {
                          setState(() {
                            if (currentMonth == 12) {
                              currentMonth = 1;
                              currentYear += 1;
                            } else {
                              currentMonth += 1;
                            }
                            debugPrint("Swiped left → Next month");
                            _createCalendar();
                          });
                        } else if (details.primaryVelocity! > 0) {
                          setState(() {
                            if (currentMonth == 1) {
                              currentMonth = 12;
                              currentYear -= 1;
                            } else {
                              currentMonth -= 1;
                            }
                            debugPrint("Swiped right → Previous month");
                            _createCalendar();
                          });
                        }
                      }
                    },
                    child: GridView.count(
                      crossAxisCount: 7,
                      childAspectRatio: 0.5,
                      children: <Widget>[
                        ..._createCalendar(),
                      ],
                    ),
                  ),
                ),
                Tooltip(
                  key: tooltipkey,
                  triggerMode: TooltipTriggerMode.manual,
                  showDuration: const Duration(seconds: 1),
                  message: "Price of ${_timeOfDay.standardName.toLowerCase()} for the next 7 days",
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                      ),
                      Text(
                        "Predicted Cost: ",
                        style: AppTextStyles.largerBold,
                      ),
                      Text(
                        NumberFormat.currency(locale: "en_UK", symbol: "£").format(_upcomingCost),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 28,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.help,
                          color: Color(0xFF26693C),
                        ),
                        onPressed: () {
                          tooltipkey.currentState?.ensureTooltipVisible();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _isLoading,
              child: LoadingScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
