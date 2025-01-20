
class IngredientItem {
  final int id;
  final int ingredientId;
  final String? description;
  final int? recipeId;

  IngredientItem({
    required this.id,
    required this.ingredientId,
    this.description,
    this.recipeId,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      id: json['id'],
      ingredientId: json['ingredientid'],
      description: json['ingredientitemdescription'],
      recipeId: json['recipeid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientid': ingredientId,
      'ingredientitemdescription': description,
      'recipeid': recipeId,
    };
  }
}