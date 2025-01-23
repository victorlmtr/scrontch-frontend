import 'package:flutter/material.dart';

class SurveyTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String stepName;
  final int questionIndex;
  final int totalQuestionsCount;
  final VoidCallback onClosePressed;

  const SurveyTopAppBar({
    Key? key,
    required this.stepName,
    required this.questionIndex,
    required this.totalQuestionsCount,
    required this.onClosePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = (questionIndex + 1) / totalQuestionsCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${questionIndex + 1}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    ' / $totalQuestionsCount',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: onClosePressed,
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}