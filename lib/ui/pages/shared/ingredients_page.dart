import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key, required this.user, required this.ingredients});

  final User user;
  final List<Ingredient>? ingredients;

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final _searchController = TextEditingController();
  final _ingredientDB = DatabaseIngredients();

  final Map<IngredientType, bool> _isOpen = {
    for (var type in IngredientType.values) type: true,
  };
  final Map<IngredientType, List<IngredientCard>> ingredientMap = {
    for (var type in IngredientType.values) type: [],
  };

  Ingredient? _selectedIngredient;

  @override
  void initState() {
    super.initState();
    _setUpIngredientMap();
  }

  void _setUpIngredientMap() {
    if (widget.ingredients == null) return;
    for (Ingredient i in widget.ingredients!) {
      final IngredientType t = i.type ?? IngredientType.misc;
      ingredientMap[t]!.add(IngredientCard(ingredient: i, onRemove: () async => _removeIngredient(i),));
    }
  }

  void _printIngredients() async {
    final List<Ingredient>? ingredients = await _ingredientDB.getAllIngredients(widget.user.uid!);
    if (ingredients == null) return;
    debugPrint("Length of ingredients: ${ingredients.length}");
  }

  void _selectIngredient(Ingredient ingredient) {
    setState(() {
      if (_selectedIngredient == ingredient) {
        _selectedIngredient = null;
      } else {
        _selectedIngredient = ingredient;
        if (_selectedIngredient != null) _selectedIngredient!.amount = 1;
      }
    });
  }

  void _removeIngredient(Ingredient ingredient) async {
    bool success = await _ingredientDB.removeIngredient(widget.user.uid!, ingredient.id!);
    if (!success) return;
    
    setState(() {
      _selectedIngredient = null;

      final type = ingredient.type ?? IngredientType.misc;
      ingredientMap[type]!.removeWhere((card) => card.ingredient == ingredient);
    });
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
                  onPressed: _printIngredients, 
                  child: Text(
                    "+"
                  ),
                ),
              ],
            ),
            SearchBar(
              controller: _searchController,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: (_) => setState(() {}),
              trailing: const [Icon(Icons.search)],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: (index, isExpanded) {
                    final type = ingredientMap.entries.elementAt(index).key;
                    setState(() {
                      _isOpen[type] = isExpanded;
                      debugPrint("Toggled $type -> ${_isOpen[type]}");
                    });
                  },
                  children: ingredientMap.entries.map((entry) {
                    final index = entry.key;
                    final mapEntry = entry.value;
                    return ExpansionPanel(
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text(index.name),
                        );
                      },
                      body: ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: mapEntry.map((ingredientCard) {
                          final ingredient = ingredientCard.ingredient;
                          return (GestureDetector(
                            onTap: () => _selectIngredient(ingredient),
                            child: Container(
                              color: ingredient.isEqual(_selectedIngredient)
                                  ? Colors.green[100]
                                  : Colors.transparent,
                              child: ingredientCard,
                            ),
                          ));
                        }).toList(),
                      ),
                      isExpanded: _isOpen[index]!,
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    if (_selectedIngredient == null) return;
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        String value = '';
                        return AlertDialog(
                          title: Text('Enter the amount'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (val) => value = val,
                            autofocus: true,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, value),
                              child: Text('Set'),
                            ),
                          ],
                        );
                      },
                    );
                    if (result == null) return;
                    final parsedValue = int.tryParse(result);
                    if (parsedValue == null) return;

                    setState(() {
                      _selectedIngredient!.amount = parsedValue;
                      _selectedIngredient = _selectedIngredient;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Text("Amount: "),
                      Text(_selectedIngredient == null ? "0" : _selectedIngredient!.amount.toString()),
                      Text(_selectedIngredient == null ? "" : _selectedIngredient!.metric.name),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedIngredient,); 
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
