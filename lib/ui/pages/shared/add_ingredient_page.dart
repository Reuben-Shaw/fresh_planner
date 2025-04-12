import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/styles/text_field_styles.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key, required this.user, required this.ingredients, required this.ingredientDB});
  
  final User user;
  final List<Ingredient> ingredients;
  final DatabaseIngredients ingredientDB;

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final costAmountController = TextEditingController();

  InputDecoration costAmountHint = AppTextFieldStyles.primaryStyle("/amount");

  String _errorText = "";
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  String _metricText = "";
  String get metricText => _metricText;
  set metricText(String value) => setState(() => _metricText = value);



  IngredientMetric? _metricDropdownValue;
  void metricDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is IngredientMetric) {
      setState(() {
        metricText = selectedVaue != IngredientMetric.item ? selectedVaue.metricSymbol : "";
        _metricDropdownValue = selectedVaue;
      });
    }
  }

  IngredientType? _typeDropdownValue;
  void typeDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is IngredientType) {
      setState(() {
        _typeDropdownValue = selectedVaue;
      });
    }
  }

  
  @override
  void initState() {
    super.initState();
    costController.addListener(_updateCostAmount);
  }
  @override
  void dispose() {
    costController.dispose();
    super.dispose();
  }

  void _updateCostAmount() {
    if (costController.text.isNotEmpty) {
      setState(() {
        costAmountHint = AppTextFieldStyles.primaryStyle("/amount*");
      });
    } else {
      setState(() {
        costAmountHint = AppTextFieldStyles.primaryStyle("/amount");
      });
    }
  }

  void addIngredient() async {
    if (nameController.text == "" || _metricDropdownValue == null) {
      errorText = "Ensure all required values are filled";
      return;
    }
    if (costController.text.isNotEmpty && costAmountController.text.isEmpty) {
      errorText = "Please ensure an amount per cost is provided";
      return;
    }

    double? costParsed;
    int? costAmountParsed;
    if (costController.text.isNotEmpty || costAmountController.text.isNotEmpty) {
      costParsed = double.tryParse(costController.text);
      if (costParsed == null) {
        errorText = "Cost is not numeric";
        return;
      }
      costAmountParsed = int.tryParse(costAmountController.text);
      if (costAmountParsed == null) {
        errorText = "Amount per cost is not numeric";
        return;
      }
    }
    if (widget.ingredients.any((i) => i.name == nameController.text.toLowerCase())) {
      errorText = "Ingredient with the same name already exists";
      return;
    }

    final ingredient = Ingredient(
      name: nameController.text.toLowerCase(), 
      cost: costParsed,
      costAmount: costAmountParsed,
      metric: _metricDropdownValue!,
      type: _typeDropdownValue != IngredientType.misc ? _typeDropdownValue : null,
    );

    (bool, String?) response = await widget.ingredientDB.addIngredient(widget.user.uid!, ingredient);
    if (!response.$1 || !mounted) {
      errorText = "Internal server error, please try again";
      return;
    }
    ingredient.id = response.$2;

    Navigator.pop(context, ingredient,); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back,),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "New\nIngredient",
                        style: AppTextStyles.mainTitle,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "*must be included",
                        style: AppTextStyles.subTitle,
                      ),
                      SizedBox(height: 20,),
                      Container(
                        decoration: AppTextFieldStyles.dropShadow,
                        child: TextField(
                          controller: nameController,
                          decoration: AppTextFieldStyles.primaryStyle("name*"),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        decoration: AppTextFieldStyles.dropShadowWithColour,
                        child: DropdownButton(
                          items: IngredientMetric.values.map((type) {
                            return DropdownMenuItem<IngredientMetric>(
                              value: type,
                              child: Text("   ${type.standardName}"),
                            );
                          }).toList(),
                          value: _metricDropdownValue,
                          onChanged: metricDropdownCallback,
                          isExpanded: true,
                          underline: Text(""),
                          hint: Text(
                            "   ingredient metric*",
                            style: AppTextStyles.hint,
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "£",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF898989),
                              fontSize: 46,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppTextFieldStyles.dropShadow,
                              child: TextField(
                                controller: costController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                decoration: AppTextFieldStyles.primaryStyle("cost"),
                              ),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: AppTextFieldStyles.dropShadow,
                              child: TextField(
                                controller: costAmountController,
                                keyboardType: TextInputType.number,
                                decoration: costAmountHint,
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(
                            metricText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF898989),
                              fontSize: 46,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Container(
                        decoration: AppTextFieldStyles.dropShadowWithColour,
                        child: DropdownButton(
                          items: IngredientType.values.map((type) {
                            return DropdownMenuItem<IngredientType>(
                              value: type,
                              child: Text("   ${type.standardName}"),
                            );
                          }).toList(),
                          value: _typeDropdownValue,
                          onChanged: typeDropdownCallback,
                          isExpanded: true,
                          underline: Text(""),
                          hint: Text(
                            "   type of ingredient",
                            style: AppTextStyles.hint,
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        errorText,
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: addIngredient,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF399E5A)),
                            ),
                            child: Text(
                              "    Add    ",
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white,
                                height: 2.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
