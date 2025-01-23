import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/step.dart';
import '../models/step_ingredient.dart';
import '../utils/french_text_handler.dart';
import '../utils/number_formatter.dart';
import '../widgets/survey_bottom_bar.dart';
import '../widgets/survey_top_app_bar.dart';

class StepDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  final int initialStep; // -1 for global view, 0+ for specific steps

  const StepDetailsScreen({
    Key? key,
    required this.recipe,
    this.initialStep = -1,
  }) : super(key: key);

  @override
  _StepDetailsScreenState createState() => _StepDetailsScreenState();
}

class _StepDetailsScreenState extends State<StepDetailsScreen> {
  late int _currentStepIndex;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = widget.initialStep;
  }

  void _goToNextStep() {
    setState(() {
      if (_currentStepIndex < widget.recipe.recipeSteps.length - 1) {
        _currentStepIndex++;
      }
    });
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStepIndex > -1) {
        _currentStepIndex--;
      }
    });
  }

  void _goToGlobalView() {
    setState(() {
      _currentStepIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentStepIndex == -1
          ? AppBar(
        title: Text(widget.recipe.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      )
          : SurveyTopAppBar(
        stepName: widget.recipe.recipeSteps[_currentStepIndex].title,
        questionIndex: _currentStepIndex,
        totalQuestionsCount: widget.recipe.recipeSteps.length,
        onClosePressed: _goToGlobalView,
      ),
      body: _currentStepIndex == -1
          ? _buildGlobalView()
          : _buildStepView(widget.recipe.recipeSteps[_currentStepIndex]),
      bottomNavigationBar: SurveyBottomBar(
        shouldShowPreviousButton: _currentStepIndex >= 0,
        shouldShowDoneButton: _currentStepIndex == widget.recipe.recipeSteps.length - 1,
        isNextButtonEnabled: true,
        onPreviousPressed: _goToPreviousStep,
        onNextPressed: _goToNextStep,
        onDonePressed: _goToGlobalView,
      ),
    );
  }

  Widget _buildGlobalView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.recipe.image != null && widget.recipe.image!.isNotEmpty)
            Image.network(
              widget.recipe.image!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeInfo(),
                const SizedBox(height: 24),
                _buildAllIngredients(),
                const SizedBox(height: 24),
                _buildStepsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Difficulté: ${widget.recipe.difficulty}/5'),
            Text('Portions: ${widget.recipe.portions}'),
            Text('Temps total: ${widget.recipe.formattedTotalTime}'),
            if (widget.recipe.notes != null && widget.recipe.notes!.isNotEmpty)
              Text('Notes: ${widget.recipe.notes}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAllIngredients() {
    // Gather all ingredients across all steps
    final allIngredients = <StepIngredient>{};
    for (var step in widget.recipe.recipeSteps) {
      allIngredients.addAll(step.stepIngredients);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des ingrédients',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...allIngredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildIngredientItem(ingredient),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étapes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.recipe.recipeSteps.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(widget.recipe.recipeSteps[index].title),
                onTap: () {
                  setState(() {
                    _currentStepIndex = index;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepView(RecipeStep step) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step.image != null && step.image!.isNotEmpty)
            Image.network(
              step.image!,
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
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(step.instructions),
                const SizedBox(height: 24),
                Text(
                  'Ingrédients nécessaires',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...step.stepIngredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildIngredientItem(ingredient),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(StepIngredient stepIngredient) {
    return Row(
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
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${NumberFormatter.format(stepIngredient.quantity)} '
                      '${FrenchTextHandler.handleUnitName(stepIngredient.unit.unitName, stepIngredient.quantity)} ',
                ),
                TextSpan(
                  text: stepIngredient.ingredient != null
                      ? FrenchTextHandler.handlePlural(
                    stepIngredient.ingredient!.name,
                    stepIngredient.quantity,
                  )
                      : 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (stepIngredient.isOptional)
                  const TextSpan(
                    text: ' (optionnel)',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                if (stepIngredient.preparationMethod.name.isNotEmpty &&
                    stepIngredient.preparationMethod.name != 'undefined')
                  TextSpan(
                    text: ' - ${FrenchTextHandler.handlePreparationMethod(
                      stepIngredient.preparationMethod.name,
                      stepIngredient.ingredient?.isFemale ?? false,
                      stepIngredient.quantity,
                    )}',
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
    );
  }
}