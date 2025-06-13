import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/recipe.dart';
import 'package:fresh_planner/source/objects/user.dart';

// Used by a few pages in the system to contain commonly used variables
abstract class ParentPage extends StatefulWidget {
  const ParentPage({super.key, required this.user, required this.ingredients, required this.recipes});

  final User user;
  final List<Ingredient> ingredients;
  final List<Recipe> recipes;
}
