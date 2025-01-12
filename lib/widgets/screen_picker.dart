import 'package:flutter/material.dart';

class ScreenPicker extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  const ScreenPicker({
    Key? key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TabBar(
        indicatorColor: Theme.of(context).colorScheme.onPrimary,
        tabs: options.map((option) {
          return Tab(
            text: option,
          );
        }).toList(),
        onTap: (index) {
          onOptionSelected(options[index]);
        },
      ),
    );
  }
}