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
    final bool repeatingWeek = other.repeatFromWeek != null;
    final bool repeatingOtherWeek = other.repeatFromOtherWeek != null;
    final bool repeatingDay = other.repeatFromDay != null;
    final bool repeatingNever = other.day != null;

    //debugPrint("Comparing ${toString()} with ${other.toString()}");

    if (repeatFromWeek != null) {
      //debugPrint("Repeating from Week");
      if (repeatingWeek) { 
        //debugPrint("Other is also repeating from Week");
        return repeatFromWeek!.compareTo(other.repeatFromWeek!); 
      } else {
        //debugPrint("Sorted before");
        return -1;
      }
    }

    if (repeatFromOtherWeek != null) {
      //debugPrint("Repeating from Other Week");
      if (repeatingOtherWeek) {
        //debugPrint("Other is also repeating from Other Week");
        return repeatFromOtherWeek!.compareTo(other.repeatFromOtherWeek!);
      } else if (!repeatingWeek) {
        //debugPrint("Sorted before");
        return -1;
      } else {
        //debugPrint("Sorted after");
        return 1;
      }
    }

    if (repeatFromDay != null) {
      //debugPrint("Repeating from Day");
      if (repeatingDay) {
        //debugPrint("Other is also repeating from Day");
        return repeatFromDay!.compareTo(other.repeatFromDay!);
      } else if (!repeatingWeek && !repeatingOtherWeek) {
        //debugPrint("Sorted before");
        return -1;
      } else {
        //debugPrint("Sorted after");
        return 1;
      }
    }

    if (day != null) {
      //debugPrint("Not repeating");
      if (repeatingNever) {
        //debugPrint("Other is also Not repeating");
        return day!.compareTo(other.day!);
      } else {
        //debugPrint("Sorted after");
        return 1;
      }
    }
    return 0;
  }

  @override
  String toString() {
    String repetition = "";
    if (repeatFromWeek != null) {
      repetition += "every week on a $repeatFromWeek";
    } 
    if (repeatFromOtherWeek != null) {
      repetition += "every other week";
    } 
    if (repeatFromDay != null) {
      repetition += "every month on the $repeatFromDay";
    }
    if (day != null) {
      repetition += "never, only on the ${day!.day}/${day!.month}/${day!.year}";
    }
    return ("Cooking ${recipe.name} at ${time.standardName}, repeating $repetition");
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