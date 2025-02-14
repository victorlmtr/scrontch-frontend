import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';
import '../models/country.dart';
import '../models/diet.dart';
import '../models/preparation_method.dart';
import '../models/recipe_type.dart';
import '../models/step.dart';
import '../models/ingredient.dart';
import '../models/step_ingredient.dart';
import '../models/unit.dart';

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
  List<Unit> _units = [];
  List<PreparationMethod> _preparationMethods = [];
  List<RecipeType> _types = [];
  List<Country> _countries = [];
  List<Diet> _diets = [];
  List<Ingredient> _ingredients = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _portionsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _stepTitleController = TextEditingController();
  final TextEditingController _stepInstructionsController = TextEditingController();
  final TextEditingController _stepLengthController = TextEditingController();
  String? _stepImage;
  File? _stepImageFile;
  List<StepIngredient> _currentStepIngredients = [];
  bool _isSearching = false;
  String _searchQuery = '';
  File? _imageFile;
  bool _isUploading = false;
  final FocusNode _searchFocusNode = FocusNode();

  List<Country> get _filteredCountries {
    if (_searchQuery.isEmpty) return [];
    return _countries
        .where((country) =>
        country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .take(10)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _portionsController.text = _portions.toString();
  }

  @override
  void dispose() {
    _stepTitleController.dispose();
    _stepInstructionsController.dispose();
    _stepLengthController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _portionsController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _resetStepState() {
    _stepTitleController.clear();
    _stepInstructionsController.clear();
    _stepLengthController.clear();
    _stepImage = null;
    _stepImageFile = null;
    _currentStepIngredients = [];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);
    try {
      final uri = Uri.parse('https://images.victorl.xyz/upload');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'files',
          _imageFile!.path,
        ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final urls = json.decode(responseData)['urls'] as List;
        setState(() {
          _image = urls[0] as String;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      _showError('Error uploading image: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Add country selection methods
  void _toggleCountrySelection(Country country) {
    setState(() {
      if (_selectedCountries.contains(country.id)) {
        _selectedCountries.remove(country.id);
      } else {
        _selectedCountries.add(country.id);
      }
    });
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pays d\'origine'),
        const SizedBox(height: 8),
        // Selected countries display
        if (_selectedCountries.isNotEmpty)
          Wrap(
            spacing: 8.0,
            children: _selectedCountries.map((countryId) {
              final country = _countries.firstWhere((c) => c.id == countryId);
              return Chip(
                label: Text(country.name),
                onDeleted: () => _toggleCountrySelection(country),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        // Search field
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'Rechercher un pays...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _isSearching = value.isNotEmpty;
            });
          },
          onTap: () {
            setState(() {
              _isSearching = _searchQuery.isNotEmpty;
            });
          },
        ),
        // Dropdown results
        if (_isSearching && _filteredCountries.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  title: Text(country.name),
                  selected: _selectedCountries.contains(country.id),
                  onTap: () {
                    _toggleCountrySelection(country);
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                    _searchFocusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter une étape'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _stepTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre*',
                        hintText: 'Entrez le titre de l\'étape',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _stepInstructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions*',
                        hintText: 'Décrivez les instructions',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _stepLengthController,
                      decoration: const InputDecoration(
                        labelText: 'Durée (minutes)*',
                        hintText: 'Ex: 15',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : () async {
                        await _pickStepImage();
                        setState(() {}); // Refresh dialog UI
                      },
                      icon: const Icon(Icons.image),
                      label: Text(_isUploading ? 'Uploading...' : 'Ajouter une image'),
                    ),
                    if (_stepImage != null) ...[
                      const SizedBox(height: 8),
                      Image.network(
                        _stepImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showAddStepIngredientDialog(),
                      child: const Text('Ajouter des ingrédients'),
                    ),
                    if (_currentStepIngredients.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Ingrédients de l\'étape:'),
                      Column(
                        children: _currentStepIngredients.map((ingredient) {
                          return ListTile(
                            title: Text('${ingredient.quantity} ${ingredient.unit} ${_ingredients.firstWhere((i) => i.id == ingredient.ingredientId).name}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _currentStepIngredients.remove(ingredient);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearStepForm();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_validateStep()) {
                      _saveStep();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickStepImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        await _uploadStepImage();
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _uploadStepImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);
    try {
      final uri = Uri.parse('https://images.victorl.xyz/upload');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'files',
          _imageFile!.path,
        ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final urls = json.decode(responseData)['urls'] as List;
        setState(() {
          _stepImage = urls[0] as String;
        });
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      _showError('Error uploading image: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showAddStepIngredientDialog() {
    int? selectedIngredientId;
    double quantity = 0;
    bool isOptional = false;
    int? selectedUnitId;
    int? selectedPrepMethodId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un ingrédient'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Ingrédient*'),
                      value: selectedIngredientId,
                      items: _ingredients.map((ingredient) {
                        return DropdownMenuItem(
                          value: ingredient.id,
                          child: Text(ingredient.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedIngredientId = value;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Quantité*',
                        hintText: 'Ex: 100',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          quantity = double.tryParse(value) ?? 0;
                        }
                      },
                    ),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Unité*'),
                      value: selectedUnitId,
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit.id,
                          child: Text(unit.unitName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnitId = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Méthode de préparation*'),
                      value: selectedPrepMethodId,
                      items: _preparationMethods.map((method) {
                        return DropdownMenuItem(
                          value: method.id,
                          child: Text(method.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPrepMethodId = value;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Optionnel'),
                      value: isOptional,
                      onChanged: (bool? value) {
                        setState(() {
                          isOptional = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedIngredientId != null &&
                        quantity > 0 &&
                        selectedUnitId != null &&
                        selectedPrepMethodId != null) {
                      final unit = _units.firstWhere((u) => u.id == selectedUnitId);
                      final prepMethod = _preparationMethods.firstWhere((p) => p.id == selectedPrepMethodId);
                      final ingredient = _ingredients.firstWhere((i) => i.id == selectedIngredientId);

                      setState(() {
                        _currentStepIngredients.add(
                          StepIngredient(
                            id: 0, // Will be set by backend
                            ingredientId: selectedIngredientId!,
                            quantity: quantity,
                            isOptional: isOptional,
                            unit: unit,
                            preparationMethod: prepMethod,
                            ingredient: ingredient,
                          ),
                        );
                      });
                      Navigator.of(context).pop();
                    } else {
                      _showError('Veuillez remplir tous les champs obligatoires');
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateStep() {
    if (_stepTitleController.text.isEmpty ||
        _stepInstructionsController.text.isEmpty ||
        _stepLengthController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs obligatoires');
      return false;
    }
    if (int.tryParse(_stepLengthController.text) == null) {
      _showError('La durée doit être un nombre entier');
      return false;
    }
    return true;
  }

  void _saveStep() {
    final newStep = RecipeStep(
      id: 0, // Will be set by the backend
      title: _stepTitleController.text,
      instructions: _stepInstructionsController.text,
      length: int.parse(_stepLengthController.text),
      image: _stepImage,
      stepOrder: _steps.length + 1,
      stepIngredients: _currentStepIngredients,
    );

    setState(() {
      _steps.add(newStep);
      _clearStepForm();
    });
  }

  void _clearStepForm() {
    _stepTitleController.clear();
    _stepInstructionsController.clear();
    _stepLengthController.clear();
    _stepImage = null;
    _currentStepIngredients.clear();
  }

  Widget _buildStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étapes de la recette',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_steps.isEmpty)
          const Text('Aucune étape ajoutée')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Étape ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _steps.removeAt(index);
                                // Update step orders
                                for (var i = 0; i < _steps.length; i++) {
                                  _steps[i] = RecipeStep(
                                    id: _steps[i].id,
                                    title: _steps[i].title,
                                    instructions: _steps[i].instructions,
                                    length: _steps[i].length,
                                    image: _steps[i].image,
                                    stepOrder: i + 1,
                                    stepIngredients: _steps[i].stepIngredients,
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Titre: ${step.title}'),
                      const SizedBox(height: 8),
                      Text('Instructions: ${step.instructions}'),
                      const SizedBox(height: 8),
                      Text('Durée: ${step.length} minutes'),
                      if (step.image != null) ...[
                        const SizedBox(height: 8),
                        Image.network(
                          step.image!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ],
                      if (step.stepIngredients.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Ingrédients:'),
                        Column(
                          children: step.stepIngredients.map((ingredient) {
                            final ingredientName = ingredient.ingredient?.name ??
                                _ingredients.firstWhere((i) => i.id == ingredient.ingredientId).name;
                            return Text(
                              '- ${ingredient.quantity} ${ingredient.unit.unitName} $ingredientName' +
                                  (ingredient.isOptional ? ' (optionnel)' : '') +
                                  ' - ${ingredient.preparationMethod.name}',
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addStep,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une étape'),
        ),
      ],
    );
  }



  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchTypes(),
        _apiService.fetchCountries(),
        _apiService.fetchDiets(),
        _apiService.fetchIngredients(),
        _apiService.fetchUnits(),
        _apiService.fetchPreparationMethods(),
      ]);

      setState(() {
        _types = results[0] as List<RecipeType>;
        _countries = results[1] as List<Country>;
        _diets = (results[2] as List).cast<Diet>();
        _ingredients = (results[3] as List).cast<Ingredient>();
        _units = (results[4] as List).cast<Unit>();  // Add this
        _preparationMethods = (results[5] as List).cast<PreparationMethod>();  // Add this
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error loading initial data: $e');
    }
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
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
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la recette*',
                hintText: 'Entrez le nom de votre recette',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
              onSaved: (value) => _name = value ?? '',
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description*',
                hintText: 'Décrivez votre recette',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
              onSaved: (value) => _description = value ?? '',
            ),
            const SizedBox(height: 16),

            // Difficulty slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Difficulté'),
                Slider(
                  value: _difficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _difficulty.toString(),
                  onChanged: (value) {
                    setState(() {
                      _difficulty = value.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Très facile'),
                    Text('Très difficile'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Portions field
            TextFormField(
              controller: _portionsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de portions*',
                hintText: 'Ex: 4',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de portions';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onSaved: (value) => _portions = double.parse(value ?? '1'),
            ),
            const SizedBox(height: 16),

            // Recipe type dropdown
            DropdownButtonFormField<int>(
              value: _selectedTypeId,
              decoration: const InputDecoration(
                labelText: 'Type de recette*',
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type.id,
                  child: Text(type.typeName),
                );
              }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un type';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedTypeId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildCountrySelector(),
            const SizedBox(height: 16),

            // Diets multi-select
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Régimes alimentaires'),
                Wrap(
                  spacing: 8.0,
                  children: _diets.map((diet) {
                    return FilterChip(
                      label: Text(diet.name),
                      selected: _selectedDiets.contains(diet.id),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDiets.add(diet.id);
                          } else {
                            _selectedDiets.remove(diet.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes additionnelles',
                hintText: 'Ajoutez des notes ou conseils (optionnel)',
              ),
              maxLines: 3,
              onSaved: (value) => _notes = value ?? '',
            ),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 8),
              Image.network(
                _image!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 16),
            _buildStepsList(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _submitRecipe();
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Ajouter la recette',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
