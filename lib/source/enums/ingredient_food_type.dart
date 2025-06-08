enum IngredientType {
  baking('Baking'),
  dairy('Dairy'),
  driedGood('Dried Goods'),
  frozen('Frozens'),
  fruitNut('Fruits & Nuts'),
  herbSpice('Herbs & Spices'),
  liquid('Liquids'),
  meat('Meats'),
  preserve('Preserves'),
  snack('Snacks'),
  vegetable('Vegetables'),
  misc('Miscellaneous');

  final String standardName;

  const IngredientType(this.standardName);
  static IngredientType? fromStandardName(String? name) {
    if (name == null) return null;
    return IngredientType.values.firstWhere(
      (e) => e.standardName.toLowerCase() == name.toLowerCase()
    );
  }
}