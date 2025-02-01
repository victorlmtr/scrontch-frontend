import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/country.dart';
import '../models/diet.dart';
import '../models/recipe_type.dart';
import '../models/step.dart';
import '../models/ingredient.dart';

class AddRecipeScreen extends StatefulWidget {
  final int userId;

  const AddRecipeScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  // Form data
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _difficulty = 1;
  double _portions = 1;
  String _notes = '';
  String? _image;
  int? _selectedTypeId;
  List<int> _selectedCountries = [];
  List<int> _selectedDiets = [];
  List<RecipeStep> _steps = [];

  // Data lists
  List<RecipeType> _types = [];
  List<Country> _countries = [];
  List<Diet> _diets = [];
  List<Ingredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchTypes(),
        _apiService.fetchCountries(),
        _apiService.fetchDiets(),
        _apiService.fetchIngredients(),
      ]);

      setState(() {
        _types = results[0] as List<RecipeType>;
        _countries = results[1] as List<Country>;
        _diets = (results[2] as List).cast<Diet>();  // Properly cast the diets
        _ingredients = (results[3] as List).cast<Ingredient>();  // Properly cast the ingredients
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error loading initial data: $e');  // Add debug logging
    }
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create recipe data
      final recipeData = {
        'name': _name,
        'description': _description,
        'difficulty': _difficulty,
        'portions': _portions,
        'notes': _notes,
        'image': _image,
        'typeId': _selectedTypeId,
        'countries': _selectedCountries,
        'recipediets': _selectedDiets.map((id) => {'dietid': id}).toList(),
        'steps': _steps.map((step) => step.toJson()).toList(),
      };

      await _apiService.createRecipe(recipeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette ajoutée avec succès!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Erreur: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une recette'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom de la recette'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _name = value ?? '',
            ),
            // Add other form fields here
            // ...

            ElevatedButton(
              onPressed: _submitRecipe,
              child: const Text('Ajouter la recette'),
            ),
          ],
        ),
      ),
    );
  }
}