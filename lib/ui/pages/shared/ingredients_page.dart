import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/pages/shared/add_ingredient_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';

// Used to display a list of all ingredients that the user currently has
class IngredientsPage extends ParentPage {
  const IngredientsPage({super.key, required super.user, required super.ingredients, required super.recipes});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final _searchController = TextEditingController();
  final _ingredientDB = DatabaseIngredients();
  
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  // _isOpen is needed as dart will unload sufficiently long lists, and this prevents data from being lost
  final Map<IngredientType, bool> _isOpen = {
    for (var type in IngredientType.values) type: false,
  };
  final Map<IngredientType, List<IngredientCard>> _ingredientMap = {
    for (var type in IngredientType.values) type: [],
  };
  List<IngredientCard> _searchedIngredients = [];

  IngredientCard? _selectedIngredientCard;
  Ingredient? _selectedIngredient;
  bool _displaySearchList = false;

  @override
  void initState() {
    super.initState();
    _setUpIngredientMap();
  }

  void _setUpIngredientMap() {
    for (Ingredient i in widget.ingredients) {
      final IngredientType t = i.type ?? IngredientType.misc;
      _ingredientMap[t]!.add(IngredientCard(ingredient: i, onRemove: () async => _removeIngredient(i), showAmount: false, isSelected: false,));
    }
  }

  /// Handles logic for when an ingredient card is selected
  void _selectIngredient(IngredientCard ingredientCard) {
    Ingredient ingredient = ingredientCard.ingredient;
    IngredientType type = ingredientCard.ingredient.type ?? IngredientType.misc;

    // When selected, the card is removed and re-added so the colour can change, IngredientCard is stateful and must have all values assigned at initiation
    setState(() {
      if (_selectedIngredient == ingredient) {
        _selectedIngredient = null;
        _selectedIngredientCard = null;
        _ingredientMap[type]!.remove(ingredientCard);
        _ingredientMap[type]!.add(IngredientCard(ingredient: ingredient, onRemove: () async => _removeIngredient(ingredient), showAmount: false, isSelected: false,));
      } else {
        if (_selectedIngredientCard != null && _selectedIngredient != null) {
          _ingredientMap[type]!.remove(_selectedIngredientCard);
          _ingredientMap[type]!.add(IngredientCard(ingredient: _selectedIngredient!, onRemove: () async => _removeIngredient(_selectedIngredient!), showAmount: false, isSelected: false,));
        }
        _selectedIngredient = ingredient;
        _ingredientMap[type]!.remove(ingredientCard);
        final newIngredientCard = IngredientCard(ingredient: ingredient, onRemove: () async => _removeIngredient(ingredient), showAmount: false, isSelected: true,);
        _ingredientMap[type]!.add(newIngredientCard);
        _selectedIngredientCard = newIngredientCard;
        if (_selectedIngredient != null) _selectedIngredient!.amount = 0;
      }
      _ingredientMap[type]!.sort();
    });
  }

  void _removeIngredient(Ingredient ingredient) async {
    _isLoading = true;

    for(Recipe r in widget.recipes) {
      if (r.ingredients.contains(ingredient)) {
        await _showErrorDialog('Error, you attempted to remove an ingredient contained in the recipe ${r.name}. Please delete this recipe before deleting the ingredient');
        _isLoading = false;
        return;
      }
    }

    bool success = await _ingredientDB.removeIngredient(widget.user.uid!, ingredient.id!);
    _isLoading = false;

    if (!success) return;
    
    setState(() {
      _selectedIngredient = null;

      final type = ingredient.type ?? IngredientType.misc;
      _ingredientMap[type]!.removeWhere((card) => card.ingredient == ingredient);
      widget.ingredients.remove(ingredient);
    });
  }

  void _updateSearch(String searchedText) {
    String text = searchedText.toLowerCase();
    setState(() {
        _selectedIngredient = null;

      // If search text is empty the list headers need to be displayed
      if (searchedText.isEmpty) {
        _searchedIngredients.clear();
        _displaySearchList = false;
        return;
      }

      // If search has text the list headers need to be hidden
      _displaySearchList = true;

      if (_searchedIngredients.isEmpty) {
        for (var entry in _ingredientMap.entries) {
          final mapEntry = entry.value;

          for (var listEntry in mapEntry) {
            if (listEntry.ingredient.name.toLowerCase().contains(text)) {
              _searchedIngredients.add(listEntry);
            }
          }
        }
      }
      else {
        List<IngredientCard> newIngredients = [];
        for (var listEntry in _searchedIngredients) {
          if (listEntry.ingredient.name.toLowerCase().contains(text)) {
            newIngredients.add(listEntry);
          }
        }
        newIngredients.sort();
        _searchedIngredients = newIngredients;
      }
    });
  }

