import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

class Meal implements Comparable<Meal> {
  String? id;
  Recipe recipe;
  final TimeOfDay time;
  int? repeatFromWeek;
  DateTime? repeatFromOtherWeek;
  int? repeatFromDay;
  DateTime? day;

  Meal({
    this.id,
    required this.recipe,
    required this.time,
    this.repeatFromWeek,
    this.repeatFromOtherWeek,
    this.repeatFromDay,
    this.day,
  });

  Map<String, Object?> toMap() {
    return {
      'recipe': recipe.id,
      'time': timeOfDayToJson(time),
      'repeatFromWeek': repeatFromWeek,
      'repeatFromOtherWeek': repeatFromOtherWeek?.toIso8601String(),
      'repeatFromDay': repeatFromDay,
      'day': day?.toIso8601String(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      recipe: Recipe.fromJson(json['recipe']),
      time: timeOfDayFromJson(json['time']),
      repeatFromWeek: json['repeatFromWeek'] as int?,
      repeatFromOtherWeek: parseIso8601(json['repeatFromOtherWeek']),
      repeatFromDay: json['repeatFromDay'] as int?,
      day: parseIso8601(json['day']),
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

    if (repeatFromWeek != null && (repeatingOtherWeek || repeatingDay)) return -1;
    if (repeatFromOtherWeek != null && (repeatingDay)) return -1;
    if (repeatFromDay != null) return -1;
    return day == null ? 0 : other.day == null ? 0 : day!.day.compareTo(other.day!.day);
  }
}

DateTime? parseIso8601(String? json) {
  return json == null ? null : DateTime.tryParse(json);
}

String timeOfDayToJson(TimeOfDay timeOfDay) {
  return timeOfDay.toString().split('.').last;
}
TimeOfDay timeOfDayFromJson(String json) {
  return TimeOfDay.values.firstWhere((e) => e.toString().split('.').last == json);
}