import 'package:scrontch_flutter/models/recipe_diet.dart';
import 'package:scrontch_flutter/models/recipe_type.dart';
import 'package:scrontch_flutter/models/step.dart';

import 'country.dart';

class Recipe {
  final int id;
  final String name;
  final String description;
  final int difficulty;
  final double portions;
  final String? notes;
  final String? image;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RecipeType type;
  final List<Country> countries;
  final List<RecipeDiet> recipeDiets;
  final List<RecipeStep> recipeSteps;
  final String formattedTotalTime;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.portions,
    this.notes,
    this.image,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    required this.countries,
    required this.recipeDiets,
    required this.recipeSteps,
    required this.formattedTotalTime,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing recipe JSON: $json');
      return Recipe(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        difficulty: json['difficulty'] ?? 0,
        portions: (json['portions'] ?? 0.0).toDouble(),
        notes: json['notes'],
        image: json['image'],
        createdAt: json['createdat'] != null
            ? DateTime.parse(json['createdat'])
            : DateTime.now(),
        updatedAt: json['updatedat'] != null
            ? DateTime.parse(json['updatedat'])
            : null,
        type: RecipeType.fromJson(json['typeid'] ?? {}),
        countries: (json['countries'] as List?)
            ?.map((country) => Country.fromJson(country))
            .toList() ?? [],
        recipeDiets: (json['recipediets'] as List?)
            ?.map((diet) => RecipeDiet.fromJson(diet))
            .toList() ?? [],
        recipeSteps: (json['steps'] as List?)
            ?.map((step) => RecipeStep.fromJson(step))
            .toList() ?? [],
        formattedTotalTime: json['formattedTotalTime'] ?? '',
      );
    } catch (e, stackTrace) {
      print('Error parsing recipe: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}