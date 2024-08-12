import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:flutter/material.dart';

ColorScheme lightScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color.fromRGBO(191, 231, 237, 1),
    secondary: Color.fromRGBO(12, 77, 86, 1),
    tertiary: Color.fromRGBO(241, 241, 241, 1),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Color.fromRGBO(98, 98, 98, 1),
    onSurface: Colors.black,
    onError: Colors.white,
    surfaceDim: Color.fromRGBO(231, 231, 231, 1),
    onSurfaceVariant: Color.fromRGBO(117, 117, 117, 1));

ColorPallete lightPallete = ColorPallete(
    redAllianceBackground: const Color.fromRGBO(255, 215, 215, 1),
    redAllianceText: const Color.fromRGBO(187, 51, 51, 1),
    blueAllianceBackground: const Color.fromRGBO(221, 245, 255, 1),
    blueAllianceText: const Color.fromRGBO(22, 98, 128, 1),
    greenBackground: const Color.fromARGB(255, 190, 255, 222),
    greenText: const Color.fromARGB(255, 0, 133, 95));

ColorScheme darkScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromRGBO(12, 77, 86, 1),
    secondary: Color.fromRGBO(191, 231, 237, 1),
    tertiary: Color.fromRGBO(32, 32, 32, 1),
    surface: Colors.black,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Color.fromRGBO(241, 241, 241, 1),
    onSurface: Colors.white,
    onError: Colors.white,
    surfaceDim: Color.fromRGBO(55, 55, 55, 1),
    onSurfaceVariant: Color.fromRGBO(189, 189, 189, 1));

ColorPallete darkPallete = ColorPallete(
  redAllianceBackground: const Color.fromRGBO(137, 53, 53, 1),
  redAllianceText: const Color.fromRGBO(255, 215, 215, 1),
  blueAllianceBackground: const Color.fromRGBO(9, 56, 75, 1),
  blueAllianceText: const Color.fromRGBO(221, 245, 255, 1),
  greenBackground: const Color.fromRGBO(0, 51, 0, 1),
  greenText: const Color.fromRGBO(190, 255, 222, 1),
);
