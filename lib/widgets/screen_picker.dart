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

    return Column(
      children: [

        Container(
          height: 11.0,
          color: backgroundColor,
        ),

        Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
          ),
          child: DefaultTabController(
            length: options.length,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Theme.of(context).colorScheme.onSecondary,
                  labelColor: Theme.of(context).colorScheme.onSecondary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSecondary,
                  tabs: options.map((option) {
                    return Tab(
                      text: option,
                    );
                  }).toList(),
                  onTap: (index) {
                    onOptionSelected(options[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
