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

  @override
  String toString() {
    return 'User{name: $name, colour: $colour}';
  }
}
