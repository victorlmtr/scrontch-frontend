import 'package:scrontch_flutter/models/step_ingredient.dart';

class RecipeStep {
  final int id;
  final String title;
  final String instructions;
  final int length;
  final String? image;
  final int stepOrder;
  final List<StepIngredient> stepIngredients;

  RecipeStep({
    required this.id,
    required this.title,
    required this.instructions,
    required this.length,
    this.image,
    required this.stepOrder,
    required this.stepIngredients,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    try {
      return RecipeStep(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        instructions: json['instructions'] ?? '',
        length: json['length'] ?? 0,
        image: json['image'],
        stepOrder: json['steporder'] ?? 0,
        stepIngredients: (json['stepingredients'] as List?)
            ?.map((ingredient) => StepIngredient.fromJson(ingredient))
            .toList() ?? [],
      );
    } catch (e, stackTrace) {
      print('Error parsing RecipeStep: $e');
      print('RecipeStep JSON: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}