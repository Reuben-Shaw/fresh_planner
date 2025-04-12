import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';

class Ingredient implements Comparable<Ingredient> {
  String? id;
  String name;
  int amount;
  double? cost;
  IngredientMetric metric;
  IngredientType? type;

  Ingredient({
    this.id,
    required this.name,
    this.amount = 0,
    this.cost,
    required this.metric,
    this.type,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'cost' : cost,
      'metric': metricToJson(metric),
      'type': ingredientTypeToJson(type),
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      amount: 0,
      cost: json['cost'],
      metric: metricFromJson(json['metric']),
      type: ingredientTypeFromJson(json['type']),
    );
  }

  bool isEqual(Ingredient? other) {
    if (other == null) return false;
    if (name != other.name) return false;
    if (metric != other.metric) return false;
    if (type != other.type) return false;
    return true;
  }

  @override
  int compareTo(Ingredient other) {
    int i = type == null ? 0 : other.type == null ? 0 : type!.index.compareTo(other.type!.index);
    int j = name.compareTo(other.name);
    return i != 0 ? i : j;
  }

  @override
  String toString() {
    return 'Ingredient{id: $id, name: $name, amount: $amount $metric, cost: $cost type: $type}';
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
