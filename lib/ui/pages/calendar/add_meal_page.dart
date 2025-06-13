import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/enums/meal_repetition.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/meal.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/pages/shared/recipe_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contains all logic for adding new meals to the `calendar_page`
class AddMealPage extends ParentPage {
  /// currentMeal is used for viewing the meal's information, editing meals is not included in this version of the application
  const AddMealPage({super.key, required super.user, required super.ingredients, required super.recipes, required this.calendarDB, required this.day, required this.time, this.currentMeal, required this.meals});

  final DatabaseCalendar calendarDB;
  final DateTime day;
  final TimeOfDay time;
  final Meal? currentMeal;
  final Map<TimeOfDay, List<Meal>> meals;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  bool __isExpanded = false;
  bool get _isExpanded => __isExpanded;
  set _isExpanded(bool value) => setState(() => __isExpanded = value);

  bool? _isFresh = true;
  MealRepetition? _repetition = MealRepetition.never;

  String _errorText = '';

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

  // Used to hide radiobuttons when a meal is being overriden with another, to prevent a new rule from completely superseding the original one
  // e.g. overidding an every other week repetition pattern with an every week would invalidate the original rule, so it isn't allowed
  MealRepetition? _repetitionHider;

  // Used to control what widgets are visible, and if the page is just being used to view the meal's details
  late bool _isAddingMeal;

  @override
  void initState() {
    super.initState();
    
    _isAddingMeal = widget.currentMeal == null;
    if (_isAddingMeal) return;

    setState(() {
      _selectedRecipe = widget.currentMeal!.recipe;
    });
  }

  /// Small function used for improved UX on a radio button
  String _dayWithSuffix(DateTime date) {
    final day = date.day;

    if (day >= 11 && day <= 13) return ('${DateFormat('d').format(date)}th');
    return '${DateFormat('d').format(date)}${switch(day % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    }}';
  }

  /// Changes the default American logic to reflect the British display (American: Sunday = 0, Saturday = 6 - British: Monday = 0, Sunday = 6)
  int _britishWeekday(DateTime date) {
    return (date.weekday + 6) % 7;
  }

  /// Handles logic and error trapping for adding a new meal to the calendar
  void _addNewMeal() async {
    _errorText = '';
    if (_selectedRecipe == null) {
      setState(() {
        _errorText = 'Please ensure a recipe is selected';
      });
      return;
    }

    final meal = Meal(
      recipe: _selectedRecipe!,
      time: widget.time,
      repeatFromWeek: _repetition == MealRepetition.everyWeek ? _britishWeekday(widget.day) : null,
      repeatFromOtherWeek: _repetition == MealRepetition.everyOtherWeek ? widget.day : null,
      repeatFromDay: _repetition == MealRepetition.everyDate ? widget.day.day : null,
      day: _repetition == MealRepetition.never ? widget.day : null,
      cookedFresh: _isFresh,
    );
    _isLoading = true;

    (bool, String?) response = await widget.calendarDB.addMeal(widget.user.uid!, meal);
    if (!response.$1 || !mounted) {
      _errorText = 'Internal server error, please try again';
      _isLoading = false;
      return;
    }
    meal.id = response.$2;

    Navigator.pop(context, meal,); 
  }

