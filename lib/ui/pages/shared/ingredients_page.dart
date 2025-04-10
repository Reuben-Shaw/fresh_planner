import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';
import 'package:fresh_planner/ui/widgets/ingredient_list_view.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key, required this.user, required this.ingredients});

  final User user;
  final List<Ingredient>? ingredients;

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final searchController = TextEditingController();

  final ingredientDB = DatabaseIngredients();

  List<IngredientListView> ingredientCollapseLists = [];
  Map<IngredientType, List<IngredientCard>> ingredientMap = {
    IngredientType.baking : [],
    IngredientType.dairy : [],
    IngredientType.driedGood : [],
    IngredientType.frozen : [],
    IngredientType.fruitNut : [],
    IngredientType.herbSpice : [],
    IngredientType.liquid : [],
    IngredientType.meat : [],
    IngredientType.preserve : [],
    IngredientType.snack : [],
    IngredientType.vegetable : [],
    IngredientType.misc : [],
  };

  @override
  void initState() {
    super.initState();
    setUpIngredientMap();
  }

  void setUpIngredientMap() {
    if (widget.ingredients == null) return;
    for (Ingredient i in widget.ingredients!) {
      ingredientMap[i.type ?? IngredientType.misc]!.add(IngredientCard(ingredient: i));
    }
    for (var i in ingredientMap.entries) {
      ingredientCollapseLists.add(IngredientListView(ingredientCards: i.value, section: i.key.name));
    }
  }

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
            SearchBar(
              controller: searchController,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: (_) => setState(() {}),
              trailing: const [Icon(Icons.search)],
            ),
            Expanded(
              child: ListView(
                children: ingredientCollapseLists,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context,); 
                  }, 
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  ),
                  child: Text(
                    "Select",
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
