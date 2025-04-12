import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';

class Recipe {
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

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'link': link,
      'ingredients': ingredients,
      'colour': colour,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      link: json['link'],
      ingredients: json['ingredients'],
      colour: json['colour'],
    );
  }

  @override
  String toString() {
    return 'Recipe{name: $name, link: $link}';
  }
}