  /// Logic for restructuring the page for overriding a meal if initially entered viewing an existing meal
  void _replaceMeal() {
    setState(() {
      _selectedRecipe = null;
      _repetitionHider = widget.currentMeal!.repetitionType();
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
                    FocusManager.instance.primaryFocus?.unfocus();
                    _isLoading = true;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back,),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _isAddingMeal ? 'Adding a\nMeal' : 'Viewing\nMeal',
                            style: AppTextStyles.mainTitle,
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                key: const Key('time_icon'),
                                widget.time == TimeOfDay.breakfast ? Icons.sunny_snowing : widget.time == TimeOfDay.lunch ? Icons.sunny : Icons.nightlight,
                                color: const Color(0xFF979797),
                              ),
                              Text(
                                ' - ${widget.time.standardName}: ${DateFormat('dd/MM/yy').format(widget.day)}',
                                style: AppTextStyles.subTitle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Visibility(
                            visible: _isAddingMeal,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: AppTextFieldStyles.dropShadowWithColour,
                                    child: DropdownButton(
                                      key: const Key('recipe_dropdown'),
                                      items: widget.recipes.map((r) {
                                        return DropdownMenuItem<Recipe>(
                                          value: r,
                                          child: Text('   ${r.name}'),
                                        );
                                      }).toList(),
                                      value: _recipeDropdownValue,
                                      onChanged: _recipeDropdownCallback,
                                      isExpanded: true,
                                      underline: const Text(''),
                                      hint: const Text(
                                        '   select a recipe',
                                        style: AppTextStyles.hint,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                // Icon button used to navigate the recipe page for creating a new recipe, returns and auto selects the recipe once done
                                IconButton(
                                  onPressed: () async {
                                    _isLoading = true;
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RecipePage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, calendarDB: widget.calendarDB,)),
                                    );
                                    _isLoading = false;
                                    if (result is! Recipe) return;
                                    setState(() {
                                      widget.recipes.add(result);
                                      widget.recipes.sort();
                                      _selectedRecipe = result;
                                      _recipeDropdownValue = result;
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF399E5A)),
                                  ), 
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15,),
                          Container(
                            decoration: AppTextFieldStyles.dropShadow,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                color: const Color(0xFFd7f1e0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Visibility(
                                      visible: widget.currentMeal?.isSingleDay() ?? false,
                                      child: const SizedBox(height: 16,)
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          _selectedRecipe?.name ?? '',
                                          style: AppTextStyles.innerTitle,
                                        ),
                                        Stack(
                                          children: <Widget>[
                                            Visibility(
                                              visible: !_isAddingMeal && !(widget.currentMeal?.isSingleDay() ?? false),
                                              child: IconButton(
                                                onPressed: _replaceMeal, 
                                                icon: const Icon(
                                                  Icons.edit_square,
                                                  color: Color(0xFF26693C),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: _isAddingMeal,
                                              // Deleting recipes
                                              child: IconButton(
                                                onPressed: () async {
                                                  _isLoading = true;
                                                  final updatedMeals = await _showConfirmDeleteRecipe(_selectedRecipe);
                                                  if (updatedMeals != null && context.mounted) {
                                                    final success = await widget.calendarDB.deleteRecipe(widget.user.uid!, _selectedRecipe!);
                                                    if (success && context.mounted) {  
                                                      Navigator.pop(context, (updatedMeals, _selectedRecipe),); 
                                                    } else {
                                                      setState(() {
                                                        _errorText = 'Meals deleted, failed with recipe';
                                                      });
                                                    }
                                                  } else {
                                                    setState(() {
                                                      _errorText = 'Failed to delete recipe, please try again';
                                                    });
                                                  }
                                                  _isLoading = false;
                                                },
                                                icon: const Icon(
                                                  Icons.delete_forever,
                                                  color: Color(0xFF26693C),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Visibility(
                                      visible: _selectedRecipe?.link != null,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const Text(
                                            'Link to Recipe:',
                                            style: AppTextStyles.largerBold,
                                          ),
                                          const SizedBox(height: 5,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: InkWell(
                                              child: Text(
                                                _selectedRecipe?.link ?? '',
                                                style: const TextStyle(
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
                                    const SizedBox(height: 10,),
                                    Visibility(
                                      visible: _selectedRecipe != null && _selectedRecipe!.cost > 0,
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            _selectedRecipe == null ?
                                            '' : 'Cost:',
                                            style: AppTextStyles.largerBold,
                                          ),
                                          Text(
                                            _selectedRecipe == null ? '' :
                                            NumberFormat.currency(locale: 'en_UK', symbol: '£').format(
                                              _selectedRecipe!.cost
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: !_isAddingMeal,
                                      child: Text(
                                        widget.currentMeal == null ? '' : 
                                          widget.currentMeal!.cookedFresh == null ? '' : 
                                            widget.currentMeal!.cookedFresh! ? 'Cooked Fresh' : 'Leftovers',
                                      ), 
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                _selectedRecipe == null ? '' : 'Ingredients:',
                                                style: AppTextStyles.largerBold,
                                              ),
                                              const SizedBox(height: 5,),
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
                                                color: const Color(0xFF26693C),
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
                          const SizedBox(height: 15,),
                          // Visibility contains all the radio buttons in the page, much of the code here is just repeated boilerplate stuff
                          Visibility(
                            visible: _isAddingMeal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Meal Type:',
                                  style: AppTextStyles.innerTitle,
                                ),
                                AppRadiobuttonStyle.tileDec(
                                  context, 
                                  'Cooked Fresh',
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
                                  'Leftovers',
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
                                const Text(
                                  'Repeat:',
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
                                  visible: _repetitionHider != MealRepetition.everyWeek && _repetitionHider != MealRepetition.everyOtherWeek,
                                  child: AppRadiobuttonStyle.tileDec(
                                    context, 
                                    '${MealRepetition.everyWeek.standardName}${DateFormat('EEE').format(widget.day)}',
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
                                  visible: _repetitionHider != MealRepetition.everyOtherWeek,
                                  child: AppRadiobuttonStyle.tileDec(
                                    context, 
                                    '${MealRepetition.everyOtherWeek.standardName}${DateFormat('EEE').format(widget.day)}',
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
                                  visible: _repetitionHider != MealRepetition.everyDate,
                                  child: AppRadiobuttonStyle.tileDec(
                                    context, 
                                    '${MealRepetition.everyDate.standardName}${_dayWithSuffix(widget.day)}',
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
                          Text(
                            _errorText,
                            style: const TextStyle(
                              fontSize: 14, 
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
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
                                    key: const Key('add_button'),
                                    onPressed: _addNewMeal,
                                    style: AppButtonStyles.mainBackStyle,
                                    child: Text(
                                      '    Add    ',
                                      style: AppButtonStyles.mainTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !_isAddingMeal,
                                /// Logic for deleting a meal from the calendar
                                child: IconButton(
                                  key: const Key('delete_button'),
                                  onPressed: () async {
                                    _isLoading = true;
                                    final success = await widget.calendarDB.deleteMeal(widget.user.uid!, widget.currentMeal!);
                                    _isLoading = false;
                                    if (!success || !context.mounted) {
                                      _errorText = 'Internal server error, please try again';
                                      return;
                                    }

                                    Navigator.pop(context, 'delete',); 
                                  }, 
                                  icon: const Icon(
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
                          const SizedBox(height: 15,),
                        ],
                      ),
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

  /// Seperate widget used for the container box for information, this is needed as you want the container to shrink to fit the contents
  /// if the contents aren't sufficiently long but cut off the content if it is, and not wrap itself to it.
  Widget _ingredientListView(bool isExpanded) {
    return (isExpanded || !_isAddingMeal)
      ? _buildIngredientList()
      : ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 120,
        ),
        child: _buildIngredientList(),
      );
  }

  /// Widget that contains a bullet list of all the ingredients in the recipe
  Widget _buildIngredientList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ..._selectedRecipe?.ingredients.map((i) => 
            Text('• ${i.name}${i.amount != 0 ? ' - ${i.amount}${i.metric != IngredientMetric.item ? i.metric.metricSymbol : ' ${i.metric.metricSymbol}'}' : ''}'),
          ).toList() ?? [],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Handles deleting recipes, and all meals using that recipe on the calendar
  Future<Map<TimeOfDay, List<Meal>>?> _showConfirmDeleteRecipe(Recipe? recipe) async {
    if (recipe == null) return null;

    return showDialog<Map<TimeOfDay, List<Meal>>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to delete the recipe for ${recipe.name}? This will delete all instances of meals containing it.'),
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
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final newMeals = <TimeOfDay, List<Meal>>{
                  TimeOfDay.breakfast: [],
                  TimeOfDay.lunch: [],
                  TimeOfDay.dinner: [],
                };

                List<Future<bool>> deleteMealTasks = [];
                for (final time in [TimeOfDay.breakfast, TimeOfDay.lunch, TimeOfDay.dinner]) {
                  for (final meal in widget.meals[time]!) {
                    if (meal.recipe != recipe) {
                      newMeals[time]!.add(meal);
                    } else {
                      deleteMealTasks.add(widget.calendarDB.deleteMeal(widget.user.uid!, meal));
                    }
                  }
                }
                // Meals all delted in parallel, to improve program speed
                final results = await Future.wait(deleteMealTasks);
                final success = results.every((result) => result == true);
                if (!success) {
                  setState(() {
                    _errorText = 'Internal server error deleting meals, data may be corrupted';
                  });
                }
                
                if (context.mounted) Navigator.of(context).pop(newMeals);
              },
            ),
          ],
        );
      },
    );
  }
}
