import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class Recipe implements Comparable<Recipe> {
  String? id;
  final String name;
  final String? link;
  final List<Ingredient> ingredients;
  final Color colour;

  Recipe({
    this.id,
    required this.name,
    this.link,
    required this.ingredients,
    required this.colour,
  });

  double get cost {
    return calcCost(ingredients);
  }

  static double calcCost(List<Ingredient> ingredients) {
    double cost = 0;
    for (Ingredient i in ingredients) {
      cost += ((i.cost ?? 0) / (i.costAmount ?? 1)) * i.amount;
    }
    return cost;
  }

  @override
  int compareTo(Recipe other) {
    return (name.compareTo(other.name));
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'link': link,
      'ingredients': ingredients.map((i) => {'id': i.id, 'amount': i.amount}).toList(),
      'colour': colourToJson(colour),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      link: json['link'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
        ?.map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
        .toList() ??
      [],
      colour: colourFromJson(json['colour']),
    );
  }

  @override
  String toString() {
    return 'Recipe{name: $name, link: $link, ${ingredients.toString()} colour: $colour}';
  }
}

Map<String, double> colourToJson(Color colour) {
    return {
      'red': colour.r,
      'blue': colour.b,
      'green': colour.g,
      'alpha': colour.a,
    };
  }

Color colourFromJson(Map<String, dynamic> colourMap) {
    return Color.from(
      alpha: (colourMap['alpha']!).toDouble(),
      red: (colourMap['red']!).toDouble(),
      green: (colourMap['green']!).toDouble(),
      blue: (colourMap['blue']!).toDouble(),
    );
  }
