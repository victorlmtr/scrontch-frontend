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
import '../widgets/survey_bottom_bar.dart';
import '../widgets/survey_top_app_bar.dart';

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
    return FutureBuilder<Recipe>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: snapshot.hasData
              ? SurveyTopAppBar(
            stepName: snapshot.data!.name,
            questionIndex: -1,  // Always -1 for recipe overview
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
            if (stepIngredient.ingredient?.image != null &&
                stepIngredient.ingredient!.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  stepIngredient.ingredient!.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 40,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${NumberFormatter.format(stepIngredient.quantity)} '
                                '${FrenchTextHandler.handleUnitName(stepIngredient.unit.unitName, stepIngredient.quantity)} ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: stepIngredient.ingredient != null
                                ? FrenchTextHandler.handlePlural(
                              stepIngredient.ingredient!.name,
                              stepIngredient.quantity,
                            )
                                : 'Loading...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (stepIngredient.isOptional)
                            TextSpan(
                              text: ' (optionnel)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (stepIngredient.preparationMethod.name.isNotEmpty &&
                              stepIngredient.preparationMethod.name != 'undefined')
                            TextSpan(
                              text: ' - ${FrenchTextHandler.handlePreparationMethod(
                                stepIngredient.preparationMethod.name,
                                stepIngredient.ingredient?.isFemale ?? false,
                                stepIngredient.quantity,
                              )}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (stepIngredient.ingredient != null)
                    Icon(
                      stepIngredient.ingredient!.isSelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: stepIngredient.ingredient!.isSelected
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                ],
              ),
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
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery
                  .of(context)
                  .size
                  .height * 0.8,
              maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    ingredient.name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ingredient.image.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.3,
                            ),
                            width: double.infinity,
                            child: Image.network(
                              ingredient.image,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child,
                                  loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ingredient.alias.isNotEmpty) ...[
                                Text(
                                  'Also known as:',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ingredient.alias,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (ingredient.description.isNotEmpty) ...[
                                Text(
                                  'Description:',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ingredient.description,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                OverflowBar(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}