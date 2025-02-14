import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../api/api_service.dart';

class IngredientDetailsDialog extends StatefulWidget {
  final Ingredient ingredient;
  final int userId;
  final Function()? onIngredientUpdated;

  const IngredientDetailsDialog({
    Key? key,
    required this.ingredient,
    required this.userId,
    this.onIngredientUpdated,
  }) : super(key: key);

  @override
  State<IngredientDetailsDialog> createState() => _IngredientDetailsDialogState();
}

class _IngredientDetailsDialogState extends State<IngredientDetailsDialog> {
  final ApiService _apiService = ApiService();
  late bool isSelectedState;
  late bool isEssentialState;

  @override
  void initState() {
    super.initState();
    isSelectedState = widget.ingredient.isSelected;
    isEssentialState = widget.ingredient.isEssential;
  }

  Future<void> _togglePantryStatus(bool value) async {
    try {
      if (value) {
        await _apiService.addUserIngredient(
          widget.ingredient.id,
          widget.userId,
        );
      } else {
        await _apiService.removeUserIngredient(
          widget.ingredient.id,
          widget.userId,
        );
      }
      setState(() {
        isSelectedState = value;
        widget.ingredient.isSelected = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Ajouté au garde-manger' : 'Retiré du garde-manger',
            ),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      }
      widget.onIngredientUpdated?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleEssentialStatus(bool value) async {
    try {
      if (value) {
        await _apiService.addEssentialIngredient(
          widget.ingredient.id,
          widget.userId,
        );
      } else {
        await _apiService.removeEssentialIngredient(
          widget.ingredient.id,
          widget.userId,
        );
      }
      setState(() {
        isEssentialState = value;
        widget.ingredient.isEssential = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Marqué comme essentiel' : 'Retiré des essentiels',
            ),
            backgroundColor: value ? Colors.orange : Colors.grey,
          ),
        );
      }
      widget.onIngredientUpdated?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.ingredient.name,
        style: Theme
            .of(context)
            .textTheme
            .titleLarge,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery
              .of(context)
              .size
              .width * 0.9,
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section
              if (widget.ingredient.image.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery
                          .of(context)
                          .size
                          .width * 0.8,
                      maxHeight: 200,
                    ),
                    child: Image.network(
                      widget.ingredient.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Rest of the content remains the same
              if (widget.ingredient.alias.isNotEmpty) ...[
                Text(
                  'Autres noms :',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.ingredient.alias,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                const SizedBox(height: 16),
              ],

              ListTile(
                leading: Icon(
                  Icons.watch_later_outlined,
                  color: isSelectedState ? Colors.green : Colors.grey,
                ),
                title: Text(
                  'Dans le garde-manger',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                trailing: Switch(
                  value: isSelectedState,
                  onChanged: _togglePantryStatus,
                ),
              ),

              ListTile(
                leading: Icon(
                  Icons.label_important,
                  color: isEssentialState ? Colors.orange : Colors.grey,
                ),
                title: Text(
                  'Ingrédient essentiel',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                trailing: Switch(
                  value: isEssentialState,
                  onChanged: _toggleEssentialStatus,
                ),
              ),

              if (widget.ingredient.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Description :',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.ingredient.description,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}