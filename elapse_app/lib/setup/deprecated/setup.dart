import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/welcome/first_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/deprecated/team_setup.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
      bool systemDefined = false;
      ColorScheme systemTheme =
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? darkScheme
              : lightScheme;

      if (prefs.getString("theme") == "system") {
        systemDefined = true;
      }

      ColorScheme chosenTheme =
          systemDefined ? systemTheme : colorProvider.colorScheme;
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: chosenTheme,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          fontFamily: "Manrope",
        ),
        home: TeamSetupPage(prefs: prefs),
      );
    });
  }
}
