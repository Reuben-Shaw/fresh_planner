import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onRemove;

  const IngredientCard({
    super.key,
    required this.ingredient,
    this.onRemove,
  });

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
                    ingredient.metric.name,
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onRemove, 
          icon: Image.asset('assets/images/bin.png'),
        ),
      ],
    );
  }
}
