import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  const LongButton(
      {super.key,
      required this.onPressed,
      this.gradient = false,
      required this.text,
      this.icon,
      this.trailingIcon = Icons.arrow_forward,
      this.useForwardArrow = true,
      this.centerAlign = false,
      this.isGray = false});
  final void Function()? onPressed;
  final bool gradient;
  final String text;
  final IconData? icon;
  final IconData trailingIcon;
  final bool useForwardArrow;
  final bool centerAlign;
  final bool isGray;

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
<<<<<<< HEAD
              color: isGray
                  ? Theme.of(context).colorScheme.surfaceDim
                  : Theme.of(context).colorScheme.primary,
=======
              color: isGray ? Theme.of(context).colorScheme.surfaceDim : Theme.of(context).colorScheme.primary,
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
<<<<<<< HEAD
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
=======
            splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  centerAlign ? Spacer() : Container(),
<<<<<<< HEAD
                  if (icon != null)
                    Icon(icon, color: Theme.of(context).colorScheme.secondary),
=======
                  if (icon != null) Icon(icon, color: Theme.of(context).colorScheme.secondary),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                  if (icon != null) const SizedBox(width: 18),
                  Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (useForwardArrow)
                    Icon(
                      trailingIcon,
<<<<<<< HEAD
                      color: isGray
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.secondary,
=======
                      color: isGray ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.secondary,
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
