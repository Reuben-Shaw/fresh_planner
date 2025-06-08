import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/ingredient.dart';
import 'package:fresh_planner/source/objects/user.dart';

abstract class ParentPage extends StatefulWidget {
  const ParentPage({super.key, required this.user, required this.ingredients,});

  final User user;
  final List<Ingredient> ingredients;
  
  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
