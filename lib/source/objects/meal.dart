import 'package:fresh_planner/source/enums/meal_repetition.dart';
import 'package:fresh_planner/source/enums/time_of_day.dart';
import 'package:fresh_planner/source/objects/recipe.dart';

/// Stores meals, which are in effect a recipe with a date of some kind
class Meal implements Comparable<Meal> {
  String? id;
  Recipe recipe;
  final TimeOfDay time;
  int? repeatFromWeek;
  DateTime? repeatFromOtherWeek;
  int? repeatFromDay;
  DateTime? day;
  bool? cookedFresh;

  /// `repeatFromWeek`, `repeatFromOtherWeek`, `repeatFromDay`, and `day` are all used for discerning repetition:
  /// 
  /// `repeatFromWeek` -> repeats every given i day, where i is an int ranged 0-6 - 0 = Monday, 6 = Sunday
  /// 
  /// `repeatFromOtherWeek` -> repeats every 14 days on and behind the given date
  /// 
  /// `repeatFromDay` -> repeats every i day, where i is a day of the month
  /// 
  /// `day` -> never repeats, only displays on the given day
  /// 
  /// `cookedFresh` is needed for calcualating cost, if it's not cooked fresh it's considered free
  Meal({
    this.id,
    required this.recipe,
    required this.time,
    this.repeatFromWeek,
    this.repeatFromOtherWeek,
    this.repeatFromDay,
    this.day,
    this.cookedFresh,
  });

  /// Mapping uses `timeOfDayToJson` and `.toIso8601String` to parse data in a way serialisable by JSON 
  Map<String, Object?> toMap() {
    return {
      'recipe': recipe.id,
      'time': timeOfDayToJson(time),
      'repeatFromWeek': repeatFromWeek,
      'repeatFromOtherWeek': repeatFromOtherWeek?.toIso8601String(),
      'repeatFromDay': repeatFromDay,
      'day': day?.toIso8601String(),
      'cookedFresh': cookedFresh,
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
      cookedFresh: json['cookedFresh'] as bool?,
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

  MealRepetition repetitionType() {
    if (isRepeatingWeek()) {
      return MealRepetition.everyWeek;
    } else if (isRepeatingOtherWeek()) {
      return MealRepetition.everyOtherWeek;
    } else if (isRepeatingDay()) {
      return MealRepetition.everyDate;
    }
    return MealRepetition.never;
  }

  double cost() {
    if (cookedFresh != null && !cookedFresh!) {
      return 0;
    }
    return recipe.cost; 
  }

  /// Meals are ordered in this order from last -> first:
  /// 
  /// Repeat never -> repeat on a set date -> repeat every other week -> repeat every week
  /// 
  /// This order is essential as it ensures that in runtime meals can overwrite each other, if they would happen to fall on the same day,
  /// e.g. a meal that repeats every week on a monday is sorted first so that a meal that repeats never, but happens to fall on a monday, 
  /// will be read by the program and overwrite the previously read and loaded every week
  @override
  int compareTo(Meal other) {
    final bool repeatingWeek = other.repeatFromWeek != null;
    final bool repeatingOtherWeek = other.repeatFromOtherWeek != null;
    final bool repeatingDay = other.repeatFromDay != null;
    final bool repeatingNever = other.day != null;

    if (repeatFromWeek != null) {
      if (repeatingWeek) { 
        return repeatFromWeek!.compareTo(other.repeatFromWeek!); 
      } else {
        return -1;
      }
    }

    if (repeatFromOtherWeek != null) {
      if (repeatingOtherWeek) {
        return repeatFromOtherWeek!.compareTo(other.repeatFromOtherWeek!);
      } else if (!repeatingWeek) {
        return -1;
      } else {
        return 1;
      }
    }

    if (repeatFromDay != null) {
      if (repeatingDay) {
        return repeatFromDay!.compareTo(other.repeatFromDay!);
      } else if (!repeatingWeek && !repeatingOtherWeek) {
        return -1;
      } else {
        return 1;
      }
    }

    if (day != null) {
      if (repeatingNever) {
        return day!.compareTo(other.day!);
      } else {
        return 1;
      }
    }
    return 0;
  }

  @override
  String toString() {
    String repetition = '';
    if (repeatFromWeek != null) {
      repetition += 'every week on a $repeatFromWeek';
    } 
    if (repeatFromOtherWeek != null) {
      repetition += 'every other week';
    } 
    if (repeatFromDay != null) {
      repetition += 'every month on the $repeatFromDay';
    }
    if (day != null) {
      repetition += 'never, only on the ${day!.day}/${day!.month}/${day!.year}';
    }
    return ('Cooking ${recipe.name} at ${time.standardName}, repeating $repetition, is fresh $cookedFresh');
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