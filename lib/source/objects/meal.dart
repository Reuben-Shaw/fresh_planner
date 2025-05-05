import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

class Meal implements Comparable<Meal> {
  final Recipe recipe;
  final Color colour;
  final TimeOfDay time;
  final DateTime? day;
  final int? repeatFromWeek;
  final DateTime? repeatFromOtherWeek;
  final int? repeatFromDay;

  Meal({
    required this.recipe,
    required this.colour,
    required this.time,
    this.repeatFromWeek,
    this.repeatFromOtherWeek,
    this.repeatFromDay,
    this.day,
  });

  Map<String, Object?> toMap() {
    return {
      'recipe_id': recipe.id,
      'colour': colour,
      'time': timeOfDayToJson(time),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      recipe: json['recipe'],
      colour: json['colour'],
      time: timeOfDayFromJson('time'),
    );
  }

  bool isRepeatingWeek() {
    return repeatFromWeek != null;
  }
  bool isRepeatingOtherWeek() {
    return repeatFromOtherWeek != null;
  }
  bool isRepeatingDay() {
    return repeatFromDay != null;
  }
  bool isSingleDay() {
    return day != null;
  }

  @override
  int compareTo(Meal other) {
    final bool repeatingWeek = other.repeatFromWeek == null;
    final bool repeatingOtherWeek = other.repeatFromOtherWeek == null;
    final bool repeatingDay = other.repeatFromDay == null;

    if (repeatFromWeek == null && (repeatingWeek || repeatingOtherWeek || repeatingDay)) return -1;
    if (repeatFromOtherWeek == null && (repeatingOtherWeek || repeatingDay)) return -1;
    if (repeatFromDay == null && repeatingDay) return -1;
    return day == null ? 0 : other.day == null ? 0 : day!.day.compareTo(other.day!.day);
  }
}

String timeOfDayToJson(TimeOfDay timeOfDay) {
  return timeOfDay.toString().split('.').last;
}
TimeOfDay timeOfDayFromJson(String json) {
  return TimeOfDay.values.firstWhere((e) => e.toString().split('.').last == json);
}