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
    final response = await http.get(Uri.parse(_apiService.getRecipesUrl()));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<Recipe> getRecipeById(int id) async {
    try {
      print('RecipeService: Fetching recipe with ID: $id');
      final json = await _apiService.get('/recipes/$id');
      print('RecipeService: Received response for recipe $id: $json');
      final recipe = Recipe.fromJson(json);

      // Load ingredients after parsing the recipe
      await _loadIngredientsForRecipe(recipe);

      return recipe;
    } catch (e, stackTrace) {
      print('RecipeService: Error fetching recipe $id:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load recipe: $e');
    }
  }

  Future<void> _loadIngredientsForRecipe(Recipe recipe) async {
    // First, fetch all ingredients at once to reduce API calls
    try {
      final response = await http.get(
        Uri.parse(_apiService.getIngredientsUrl()),
        headers: {'Accept-Charset': 'UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> ingredientsData = json.decode(utf8.decode(response.bodyBytes));
        final Map<int, Ingredient> ingredientsMap = {
          for (var json in ingredientsData)
            json['id']: Ingredient.fromJson(json)
        };

        // Update all step ingredients with their corresponding ingredient data
        for (var step in recipe.recipeSteps) {
          for (var stepIngredient in step.stepIngredients) {
            if (ingredientsMap.containsKey(stepIngredient.ingredientId)) {
              stepIngredient.ingredient = ingredientsMap[stepIngredient.ingredientId];
            }
          }
        }
      }
    } catch (e) {
      print('Error loading ingredients: $e');
    }
  }
}