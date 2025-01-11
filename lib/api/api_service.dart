import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String recipesUrl = 'http://192.168.1.21:8084/api/v1/recipes';
  final String ingredientsUrl = 'http://192.168.1.21:8083/api/v1/ingredients';
  final String commentsUrl = 'http://192.168.1.21:8081/api/v1/comments';
  final String shoppingListsUrl = 'http://192.168.1.21:8085/api/v1/shoppinglists';
  final String dietsUrl = 'http://192.168.1.21:8082/api/v1/diets';
  final String usersUrl = 'http://192.168.1.21:8086/api/v1/users';


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

  Future<List<dynamic>> fetchDiets() async {
    final response = await http.get(Uri.parse(dietsUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load diets');
    }
  }

  Future<List<dynamic>> fetchIngredients() async {
    final response = await http.get(Uri.parse(ingredientsUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load ingredients');
    }
  }
}


