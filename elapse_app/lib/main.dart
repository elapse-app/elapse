import 'dart:convert';

import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/extras/auth.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/providers/tournament_mode_provider.dart';
import 'package:elapse_app/screens/error/error_page.dart';
import 'package:elapse_app/screens/explore/explore.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/screens/my_team/my_team.dart';
import 'package:elapse_app/screens/scout/cloud_scout.dart';
import 'package:elapse_app/screens/tournament_mode/home.dart';
import 'package:elapse_app/screens/tournament_mode/my_teams.dart';
import 'package:elapse_app/screens/tournament_mode/tournament.dart';
import 'package:elapse_app/setup/welcome/first_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();
late SharedPreferences prefs;
late PackageInfo appInfo;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  prefs = await SharedPreferences.getInstance();

  // Set android system navbar colour
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Navigation bar color
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if ((prefs.getBool("isSetUp") ?? false) &&
      FirebaseAuth.instance.currentUser != null) {
    print(FirebaseAuth.instance.currentUser);
    await checkAccountDeleted();
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorPage();
  };
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ColorProvider(),
        ),
        ChangeNotifierProvider(create: (context) => TournamentModeProvider()),
      ],
      child: MyApp(key: myAppKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  int selectedIndex = 0;
  bool isTournamentMode = false;
  bool isLoggedIn = false;
  late int teamID;
  late String teamNumber;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    if (prefs.getBool("isSetUp") ?? false) {
      teamID = jsonDecode(prefs.getString("savedTeam")!)["teamID"];
      teamNumber = jsonDecode(prefs.getString("savedTeam")!)["teamNumber"];
      initializeTournamentMode();
    }
  }

  void initializeTournamentMode() {
    if (prefs.getBool("isTournamentMode") ?? false) {
      int? tournamentID = prefs.getInt("tournamentID");
      teamID = jsonDecode(prefs.getString("savedTeam")!)["teamID"];
      teamNumber = jsonDecode(prefs.getString("savedTeam")!)["teamNumber"];
      if (tournamentID != null) {
        isTournamentMode = true;
      }
    } else {
      isTournamentMode = false;
      prefs.setStringList("picklist", []);
    }
  }

  void reloadApp() {
    setState(() {
      initializeTournamentMode();
    });
  }

  void _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    appInfo = info;
  }

  @override
  Widget build(BuildContext context) {
    if (!(prefs.getBool("isSetUp") ?? false)) {
      return Consumer<ColorProvider>(
        builder: (context, value, child) {
          prefs.setString("theme", "system");
          ColorScheme systemTheme =
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? darkScheme
                  : lightScheme;

          ColorScheme chosenTheme = systemTheme;

          return MaterialApp(
            home: const FirstSetupPage(),
            theme: ThemeData(
              colorScheme: chosenTheme,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              fontFamily: "Manrope",
            ),
          );
        },
      );
    }
    TeamPreview savedTeam = TeamPreview(
        teamNumber: jsonDecode(prefs.getString("savedTeam")!)["teamNumber"],
        teamID: jsonDecode(prefs.getString("savedTeam")!)["teamID"]);
    List<Widget> screens;

    isTournamentMode
        ? screens = [
            TMHomePage(
              tournamentID: prefs.getInt("tournamentID") ?? 0,
              teamID: teamID,
              teamNumber: teamNumber,
            ),
            TMTournamentScreen(
              tournamentID: prefs.getInt("tournamentID") ?? 0,
              isPreview: false,
            ),
            CloudScoutScreen(),
            TMMyTeams(
              tournamentID: prefs.getInt("tournamentID") ?? 0,
            ),
            ExploreScreen()
          ]
        : screens = [
            HomeScreen(
              key: PageStorageKey<String>("home"),
            ),
            CloudScoutScreen(),
            MyTeams(
              key: PageStorageKey<String>("my-teams"),
            ),
            ExploreScreen(
              key: PageStorageKey<String>("explore"),
            ),
          ];
    return Consumer2<ColorProvider, TournamentModeProvider>(
      builder: (context, colorProvider, tournamentModeProvider, child) {
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

        // Build the list of destinations dynamically
        List<NavigationDestination> destinations = [
          NavigationDestination(
              selectedIcon:
                  Icon(Icons.home_rounded, color: chosenTheme.secondary),
              icon: const Icon(Icons.home_outlined),
              label: "Home"),
          NavigationDestination(
              selectedIcon:
                  Icon(Icons.bubble_chart, color: chosenTheme.secondary),
              icon: const Icon(Icons.bubble_chart_outlined),
              label: "Scout"),
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

        final PageStorageBucket _bucket = PageStorageBucket();

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
          title: 'Elapse',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: chosenTheme,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            fontFamily: "Manrope",
          ),
          home: Scaffold(
            body: PageStorage(
              bucket: _bucket,
              child: screens[selectedIndex],
            ),
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


