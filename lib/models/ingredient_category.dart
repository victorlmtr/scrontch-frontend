import 'package:flutter/cupertino.dart';

class IngredientCategory {
  final int id;
  final String name;
  final String icon;

  IngredientCategory({required this.id, required this.name, required this.icon});

  factory IngredientCategory.fromJson(Map<String, dynamic> json) {
    return IngredientCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '',
    );
  }
}