import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/ingredients_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';
import 'package:intl/intl.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.user, required this.ingredients, required this.recipes, required this.calendarDB});

  final User user;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;
  final DatabaseCalendar calendarDB;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();
  
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  String _errorText = "";
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  final List<IngredientCard> _ingredientCards = [];
  Color? _selectedColour;

  void _updateColour(Color colour) {
    setState(() {
      _selectedColour = colour;
    });
  }

  void _addRecipe() async {
    errorText = "";
    if (_nameController.text == "") {
      errorText = "Ensure all required values are filled";
      return;
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
      errorText = "Internal server error, please try again";
      _isLoading = false;
      return;
    }
    recipe.id = response.$2;

    Navigator.pop(context, recipe,); 
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              "Create a\nRecipe",
                              style: AppTextStyles.mainTitle,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              "*must be included",
                              style: AppTextStyles.subTitle,
                            ),
                            SizedBox(height: 20,),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: AppTextFieldStyles.dropShadow,
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: AppTextFieldStyles.primaryStyle("name*"),
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                    decoration: AppTextFieldStyles.dropShadow,
                                    child: TextField(
                                      controller: _linkController,
                                      decoration: AppTextFieldStyles.primaryStyle("link to recipe"),
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Text(
                                    "Add Ingredients:",
                                    style: AppTextStyles.innerTitle,
                                  ),
                                  SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 50),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Ingredient*",
                                          style: AppTextStyles.standardBold,
                                        ),
                                        Text(
                                          "Amount",
                                          style: AppTextStyles.standardBold,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 5, thickness: 2, indent: 0, endIndent: 0, color: Colors.black),
                                  const SizedBox(height: 10,),
                                  ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      ..._ingredientCards,
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => IngredientsPage(user: widget.user, ingredients: widget.ingredients,)),
                                          );
                                          if (result is! Ingredient) return;
                                          setState(() {
                                            _ingredientCards.add(IngredientCard(ingredient: result, showAmount: true,));
                                            _ingredientCards.sort();
                                          });
                                        },
                                        child: Text(
                                          "+ Select Ingredient",
                                          style: AppTextStyles.largerBold,
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "Cost of Recipe: ",
                                            style: AppTextStyles.largerBold,
                                          ),
                                          Text(
                                            NumberFormat.currency(
                                              locale: "en_UK", symbol: "£"
                                            ).format(Recipe.calcCost(
                                              _ingredientCards.map((card) => card.ingredient).toList()
                                            )),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF26693C),
                                            ),
                                          ),  
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    errorText,
                                    style: AppTextStyles.error,
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Row(
                                        spacing: 10,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Container(
                                              width: 37,
                                              height: 37,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _selectedColour ?? Colors.red,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            spacing: 5,
                                            children: <Widget>[
                                              Row(
                                                spacing: 5,
                                                children: <Widget>[
                                                  ...[
                                                    Colors.red,
                                                    Colors.orange,
                                                    Colors.yellow,
                                                    Colors.lightGreen,
                                                    Colors.green,
                                                  ].map((c) => ColourCircle(colour: c, onTap: () => _updateColour(c),)),
                                                ],
                                              ),
                                              Row(
                                                spacing: 5,
                                                children: <Widget>[
                                                  ...[
                                                    Colors.lightBlue,
                                                    Colors.blue,
                                                    Colors.purple,
                                                    Colors.pink[200]!,
                                                    Colors.pink,
                                                  ].map((c) => (ColourCircle(colour: c, onTap: () => _updateColour(c),)))
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: AppButtonStyles.curvedShadow,
                                        child: ElevatedButton(
                                          onPressed: _addRecipe,
                                          style: AppButtonStyles.mainBackStyle,
                                          child: Text(
                                            "   Create   ",
                                            style: AppButtonStyles.mainTextStyle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

class ColourCircle extends StatelessWidget {
  final Color colour;
  final VoidCallback? onTap;

  const ColourCircle({
    super.key,
    required this.colour,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colour,
        ),
      ),
    );
  }
}
