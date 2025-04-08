import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';

class Ingredient {
  final String name;
  final int amount;
  final IngredientMetric metric;
  final IngredientType? type;

  Ingredient({
    required this.name,
    this.amount = 0,
    required this.metric,
    this.type,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'amount' : amount,
      'metric': metric,
      'type': type,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      amount: json['amount'],
      metric: json['metric'],
      type: json['type'],
    );
  }

  @override
  String toString() {
    return 'Ingredient{name: $name, amount: $amount $metric, type: $type}';
  }
}
