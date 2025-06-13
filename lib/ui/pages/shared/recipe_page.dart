
import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/pages/shared/ingredients_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';
import 'package:intl/intl.dart';

/// Page used for creating new `Recipe` objects
class RecipePage extends ParentPage {
  const RecipePage({super.key, required super.user, required super.ingredients, required super.recipes, required this.calendarDB, this.ingredientsInRecipe});

  final DatabaseCalendar calendarDB;
  final List<Ingredient>? ingredientsInRecipe;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();
  
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  String _errorText = '';
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  final List<IngredientCard> _ingredientCards = [];
  Color? _selectedColour;
  
  /// Initialises ingredient list if the recipe page is provided with a list of ingredients on construction, used for testing
  @override
  void initState() {
    super.initState();
    if (widget.ingredientsInRecipe == null) {
      return;
    } else if (widget.ingredientsInRecipe!.isNotEmpty) {
      widget.ingredients.sort();
      for (Ingredient i in widget.ingredients) {
        _ingredientCards.add(IngredientCard(ingredient: i, showAmount: true, isSelected: false,));
      }
    }
  }

  void _updateColour(Color colour) {
    setState(() {
      _selectedColour = colour;
    });
  }

  /// Handles logic for reading recipes for adding to the database, and also error trapping
  void _addRecipe() async {
    FocusManager.instance.primaryFocus?.unfocus();

    errorText = '';
    if (_nameController.text == '') {
      errorText = 'Ensure all required values are filled';
      return;
    }
    if (_linkController.text.isNotEmpty && !Uri.parse(_linkController.text).isAbsolute) {
      errorText = 'Please ensure a valid link is provided';
      return;
    }
    for (Recipe r in widget.recipes) {
      if (r.name.toLowerCase() == _nameController.text.toLowerCase()) {
        errorText = 'Recipe with that name already exists';
        return;
      }
    }

    final recipe = Recipe(
      name: _nameController.text.toLowerCase(),
      link: _linkController.text.isEmpty ? null : _linkController.text,
      ingredients: _ingredientCards.map((card) => card.ingredient).toList(),
      colour: _selectedColour ?? Colors.red,
    );

    _isLoading = true;
    (bool, String?) response = await widget.calendarDB.addRecipe(widget.user.uid!, recipe);
    if (!response.$1 || !mounted) {
      errorText = 'Internal server error, please try again';
      _isLoading = false;
      return;
    }
    recipe.id = response.$2;

    Navigator.pop(context, recipe,); 
  }

  void _removeIngredient(Ingredient ingredient) async {
    for (IngredientCard i in _ingredientCards) {
      if (i.ingredient == ingredient) {
        setState(() {
          _ingredientCards.remove(i);
        });
        return;
      }
    }
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
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Create a\nRecipe', style: AppTextStyles.mainTitle),
                        const SizedBox(height: 5),
                        const Text('*must be included', style: AppTextStyles.subTitle),
                        const SizedBox(height: 20),
                        Container(
                          decoration: AppTextFieldStyles.dropShadow,
                          child: TextField(
                            key: const Key('name_textfield'),
                            controller: _nameController,
                            decoration: AppTextFieldStyles.primaryStyle('name*'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: AppTextFieldStyles.dropShadow,
                          child: TextField(
                            key: const Key('link_textfield'),
                            controller: _linkController,
                            decoration: AppTextFieldStyles.primaryStyle('link to recipe'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Add Ingredients:', style: AppTextStyles.innerTitle),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 5, right: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Ingredient*', style: AppTextStyles.standardBold),
                              Text('Amount', style: AppTextStyles.standardBold),
                            ],
                          ),
                        ),
                        const Divider(height: 5, thickness: 2, color: Colors.black),
                        const SizedBox(height: 10),
                        ..._ingredientCards,
                        // Holds the `+Select Ingredient` and `Cost of Recipe` labels, which handle navigation to the `ingredients_page`
                        GestureDetector(
                          onTap: () async {
                            _isLoading = true;
                            // Delay added so that loading screen appears, as without it there's generally too much lag on transition for it to appear
                            await Future.delayed(const Duration(milliseconds: 50));
                            if (context.mounted) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => IngredientsPage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes,)),
                              );
                              _isLoading = false;
                              if (result is! Ingredient) return;

                              // Stacks ingredients if there is replicas
                              for (IngredientCard card in _ingredientCards) {
                                if (card.ingredient.isEqual(result)) {
                                  result.amount += card.ingredient.amount;
                                  setState(() {
                                    _ingredientCards.remove(card);
                                  });
                                  break;
                                }
                              }
                              setState(() {
                                _ingredientCards.add(IngredientCard(
                                  ingredient: result,
                                  showAmount: true,
                                  onRemove: () async => _removeIngredient(result),
                                  isSelected: false,
                                ));
                                _ingredientCards.sort();
                              });
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Row(
                                children: <Widget>[
                                  Text(
                                    '+ ', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF26693C),
                                      height: 1,
                                    ),
                                  ),
                                  Text('Select Ingredient', style: AppTextStyles.largerBold),
                                ],
                              ),
                              // Cost of recipe is included here to increase the tap size, making it easier for users to navigatge
                              Row(
                                children: <Widget>[
                                  const Text('Cost of Recipe: ', style: AppTextStyles.largerBold),
                                  Text(
                                    key: const Key('priceRecipe'),
                                    NumberFormat.currency(locale: 'en_UK', symbol: '£').format(
                                      Recipe.calcCost(_ingredientCards.map((card) => card.ingredient).toList())
                                    ),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF26693C),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(errorText, style: AppTextStyles.error),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                key: const Key('colourDisplay'),
                                width: 37,
                                height: 37,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedColour ?? Colors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      ...[(Colors.red, 'red'), (Colors.orange, 'orange'), (Colors.yellow, 'yellow'), (Colors.lightGreen, 'light_green'), (Colors.green[700]!, 'green')]
                                          .map((c) => ColourCircle(colour: c.$1, colourName: c.$2, onTap: () => _updateColour(c.$1))),
                                    ],
                                  ),
                                  const SizedBox(height: 2,),
                                  Row(
                                    children: [
                                      ...[(Colors.blue, 'light_blue'), (Colors.blue[900]!, 'blue'), (Colors.purple, 'purple'), (Colors.pink[200]!, 'pink'), (Colors.pink, 'hot_pink')]
                                          .map((c) => ColourCircle(colour: c.$1, colourName: c.$2, onTap: () => _updateColour(c.$1))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: AppButtonStyles.curvedShadow,
                            child: ElevatedButton(
                              key: const Key('create_button'),
                              onPressed: _addRecipe,
                              style: AppButtonStyles.mainBackStyle,
                              child: Text('   Create   ', style: AppButtonStyles.mainTextStyle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),

            if (_isLoading) const LoadingScreen(),
          ],
        ),
      ),
    );
  }
}

/// Small subclass used to quickly construct tapable buttons for selecting colour
class ColourCircle extends StatelessWidget {
  final Color colour;
  final String colourName;
  final VoidCallback? onTap;

  const ColourCircle({
    super.key,
    required this.colour,
    required this.colourName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          key: Key(colourName),
          onTap: onTap,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colour,
            ),
          ),
        ),
        const SizedBox(width: 2,),
      ],
    );
  }
}
