enum MealRepetition {
  everyWeek("Every "),
  everyOtherWeek("Every Other "),
  everyDate("Every "),
  never("Never");

  final String standardName;

  const MealRepetition(this.standardName);
}