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
<<<<<<< HEAD
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
=======
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
        ),
        SizedBox(
          height: textPadding,
        ),
        Text(
          message,
          style: TextStyle(
<<<<<<< HEAD
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
=======
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
          ),
        ),
      ],
    );
  }
}
