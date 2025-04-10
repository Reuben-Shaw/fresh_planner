import 'package:fresh_planner/source/objects/ingredient.dart';

class Recipe {
  String name;
  final String? link;
  final List<Ingredient> ingredients;

  Recipe({
    required this.name,
    this.link,
    required this.ingredients,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'link': link,
      'ingredients': ingredients,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      link: json['link'],
      ingredients: json['ingredients'],
    );
  }

  @override
  String toString() {
    return 'Recipe{name: $name, link: $link}';
  }
}
