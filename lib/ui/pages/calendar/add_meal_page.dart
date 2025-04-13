import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/styles/text_field_styles.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key, required this.user, required this.ingredients, required this.recipes});

  final User user;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _calendarDB = DatabaseCalendar();

  Recipe? _recipeDropdownValue;
  void _recipeDropdownCallback(Object? selectedVaue) {
    if (selectedVaue is Recipe) {
      setState(() {
        _recipeDropdownValue = selectedVaue;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Adding a\nMeal",
              style: AppTextStyles.mainTitle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.sunny,
                  color: Color(0xFF979797),
                ),
                Text(
                  " - Lunchtime: 17/10/24",
                  style: AppTextStyles.subTitle,
                ),
              ],
            ),
            Container(
              decoration: AppTextFieldStyles.dropShadowWithColour,
              child: DropdownButton(
                items: widget.recipes.map((r) {
                  return DropdownMenuItem<Recipe>(
                    value: r,
                    child: Text("   ${r.name}"),
                  );
                }).toList(),
                value: _recipeDropdownValue,
                onChanged: _recipeDropdownCallback,
                isExpanded: true,
                underline: Text(""),
                hint: Text(
                  "   select a recipe",
                  style: AppTextStyles.hint,
                ),
              ),
            ),
            Container(
              color: Color(0xFFd7f1e0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _recipeDropdownValue?.name ?? "",
                        ),
                        IconButton(
                          onPressed: (){}, 
                          icon: Icon(
                            Icons.edit_square,
                            color: Color(0xFF26693C),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: _recipeDropdownValue?.link != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Link to Recipe:"
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              _recipeDropdownValue!.link!,
                              style: TextStyle(
                                color: Color(0xFF3873CD),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (_recipeDropdownValue != null && _recipeDropdownValue!.ingredients.isNotEmpty),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Ingredients:",
                          ),
                          Container(
                            height: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ListView(
                              children: _recipeDropdownValue!.ingredients.map((i) => 
                                Text("• ${i.name}"),
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
