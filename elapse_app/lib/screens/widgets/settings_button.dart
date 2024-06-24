import 'package:elapse_app/screens/settings/settings.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.account_circle_rounded,
        weight: 0.1,
      ),
      iconSize: 30,
      color: Theme.of(context).colorScheme.onSurface,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
      },
    );
  }
}
