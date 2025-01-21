import 'package:flutter/material.dart';

class RecipeLength extends StatelessWidget {
  final String length;

  const RecipeLength({
    Key? key,
    required this.length,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      length,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}