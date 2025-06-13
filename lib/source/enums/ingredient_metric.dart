enum IngredientMetric {
  grams('Grams', 'g'),
  item('Items', 'Items'),
  ml('Millilitres', 'ml'),
  percentage('Percentage', '%');

  final String standardName;
  final String metricSymbol;

  const IngredientMetric(this.standardName, this.metricSymbol);
  
  static IngredientMetric fromStandardName(String name) {
    return IngredientMetric.values.firstWhere(
      (e) => e.standardName.toLowerCase() == name.toLowerCase()
    );
  }
}