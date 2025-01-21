import 'package:scrontch_flutter/models/preparation_method.dart';
import 'package:scrontch_flutter/models/unit.dart';

import 'ingredient.dart';

class StepIngredient {
  final int id;
  final int ingredientId;
  final double quantity;
  final bool isOptional;
  final Unit unit;
  final PreparationMethod preparationMethod;
  final String? ingredientName;  // Make nullable
  final bool? pantryStatus;      // Make nullable
  Ingredient? ingredient;        // Keep nullable

  StepIngredient({
    required this.id,
    required this.ingredientId,
    required this.quantity,
    required this.isOptional,
    required this.unit,
    required this.preparationMethod,
    this.ingredientName,
    this.pantryStatus,
    this.ingredient,
  });

  factory StepIngredient.fromJson(Map<String, dynamic> json) {
    try {
      return StepIngredient(
        id: json['id'] ?? 0,
        ingredientId: json['ingredientid'] ?? 0,
        quantity: (json['quantity'] ?? 0.0).toDouble(),
        isOptional: json['isoptional'] ?? false,
        unit: Unit.fromJson(json['unitid'] ?? {}),
        preparationMethod: PreparationMethod.fromJson(json['preparationid'] ?? {}),
        ingredientName: json['ingredientName'],
        pantryStatus: json['pantryStatus'],
      );
    } catch (e, stackTrace) {
      print('Error parsing StepIngredient: $e');
      print('StepIngredient JSON: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
