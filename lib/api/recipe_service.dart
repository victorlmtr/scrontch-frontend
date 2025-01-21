import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'diet_service.dart';

class RecipeService {
  final ApiService _apiService;

  RecipeService(this._apiService);

  Future<List<Recipe>> getAllRecipes() async {
    final response = await http.get(Uri.parse(_apiService.recipesUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<Recipe> getRecipeById(int id) async {
    final response = await http.get(Uri.parse('${_apiService.recipesUrl}/$id'));
    if (response.statusCode == 200) {
      final recipe = Recipe.fromJson(json.decode(response.body));

      // Load ingredient details
      await _loadIngredientsForRecipe(recipe);

      // Load diet names
      final dietService = DietService(_apiService);
      await dietService.updateRecipeDietsWithNames(recipe.recipeDiets);

      return recipe;
    }
    throw Exception('Failed to load recipe');
  }

  Future<void> _loadIngredientsForRecipe(Recipe recipe) async {
    for (var recipeStep in recipe.recipeSteps) {
      for (var stepIngredient in recipeStep.stepIngredients) {
        try {
          final response = await http.get(
            Uri.parse('${_apiService.ingredientsUrl}/${stepIngredient.ingredientId}'),
          );
          if (response.statusCode == 200) {
            stepIngredient.ingredient = Ingredient.fromJson(json.decode(response.body));
          }
        } catch (e) {
          print('Failed to load ingredient ${stepIngredient.ingredientId}: $e');
        }
      }
    }
  }
}