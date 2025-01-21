import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/recipe_service.dart';
import '../models/recipe.dart';
import '../models/step_ingredient.dart';
import '../models/step.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Recipe> _recipeFuture;
  final RecipeService _recipeService = RecipeService(ApiService());

  @override
  void initState() {
    super.initState();
    _recipeFuture = _recipeService.getRecipeById(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
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
                    recipe.image!,  // Use ! since we've checked it's not null
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
                  recipeStep.image!,  // Use ! since we've checked it's not null
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
                      style: Theme.of(context).textTheme.titleMedium,
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
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...ingredients.map((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(StepIngredient stepIngredient) {
    final ingredient = stepIngredient.ingredient;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (ingredient?.image != null && ingredient!.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                ingredient.image,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${stepIngredient.quantity} ${stepIngredient.unit.unitName} '
                  '${ingredient?.name ?? stepIngredient.ingredientName}'
                  '${stepIngredient.isOptional ? ' (optional)' : ''}'
                  '${stepIngredient.preparationMethod.name.isNotEmpty ? ' - ${stepIngredient.preparationMethod.name}' : ''}',
            ),
          ),
        ],
      ),
    );
  }
}