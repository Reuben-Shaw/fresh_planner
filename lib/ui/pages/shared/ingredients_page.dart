import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/shared/add_ingredient_page.dart';
import 'package:fresh_planner/ui/styles/button_styles.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key, required this.user, required this.ingredients});

  final User user;
  final List<Ingredient> ingredients;

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final _searchController = TextEditingController();
  final _ingredientDB = DatabaseIngredients();

  final Map<IngredientType, bool> _isOpen = {
    for (var type in IngredientType.values) type: true,
  };
  final Map<IngredientType, List<IngredientCard>> _ingredientMap = {
    for (var type in IngredientType.values) type: [],
  };

  Ingredient? _selectedIngredient;

  @override
  void initState() {
    super.initState();
    _setUpIngredientMap();
  }

  void _setUpIngredientMap() {
    for (Ingredient i in widget.ingredients) {
      final IngredientType t = i.type ?? IngredientType.misc;
      _ingredientMap[t]!.add(IngredientCard(ingredient: i, onRemove: () async => _removeIngredient(i), showAmount: false,));
    }
  }

  void _selectIngredient(Ingredient ingredient) {
    setState(() {
      if (_selectedIngredient == ingredient) {
        _selectedIngredient = null;
      } else {
        _selectedIngredient = ingredient;
        if (_selectedIngredient != null) _selectedIngredient!.amount = 0;
      }
    });
  }

  void _removeIngredient(Ingredient ingredient) async {
    bool success = await _ingredientDB.removeIngredient(widget.user.uid!, ingredient.id!);
    if (!success) return;
    
    setState(() {
      _selectedIngredient = null;

      final type = ingredient.type ?? IngredientType.misc;
      _ingredientMap[type]!.removeWhere((card) => card.ingredient == ingredient);
      widget.ingredients.remove(ingredient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Ingredients",
                  style: AppTextStyles.mainTitle,
                ),
                Container(
                  decoration: AppButtonStyles.circularShadow,
                  child: IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddIngredientPage(user: widget.user, ingredients: widget.ingredients, ingredientDB: _ingredientDB,)),
                      );
                      if (result is! Ingredient) return;
                      setState(() {
                        widget.ingredients.add(result);
                        widget.ingredients.sort();
                        _ingredientMap[result.type ?? IngredientType.misc]!.add(IngredientCard(ingredient: result, onRemove: () async => _removeIngredient(result), showAmount: false,));
                        _ingredientMap[result.type ?? IngredientType.misc]!.sort();
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
                    final type = _ingredientMap.entries.elementAt(index).key;
                    setState(() {
                      _isOpen[type] = isExpanded;
                      debugPrint("Toggled $type -> ${_isOpen[type]}");
                    });
                  },
                  children: _ingredientMap.entries.map((entry) {
                    final index = entry.key;
                    final mapEntry = entry.value;
                    return ExpansionPanel(
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text(index.standardName),
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
                      Text(_selectedIngredient == null ? "" : _selectedIngredient!.metric.metricSymbol),
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
