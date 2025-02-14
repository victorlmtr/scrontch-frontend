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
    final backgroundColor = Theme.of(context).colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTabController(
            length: options.length,
            child: TabBar(
              isScrollable: false,
              indicatorColor: Theme.of(context).colorScheme.onSecondary,
              labelColor: Theme.of(context).colorScheme.onSecondary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSecondary,
              labelStyle: const TextStyle(fontSize: 13),
              tabs: options.map((option) {
                return Tab(
                  text: option,
                  height: 48,
                );
              }).toList(),
              onTap: (index) {
                onOptionSelected(options[index]);
              },
            ),
          ),
          Container(
            height: 8.0,
          ),
        ],
      ),
    );
  }
}