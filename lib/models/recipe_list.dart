import 'recipe_item.dart';

class RecipeList {
  final int id;
  final int userId;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<RecipeItem> recipeItems;

  RecipeList({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.recipeItems,
  });

  factory RecipeList.fromJson(Map<String, dynamic> json) {
    return RecipeList(
      id: json['id'],
      userId: json['userid'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdat']),
      updatedAt: json['updatedat'] != null ? DateTime.parse(json['updatedat']) : null,
      recipeItems: (json['recipeitems'] as List)
          .map((item) => RecipeItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userId,
      'name': name,
      'createdat': createdAt.toIso8601String(),
      'updatedat': updatedAt?.toIso8601String(),
      'recipeitems': recipeItems.map((item) => item.toJson()).toList(),
    };
  }
}