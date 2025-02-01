import 'package:flutter/material.dart';
import 'package:scrontch_flutter/screens/step_detail_screen.dart';
import '../api/api_service.dart';
import '../api/recipe_service.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/step_ingredient.dart';
import '../models/step.dart';
import '../utils/french_text_handler.dart';
import '../utils/number_formatter.dart';
import '../widgets/ingredient_details_dialog.dart';
import '../widgets/survey_bottom_bar.dart';
import '../widgets/survey_top_app_bar.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final int userId;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
    required this.userId,
  }) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Recipe> _recipeFuture;
  final RecipeService _recipeService = RecipeService(ApiService());
  final ApiService _apiService = ApiService();
  List<Ingredient> pantryIngredients = [];
  List<Ingredient> essentialIngredients = [];

  @override
  void initState() {
    super.initState();
    _recipeFuture = _loadRecipeAndPantryData();
  }

  Future<Recipe> _loadRecipeAndPantryData() async {
    try {
      // Load recipe and pantry data in parallel
      final results = await Future.wait([
        _recipeService.getRecipeById(widget.recipeId),
        _apiService.fetchUserPantry(widget.userId),
        _apiService.fetchEssentialIngredients(widget.userId),
      ]);

      final recipe = results[0] as Recipe;
      pantryIngredients = results[1] as List<Ingredient>;
      essentialIngredients = results[2] as List<Ingredient>;

      // Create sets for quick lookup
      final pantryIngredientIds = pantryIngredients.map((p) => p.id).toSet();
      final essentialIngredientIds = essentialIngredients.map((p) => p.id).toSet();

      // Update ingredient status in the recipe
      for (var step in recipe.recipeSteps) {
        for (var stepIngredient in step.stepIngredients) {
          if (stepIngredient.ingredient != null) {
            stepIngredient.ingredient!.isSelected =
                pantryIngredientIds.contains(stepIngredient.ingredient!.id);
            stepIngredient.ingredient!.isEssential =
                essentialIngredientIds.contains(stepIngredient.ingredient!.id);
          }
        }
      }

      return recipe;
    } catch (e) {
      print('Error loading recipe and pantry data: $e');
      rethrow;
    }
  }

  Future<void> _refreshRecipe() async {
    setState(() {
      _recipeFuture = _loadRecipeAndPantryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: snapshot.hasData
              ? SurveyTopAppBar(
            stepName: snapshot.data!.name,
            questionIndex: -1,
            totalQuestionsCount: snapshot.data!.recipeSteps.length,
            onClosePressed: () => Navigator.of(context).pop(),
          )
              : AppBar(title: const Text('Détails de la recette')),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              final recipe = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.image != null && recipe.image!.isNotEmpty)
                      Image.network(
                        recipe.image!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(recipe.description),
                          const SizedBox(height: 16),
                          _buildRecipeInfo(recipe),
                          const SizedBox(height: 24),
                          _buildStepsList(recipe.recipeSteps),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: snapshot.hasData
              ? SurveyBottomBar(
            shouldShowPreviousButton: false,
            shouldShowDoneButton: false,
            isNextButtonEnabled: true,
            onPreviousPressed: () {},
            onNextPressed: () => _navigateToStep(snapshot.data!, 0),
            onDonePressed: () {},
          )
              : null,
        );
      },
    );
  }

  void _navigateToStep(Recipe recipe, int stepIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StepDetailsScreen(
          recipe: recipe,
          initialStep: stepIndex,
        ),
      ),
    );
  }


  Widget _buildRecipeInfo(Recipe recipe) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Difficulty: ${recipe.difficulty}/5'),
            Text('Portions: ${recipe.portions}'),
            Text('Total Time: ${recipe.formattedTotalTime}'),
            if (recipe.notes != null && recipe.notes!.isNotEmpty)
              Text('Notes: ${recipe.notes}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList(List<RecipeStep> recipeSteps) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipeSteps.length,
      itemBuilder: (context, index) {
        final recipeStep = recipeSteps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipeStep.image != null && recipeStep.image!.isNotEmpty)
                Image.network(
                  recipeStep.image!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${index + 1}: ${recipeStep.title}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(recipeStep.instructions),
                    const SizedBox(height: 16),
                    _buildStepIngredients(recipeStep.stepIngredients),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIngredients(List<StepIngredient> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients:',
          style: Theme
              .of(context)
              .textTheme
              .titleSmall,
        ),
        const SizedBox(height: 8),
        ...ingredients.map((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(StepIngredient stepIngredient) {
    final ingredientName = stepIngredient.ingredient?.name ?? 'Loading...';
    final startsWithVowel = 'aeiouAEIOU'.contains(ingredientName[0]);
    final useUnits = stepIngredient.unit.unitName != "unité(s)";

    return GestureDetector(
      onLongPress: () {
        if (stepIngredient.ingredient != null) {
          _showIngredientDetails(stepIngredient.ingredient!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    // Quantity
                    TextSpan(
                      text: NumberFormatter.format(stepIngredient.quantity),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Space
                    const TextSpan(text: ' '),
                    // Unit and "de/d'" if needed
                    if (useUnits) ...[
                      TextSpan(
                        text: '${stepIngredient.unit.unitName} ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: startsWithVowel ? 'd\'' : 'de ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    // Ingredient name
                    TextSpan(
                      text: ingredientName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Preparation method
                    if (stepIngredient.preparationMethod.name.isNotEmpty &&
                        stepIngredient.preparationMethod.name != 'undefined')
                      TextSpan(
                        text: ', ${stepIngredient.preparationMethod.name}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    // Optional indicator
                    if (stepIngredient.isOptional)
                      TextSpan(
                        text: ' (optionnel)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Pantry status indicator
            if (stepIngredient.ingredient != null)
              stepIngredient.ingredient!.isSelected
                  ? const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              )
                  : IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  try {
                    await _apiService.addUserIngredient(
                      stepIngredient.ingredient!.id,
                      widget.userId,
                    );

                    // Refresh the recipe data to update all instances of this ingredient
                    await _refreshRecipe();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingrédient ajouté au garde-manger'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ajout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showIngredientDetails(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IngredientDetailsDialog(
          ingredient: ingredient,
          userId: widget.userId,
          onIngredientUpdated: () {
            _refreshRecipe();
          },
        );
      },
    );
  }
}