import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/screens/explore/explore.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/screens/my_team/my_team.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // runApp(MyApp(
  //   prefs: prefs,
  // ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ColorProvider(prefs: prefs),
      child: MyApp(prefs: prefs),
    ),
  );
}

class MyApp extends StatefulWidget {
  final prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  int selectedIndex = 0;

  @override
  List<Widget> screens = [
    HomeScreen(),
    TournamentScreen(),
    MyTeamScreen(),
    ExploreScreen(),
  ];
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      bool systemDefined = false;
      ColorScheme systemTheme =
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? darkScheme
              : lightScheme;
      ;

      if (widget.prefs.getString("theme") == "system") {
        systemDefined = true;
      }

      ColorScheme chosenTheme =
          systemDefined ? systemTheme : colorProvider.colorScheme;
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: chosenTheme,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          fontFamily: "Manrope",
        ),
        home: Scaffold(
          body: screens[selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            indicatorColor: chosenTheme.primary,
            animationDuration: const Duration(milliseconds: 500),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: (value) =>
                setState(() => selectedIndex = value),
            destinations: [
              NavigationDestination(
                  selectedIcon:
                      Icon(Icons.home_rounded, color: chosenTheme.secondary),
                  icon: const Icon(Icons.home_outlined),
                  label: "Home"),
              NavigationDestination(
                selectedIcon: Icon(Icons.emoji_events_rounded,
                    color: chosenTheme.secondary),
                icon: const Icon(Icons.emoji_events_outlined),
                label: "Tournament",
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.people_alt_rounded,
                    color: chosenTheme.secondary),
                icon: const Icon(Icons.people_alt_outlined),
                label: "My Team",
              ),
              NavigationDestination(
                selectedIcon:
                    Icon(Icons.explore_rounded, color: chosenTheme.secondary),
                icon: const Icon(Icons.explore_outlined),
                label: "Explore",
              ),
            ],
          ),
        ),
      );
    });
  }
}
