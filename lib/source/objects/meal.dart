import 'package:flutter/material.dart';

class Meal {
  final String name;
  final Color colour;

  Meal({
    required this.name,
    required this.colour,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'colour': colour,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'],
      colour: json['colour'],
    );
  }

  @override
  String toString() {
    return 'Meal{name: $name, colour: $colour}';
  }
}
