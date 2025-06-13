import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/ui/pages/calendar/add_meal_page.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/calendar_cell.dart';

class CalendarPage extends ParentPage {
  const CalendarPage({super.key, required super.user, required super.ingredients, required super.recipes, required this.meals, required this.calendarDB});

  final Map<TimeOfDay, List<Meal>> meals;
  final DatabaseCalendar calendarDB;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> { 
  /// Current local datetime
  DateTime _currentDate = DateTime.now();
  // Month and year that the calendar is currently displaying, seperate from local time
	int _displayedMonth = 1;
	int _displayedYear = 1970;

  // Contains all the days of the month used in display
  List<Widget> _calendarCells = [];

  TimeOfDay __timeOfDay = TimeOfDay.lunch;
  TimeOfDay get _timeOfDay => __timeOfDay;
  set _timeOfDay(TimeOfDay value) {
    setState(() {
      __timeOfDay = value;
      _calendarCells = _createCalendar();
    });
  }

  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  double __upcomingCost = 0;
  double get _upcomingCost => __upcomingCost;
  set _upcomingCost(double value) => setState(() => __upcomingCost = value);

  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  /// Used for creation of display cells
  CalendarCell _cloneCell(CalendarCell? c, Meal m, DateTime d) => CalendarCell(date: d, meal: m, isCurrentDay: c!.isCurrentDay, isPassed: c.isPassed, isFaded: c.isFaded,);
  
  /// Responsible for setting the current time of day based on the local time
  @override
  void initState() {
    super.initState();

    DateTime time = DateTime.now();
    DateTime date = DateTime.utc(time.year, time.month, time.day, 0, 0, 0);

    setState(() {
      _currentDate = date;
      _displayedMonth = date.month;
      _displayedYear = date.year;  
    });

    if (date.toLocal().add(const Duration(hours: 14, minutes: 59)).isBefore(time)) {
      debugPrint('Dinner time');
      _timeOfDay = TimeOfDay.dinner;
    } else if (date.toLocal().add(const Duration(hours: 9, minutes: 59)).isBefore(time)) {
      debugPrint('Lunch time');
      _timeOfDay = TimeOfDay.lunch;
    } else {
      debugPrint('Breakfast time');
      _timeOfDay = TimeOfDay.breakfast;
    }
    debugPrint('Time Of Day is $_timeOfDay');

    setState(() {
      _calendarCells = _createCalendar();
    });
  }

  /// Very long function that creates the entire calendar
  List<GestureDetector> _createCalendar() {
    final List<GestureDetector> cells = [];

    // Key variable intitialisation for values that are used for calculations throughout the function
    final int monthStartDay;
		final int monthLength;

		int priorMonth = _displayedMonth - 1;
		int priorYear = _displayedYear;
		int nextMonth = _displayedMonth + 1;
		int nextYear = _displayedYear;
		final int priorMonthLength;

    monthStartDay = _britishWeekday(DateTime.utc(_displayedYear, _displayedMonth, 1));
    monthLength = _getDaysInMonth(_displayedYear, _displayedMonth);

    // Logic for handling overflow and underflow of the current year when display previous/next month run offs
    if (_displayedMonth == 1) {
			priorMonth = 12;
			priorYear = _displayedYear - 1;
		}
		else if (_displayedMonth == 12) {
			nextMonth = 1;
			nextYear = _displayedYear + 1;
		}

    priorMonthLength = _getDaysInMonth(priorYear, priorMonth);

    // numberAfterAdded is used to cut the list if it exceeds 6, as it means an entire extra week for the next month has been added without reason
    int numberAfterAdded = 0;
    Map<DateTime, CalendarCell?> cellMap = {};

    // Nested for loops create the calendar cells and assigns dates but doesn't populate them with meals
    for (int week = 0; week < 6; week++) {
			for (int day = 0; day < 7; day++) {
				final int offsetIndex = (week * 7) + day + 1;

				// Logic for adding the days before the start of the month
				if (offsetIndex < monthStartDay + 1) {
          final day = DateTime.utc(priorYear, priorMonth, priorMonthLength - monthStartDay + offsetIndex);
					cellMap[day] = CalendarCell(date: day, isPassed: day.isBefore(_currentDate), isFaded: true,);
				}
				// Logic for adding the days after the end of the month
				else if (offsetIndex > monthLength + monthStartDay) {
          final day = DateTime.utc(nextYear, nextMonth, offsetIndex - (monthLength + monthStartDay));
					cellMap[day] = CalendarCell(date: day, isPassed: day.isBefore(_currentDate), isFaded: true);
          numberAfterAdded++;
				}
				// Logic for adding days in the month
				else {
          final day = DateTime.utc(_displayedYear, _displayedMonth, offsetIndex - monthStartDay);
					cellMap[day] = CalendarCell(
            date: day, 
            isCurrentDay: day == _currentDate, 
            isPassed: day.isBefore(_currentDate), 
            // Days in the current month are faded if they are passed, to assist with clarity for upcoming vs passed days
            isFaded: _displayedMonth == _currentDate.month ? day.isBefore(_currentDate) : false,
          );
				}
			}
		}

    DateTime firstDate = cellMap.entries.first.key;
    DateTime lastDate = cellMap.entries.last.key;

    // For loop populates all the created calendar cells with meals
    // Meals are kept in an ordered list with the intention that they override each other, see `Meal.dart` for more information
    // It's likely that calendar cells are assigned multiple meals in the run of this loop
    for (Meal m in widget.meals[_timeOfDay]!) {
      // Every week
      if (m.isRepeatingWeek()) {
        final startDate = _getFirstInstanceOfDay(m.repeatFromWeek!, cellMap); 
        for(int i = 0; i < 6; i++) {
          final newDate = startDate.add(Duration(days: i * 7));
          cellMap[newDate] = _cloneCell(cellMap[newDate], m, newDate,);
        }
      }
      // Every other week
      else if (m.isRepeatingOtherWeek()) {
        final firstInstanceOfDay = _getFirstInstanceOfDay(_britishWeekday(m.repeatFromOtherWeek!), cellMap);
        int difference = m.repeatFromOtherWeek!.difference(firstInstanceOfDay).inDays.abs();
        final offset = difference % 14;

        for(int i = 0; i < 3; i++)
        {
          final newDate = firstInstanceOfDay.add(Duration(days: (i * 14) + offset));
          if (!newDate.isBefore(cellMap.keys.last) && newDate != cellMap.keys.last) continue;
          cellMap[newDate] = _cloneCell(cellMap[newDate], m, newDate,);
        }
      }
      // Specific date
      else if (m.isRepeatingDay()) {
        cellMap = _addRepeatingDay('$priorYear-${priorMonth.toString().padLeft(2, '0')}-${m.repeatFromDay!.toString().padLeft(2, '0')} 00:00:00.000Z', cellMap, m);
        cellMap = _addRepeatingDay('$_displayedYear-${_displayedMonth.toString().padLeft(2, '0')}-${m.repeatFromDay!.toString().padLeft(2, '0')} 00:00:00.000Z', cellMap, m);
        cellMap = _addRepeatingDay('$nextYear-${nextMonth.toString().padLeft(2, '0')}-${m.repeatFromDay!.toString().padLeft(2, '0')} 00:00:00.000Z', cellMap, m);
      }
      // Never repeats
      else if (m.isSingleDay() && m.day!.isAfter(firstDate) && m.day!.isBefore(lastDate)) {
        cellMap[m.day!] = _cloneCell(cellMap[m.day!], m, m.day!,);
      }
    }

    // Final for loop to assign interaction states to each day
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

    // Cuts the displayed cells if the end of the month is short enough that an entire extra week is displayed from the upcoming month
    if (numberAfterAdded > 6) {
      cells.length = cells.length - 7;
    }

    _setCostForNextSevenDays(cellMap);

    return cells;
  }


  int _getDaysInMonth(int year, int month) {
    final firstDayOfNextMonth = (month < 12)
        ? DateTime.utc(year, month + 1, 1)
        : DateTime.utc(year + 1, 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  /// Changes the default American logic to reflect the British display (American: Sunday = 0, Saturday = 6 - British: Monday = 0, Sunday = 6)
  int _britishWeekday(DateTime date) {
    return (date.weekday + 6) % 7;
  }

  /// Used for ensuring that repetition on an exact date works for days that aren't present every month (29th-31st)
  bool _validateDateTime(String input) {
    try {
      DateFormat('yyyy-MM-dd').parseStrict(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Condensed repeated logic for adding days that repeat once a month on a specific day
  Map<DateTime, CalendarCell?> _addRepeatingDay(String currentTimeStr, Map<DateTime, CalendarCell?> cellMap, Meal m) {
    final isDate = _validateDateTime(currentTimeStr.split(' ')[0]);
    if (!isDate) return cellMap;

    final date = DateTime.parse(currentTimeStr);

    if (cellMap.containsKey(date)) {
      cellMap[date] = _cloneCell(cellMap[date], m, date,);
    }
    return cellMap;
  }

  /// Handles logic for navigating to the `add_meal_page` when the cell is clicked, if it is empty it navigates to add a new meal, if not it's just a display screen
  Future<void> _onCellClick(DateTime day, CalendarCell? cell) async {
    if (cell?.isPassed ?? true) return;
    
    _isLoading = true;
    Meal? meal = cell?.meal;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMealPage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, calendarDB: widget.calendarDB, day: day, time: _timeOfDay, currentMeal: meal, meals: widget.meals,)),
    );
    _isLoading = false;
    if (result is Meal) {
      setState(() {
        widget.meals[result.time]!.add(result);
        widget.meals[result.time]!.sort();
        _calendarCells = _createCalendar();
      });
    } else if (result is String && result == 'delete') {
      setState(() {
        widget.meals[_timeOfDay]!.remove(cell!.meal!);
        widget.meals[_timeOfDay]!.sort();
        _calendarCells = _createCalendar();
      });
    } else if (result is (Map<TimeOfDay, List<Meal>>, Recipe)) {
      for (TimeOfDay time in [TimeOfDay.breakfast, TimeOfDay.lunch, TimeOfDay.dinner]) {
        setState(() {
          widget.meals[time] = result.$1[time]!;
          widget.meals[time]!.sort();
        });
      }
      setState(() {
        widget.recipes.remove(result.$2);
      });
      _calendarCells = _createCalendar();
    }
  } 

  /// Gets the first instance of a day of the week from the cellMap
  DateTime _getFirstInstanceOfDay(int dayOfWeek, Map<DateTime, CalendarCell?> cellMap) {
    return cellMap.entries.elementAt(dayOfWeek).key;
  }

  /// Calculates the expected cost for the next seven days, only works on the current month
  void _setCostForNextSevenDays(Map<DateTime, CalendarCell?> cellMap) {
    double upcomingCost = 0;
    for (int i = 0; i < 7; i++) {
      DateTime dateCheck = DateTime.utc(_currentDate.year, _currentDate.month, _currentDate.day + i);
      if (cellMap.containsKey(dateCheck)) {
        upcomingCost += cellMap[dateCheck]?.meal?.cost() ?? 0;
      }
    }
    setState(() {
      _upcomingCost = upcomingCost;
    });
  }

  /// Delete popup from holding down on a day, deleting meals can also be done in `add_meal_page` when viewing a meal
  Future<void> _showDeleteDialog(CalendarCell? cell) async {
    if (cell == null || cell.meal == null) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deleting ${cell.meal?.recipe.name} will remove it from your calendar, and remove any repetition rules attached'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red,),),
              onPressed: () async {
                _isLoading = true;
                final success = await widget.calendarDB.deleteMeal(widget.user.uid!, cell.meal!);
                _isLoading = false;

                if (success) {
                  setState(() {
                    widget.meals[_timeOfDay]!.remove(cell.meal!);
                    widget.meals[_timeOfDay]!.sort();
                    _calendarCells = _createCalendar();
                  });
                } 
                if (context.mounted) Navigator.of(context).pop();
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
      key: const Key('calendar_page'),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back,),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            // Handles the title, which only displays the year if the year is not the one that's local to the user, if the year is displayed month is shortened to fit
                            child: Text(
                              _displayedYear == _currentDate.year ?
                                DateFormat('MMMM').format(DateTime(_displayedYear, _displayedMonth)) :
                                '${DateFormat('MMM').format(DateTime(_displayedYear, _displayedMonth))}${_displayedYear == _currentDate.year ? '' : ' - ${_displayedYear.toString().substring(2, 4)}'}', 
                              style: AppTextStyles.mainTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(35)),
                              border: Border.all(color: const Color(0xFF399E5A), width: 2),
                            ),
                            child: Row(
                              spacing: 4,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.sunny_snowing,
                                    color: _timeOfDay == TimeOfDay.breakfast ? Colors.white : const Color(0xFF26693C),
                                  ), 
                                  onPressed: () => { _timeOfDay = TimeOfDay.breakfast }, 
                                  style: ButtonStyle(
                                    backgroundColor: _timeOfDay == TimeOfDay.breakfast ? WidgetStateProperty.all<Color>(const Color(0xFF26693C)) : WidgetStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.sunny,
                                    color: _timeOfDay == TimeOfDay.lunch ? Colors.white : const Color(0xFF26693C),
                                  ), 
                                  onPressed: () => { _timeOfDay = TimeOfDay.lunch }, 
                                  style: ButtonStyle(
                                    backgroundColor: _timeOfDay == TimeOfDay.lunch ? WidgetStateProperty.all<Color>(const Color(0xFF26693C)) : WidgetStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.nightlight,
                                    color: _timeOfDay == TimeOfDay.dinner ? Colors.white : const Color(0xFF26693C),
                                  ), 
                                  onPressed: () => { _timeOfDay = TimeOfDay.dinner }, 
                                  style: ButtonStyle(
                                    backgroundColor: _timeOfDay == TimeOfDay.dinner ? WidgetStateProperty.all<Color>(const Color(0xFF26693C)) : WidgetStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Row(
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
                    const SizedBox(height: 4,),
                  ],
                ),
                Expanded(
                  // Handles navigation between months by swiping to the left and right
                  child: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < 0) {
                          setState(() {
                            if (_displayedMonth == 12) {
                              _displayedMonth = 1;
                              _displayedYear += 1;
                            } else {
                              _displayedMonth += 1;
                            }
                            _calendarCells = _createCalendar();
                          });
                        } else if (details.primaryVelocity! > 0) {
                          setState(() {
                            if (_displayedMonth == 1) {
                              _displayedMonth = 12;
                              _displayedYear -= 1;
                            } else {
                              _displayedMonth -= 1;
                            }
                            _calendarCells = _createCalendar();
                          });
                        }
                      }
                    },
                    child: GridView.count(
                      crossAxisCount: 7,
                      childAspectRatio: 0.5,
                      children: <Widget>[
                        ..._calendarCells,
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _displayedMonth == _currentDate.month,
                  child: Tooltip(
                    key: _tooltipKey,
                    triggerMode: TooltipTriggerMode.manual,
                    showDuration: const Duration(seconds: 1),
                    message: 'Predicted cost of ${_timeOfDay.standardName.toLowerCase()} for the next 7 days',
                    child: Row(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                        ),
                        const Text(
                          'Predicted Cost: ',
                          style: AppTextStyles.largerBold,
                        ),
                        Text(
                          NumberFormat.currency(locale: 'en_UK', symbol: '£').format(_upcomingCost),
                          style: const TextStyle(
                            color: Color(0xFF26693C),
                            fontSize: 28,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.help,
                            color: Color(0xFF26693C),
                          ),
                          onPressed: () {
                            _tooltipKey.currentState?.ensureTooltipVisible();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _isLoading,
              child: const LoadingScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
