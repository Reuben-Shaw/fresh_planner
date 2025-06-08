import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';

class AddIngredientPage extends ParentPage {
  const AddIngredientPage({super.key, required super.user, required super.ingredients, required this.ingredientDB});
  
  final DatabaseIngredients ingredientDB;

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _costAmountController = TextEditingController();

  InputDecoration _costAmountHint = AppTextFieldStyles.primaryStyle("/amount");
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  String _errorText = "";
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  String _metricText = "";
  String get metricText => _metricText;
  set metricText(String value) => setState(() => _metricText = value);

  IngredientMetric? _metricDropdownValue;
  void _metricDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is IngredientMetric) {
      setState(() {
        metricText = selectedVaue != IngredientMetric.item ? selectedVaue.metricSymbol : "";
        _metricDropdownValue = selectedVaue;
      });
    }
  }

  IngredientType? _typeDropdownValue;
  void _typeDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is IngredientType) {
      setState(() {
        _typeDropdownValue = selectedVaue;
      });
    }
  }

  
  @override
  void initState() {
    super.initState();
    _costController.addListener(_updateCostAmount);
  }
  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  void _updateCostAmount() {
    if (_costController.text.isNotEmpty) {
      setState(() {
        _costAmountHint = AppTextFieldStyles.primaryStyle("/amount*");
      });
    } else {
      setState(() {
        _costAmountHint = AppTextFieldStyles.primaryStyle("/amount");
      });
    }
  }

  void addIngredient() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_nameController.text == "" || _metricDropdownValue == null) {
      errorText = "Ensure all required values are filled";
      return;
    }
    if (_costController.text.isNotEmpty && _costAmountController.text.isEmpty) {
      errorText = "Please ensure an amount per cost is provided";
      return;
    }

    double? costParsed;
    int? costAmountParsed;
    if (_costController.text.isNotEmpty || _costAmountController.text.isNotEmpty) {
      costParsed = double.tryParse(_costController.text);
      if (costParsed == null) {
        errorText = "Cost is not numeric";
        return;
      }
      costAmountParsed = int.tryParse(_costAmountController.text);
      if (costAmountParsed == null) {
        errorText = "Amount per cost is not numeric";
        return;
      }
      if (costParsed < 0 || costAmountParsed < 0) {
        errorText = "Pricing cannot use negative numbers";
        return;
      }
    }
    if (widget.ingredients.any((i) => i.name == _nameController.text.toLowerCase())) {
      errorText = "Ingredient with the same name already exists";
      return;
    }

    final ingredient = Ingredient(
      name: _nameController.text.toLowerCase(), 
      cost: costParsed,
      costAmount: costAmountParsed,
      metric: _metricDropdownValue!,
      type: _typeDropdownValue != IngredientType.misc ? _typeDropdownValue : null,
    );
    _isLoading = true;
    debugPrint("debug 1");
    (bool, String?) response = await widget.ingredientDB.addIngredient(widget.user.uid!, ingredient);
    debugPrint("debug 2");
    if (!response.$1 || !mounted) {
      debugPrint("debug 3");
      errorText = "Internal server error, please try again";
      _isLoading = false;
      return;
    }
    ingredient.id = response.$2;

    debugPrint("adding is done with $ingredient");
    Navigator.pop(context, ingredient,); 
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
                              key: Key("name_textfield"),
                              controller: _nameController,
                              decoration: AppTextFieldStyles.primaryStyle("name*"),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            decoration: AppTextFieldStyles.dropShadowWithColour,
                            child: DropdownButton(
                              key: Key("metric_dropdown"),
                              items: IngredientMetric.values.map((type) {
                                return DropdownMenuItem<IngredientMetric>(
                                  value: type,
                                  child: Text("   ${type.standardName}"),
                                );
                              }).toList(),
                              value: _metricDropdownValue,
                              onChanged: _metricDropdownCallback,
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
                                    key: Key("cost_textfield"),
                                    controller: _costController,
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
                                    key: Key("amount_textfield"),
                                    controller: _costAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: _costAmountHint,
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
                              key: Key("type_dropdown"),
                              items: IngredientType.values.map((type) {
                                return DropdownMenuItem<IngredientType>(
                                  value: type,
                                  child: Text("   ${type.standardName}"),
                                );
                              }).toList(),
                              value: _typeDropdownValue,
                              onChanged: _typeDropdownCallback,
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
                              Container(
                                decoration: AppButtonStyles.circularShadow,
                                child: ElevatedButton(
                                  key: Key("add_button"),
                                  onPressed: addIngredient,
                                  style: AppButtonStyles.mainBackStyle,
                                  child: Text(
                                    "    Add    ",
                                    style: AppButtonStyles.mainTextStyle,
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
