import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/ingredients_page.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.user, required this.ingredients});

  final User user;
  final List<Ingredient>? ingredients;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();

  final List<IngredientCard> _ingredientCards = [];

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
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
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
                      _ingredientCards.add(IngredientCard(ingredient: result));
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
      ),
    );
  }
}
