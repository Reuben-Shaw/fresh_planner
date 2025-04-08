import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/ui/widgets/ingredient_card.dart';

class IngredientListView extends StatefulWidget {
  final List<Widget> ingredientCards;
  final String section;

  const IngredientListView({
    super.key,
    required this.ingredientCards,
    required this.section,
  });

  @override
  IngredientListViewState createState() => IngredientListViewState();
}

class IngredientListViewState extends State<IngredientListView> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[ 
            Text(
              widget.section,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isCollapsed = !isCollapsed; 
                });
              },
              icon: Image.asset('assets/images/${isCollapsed ? "up" : "down"}Arrow.png'),
            ),
          ],
        ),
        Visibility(
          visible: !isCollapsed,
          child: ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: widget.ingredientCards,
          ),
        ),
      ],
    );
  }
}