import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/ingredients_page.dart';
import 'package:fresh_planner/ui/styles/button_styles.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';

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

    (bool, String?) response = await widget.calendarDB.addRecipe(widget.user.uid!, recipe);
    if (!response.$1 || !mounted) {
      errorText = "Internal server error, please try again";
      return;
    }
    recipe.id = response.$2;

    Navigator.pop(context, recipe,); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Recipe",
          style: AppTextStyles.mainTitle,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFD7F1E0),
                    hintText: 'name*',
                    hintStyle: TextStyle(
                      color: Color(0x33000000),
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFD7F1E0),
                    hintText: 'link to recipe',
                    hintStyle: TextStyle(
                      color: Color(0x33000000),
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                Text(
                  "Add Ingredients:"
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "Ingredient"
                    ),
                    Text(
                      "Amount"
                    ),
                  ],
                ),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: <Widget>[
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
