import 'package:flutter/material.dart';

class GradientLongButton extends StatelessWidget {
  const GradientLongButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
