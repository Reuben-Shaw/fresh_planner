import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class IngredientCard extends StatelessWidget implements Comparable<IngredientCard> {
  final Ingredient ingredient;
  final VoidCallback? onRemove;

  const IngredientCard({
    super.key,
    required this.ingredient,
    this.onRemove,
  });

  @override
  int compareTo(IngredientCard other) {
    return (ingredient.name.compareTo(other.ingredient.name));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: (Colors.green[900])!),
              color: Colors.green[300],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    ingredient.name,
                  ),
                  Text(
                    ingredient.metric.standardName,
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onRemove, 
          icon: Icon(
            Icons.delete_forever_rounded, 
            color: Color(0xFF26693C),
          ),
        ),
      ],
    );
  }
}
