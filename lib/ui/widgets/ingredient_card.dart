import 'package:flutter/material.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class IngredientCard extends StatelessWidget implements Comparable<IngredientCard> {
  final Ingredient ingredient;
  final VoidCallback? onRemove;
  final bool showAmount;

  const IngredientCard({
    super.key,
    required this.ingredient,
    this.onRemove,
    required this.showAmount,
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
                  Row(
                    children: <Widget>[
                      Visibility(
                        visible: showAmount,
                        child: Text(
                          ingredient.amount == 0 ? "" : ingredient.amount.toString(),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        (showAmount && (ingredient.metric == IngredientMetric.item || ingredient.amount == 0)) ? "" : 
                        showAmount ? ingredient.metric.metricSymbol : ingredient.metric.standardName, 
                      ),
                    ],
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
