import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key, required this.user, this.ingredients});

  final User user;
  final List<Ingredient>? ingredients;

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final ingredientDB = DatabaseIngredients();

  void printIngredients() async {
    List<Ingredient>? ingredients = await ingredientDB.getAllIngredients(widget.user.uid!);
    if (ingredients == null) return;
    debugPrint("Length of ingredients: ${ingredients.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ingredients",
          style: AppTextStyles.mainTitle,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Ingredients"
                ),
                ElevatedButton(
                  onPressed: printIngredients, 
                  child: Text(
                    "+"
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  IngredientCard(ingredient: Ingredient(name: "Bread", metric: IngredientMetric.grams))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
