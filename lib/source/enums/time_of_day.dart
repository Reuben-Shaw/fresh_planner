enum TimeOfDay {
  breakfast("Breakfast"),
  lunch("Lunchtime"),
  dinner("Dinnertime");

  final String standardName;

  const TimeOfDay(this.standardName);
  static TimeOfDay? fromStandardName(String? name) {
    if (name == null) return null;
    return TimeOfDay.values.firstWhere(
      (e) => e.standardName.toLowerCase() == name.toLowerCase()
    );
  }
}