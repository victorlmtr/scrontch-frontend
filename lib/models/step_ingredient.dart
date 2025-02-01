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
  Ingredient? ingredient;
  StepIngredient({
    required this.id,
    required this.ingredientId,
    required this.quantity,
    required this.isOptional,
    required this.unit,
    required this.preparationMethod,
    this.ingredient
  });

  factory StepIngredient.fromJson(Map<String, dynamic> json) {
    try {
      print('\nParsing StepIngredient:');
      print('Raw JSON: $json');

      // Parse unit
      print('Parsing unit data: ${json['unitid']}');
      final unit = Unit.fromJson(json['unitid'] ?? {});
      print('Parsed unit: ${unit.unitName} (${unit.id})');

      // Parse preparation method
      print('Parsing preparation method data: ${json['preparationid']}');
      final prepMethod = PreparationMethod.fromJson(json['preparationid'] ?? {});
      print('Parsed preparation method: ${prepMethod.name} (${prepMethod.id})');

      final stepIngredient = StepIngredient(
        id: json['id'] ?? 0,
        ingredientId: json['ingredientid'] ?? 0,
        quantity: (json['quantity'] ?? 0.0).toDouble(),
        isOptional: json['isoptional'] ?? false,
        unit: unit,
        preparationMethod: prepMethod
      );

      print('Successfully parsed StepIngredient: ${stepIngredient.id}');
      return stepIngredient;

    } catch (e, stackTrace) {
      print('Error parsing StepIngredient:');
      print('Error: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientid': ingredient?.id,
      'quantity': quantity,
      'isoptional': isOptional,
      'unitid': unit.id,
      'preparationid': preparationMethod.id,
    };
  }

}
