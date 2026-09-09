import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  static AppThemePreference fromStorage(String? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class ColorProvider extends ChangeNotifier {
  ColorProvider(this._preferences)
      : _preference = AppThemePreference.fromStorage(
          _preferences.getString(_themeKey),
        );

  static const _themeKey = 'theme';

  final SharedPreferences _preferences;
  AppThemePreference _preference;

  AppThemePreference get preference => _preference;

  String get storageValue => _preference.name;

  ThemeMode get themeMode => switch (_preference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };

  // Kept for older consumers while they migrate to Theme.of(context).
  ColorScheme get colorScheme =>
      _preference == AppThemePreference.dark ? darkScheme : lightScheme;

  ColorPallete get alliancePallete =>
      _preference == AppThemePreference.dark ? darkPallete : lightPallete;

  Future<void> setDark() => _setPreference(AppThemePreference.dark);

  Future<void> setLight() => _setPreference(AppThemePreference.light);

  Future<void> setSystem() => _setPreference(AppThemePreference.system);

  Future<void> _setPreference(AppThemePreference preference) async {
    if (_preference == preference) {
      if (_preferences.getString(_themeKey) != preference.name) {
        await _preferences.setString(_themeKey, preference.name);
      }
      return;
    }

    _preference = preference;
    notifyListeners();
    await _preferences.setString(_themeKey, preference.name);
  }
}
