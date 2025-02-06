class RecipeItem {
  final int id;
  final int? recipeId;
  final String? recipeName;
  late final String? recipeLink;
  final int recipeListId;

  RecipeItem({
    required this.id,
    this.recipeId,
    this.recipeName,
    this.recipeLink,
    required this.recipeListId,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      id: json['id'],
      recipeId: json['recipeid'],
      recipeName: json['recipename'] as String?,
      recipeLink: json['recipeLink'] as String?,
      recipeListId: json['recipelistid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeid': recipeId,
      'recipename': recipeName,
      'recipeLink': recipeLink,
      'recipelistid': recipeListId,
    };
  }
}