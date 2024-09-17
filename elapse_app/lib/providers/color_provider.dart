import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

class ColorProvider extends ChangeNotifier {
  ColorProvider() {
    getScheme();
  }
  ColorScheme get colorScheme => _colorScheme;
  ColorScheme _colorScheme = lightScheme;
  ColorPallete alliancePallete = lightPallete;

  void setDark() {
    _colorScheme = darkScheme;
    alliancePallete = darkPallete;
    prefs.setString("theme", "dark");
    notifyListeners();
  }

  void setLight() {
    _colorScheme = lightScheme;
    alliancePallete = lightPallete;
    prefs.setString("theme", "light");
    notifyListeners();
  }

  void setSystem() {
    prefs.setString("theme", "system");
    notifyListeners();
  }

  void getScheme() {
    String? theme = prefs.getString("theme");
    switch (theme) {
      case "dark":
        _colorScheme = darkScheme;
        alliancePallete = darkPallete;
        break;
      case "light":
        _colorScheme = lightScheme;
        alliancePallete = lightPallete;
        break;

      default:
        _colorScheme = lightScheme;
        alliancePallete = lightPallete;
    }
    notifyListeners();
  }
}
