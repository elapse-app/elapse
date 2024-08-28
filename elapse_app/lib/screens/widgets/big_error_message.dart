import 'package:flutter/material.dart';

class BigErrorMessage extends StatelessWidget {
  const BigErrorMessage({
    super.key,
    required this.icon,
    required this.message,
    this.topPadding = 50,
    this.textPadding = 25,
  });

  final IconData icon;
  final String message;
  final double topPadding;
  final double textPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: topPadding,
        ),
        Icon(
          icon,
          size: 128,
          weight: 0.1,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        SizedBox(
          height: textPadding,
        ),
        Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}
