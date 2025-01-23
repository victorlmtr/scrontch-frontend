import 'package:flutter/material.dart';

class SurveyBottomBar extends StatelessWidget {
  final bool shouldShowPreviousButton;
  final bool shouldShowDoneButton;
  final bool isNextButtonEnabled;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onDonePressed;

  const SurveyBottomBar({
    Key? key,
    required this.shouldShowPreviousButton,
    required this.shouldShowDoneButton,
    required this.isNextButtonEnabled,
    required this.onPreviousPressed,
    required this.onNextPressed,
    required this.onDonePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            if (shouldShowPreviousButton) ...[
              OutlinedButton(
                onPressed: onPreviousPressed,
                child: const Text('Précédent'),
              ),
              const SizedBox(width: 16.0),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: shouldShowDoneButton ? onDonePressed : onNextPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: shouldShowDoneButton ? null : Theme.of(context).colorScheme.onPrimary, backgroundColor: shouldShowDoneButton ? null : Theme.of(context).colorScheme.primary,
                ),
                child: Text(shouldShowDoneButton ? 'Terminé' : 'Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}