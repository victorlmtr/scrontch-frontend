import 'package:flutter/material.dart';
import 'package:scrontch_flutter/api/ingredient_category.dart';
import '../api/ingredient.dart';

class IngredientCategoryWidget extends StatefulWidget {
  final IngredientCategory category;
  final List<Ingredient> ingredients;
  final ValueChanged<Ingredient> onIngredientToggle;
  final ValueChanged<Ingredient> onEssentialToggle;

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
            subtitle: Text('$selectedCount / $totalCount selected'),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: ingredient.isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface, backgroundColor: ingredient.isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                ingredient.isSelected = !ingredient.isSelected;
              });
              widget.onIngredientToggle(ingredient);
            },
            child: Text(
              ingredient.name,
              textAlign: TextAlign.center,
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
              onPressed: () {
                setState(() {
                  ingredient.isEssential = !ingredient.isEssential;
                });
                widget.onEssentialToggle(ingredient);
              },
            ),
          ),
        ],
      );
    }).toList();
  }
}
