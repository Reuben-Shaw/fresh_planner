import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/ui/pages/parent_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';

// Page used for creating new ingredients, lowest page in the hierarchy of the app
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

  // Used to update the hint text to have an * when cost is entered, since it is then required
  InputDecoration _costAmountHint = AppTextFieldStyles.primaryStyle('/amount');
  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  String _errorText = '';
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  String _metricText = '';
  String get metricText => _metricText;
  set metricText(String value) => setState(() => _metricText = value);

  IngredientMetric? _metricDropdownValue;
  void _metricDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is IngredientMetric) {
      setState(() {
        metricText = selectedVaue != IngredientMetric.item ? selectedVaue.metricSymbol : '';
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
        _costAmountHint = AppTextFieldStyles.primaryStyle('/amount*');
      });
    } else {
      setState(() {
        _costAmountHint = AppTextFieldStyles.primaryStyle('/amount');
      });
    }
  }

  // Handles error trapping and logic for adding new ingredients to the database
  void addIngredient() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_nameController.text == '' || _metricDropdownValue == null) {
      errorText = 'Ensure all required values are filled';
      return;
    }
    if (_costController.text.isNotEmpty && _costAmountController.text.isEmpty) {
      errorText = 'Please ensure an amount per cost is provided';
      return;
    }

    double? costParsed;
    int? costAmountParsed;
    if (_costController.text.isNotEmpty || _costAmountController.text.isNotEmpty) {
      costParsed = double.tryParse(_costController.text);
      if (costParsed == null) {
        errorText = 'Cost is not numeric';
        return;
      }
      costAmountParsed = int.tryParse(_costAmountController.text);
      if (costAmountParsed == null) {
        errorText = 'Amount per cost is not numeric';
        return;
      }
      if (costParsed < 0 || costAmountParsed < 0) {
        errorText = 'Pricing cannot use negative numbers';
        return;
      }
    }
    if (widget.ingredients.any((i) => i.name == _nameController.text.toLowerCase())) {
      errorText = 'Ingredient with the same name already exists';
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
    
    (bool, String?) response = await widget.ingredientDB.addIngredient(widget.user.uid!, ingredient);

    if (!response.$1 || !mounted) {
      errorText = 'Internal server error, please try again';
      _isLoading = false;
      return;
    }
    ingredient.id = response.$2;

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
                  icon: const Icon(Icons.arrow_back,),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'New\nIngredient',
                            style: AppTextStyles.mainTitle,
                          ),
                          const SizedBox(height: 5,),
                          const Text(
                            '*must be included',
                            style: AppTextStyles.subTitle,
                          ),
                          const SizedBox(height: 20,),
                          Container(
                            decoration: AppTextFieldStyles.dropShadow,
                            child: TextField(
                              key: const Key('name_textfield'),
                              controller: _nameController,
                              decoration: AppTextFieldStyles.primaryStyle('name*'),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          Container(
                            decoration: AppTextFieldStyles.dropShadowWithColour,
                            child: DropdownButton(
                              key: const Key('metric_dropdown'),
                              items: IngredientMetric.values.map((type) {
                                return DropdownMenuItem<IngredientMetric>(
                                  value: type,
                                  child: Text('   ${type.standardName}'),
                                );
                              }).toList(),
                              value: _metricDropdownValue,
                              onChanged: _metricDropdownCallback,
                              isExpanded: true,
                              underline: const Text(''),
                              hint: const Text(
                                '   ingredient metric*',
                                style: AppTextStyles.hint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                '£',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF898989),
                                  fontSize: 46,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: AppTextFieldStyles.dropShadow,
                                  child: TextField(
                                    key: const Key('cost_textfield'),
                                    controller: _costController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: AppTextFieldStyles.primaryStyle('cost'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: AppTextFieldStyles.dropShadow,
                                  child: TextField(
                                    key: const Key('amount_textfield'),
                                    controller: _costAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: _costAmountHint,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                metricText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF898989),
                                  fontSize: 46,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Container(
                            decoration: AppTextFieldStyles.dropShadowWithColour,
                            child: DropdownButton(
                              key: const Key('type_dropdown'),
                              items: IngredientType.values.map((type) {
                                return DropdownMenuItem<IngredientType>(
                                  value: type,
                                  child: Text('   ${type.standardName}'),
                                );
                              }).toList(),
                              value: _typeDropdownValue,
                              onChanged: _typeDropdownCallback,
                              isExpanded: true,
                              underline: const Text(''),
                              hint: const Text(
                                '   type of ingredient',
                                style: AppTextStyles.hint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Text(
                            errorText,
                            style: const TextStyle(
                              fontSize: 14, 
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                decoration: AppButtonStyles.circularShadow,
                                child: ElevatedButton(
                                  key: const Key('add_button'),
                                  onPressed: addIngredient,
                                  style: AppButtonStyles.mainBackStyle,
                                  child: Text(
                                    '    Add    ',
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
              child: const LoadingScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
