import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/country.dart';
import '../models/diet.dart';
import '../models/ingredient.dart';
import '../models/preparation_method.dart';
import '../models/recipe_type.dart';
import '../models/unit.dart';

class ApiService {
  static const String _host = 'victorl.xyz';
  static const String _apiPath = '/api/v1';
  final Map<String, String> _standardHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    'Accept-Charset': 'utf-8',
  };

  final Map<String, String> _endpoints = {
    'recipes': '8084',
    'ingredients': '8083',
    'comments': '8081',
    'shoppinglists': '8085',
    'diets': '8082',
    'users': '8086',
    'units': '8084',
    'preparations': '8084',
  };

  String getDietsUrl() => _buildUrl('diets', '/diets');
  String getRecipesUrl() => _buildUrl('recipes', '/recipes');
  String getIngredientsUrl() => _buildUrl('ingredients', '/ingredients');
  String _buildUrl(String service, [String path = '']) {
    return 'https://$_host:${_endpoints[service]}$_apiPath$path';
  }

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await http.get(Uri.parse(_buildUrl('recipes', '/recipes')));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedBody);
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = _buildUrl('recipes', endpoint);
      print('ApiService: Making GET request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _standardHeaders,
      );

      print('ApiService: Received response with status: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        print('ApiService: Decoded response body: $decodedBody');
        return json.decode(decodedBody);
      } else {
        print('ApiService: Error response body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('ApiService: Error during GET request:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Network error: $e');
    }
  }

  Future<List<Diet>> fetchDiets() async {
    final response = await http.get(Uri.parse(_buildUrl('diets', '/diets')));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedBody);
      return data.map((json) => Diet.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load diets');
    }
  }

  Future<List<Diet>> fetchUserDiets(int userId) async {
    final response = await http.get(Uri.parse(_buildUrl('users', '/userDiets/user/$userId')));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Diet.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user diets');
    }
  }

  Future<List<dynamic>> fetchIngredients() async {
    final response = await http.get(Uri.parse(_buildUrl('ingredients', '/ingredients')));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse(_buildUrl('ingredients', '/categories')));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> addUserIngredient(int ingredientId, int userId) async {
    final response = await http.post(
      Uri.parse(_buildUrl('users', '/userIngredients')),
      headers: _standardHeaders,
      body: jsonEncode({
        'ingredientid': ingredientId,
        'userid': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add user ingredient: ${response.body}');
    }
  }

  Future<List<RecipeType>> fetchTypes() async {
    final response = await http.get(
      Uri.parse('https://victorl.xyz:8084/api/v1/types'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RecipeType.fromJson(json)).toList();
    }
    throw Exception('Failed to load types');
  }

  Future<List<Country>> fetchCountries() async {
    final response = await http.get(
      Uri.parse('https://victorl.xyz:8084/api/v1/countries'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
      },
    );
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      return data.map((json) => Country.fromJson(json)).toList();
    }
    throw Exception('Failed to load countries');
  }

  Future<void> createRecipe(Map<String, dynamic> recipeData) async {
    final response = await http.post(
      Uri.parse('https://victorl.xyz:8084/api/v1/recipes'),
      headers: _standardHeaders,
      body: json.encode(recipeData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create recipe');
    }
  }

  Future<void> removeUserIngredient(int ingredientId, int userId) async {
    final response = await http.delete(
        Uri.parse(_buildUrl('users', '/userIngredients/user/$userId/ingredient/$ingredientId'))
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove user ingredient: ${response.body}');
    }
  }

  Future<void> addEssentialIngredient(int ingredientId, int userId) async {
    final response = await http.post(
      Uri.parse(_buildUrl('users', '/essentialIngredients')),
      headers: _standardHeaders,
      body: jsonEncode({
        'ingredientid': ingredientId,
        'userid': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add essential ingredient: ${response.body}');
    }
  }

  Future<void> removeEssentialIngredient(int ingredientId, int userId) async {
    final response = await http.delete(
        Uri.parse(_buildUrl('users', '/essentialIngredients/user/$userId/ingredient/$ingredientId'))
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to remove user ingredient: ${response.body}');
    }
  }

  Future<List<Ingredient>> fetchUserPantry(int userId) async {
    final response = await http.get(Uri.parse(_buildUrl('users', '/userIngredients/user/$userId')));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final ingredientsResponse = await http.get(Uri.parse(_buildUrl('ingredients', '/ingredients')));

      if (ingredientsResponse.statusCode != 200) {
        throw Exception('Failed to load ingredients');
      }

      final List<dynamic> ingredientsData = jsonDecode(ingredientsResponse.body);
      List<Ingredient> allIngredients = ingredientsData.map((json) => Ingredient.fromJson(json)).toList();

      return data.map((json) {
        final ingredientId = json['ingredientid'];
        final isSelected = json['isSelected'] ?? false;
        final isEssential = json['isEssential'] ?? false;

        final ingredient = allIngredients.firstWhere(
                (i) => i.id == ingredientId,
            orElse: () => Ingredient(
              id: ingredientId,
              name: '',
              alias: '',
              image: '',
              description: '',
              categoryId: 0,
              isSelected: isSelected,
              isEssential: isEssential,
            )
        );

        ingredient.isSelected = isSelected;
        ingredient.isEssential = isEssential;
        return ingredient;
      }).toList();
    } else {
      throw Exception('Failed to fetch user pantry');
    }
  }

  Future<List<Ingredient>> fetchEssentialIngredients(int userId) async {
    final response = await http.get(Uri.parse(_buildUrl('users', '/essentialIngredients/user/$userId')));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final ingredientsResponse = await http.get(Uri.parse(_buildUrl('ingredients', '/ingredients')));

      if (ingredientsResponse.statusCode != 200) {
        throw Exception('Failed to load ingredients');
      }

      final List<dynamic> ingredientsData = jsonDecode(ingredientsResponse.body);
      List<Ingredient> allIngredients = ingredientsData.map((json) => Ingredient.fromJson(json)).toList();

      return data.map((json) {
        final ingredientId = json['ingredientid'];
        final ingredient = allIngredients.firstWhere(
                (i) => i.id == ingredientId,
            orElse: () => Ingredient(
              id: ingredientId,
              name: '',
              alias: '',
              image: '',
              description: '',
              categoryId: 0,
              isSelected: false,
              isEssential: true,
            )
        );

        ingredient.isEssential = true;
        return ingredient;
      }).toList();
    } else {
      throw Exception('Failed to fetch essential ingredients');
    }
  }

  Future<void> createIngredient(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(_buildUrl('ingredients', '/ingredients')),
      headers: _standardHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create ingredient: ${response.body}');
    }
  }

  Future<void> updateIngredient(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(_buildUrl('ingredients', '/ingredients/$id')),
      headers: _standardHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredient: ${response.body}');
    }
  }

  Future<List<Unit>> fetchUnits() async {
    final response = await http.get(
      Uri.parse(_buildUrl('units', '/units')),
      headers: _standardHeaders,
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      return data.map((json) => Unit.fromJson(json)).toList();
    }
    throw Exception('Failed to load units');
  }

  Future<List<PreparationMethod>> fetchPreparationMethods() async {
    final response = await http.get(
      Uri.parse(_buildUrl('preparations', '/preparationmethods')),
      headers: _standardHeaders,
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      return data.map((json) => PreparationMethod.fromJson(json)).toList();
    }
    throw Exception('Failed to load preparation methods');
  }
}