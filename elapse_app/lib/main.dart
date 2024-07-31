import 'dart:convert';

import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/providers/tournament_mode_provider.dart';
import 'package:elapse_app/screens/explore/explore.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/screens/my_team/my_team.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:elapse_app/screens/tournament_mode/home.dart';
import 'package:elapse_app/screens/tournament_mode/tournament.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("savedTeam", '{"teamID": 161877, "teamNumber": "16868C"}');
  prefs.remove("isTournamentMode");

  // Set android system navbar colour
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Navigation bar color
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ColorProvider(prefs: prefs),
        ),
        ChangeNotifierProvider(create: (context) => TournamentModeProvider()),
      ],
      child: MyApp(key: myAppKey, prefs: prefs),
    ),
  );
}

class MyApp extends StatefulWidget {
  final prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  int selectedIndex = 0;
  bool isTournamentMode = false;
  late int teamID;

  void initState() {
    super.initState();
    teamID = jsonDecode(widget.prefs.getString("savedTeam"))["teamID"];
    initializeTournamentMode();
  }

  Future<Tournament>? tmTournament;

  void initializeTournamentMode() {
    if (widget.prefs.getBool("isTournamentMode") ?? false) {
      int? tournamentID = widget.prefs.getInt("tournamentID");
      if (tournamentID != null) {
        tmTournament = getTournamentDetails(52543);
        isTournamentMode = true;
      }
    }
  }

  void reloadApp() {
    setState(() {
      initializeTournamentMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    TeamPreview savedTeam = TeamPreview(
        teamNumber:
            jsonDecode(widget.prefs.getString("savedTeam"))["teamNumber"],
        teamID: jsonDecode(widget.prefs.getString("savedTeam"))["teamID"]);
    List<Widget> screens;
    isTournamentMode
        ? screens = [
            TMHomePage(
              tournament: tmTournament,
              teamID: teamID,
            ),
            TMTournamentScreen(
                tournamentID: widget.prefs.getInt("tournamentID"),
                isPreview: false,
                tournamentFuture: tmTournament),
            MyTeams(prefs: widget.prefs),
            ExploreScreen(prefs: widget.prefs)
          ]
        : screens = [
            HomeScreen(
              teamID: savedTeam.teamID,
              prefs: widget.prefs,
            ),
            MyTeams(
              prefs: widget.prefs,
            ),
            ExploreScreen(prefs: widget.prefs),
          ];
    widget.prefs.setString("theme", "system");
    return Consumer2<ColorProvider, TournamentModeProvider>(
      builder: (context, colorProvider, tournamentModeProvider, child) {
        bool systemDefined = false;
        ColorScheme systemTheme =
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? darkScheme
                : lightScheme;

        if (widget.prefs.getString("theme") == "system") {
          systemDefined = true;
        }

        ColorScheme chosenTheme =
            systemDefined ? systemTheme : colorProvider.colorScheme;

        // Build the list of destinations dynamically
        List<NavigationDestination> destinations = [
          NavigationDestination(
              selectedIcon:
                  Icon(Icons.home_rounded, color: chosenTheme.secondary),
              icon: const Icon(Icons.home_outlined),
              label: "Home"),
          NavigationDestination(
            selectedIcon:
                Icon(Icons.people_alt_rounded, color: chosenTheme.secondary),
            icon: const Icon(Icons.people_alt_outlined),
            label: "My Team",
          ),
          NavigationDestination(
            selectedIcon:
                Icon(Icons.explore_rounded, color: chosenTheme.secondary),
            icon: const Icon(Icons.explore_outlined),
            label: "Explore",
          ),
        ];

        // Add the tournament destination if tournament mode is enabled
        if (isTournamentMode) {
          destinations.insert(
            1, // Add it to the second position
            NavigationDestination(
              selectedIcon: Icon(Icons.emoji_events_rounded,
                  color: chosenTheme.secondary),
              icon: const Icon(Icons.emoji_events_outlined),
              label: "Tournament",
            ),
          );
        }

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
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
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: (value) =>
                  setState(() => selectedIndex = value),
              destinations: destinations,
            ),
          ),
        );
      },
    );
  }
}
