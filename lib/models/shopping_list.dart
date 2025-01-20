import 'ingredient_item.dart';
import 'nonfooditem.dart';

class ShoppingList {
  final int? id;
  final int userId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<IngredientItem> ingredientItems;
  final List<NonFoodItem> nonFoodItems;

  ShoppingList({
    this.id,
    required this.userId,
    required this.name,
    this.createdAt,
    this.updatedAt,
    required this.ingredientItems,
    required this.nonFoodItems,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      userId: json['userid'],
      name: json['name'],
      createdAt: json['createdat'] != null ? DateTime.parse(json['createdat']) : null,
      updatedAt: json['updatedat'] != null ? DateTime.parse(json['updatedat']) : null,
      ingredientItems: (json['ingredientitems'] as List<dynamic>)
          .map((item) => IngredientItem.fromJson(item))
          .toList(),
      nonFoodItems: (json['nonfooditems'] as List<dynamic>)
          .map((item) => NonFoodItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userid': userId,
      'name': name,
      'ingredientitems': ingredientItems.map((item) => item.toJson()).toList(),
      'nonfooditems': nonFoodItems.map((item) => item.toJson()).toList(),
    };

    if (id != null) data['id'] = id;
    if (createdAt != null) data['createdat'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedat'] = updatedAt!.toIso8601String();

    return data;
  }
}