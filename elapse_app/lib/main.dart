import 'dart:convert';

import 'package:elapse_app/aesthetics/color_schemes.dart';
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
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:elapse_app/classes/Miscellaneous/remote_config.dart';
import 'package:elapse_app/database/database_helper.dart';

final GlobalKey<SetupGateState> setupGateKey = GlobalKey<SetupGateState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences prefs;
late PackageInfo appInfo;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going  use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

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

  await FirebaseRemoteConfigService().initialize();

  prefs = await SharedPreferences.getInstance();

  // Initialize SQLite database for tournament caching
  await DatabaseHelper().database;

  // Tournament data is now loaded directly from SQLite by each screen
  // No in-memory cache restoration needed - screens use getTournamentFromCache(tournamentId)
  // which reads from SQLite asynchronously

  // Set android system navbar colour
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Navigation bar color
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if ((prefs.getBool("isSetUp") ?? false) && FirebaseAuth.instance.currentUser != null) {
    print(FirebaseAuth.instance.currentUser);
    await checkAccountDeleted();
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorPage();
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    if (message.notification!.title != "" && message.notification!.body != "") {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(message.notification!.title ?? 'Upcoming match'),
          content: Text(message.notification!.body ?? 'No content'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ColorProvider(),
      ),
      ChangeNotifierProvider(create: (context) => TournamentModeProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  void _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    appInfo = info;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ColorProvider, TournamentModeProvider>(
      builder: (context, colorProvider, tournamentModeProvider, child) {
        if (!(prefs.getBool("isSetUp") ?? false) &&
            prefs.getString("theme") == null) {
          prefs.setString("theme", "system");
        }

        bool systemDefined = prefs.getString("theme") == "system";
        ColorScheme systemTheme =
            MediaQuery.of(context).platformBrightness == Brightness.dark ? darkScheme : lightScheme;
        ColorScheme chosenTheme = systemDefined ? systemTheme : colorProvider.colorScheme;

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
          home: SetupGate(key: setupGateKey),
        );
      },
    );
  }
}

class SetupGate extends StatefulWidget {
  const SetupGate({super.key});

  @override
  State<SetupGate> createState() => SetupGateState();
}

class SetupGateState extends State<SetupGate> {
  int selectedIndex = 0;
  bool isTournamentMode = false;
  int teamID = 0;
  String teamNumber = "";
  bool _hasTeamInfo = false;
  final PageStorageBucket _bucket = PageStorageBucket();
  List<Widget> _screens = [];
  bool _lastTournamentMode = false;

  @override
  void initState() {
    super.initState();
    if (prefs.getBool("isSetUp") ?? false) {
      _loadTeamInfo();
      initializeTournamentMode();
      _lastTournamentMode = isTournamentMode;
      _rebuildScreens();
    }
  }

  void _rebuildScreens() {
    if (isTournamentMode) {
      _screens = [
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
      ];
    } else {
      _screens = [
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
    }
    if (selectedIndex >= _screens.length) {
      selectedIndex = 0;
    }
  }

  void _loadTeamInfo() {
    if (_hasTeamInfo) return;
    final savedTeam = prefs.getString("savedTeam");
    if (savedTeam == null || savedTeam.isEmpty) return;
    try {
      final decoded = jsonDecode(savedTeam);
      teamID = decoded["teamID"];
      teamNumber = decoded["teamNumber"];
      _hasTeamInfo = true;
    } catch (_) {
      // Corrupted prefs — silently ignore so the app can still start
    }
  }

  void initializeTournamentMode() {
    if (prefs.getBool("isTournamentMode") ?? false) {
      int? tournamentID = prefs.getInt("tournamentID");
      _loadTeamInfo();
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
      _hasTeamInfo = false;
      if (prefs.getBool("isSetUp") ?? false) {
        _loadTeamInfo();
        initializeTournamentMode();
        _lastTournamentMode = isTournamentMode;
        _rebuildScreens();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (debugShowCompleteSetup) {
    //   return const FirstSetupPage();
    // }
    if (!(prefs.getBool("isSetUp") ?? false)) {
      return const FirstSetupPage();
    }

    _loadTeamInfo();
    final chosenTheme = Theme.of(context).colorScheme;
    if (_screens.isEmpty || _lastTournamentMode != isTournamentMode) {
      _lastTournamentMode = isTournamentMode;
      _rebuildScreens();
    }

    List<NavigationDestination> destinations = [
      NavigationDestination(
          selectedIcon: Icon(Icons.home_rounded, color: chosenTheme.secondary),
          icon: const Icon(Icons.home_outlined),
          label: "Home"),
      NavigationDestination(
          selectedIcon: Icon(Icons.bubble_chart, color: chosenTheme.secondary),
          icon: const Icon(Icons.bubble_chart_outlined),
          label: "Scout"),
      NavigationDestination(
        selectedIcon: Icon(Icons.people_alt_rounded, color: chosenTheme.secondary),
        icon: const Icon(Icons.people_alt_outlined),
        label: "My Team",
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.explore_rounded, color: chosenTheme.secondary),
        icon: const Icon(Icons.explore_outlined),
        label: "Explore",
      ),
    ];

    if (isTournamentMode) {
      destinations.insert(
        1,
        NavigationDestination(
          selectedIcon: Icon(Icons.emoji_events_rounded, color: chosenTheme.secondary),
          icon: const Icon(Icons.emoji_events_outlined),
          label: "Tournament",
        ),
      );
    }

    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        indicatorColor: chosenTheme.primary,
        animationDuration: const Duration(milliseconds: 500),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        destinations: destinations,
      ),
    );
  }
}
