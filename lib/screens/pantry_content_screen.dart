import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../api/api_service.dart';
import '../models/ingredient_category.dart';
import '../widgets/ingredient_category_widget.dart';

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
  List<Ingredient> allIngredients = [];
  List<IngredientCategory> categories = [];
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    currentUserId = widget.userId;

    // Load all ingredients first
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
      // Fetch pantry data
      final pantry = await apiService.fetchUserPantry(currentUserId);
      print('Pantry data (raw): ${pantry.map((e) => e.toJson()).toList()}');

      setState(() {
        pantryIngredients = pantry;

        // Create a set of ingredient IDs from the pantry for quick lookup
        final pantryIngredientIds = pantryIngredients.map((p) => p.id).toSet();

        // Update allIngredients based on pantry data
        for (var ingredient in allIngredients) {
          // Check if the ingredient is in the pantry
          ingredient.isSelected = pantryIngredientIds.contains(ingredient.id);
          print('Checking ingredient ${ingredient.id} (${ingredient.name}): isInPantry=${ingredient.isSelected}');
        }

        // Log only selected ingredients
        final selectedIngredients = allIngredients.where((ingredient) => ingredient.isSelected).toList();
        print('Updated selected ingredients: ${selectedIngredients.map((e) => e.toJson()).toList()}');
      });
    } catch (error) {
      print('Error loading pantry: $error');
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
        var allIngredientsItem = allIngredients.firstWhere((i) => i.id == ingredient.id);
        allIngredientsItem.isSelected = ingredient.isSelected;
      });

      if (!isInPantry) {
        await apiService.addUserIngredient(ingredient.id, currentUserId);
        print('Ingredient ${ingredient.name} (ID: ${ingredient.id}) added to pantry');

        setState(() {
          pantryIngredients.add(ingredient);
        });
      } else {
        await apiService.removeUserIngredient(ingredient.id, currentUserId);
        print('Ingredient ${ingredient.name} (ID: ${ingredient.id}) removed from pantry');

        setState(() {
          pantryIngredients.removeWhere((p) => p.id == ingredient.id);
        });
      }

      print('Ingredient toggled successfully. Current pantry size: ${pantryIngredients.length}');
    } catch (error) {
      setState(() {
        // Revert the changes in both lists on error
        ingredient.isSelected = !ingredient.isSelected;
        var allIngredientsItem = allIngredients.firstWhere((i) => i.id == ingredient.id);
        allIngredientsItem.isSelected = ingredient.isSelected;
      });
      print('Error toggling ingredient ${ingredient.name} (ID: ${ingredient.id}): $error');
    }
  }


  void _markEssential(Ingredient ingredient) async {
    try {
      // Update the local state first
      setState(() {
        ingredient.isEssential = !ingredient.isEssential;
      });

      // Make API call to mark ingredient as essential
      await apiService.markEssentialIngredient(ingredient.id, currentUserId);

      // Log for debugging
      print('Ingredient marked as essential successfully');
    } catch (error) {
      // Rollback state on failure
      setState(() {
        ingredient.isEssential = !ingredient.isEssential;
      });
      print('Error marking essential: $error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
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
            for (var ingredient in allIngredients) {  // Use existing allIngredients
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
        });
  }
}