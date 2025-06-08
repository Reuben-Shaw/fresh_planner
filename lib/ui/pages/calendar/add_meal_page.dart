import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
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
import 'package:url_launcher/url_launcher.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key, required this.user, required this.ingredients, required this.recipes, required this.calendarDB, required this.day, required this.time, this.currentMeal});

  final User user;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;
  final DatabaseCalendar calendarDB;
  final DateTime day;
  final TimeOfDay time;
  final Meal? currentMeal;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _calendarDB = DatabaseCalendar();
  
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  bool __isExpanded = false;
  bool get _isExpanded => __isExpanded;
  set _isExpanded(bool value) => setState(() => __isExpanded = value);

  bool? _isFresh = true;
  MealRepetition? _repetition = MealRepetition.never;

  String errorText = "";

  Recipe? _selectedRecipe;
  Recipe? _recipeDropdownValue;
  void _recipeDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is Recipe) {
      setState(() {
        _recipeDropdownValue = selectedVaue;
        _selectedRecipe = _recipeDropdownValue;
      });
    }
  }

  MealRepetition? repetitionHider;

  late bool _isAddingMeal;

  @override
  void initState() {
    super.initState();
    
    _isAddingMeal = widget.currentMeal == null;
    if (widget.currentMeal == null) return;

    setState(() {
      _selectedRecipe = widget.currentMeal!.recipe;
    });
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
    if (_selectedRecipe == null) {
      errorText = "Please ensure a recipe is selected";
      return;
    }

    final meal = Meal(
      recipe: _selectedRecipe!,
      time: widget.time,
      repeatFromWeek: _repetition == MealRepetition.everyWeek ? britishWeekday(widget.day) : null,
      repeatFromOtherWeek: _repetition == MealRepetition.everyOtherWeek ? widget.day : null,
      repeatFromDay: _repetition == MealRepetition.everyDate ? widget.day.day : null,
      day: _repetition == MealRepetition.never ? widget.day : null,
      cookedFresh: _isFresh,
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

  void _replaceMeal() {
    setState(() {
      _selectedRecipe = null;
      repetitionHider = widget.currentMeal!.repetitionType();
      _isAddingMeal = true;
    });
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
                    _isLoading = true;
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
                            _isAddingMeal ? "Adding a\nMeal" : "Viewing\nMeal",
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
                          SizedBox(height: 10,),
                          Visibility(
                            visible: _isAddingMeal,
                            child: Row(
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
                                SizedBox(width: 5,),
                                IconButton(
                                  onPressed: () async {
                                    _isLoading = true;
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RecipePage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, calendarDB: _calendarDB,)),
                                    );
                                    _isLoading = false;
                                    if (result is! Recipe) return;
                                    setState(() {
                                      widget.recipes.add(result);
                                      widget.recipes.sort();
                                      _selectedRecipe = result;
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
                          ),
                          SizedBox(height: 15,),
                          Container(
                            decoration: AppTextFieldStyles.dropShadow,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                color: Color(0xFFd7f1e0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Visibility(
                                      visible: _isAddingMeal || (widget.currentMeal?.isSingleDay() ?? false),
                                      child: SizedBox(height: 16,)
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          _selectedRecipe?.name ?? "",
                                          style: AppTextStyles.innerTitle,
                                        ),
                                        Visibility(
                                          visible: !_isAddingMeal && !(widget.currentMeal?.isSingleDay() ?? false),
                                          child: IconButton(
                                            onPressed: _replaceMeal, 
                                            icon: Icon(
                                              Icons.edit_square,
                                              color: Color(0xFF26693C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: _selectedRecipe?.link != null,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Link to Recipe:",
                                            style: AppTextStyles.largerBold,
                                          ),
                                          SizedBox(height: 5,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: InkWell(
                                              child: Text(
                                                _selectedRecipe?.link ?? "",
                                                style: TextStyle(
                                                  color: Color(0xFF3873CD),
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                              onTap: () async {
                                                if (_selectedRecipe?.link == null) return; 
                                                await launchUrl(Uri.parse(_selectedRecipe!.link!));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Visibility(
                                      visible: _selectedRecipe != null && _selectedRecipe!.cost > 0,
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            _selectedRecipe == null ?
                                            "" : "Cost:",
                                            style: AppTextStyles.largerBold,
                                          ),
                                          Text(
                                            _selectedRecipe == null ? "" :
                                            NumberFormat.currency(locale: "en_UK", symbol: "£").format(
                                              _selectedRecipe!.cost
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                _selectedRecipe == null ? "" : "Ingredients:",
                                                style: AppTextStyles.largerBold,
                                              ),
                                              SizedBox(height: 5,),
                                              _ingredientListView(_isExpanded)
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: () {
                                                _isExpanded = !_isExpanded;
                                              }, 
                                              icon: Icon(
                                                _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
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
                          ),
                          SizedBox(height: 15,),
                          Visibility(
                            visible: _isAddingMeal,
                            child: Column(
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
                          ),
                          Visibility(
                            visible: _isAddingMeal,
                            child: Column(
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
                                Visibility(
                                  visible: repetitionHider != MealRepetition.everyWeek && repetitionHider != MealRepetition.everyOtherWeek,
                                  child: AppRadiobuttonStyle.tileDec(
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
                                ),
                                Visibility(
                                  visible: repetitionHider != MealRepetition.everyOtherWeek,
                                  child: AppRadiobuttonStyle.tileDec(
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
                                ),
                                Visibility(
                                  visible: repetitionHider != MealRepetition.everyDate,
                                  child: AppRadiobuttonStyle.tileDec(
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
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Visibility(
                                visible: _isAddingMeal,
                                child: Container(
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
                              ),
                              Visibility(
                                visible: !_isAddingMeal,
                                child: IconButton(
                                  onPressed: () async {
                                    _isLoading = true;
                                    final success = await widget.calendarDB.deleteMeal(widget.user.uid!, widget.currentMeal!);
                                    _isLoading = false;
                                    if (!success || !mounted) {
                                      errorText = "Internal server error, please try again";
                                    }
                                    Navigator.pop(context, "delete",); 
                                  }, 
                                  icon: Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.white,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                  ),
                                )
                              ),
                            ],
                          ),
                          SizedBox(height: 15,),
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

  Widget _ingredientListView(bool isExpanded) {
    return (isExpanded || !_isAddingMeal)
      ? _buildIngredientList()
      : ConstrainedBox(
        constraints: BoxConstraints(
        maxHeight: 120,
      ),
      child: _buildIngredientList(),
    );
  }

  Widget _buildIngredientList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ..._selectedRecipe?.ingredients.map((i) => 
            Text("• ${i.name}${i.amount != 0 ? " - ${i.amount}${i.metric != IngredientMetric.item ? i.metric.metricSymbol : " ${i.metric.metricSymbol}"}" : ""}"),
          ).toList() ?? [],
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
