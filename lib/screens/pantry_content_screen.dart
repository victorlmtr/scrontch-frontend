import 'package:flutter/material.dart';
import '../api/ingredient.dart';
import '../api/ingredient_category.dart';
import '../api/api_service.dart';
import '../widgets/ingredient_category_widget.dart';

class PantryContentScreen extends StatefulWidget {
  @override
  _PantryContentScreenState createState() => _PantryContentScreenState();
}

class _PantryContentScreenState extends State<PantryContentScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureData;
  List<Ingredient> allIngredients = []; // Store all ingredients
  List<IngredientCategory> categories = []; // Store categories
  String searchTerm = ''; // Store the search term
  bool isAdding = false; // Track if the form is open
  Ingredient newIngredient = Ingredient(
    id: 0,
    name: '',
    alias: '',
    image: '',
    description: '',
    categoryId: 0,
  ); // New ingredient data

  @override
  void initState() {
    super.initState();
    futureData = Future.wait([
      apiService.fetchIngredients(),
      apiService.fetchCategories(),
    ]);
  }
  void _toggleAddIngredient() {
    setState(() {
      isAdding = !isAdding;
      if (!isAdding) {
        // Reset the new ingredient data when closing the form
        newIngredient = Ingredient(
          id: 0,
          name: '',
          alias: '',
          image: '',
          description: '',
          categoryId: 0,
        );
      }
    });
  }

  void _handleFormSubmit() {
    // Handle the form submission logic here
    // For example, you can call an API to save the new ingredient
    print('New Ingredient: ${newIngredient.name}, ${newIngredient.alias}, ${newIngredient.image}, ${newIngredient.description}, ${newIngredient.categoryId}');
    // After saving, you might want to close the form
    _toggleAddIngredient();
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
          final ingredients = (snapshot.data![0] as List<dynamic>)
              .map((json) => Ingredient.fromJson(json))
              .toList();
          categories = (snapshot.data![1] as List<dynamic>)
              .map((json) => IngredientCategory.fromJson(json))
              .toList();

          // Store all ingredients for filtering
          allIngredients = ingredients;

          // Group ingredients by category ID
          final groupedIngredients = <int, List<Ingredient>>{};
          for (var ingredient in ingredients) {
            groupedIngredients.putIfAbsent(ingredient.categoryId, () => []).add(ingredient);
          }

          // Display all categories, even if they have no ingredients
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
                  decoration: InputDecoration(
                    labelText: 'Rechercher un ingrédient',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _toggleAddIngredient,
                child: Text('Ajouter un ingrédient'),
              ),
              if (isAdding) _buildAddIngredientForm(),
              Expanded(
                child: ListView(
                  children: categories.map((category) {
                    final categoryIngredients = groupedIngredients[category.id] ?? [];
                    // Filter category ingredients based on the search term
                    final filteredCategoryIngredients = categoryIngredients.where((ingredient) {
                      return ingredient.name.toLowerCase().contains(searchTerm) ||
                          (ingredient.alias != null &&
                              ingredient.alias!.toLowerCase().contains(searchTerm));
                    }).toList();
                    // Only display the category if it has matching ingredients or if search is empty
                    if (filteredCategoryIngredients.isNotEmpty || searchTerm.isEmpty) {
                      return IngredientCategoryWidget(
                        category: category,
                        ingredients: filteredCategoryIngredients,
                        onIngredientToggle: (ingredient) {
                          print('${ingredient.name} toggled: ${ingredient.isSelected}');
                        },
                        onEssentialToggle: (ingredient) {
                          print('${ingredient.name} is now essential: ${ingredient.isEssential}');
                        },
                      );
                    } else {
                      return SizedBox.shrink(); // Return an empty widget if no ingredients match
                    }
                  }).toList(),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildAddIngredientForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Name'),
            onChanged: (value) {
              setState(() {
                newIngredient.name = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Alias'),
            onChanged: (value) {
              setState(() {
                newIngredient.alias = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Image URL'),
            onChanged: (value) {
              setState(() {
                newIngredient.image = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Description'),
            onChanged: (value) {
              setState(() {
                newIngredient.description = value;
              });
            },
          ),
          DropdownButton<int>(
            value: newIngredient.categoryId == 0 ? null : newIngredient.categoryId, // Set to null if 0
            hint: Text('Select Category'),
            onChanged: (int? newValue) {
              setState(() {
                newIngredient.categoryId = newValue!;
              });
            },
            items: categories.map((category) {
              return DropdownMenuItem<int>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
          ),
          Row(
            children: [
              Checkbox(
                value: newIngredient.isEssential,
                onChanged: (bool? value) {
                  setState(() {
                    newIngredient.isEssential = value!;
                  });
                },
              ),
              Text('Is Female?'),
            ],
          ),
          ElevatedButton(
            onPressed: _handleFormSubmit,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}