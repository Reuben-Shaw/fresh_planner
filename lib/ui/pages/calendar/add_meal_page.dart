import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/enums/meal_repetition.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/recipe_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';
import 'package:intl/intl.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key, required this.user, required this.ingredients, required this.recipes, required this.calendarDB, required this.day, required this.time});

  final User user;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;
  final DatabaseCalendar calendarDB;
  final DateTime day;
  final TimeOfDay time;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _calendarDB = DatabaseCalendar();
  
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  bool? _isFresh = true;
  MealRepetition? _repetition = MealRepetition.never;

  String errorText = "";

  Recipe? _recipeDropdownValue;
  void _recipeDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is Recipe) {
      setState(() {
        _recipeDropdownValue = selectedVaue;
      });
    }
  }

  String _dayWithSuffix(DateTime date) {
    final day = date.day;

    if (day >= 11 && day <= 13) return ("${DateFormat('d').format(date)}th");
    return "${DateFormat('d').format(date)}${switch(day % 10) {
      1 => "st",
      2 => "nd",
      3 => "rd",
      _ => "th",
    }}";
  }

  int britishWeekday(DateTime date) {
    return (date.weekday + 6) % 7;
  }

  void addNewMeal() async {
    errorText = "";
    if (_recipeDropdownValue == null) {
      errorText = "Please ensure a recipe is selected";
      return;
    }

    final meal = Meal(
      recipe: _recipeDropdownValue!,
      time: widget.time,
      repeatFromWeek: _repetition == MealRepetition.everyWeek ? britishWeekday(widget.day) : null,
      repeatFromOtherWeek: _repetition == MealRepetition.everyOtherWeek ? widget.day : null,
      repeatFromDay: _repetition == MealRepetition.everyDate ? widget.day.day : null,
      day: _repetition == MealRepetition.never ? widget.day : null,
    );
    _isLoading = true;

    (bool, String?) response = await widget.calendarDB.addMeal(widget.user.uid!, meal);
    if (!response.$1 || !mounted) {
      errorText = "Internal server error, please try again";
      _isLoading = false;
      return;
    }
    meal.id = response.$2;

    Navigator.pop(context, meal,); 
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Adding a\nMeal",
                            style: AppTextStyles.mainTitle,
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                widget.time == TimeOfDay.breakfast ? Icons.sunny_snowing : widget.time == TimeOfDay.lunch ? Icons.sunny : Icons.nightlight,
                                color: Color(0xFF979797),
                              ),
                              Text(
                                " - ${widget.time.standardName}: ${DateFormat("dd/MM/yy").format(widget.day)}",
                                style: AppTextStyles.subTitle,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: AppTextFieldStyles.dropShadowWithColour,
                                  child: DropdownButton(
                                    items: widget.recipes.map((r) {
                                      return DropdownMenuItem<Recipe>(
                                        value: r,
                                        child: Text("   ${r.name}"),
                                      );
                                    }).toList(),
                                    value: _recipeDropdownValue,
                                    onChanged: _recipeDropdownCallback,
                                    isExpanded: true,
                                    underline: Text(""),
                                    hint: Text(
                                      "   select a recipe",
                                      style: AppTextStyles.hint,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RecipePage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, calendarDB: _calendarDB,)),
                                  );
                                  if (result is! Recipe) return;
                                  setState(() {
                                    widget.recipes.add(result);
                                    widget.recipes.sort();
                                    _recipeDropdownValue = result;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF399E5A)),
                                ), 
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: Color(0xFFd7f1e0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        _recipeDropdownValue?.name ?? "",
                                      ),
                                      IconButton(
                                        onPressed: (){}, 
                                        icon: Icon(
                                          Icons.edit_square,
                                          color: Color(0xFF26693C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: _recipeDropdownValue?.link != null,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Link to Recipe:"
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            _recipeDropdownValue?.link ?? "",
                                            style: TextStyle(
                                              color: Color(0xFF3873CD),
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _recipeDropdownValue == null ? "" : "Ingredients:",
                                            ),
                                            Container(
                                              height: 70,
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: ListView(
                                                children: _recipeDropdownValue?.ingredients.map((i) => 
                                                  Text("• ${i.name}"),
                                                ).toList() ?? [],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          IconButton(
                                            onPressed: () {}, 
                                            icon: Icon(
                                              Icons.fullscreen,
                                              color: Color(0xFF26693C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Meal Type:",
                                style: AppTextStyles.innerTitle,
                              ),
                              AppRadiobuttonStyle.tileDec(
                                context, 
                                "Cooked Fresh",
                                Radio<bool>(
                                  value: true,
                                  groupValue: _isFresh,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isFresh = value;
                                    });
                                  },
                                ),
                              ),
                              AppRadiobuttonStyle.tileDec(
                                context, 
                                "Leftovers",
                                Radio<bool>(
                                  value: false,
                                  groupValue: _isFresh,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isFresh = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Repeat:",
                                style: AppTextStyles.innerTitle,
                              ),
                              AppRadiobuttonStyle.tileDec(
                                context, 
                                MealRepetition.never.standardName,
                                Radio<MealRepetition>(
                                  value: MealRepetition.never,
                                  groupValue: _repetition,
                                  onChanged: (MealRepetition? value) {
                                    setState(() {
                                      _repetition = value;
                                    });
                                  },
                                ),
                              ),
                              AppRadiobuttonStyle.tileDec(
                                context, 
                                "${MealRepetition.everyWeek.standardName}${DateFormat('EEE').format(widget.day)}",
                                Radio<MealRepetition>(
                                  value: MealRepetition.everyWeek,
                                  groupValue: _repetition,
                                  onChanged: (MealRepetition? value) {
                                    setState(() {
                                      _repetition = value;
                                    });
                                  },
                                ),
                              ),
                              AppRadiobuttonStyle.tileDec(
                                context, 
                                "${MealRepetition.everyOtherWeek.standardName}${DateFormat('EEE').format(widget.day)}",
                                Radio<MealRepetition>(
                                  value: MealRepetition.everyOtherWeek,
                                  groupValue: _repetition,
                                  onChanged: (MealRepetition? value) {
                                    setState(() {
                                      _repetition = value;
                                    });
                                  },
                                ),
                              ),
                              AppRadiobuttonStyle.tileDec(
                                context, 
                                "${MealRepetition.everyDate.standardName}${_dayWithSuffix(widget.day)}",
                                Radio<MealRepetition>(
                                  value: MealRepetition.everyDate,
                                  groupValue: _repetition,
                                  onChanged: (MealRepetition? value) {
                                    setState(() {
                                      _repetition = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                decoration: AppButtonStyles.circularShadow,
                                child: ElevatedButton(
                                  onPressed: addNewMeal,
                                  style: AppButtonStyles.mainBackStyle,
                                  child: Text(
                                    "    Add    ",
                                    style: AppButtonStyles.mainTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
