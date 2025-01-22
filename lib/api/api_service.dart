import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/diet.dart';
import '../models/ingredient.dart';

class ApiService {
  final String baseUrl = 'http://victorl.xyz:8084/api/v1';
  final String recipesUrl = 'http://victorl.xyz:8084/api/v1/recipes';
  final String ingredientsUrl = 'http://victorl.xyz:8083/api/v1/ingredients';
  final String commentsUrl = 'http://victorl.xyz:8081/api/v1/comments';
  final String shoppingListsUrl = 'http://victorl.xyz:8085/api/v1/shoppinglists';
  final String dietsUrl = 'http://victorl.xyz:8082/api/v1/diets';
  final String usersUrl = 'http://victorl.xyz:8086/api/v1/users';
  final String baseUsersUrl = 'http://victorl.xyz:8086/api/v1';


  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await http.get(Uri.parse(recipesUrl));
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

      final url = '$baseUrl$endpoint';
      print('ApiService: Making GET request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept-Charset': 'UTF-8'},
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


  Future<List<dynamic>> fetchDiets() async {
    final response = await http.get(Uri.parse(dietsUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load diets');
    }
  }

  Future<List<Diet>> fetchUserDiets(int userId) async {
    final response = await http.get(Uri.parse('http://victorl.xyz:8086/api/v1/userDiets/user/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Diet.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user diets');
    }
  }


  Future<List<dynamic>> fetchIngredients() async {
    final response = await http.get(Uri.parse(ingredientsUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('http://victorl.xyz:8083/api/v1/categories'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> addUserIngredient(int ingredientId, int userId) async {
    final url = Uri.parse('http://victorl.xyz:8086/api/v1/userIngredients');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ingredientid': ingredientId,
        'userid': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add user ingredient: ${response.body}');
    }
  }

  Future<void> removeUserIngredient(int ingredientId, int userId) async {
    final url = Uri.parse('http://victorl.xyz:8086/api/v1/userIngredients/user/$userId/ingredient/$ingredientId');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to remove user ingredient: ${response.body}');
    }
  }


  Future<void> addEssentialIngredient(int ingredientId, int userId) async {
    final url = Uri.parse('http://victorl.xyz:8086/api/v1/essentialIngredients');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
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
    final url = Uri.parse('http://victorl.xyz:8086/api/v1/essentialIngredients/user/$userId/ingredient/$ingredientId');
    final response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Failed to remove user ingredient: ${response.body}');
    }
  }

  Future<List<Ingredient>> fetchUserPantry(int userId) async {
    final url = Uri.parse('http://victorl.xyz:8086/api/v1/userIngredients/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Fetch the ingredients from the ingredients microservice
      final ingredientsResponse = await http.get(Uri.parse(ingredientsUrl));
      if (ingredientsResponse.statusCode != 200) {
        throw Exception('Failed to load ingredients');
      }

      final List<dynamic> ingredientsData = jsonDecode(ingredientsResponse.body);

      // Map the ingredient data to Ingredient objects
      List<Ingredient> allIngredients = ingredientsData.map((json) => Ingredient.fromJson(json)).toList();

      // Map user pantry data to Ingredient objects
      List<Ingredient> pantry = data.map((json) {
        final ingredientId = json['ingredientid'];
        final isSelected = json['isSelected'] ?? false;
        final isEssential = json['isEssential'] ?? false;

        // Find the ingredient by ID
        final ingredient = allIngredients.firstWhere((i) => i.id == ingredientId, orElse: () => Ingredient(
          id: ingredientId,
          name: '',
          alias: '',
          image: '',
          description: '',
          categoryId: 0,
          isSelected: isSelected,
          isEssential: isEssential,
        ));

        // Update user-specific fields
        ingredient.isSelected = isSelected;
        ingredient.isEssential = isEssential;

        return ingredient;
      }).toList();

      return pantry;
    } else {
      throw Exception('Failed to fetch user pantry');
    }
  }

  Future<List<Ingredient>> fetchEssentialIngredients(int userId) async {
    final url = Uri.parse('$baseUsersUrl/essentialIngredients/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Fetch the ingredients from the ingredients microservice
      final ingredientsResponse = await http.get(Uri.parse(ingredientsUrl));
      if (ingredientsResponse.statusCode != 200) {
        throw Exception('Failed to load ingredients');
      }

      final List<dynamic> ingredientsData = jsonDecode(ingredientsResponse.body);
      List<Ingredient> allIngredients = ingredientsData.map((json) => Ingredient.fromJson(json)).toList();

      // Map essential ingredients data
      List<Ingredient> essentialIngredients = data.map((json) {
        final ingredientId = json['ingredientid'];

        // Find the ingredient by ID
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

      return essentialIngredients;
    } else {
      throw Exception('Failed to fetch essential ingredients');
    }
  }
  Future<void> createIngredient(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$ingredientsUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create ingredient: ${response.body}');
    }
  }

  Future<void> updateIngredient(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$ingredientsUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredient: ${response.body}');
    }
  }

}