  /// Wraps IngredientCards in a GestureDetector, so they can be selected
  GestureDetector _ingredientCardClick(IngredientCard ingredientCard) {
    return GestureDetector(
      key: Key('${ingredientCard.ingredient.name}_tap'),
      onTap: () => _selectIngredient(ingredientCard),
      child: ingredientCard,
    );
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Ingredients',
                              style: AppTextStyles.mainTitle,
                            ),
                            IconButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _isLoading = true;
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddIngredientPage(user: widget.user, ingredients: widget.ingredients, recipes: widget.recipes, ingredientDB: _ingredientDB,)),
                                );
                                _isLoading = false;
                                if (result is! Ingredient) return;
                                setState(() {
                                  widget.ingredients.add(result);
                                  widget.ingredients.sort();
                                  _ingredientMap[result.type ?? IngredientType.misc]!.add(IngredientCard(ingredient: result, onRemove: () async => _removeIngredient(result), showAmount: false, isSelected: false,));
                                  _ingredientMap[result.type ?? IngredientType.misc]!.sort();
                                  _searchController.clear();
                                  _updateSearch('');
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
                        const Divider(height: 30, thickness: 2, indent: 0, endIndent: 0, color: Colors.black),
                        Container(
                          decoration: AppTextFieldStyles.dropShadow,
                          child: TextField(
                            key: const Key('search_textfield'),
                            controller: _searchController,
                            enableSuggestions: true,
                            autocorrect: true,
                            onChanged: (text) {
                              _updateSearch(text);
                            },
                            decoration: AppTextFieldStyles.primaryStyle('search', icon: const Icon(Icons.search, color: Color(0xFF26693C))),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              Visibility(
                                visible: !_displaySearchList,
                                child: SingleChildScrollView(
                                  // This is the parent for containing all the grouped lists on display
                                  child: ExpansionPanelList(
                                    expansionCallback: (index, isExpanded) {
                                      final type = _ingredientMap.entries.elementAt(index).key;
                                      setState(() {
                                        _isOpen[type] = isExpanded;
                                        debugPrint('Toggled $type -> ${_isOpen[type]}');
                                      });
                                    },
                                    children: _ingredientMap.entries.map((entry) {
                                      final index = entry.key;
                                      final mapEntry = entry.value;
                                      return ExpansionPanel(
                                        backgroundColor: Colors.white,
                                        headerBuilder: (context, isExpanded) {
                                          return GestureDetector(
                                            key: Key('${index.standardName}_header_tap'),
                                            onTap: () {
                                              final type = index;
                                              setState(() {
                                                _isOpen[type] = !(_isOpen[type] ?? false);
                                              });
                                            },
                                            child: ListTile(
                                              title: Text(
                                                index.standardName,
                                                style: AppTextStyles.innerTitle,
                                              ),
                                            ),
                                          );
                                        },
                                        body: ListView(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          shrinkWrap: true,
                                          physics: const ClampingScrollPhysics(),
                                          children: mapEntry.map((ingredientCard) {
                                            return _ingredientCardClick(ingredientCard);
                                          }).toList(),
                                        ),
                                        isExpanded: _isOpen[index]!,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              // Displays the single scrollable list, if searching
                              Visibility(
                                visible: _displaySearchList,
                                child: ListView(
                                  key: const Key('single_search_list'),
                                  children: _searchedIngredients.map((ingredientCard) {
                                    return _ingredientCardClick(ingredientCard);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              key: const Key('amount_tap'),
                              onTap: () async {
                                if (_selectedIngredient == null) return;
                                // Popup for setting amount
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    String value = '';
                                    return AlertDialog(
                                      title: const Text('Enter the amount'),
                                      content: TextField(
                                        key: const Key('amount_textfield'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) => value = val,
                                        autofocus: true,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          key: const Key('amount_button'),
                                          onPressed: () => Navigator.pop(context, value),
                                          child: const Text('Set'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (result == null) return;
                                final parsedValue = int.tryParse(result);
                                if (parsedValue == null || parsedValue < 0) return;
                  
                                setState(() {
                                  _selectedIngredient!.amount = parsedValue;
                                  _selectedIngredient = _selectedIngredient;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  const Text('Amount: ', style: AppTextStyles.largerBold,),
                                  Text(
                                    key: const Key('amount_text'),
                                    _selectedIngredient == null ? '0' : _selectedIngredient!.amount.toString(), 
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF26693C),
                                    ),
                                  ),
                                  const Stack(
                                    children: <Widget>[
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.arrow_drop_up_rounded,
                                          ),
                                          SizedBox(height: 8,),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(height: 8,),
                                          Icon(
                                            Icons.arrow_drop_down_rounded,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(_selectedIngredient == null ? '' : _selectedIngredient!.metric.metricSymbol, style: AppTextStyles.standardBold),
                                ],
                              ),
                            ),
                            Container(
                              decoration: AppButtonStyles.curvedShadow,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (_selectedIngredient != null && _selectedIngredient!.amount < 0) _selectedIngredient!.amount = 0;
                                  Navigator.pop(context, _selectedIngredient,); 
                                }, 
                                style: AppButtonStyles.mainBackStyle,
                                child: Text(
                                  ' Select ',
                                  style: AppButtonStyles.mainTextStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15,),
                      ],
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
  
  Future<void> _showErrorDialog(String error) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(error),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
