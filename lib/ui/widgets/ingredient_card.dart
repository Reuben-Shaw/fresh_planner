import 'package:flutter/material.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/ui/styles/text_field_styles.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class IngredientCard extends StatelessWidget implements Comparable<IngredientCard> {
  final Ingredient ingredient;
  final VoidCallback? onRemove;
  final bool showAmount;
  final bool isSelected;

  const IngredientCard({
    super.key,
    required this.ingredient,
    this.onRemove,
    required this.showAmount,
    required this.isSelected,
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
            decoration: isSelected ? AppTextFieldStyles.altDropShadowWithColour : AppTextFieldStyles.dropShadowWithColour,
            height: 38,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    ingredient.name,
                    style: isSelected ? AppTextStyles.altStandardRegular : AppTextStyles.standardRegular
                  ),
                  Row(
                    children: <Widget>[
                      Visibility(
                        visible: showAmount,
                        child: Text(
                          ingredient.amount == 0 ? '' : ingredient.amount.toString(),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Text(
                        (showAmount && (ingredient.metric == IngredientMetric.item || ingredient.amount == 0)) ? '' : 
                        showAmount ? ingredient.metric.metricSymbol : ingredient.metric.standardName, 
                        style: isSelected ? AppTextStyles.altStandardBold : AppTextStyles.standardBold,
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
            showAmount ? Icons.cancel : Icons.delete_forever_rounded, 
            color: const Color(0xFF26693C),
          ),
        ),
      ],
    );
  }
}
