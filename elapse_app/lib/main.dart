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
import 'package:elapse_app/classes/Miscellaneous/remote_config.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences prefs;
late PackageInfo appInfo;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  prefs = await SharedPreferences.getInstance();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    await FirebaseRemoteConfigService().initialize();
  } catch (error, stackTrace) {
    // Firebase-backed features can recover when connectivity returns. Do not
    // prevent the locally cached app from starting in the meantime.
    debugPrint('Firebase startup failed: $error\n$stackTrace');
  }

  // Set android system navbar colour
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Navigation bar color
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (firebaseReady &&
      (prefs.getBool("isSetUp") ?? false) &&
      FirebaseAuth.instance.currentUser != null) {
    await checkAccountDeleted();
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // ErrorPage can itself be the root widget after an early build failure.
    // Giving it a Material ancestor prevents the former all-black fallback.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: lightScheme, fontFamily: 'Manrope'),
      home: const ErrorPage(),
    );
  };

  if (firebaseReady) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final title = notification?.title;
      final body = notification?.body;

      if (title == null || title.isEmpty || body == null || body.isEmpty) {
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        return;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ColorProvider(),
      ),
      ChangeNotifierProvider(create: (context) => TournamentModeProvider()),
    ],
    child: MyApp(key: myAppKey),
  ));
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
  int? teamID;
  String? teamNumber;

  TeamPreview? _savedTeam() {
    final rawTeam = prefs.getString('savedTeam');
    if (rawTeam == null || rawTeam.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawTeam);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final id = decoded['teamID'];
      final number = decoded['teamNumber'];
      if (id is! num || number is! String || number.isEmpty) {
        return null;
      }
      return TeamPreview(teamID: id.toInt(), teamNumber: number);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    final savedTeam = _savedTeam();
    if ((prefs.getBool("isSetUp") ?? false) && savedTeam != null) {
      teamID = savedTeam.teamID;
      teamNumber = savedTeam.teamNumber;
      initializeTournamentMode();
    }
  }

  void initializeTournamentMode() {
    if (prefs.getBool("isTournamentMode") ?? false) {
      int? tournamentID = prefs.getInt("tournamentID");
      final savedTeam = _savedTeam();
      if (tournamentID != null && savedTeam != null) {
        teamID = savedTeam.teamID;
        teamNumber = savedTeam.teamNumber;
        isTournamentMode = true;
      } else {
        isTournamentMode = false;
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
    final savedTeam = _savedTeam();
    if (!(prefs.getBool("isSetUp") ?? false) || savedTeam == null) {
      return Consumer<ColorProvider>(
        builder: (context, value, child) {
          prefs.setString("theme", "system");
          ColorScheme systemTheme =
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? darkScheme
                  : lightScheme;

          ColorScheme chosenTheme = systemTheme;

          return MaterialApp(
            navigatorKey: navigatorKey,
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
    List<Widget> screens;

    isTournamentMode
        ? screens = [
            TMHomePage(
              tournamentID: prefs.getInt("tournamentID") ?? 0,
              teamID: teamID!,
              teamNumber: teamNumber!,
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
          navigatorKey: navigatorKey,
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
