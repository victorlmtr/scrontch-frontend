import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/ingredient_category.dart';

class IngredientCategoryWidget extends StatefulWidget {
  final IngredientCategory category;
  final List<Ingredient> ingredients;
  final void Function(Ingredient ingredient) onIngredientToggle;
  final void Function(Ingredient ingredient) onEssentialToggle;

  const IngredientCategoryWidget({
    Key? key,
    required this.category,
    required this.ingredients,
    required this.onIngredientToggle,
    required this.onEssentialToggle,
  }) : super(key: key);

  @override
  _IngredientCategoryWidgetState createState() =>
      _IngredientCategoryWidgetState();
}

class _IngredientCategoryWidgetState extends State<IngredientCategoryWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        widget.ingredients.where((i) => i.isSelected).length;
    final totalCount = widget.ingredients.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: widget.category.icon != null
                ? Image.network(
              widget.category.icon,
              width: 36,
              height: 36,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 36),
            )
                : const Icon(Icons.category, size: 36),
            title: Text(
              widget.category.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$selectedCount / $totalCount'),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          const Divider(),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _buildIngredientButtons(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIngredientButtons() {
    final ingredientsToShow =
    isExpanded ? widget.ingredients : widget.ingredients.take(8).toList();

    return ingredientsToShow.map((ingredient) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onLongPress: () => _showIngredientDetails(ingredient),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: ingredient.isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                backgroundColor: ingredient.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () async {
                final previousState = ingredient.isSelected;
                setState(() {
                  ingredient.isSelected = !ingredient.isSelected;
                });
                try {
                  widget.onIngredientToggle(ingredient);
                } catch (error) {
                  setState(() {
                    ingredient.isSelected = previousState;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to toggle ingredient: $error')),
                  );
                }
              },
              child: Text(
                ingredient.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Prevents overflow
                maxLines: 1,
              ),
            ),
          ),
          Positioned(
            top: -16,
            right: -16,
            child: IconButton(
              icon: Icon(
                ingredient.isEssential ? Icons.star_rounded : Icons.star_border_outlined,
                color: ingredient.isEssential ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceDim,
              ),
              onPressed: () async {
                final previousState = ingredient.isEssential;
                setState(() {
                  ingredient.isEssential = !ingredient.isEssential;
                });
                try {
                  widget.onEssentialToggle(ingredient);
                } catch (error) {
                  setState(() {
                    ingredient.isEssential = previousState; // Rollback on error
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to mark essential: $error')),
                  );
                }
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  void _showIngredientDetails(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ingredient.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (ingredient.alias.isNotEmpty)
                  Text(ingredient.alias),
                if (ingredient.image.isNotEmpty)
                  Image.network(ingredient.image),
                if (ingredient.description.isNotEmpty)
                  Text(ingredient.description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}