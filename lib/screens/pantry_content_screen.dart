import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../api/api_service.dart';
import '../models/ingredient_category.dart';
import '../widgets/ingredient_category_widget.dart';
import 'add_ingredient_screen.dart';

class PantryContentScreen extends StatefulWidget {
  final int userId;
  PantryContentScreen({required this.userId});

  @override
  _PantryContentScreenState createState() => _PantryContentScreenState();
}

class _PantryContentScreenState extends State<PantryContentScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureData;
  late int currentUserId;
  List<Ingredient> pantryIngredients = [];
  List<Ingredient> essentialIngredients = [];
  List<Ingredient> allIngredients = [];
  List<IngredientCategory> categories = [];
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    currentUserId = widget.userId;
    futureData = Future.wait([
      apiService.fetchIngredients(),
      apiService.fetchCategories(),
    ]);
    futureData.then((data) {
      setState(() {
        allIngredients = (data[0] as List<dynamic>)
            .map((json) => Ingredient.fromJson(json))
            .toList();
      });
      _loadUserPantry();
    });
  }

  void _loadUserPantry() async {
    try {
      // Fetch both pantry and essential data
      final pantry = await apiService.fetchUserPantry(currentUserId);
      final essential = await apiService.fetchEssentialIngredients(
          currentUserId);

      print('Pantry data (raw): ${pantry.map((e) => e.toJson()).toList()}');
      print(
          'Essential data (raw): ${essential.map((e) => e.toJson()).toList()}');

      setState(() {
        pantryIngredients = pantry;
        essentialIngredients = essential;

        // Create sets for quick lookup
        final pantryIngredientIds = pantryIngredients.map((p) => p.id).toSet();
        final essentialIngredientIds = essentialIngredients.map((p) => p.id)
            .toSet();

        // Update allIngredients based on both pantry and essential data
        for (var ingredient in allIngredients) {
          ingredient.isSelected = pantryIngredientIds.contains(ingredient.id);
          ingredient.isEssential =
              essentialIngredientIds.contains(ingredient.id);
          print('Checking ingredient ${ingredient.id} (${ingredient.name}): '
              'isInPantry=${ingredient.isSelected}, '
              'isEssential=${ingredient.isEssential}');
        }

        // Log selected and essential ingredients
        final selectedIngredients = allIngredients.where((
            ingredient) => ingredient.isSelected).toList();
        print('Updated selected ingredients: ${selectedIngredients.map((e) =>
            e.toJson()).toList()}');

        final essentialIngs = allIngredients.where((ingredient) =>
        ingredient.isEssential).toList();
        print('Updated essential ingredients: ${essentialIngs.map((e) =>
            e.toJson()).toList()}');
      });
    } catch (error) {
      print('Error loading pantry and essential ingredients: $error');
    }
  }


  void _toggleIngredient(Ingredient ingredient) async {
    try {
      // Determine if the ingredient is actually in the pantry
      bool isInPantry = pantryIngredients.any((p) => p.id == ingredient.id);

      setState(() {
        // Update the state in both lists
        ingredient.isSelected = !ingredient.isSelected;

        // Find and update the ingredient in allIngredients
        var allIngredientsItem = allIngredients.firstWhere((i) =>
        i.id == ingredient.id);
        allIngredientsItem.isSelected = ingredient.isSelected;
      });

      if (!isInPantry) {
        await apiService.addUserIngredient(ingredient.id, currentUserId);
        print('Ingredient ${ingredient.name} (ID: ${ingredient
            .id}) added to pantry');

        setState(() {
          pantryIngredients.add(ingredient);
        });
      } else {
        await apiService.removeUserIngredient(ingredient.id, currentUserId);
        print('Ingredient ${ingredient.name} (ID: ${ingredient
            .id}) removed from pantry');

        setState(() {
          pantryIngredients.removeWhere((p) => p.id == ingredient.id);
        });
      }

      print(
          'Ingredient toggled successfully. Current pantry size: ${pantryIngredients
              .length}');
    } catch (error) {
      setState(() {
        // Revert the changes in both lists on error
        ingredient.isSelected = !ingredient.isSelected;
        var allIngredientsItem = allIngredients.firstWhere((i) =>
        i.id == ingredient.id);
        allIngredientsItem.isSelected = ingredient.isSelected;
      });
      print('Error toggling ingredient ${ingredient.name} (ID: ${ingredient
          .id}): $error');
    }
  }


  void _markEssential(Ingredient ingredient) async {
    try {
      // Determine if the ingredient is currently marked as essential
      bool isEssential = essentialIngredients.any((p) => p.id == ingredient.id);

      setState(() {
        // Update the state in both lists
        ingredient.isEssential = !ingredient.isEssential;

        // Find and update the ingredient in allIngredients
        var allIngredientsItem = allIngredients.firstWhere((i) =>
        i.id == ingredient.id);
        allIngredientsItem.isEssential = ingredient.isEssential;
      });

      if (!isEssential) {
        await apiService.addEssentialIngredient(ingredient.id, currentUserId);
        print('Ingredient ${ingredient.name} (ID: ${ingredient
            .id}) marked as essential');

        setState(() {
          essentialIngredients.add(ingredient);
        });
      } else {
        await apiService.removeEssentialIngredient(
            ingredient.id, currentUserId);
        print('Ingredient ${ingredient.name} (ID: ${ingredient
            .id}) unmarked as essential');

        setState(() {
          essentialIngredients.removeWhere((p) => p.id == ingredient.id);
        });
      }

      print(
          'Essential status toggled successfully. Current essential ingredients count: ${essentialIngredients
              .length}');
    } catch (error) {
      setState(() {
        // Revert the changes in both lists on error
        ingredient.isEssential = !ingredient.isEssential;
        var allIngredientsItem = allIngredients.firstWhere((i) =>
        i.id == ingredient.id);
        allIngredientsItem.isEssential = ingredient.isEssential;
      });
      print('Error toggling essential status for ingredient ${ingredient
          .name} (ID: ${ingredient.id}): $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              if (categories.isEmpty) {
                categories = (snapshot.data![1] as List<dynamic>)
                    .map((json) => IngredientCategory.fromJson(json))
                    .toList();
              }

              final groupedIngredients = <int, List<Ingredient>>{};
              for (var ingredient in allIngredients) { // Use existing allIngredients
                groupedIngredients.putIfAbsent(ingredient.categoryId, () => [])
                    .add(ingredient);
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Rechercher un ingrédient',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: categories.map((category) {
                        final categoryIngredients = groupedIngredients[category
                            .id] ?? [];
                        final filteredCategoryIngredients = categoryIngredients
                            .where((ingredient) {
                          return ingredient.name.toLowerCase().contains(
                              searchTerm) ||
                              (ingredient.alias.toLowerCase().contains(
                                  searchTerm));
                        }).toList();
                        if (filteredCategoryIngredients.isNotEmpty ||
                            searchTerm.isEmpty) {
                          return IngredientCategoryWidget(
                            category: category,
                            ingredients: filteredCategoryIngredients,
                            onIngredientToggle: (ingredient) {
                              _toggleIngredient(ingredient);
                            },
                            onEssentialToggle: (ingredient) {
                              _markEssential(ingredient);
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          }
      ), floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddIngredientScreen(userId: currentUserId,),
          ),
        );
      },
      child: const Icon(Icons.add),
      tooltip: 'Add Ingredient',
    ),
    );
  }
}