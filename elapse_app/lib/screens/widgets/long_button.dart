import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  const LongButton(
      {super.key,
      required this.onPressed,
      this.gradient = false,
      required this.text,
      this.icon,
      this.trailingIcon = Icons.arrow_forward});
  final void Function()? onPressed;
  final bool gradient;
  final String text;
  final IconData? icon;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: gradient
                ? RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.primary,
                    ],
                    radius: 8,
                  )
                : null,
            border: Border.all(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        // Material with InkWell to handle splash and interactions
        Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(30),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  if (icon != null)
                    Icon(icon, color: Theme.of(context).colorScheme.secondary),
                  if (icon != null) const SizedBox(width: 18),
                  Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    trailingIcon,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
