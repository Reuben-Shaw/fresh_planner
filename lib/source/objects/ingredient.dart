import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';

class Ingredient {
  final String name;
  final int amount;
  final double? cost;
  final IngredientMetric metric;
  final IngredientType? type;

  Ingredient({
    required this.name,
    this.amount = 0,
    this.cost,
    required this.metric,
    this.type,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'amount' : amount,
      'cost' : cost,
      'metric': metricToJson(metric),
      'type': ingredientTypeToJson(type),
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      amount: json['amount'],
      cost: json['cost'],
      metric: metricFromJson(json['metric']),
      type: ingredientTypeFromJson(json['type']),
    );
  }

  @override
  String toString() {
    return 'Ingredient{name: $name, amount: $amount $metric, cost: $cost type: $type}';
  }
}

String metricToJson(IngredientMetric metric) {
  return metric.toString().split('.').last;
}
IngredientMetric metricFromJson(String json) {
  return IngredientMetric.values.firstWhere((e) => e.toString().split('.').last == json);
}

String ingredientTypeToJson(IngredientType? type) {
  return type.toString().split('.').last;
}
IngredientType? ingredientTypeFromJson(String json) {
  return IngredientType.values.firstWhere((e) => e.toString().split('.').last == json);
}
