import 'package:flutter/material.dart';

import '../api/api_service.dart';

class TemporaryTestScreen extends StatefulWidget {
  const TemporaryTestScreen({Key? key}) : super(key: key);

  @override
  _TemporaryTestScreenState createState() => _TemporaryTestScreenState();
}

class _TemporaryTestScreenState extends State<TemporaryTestScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> recipesFuture;
  late Future<List<dynamic>> dietsFuture;
  late Future<List<dynamic>> ingredientsFuture;

  Map<int, String> dietNames = {};
  Map<int, String> ingredientNames = {};

  @override
  void initState() {
    super.initState();
    recipesFuture = apiService.fetchRecipes();
    dietsFuture = fetchAndCacheDiets();
    ingredientsFuture = fetchAndCacheIngredients();
  }

  Future<List<dynamic>> fetchAndCacheDiets() async {
    final diets = await apiService.fetchDiets();
    for (var diet in diets) {
      dietNames[diet['id']] = diet['dietname'];
    }
    return diets;
  }

  Future<List<dynamic>> fetchAndCacheIngredients() async {
    final ingredients = await apiService.fetchIngredients();
    for (var ingredient in ingredients) {
      ingredientNames[ingredient['id']] = ingredient['name'];
    }
    return ingredients;
  }

  Widget _buildSteps(List steps) {
    steps.sort((a, b) =>
        (a['steporder'] as int).compareTo(b['steporder'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.map((step) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Étape ${step['steporder']}: ${step['title']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("(durée : ${step['length']} minutes)", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(step['instructions']),
              const SizedBox(height: 4),
              if (step['stepingredients'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: step['stepingredients'].map<Widget>((ingredient) {
                    final unit = ingredient['unitid']?['unitname'] ?? '';
                    final ingredientName = ingredientNames[ingredient['ingredientid']] ?? 'Unknown Ingredient';
                    return Text(
                      "- ${ingredient['quantity']} $unit de $ingredientName", // Use ingredient name
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecipe(Map recipe) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe['image'] != null)
              Image.network(recipe['image'], height: 150, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              recipe['name'] ?? 'No name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (recipe['description'] != null) Text(recipe['description']),
            const SizedBox(height: 8),
            Text("Difficulté : ${recipe['difficulty']}"),
            Text("Nombre de portions: ${recipe['portions']}"),
            const SizedBox(height: 8),
            if (recipe['countries'] != null)
              Text(
                "Pays : ${recipe['countries'].map((c) => c['name']).join(
                    ', ')}",
              ),
            if (recipe['recipediets'] != null)
              Text(
                "Contient : ${recipe['recipediets'].map((
                    d) => dietNames[d['dietid']] ?? 'Unknown').join(', ')}",
              ),
            const SizedBox(height: 8),
            if (recipe['steps'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Étapes :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildSteps(recipe['steps']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Test Screen')),
      body: FutureBuilder(
        future: Future.wait([recipesFuture, dietsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final recipes = snapshot.data![0] as List<dynamic>;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return _buildRecipe(recipes[index]);
              },
            );
          } else {
            return const Center(child: Text('No recipes found.'));
          }
        },
      ),
    );
  }
}