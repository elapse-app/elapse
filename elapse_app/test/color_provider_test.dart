import 'package:elapse_app/providers/color_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('theme preference defaults to the system setting', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final provider = ColorProvider(preferences);

    expect(provider.preference, AppThemePreference.system);
    expect(provider.themeMode, ThemeMode.system);
  });

  test('theme preference is restored and persisted', () async {
    SharedPreferences.setMockInitialValues({'theme': 'dark'});
    final preferences = await SharedPreferences.getInstance();
    final provider = ColorProvider(preferences);

    expect(provider.preference, AppThemePreference.dark);
    expect(provider.themeMode, ThemeMode.dark);

    await provider.setLight();

    expect(provider.preference, AppThemePreference.light);
    expect(provider.themeMode, ThemeMode.light);
    expect(preferences.getString('theme'), 'light');
  });

  test('unknown stored theme values safely fall back to system', () async {
    SharedPreferences.setMockInitialValues({'theme': 'sepia'});
    final preferences = await SharedPreferences.getInstance();
    final provider = ColorProvider(preferences);

    expect(provider.preference, AppThemePreference.system);
    expect(provider.themeMode, ThemeMode.system);

    await provider.setSystem();
    expect(preferences.getString('theme'), 'system');
  });
}
