import 'package:flutter/material.dart';

class BigErrorMessage extends StatelessWidget {
  const BigErrorMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Icon(
          icon,
          size: 128,
          weight: 0.1,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        SizedBox(
          height: 25,
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
