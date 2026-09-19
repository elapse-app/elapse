import 'dart:async';

import 'package:elapse_app/aesthetics/app_theme.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/extras/auth.dart';
import 'package:elapse_app/providers/color_provider.dart';
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
PackageInfo? appInfo;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  prefs = await SharedPreferences.getInstance();
  try {
    appInfo = await PackageInfo.fromPlatform();
  } catch (error, stackTrace) {
    debugPrint('Package information unavailable: $error\n$stackTrace');
  }

  final firebaseReady = await _initializeFirebase();

  // Set android system navbar colour
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Navigation bar color
  ));

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  _configureBuildErrorFallback();

  if (firebaseReady) {
    _configureMessaging();
  }

  runApp(ChangeNotifierProvider(
    create: (_) => ColorProvider(prefs),
    child: MyApp(key: myAppKey),
  ));

  if (firebaseReady &&
      (prefs.getBool('isSetUp') ?? false) &&
      FirebaseAuth.instance.currentUser != null) {
    unawaited(_verifyCurrentAccount());
  }
}

Future<void> _verifyCurrentAccount() async {
  final localSessionCleared = await checkAccountDeleted();
  if (localSessionCleared) {
    myAppKey.currentState?.reloadApp();
  }
}

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Remote Config has local defaults and should never hold up first paint.
    unawaited(FirebaseRemoteConfigService().initialize());
    return true;
  } catch (error, stackTrace) {
    // Firebase-backed features can recover when connectivity returns. Do not
    // prevent the locally cached app from starting in the meantime.
    debugPrint('Firebase startup failed: $error\n$stackTrace');
    return false;
  }
}

void _configureBuildErrorFallback() {
  ErrorWidget.builder = (details) {
    FlutterError.presentError(details);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: ErrorPage(
        onRetry: () => myAppKey.currentState?.reloadApp(),
      ),
    );
  };
}

void _configureMessaging() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    final title = notification?.title?.trim();
    final body = notification?.body?.trim();

    if (title == null || title.isEmpty || body == null || body.isEmpty) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();
  final Set<int> _visitedIndices = {0};

  int _selectedIndex = 0;
  bool _isTournamentMode = false;
  int? _teamId;
  String? _teamNumber;

  TeamPreview? _savedTeam() {
    return tryLoadTeamPreview(prefs.getString('savedTeam'));
  }

  @override
  void initState() {
    super.initState();
    final savedTeam = _savedTeam();
    if ((prefs.getBool("isSetUp") ?? false) && savedTeam != null) {
      _teamId = savedTeam.teamID;
      _teamNumber = savedTeam.teamNumber;
      _initializeTournamentMode();
    }
  }

  void _initializeTournamentMode() {
    final savedTeam = _savedTeam();
    final tournamentID = prefs.getInt('tournamentID');
    _isTournamentMode = (prefs.getBool('isTournamentMode') ?? false) &&
        tournamentID != null &&
        savedTeam != null;

    if (!_isTournamentMode) {
      unawaited(prefs.setStringList('picklist', const []));
    }

    _teamId = savedTeam?.teamID;
    _teamNumber = savedTeam?.teamNumber;
  }

  void reloadApp() {
    setState(() {
      _selectedIndex = 0;
      _visitedIndices
        ..clear()
        ..add(0);
      _initializeTournamentMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedTeam = _savedTeam();
    final isConfigured =
        (prefs.getBool('isSetUp') ?? false) && savedTeam != null;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, _) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Elapse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: colorProvider.themeMode,
        themeAnimationDuration: const Duration(milliseconds: 250),
        themeAnimationCurve: Curves.easeOutCubic,
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: (isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: isConfigured ? _buildAppShell() : const FirstSetupPage(),
      ),
    );
  }

  Widget _buildAppShell() {
    final tournamentID = prefs.getInt('tournamentID') ?? 0;
    final screens = _isTournamentMode
        ? <Widget>[
            TMHomePage(
              key: const PageStorageKey('tournament-home'),
              tournamentID: tournamentID,
              teamID: _teamId!,
              teamNumber: _teamNumber!,
            ),
            TMTournamentScreen(
              key: const PageStorageKey('tournament'),
              tournamentID: tournamentID,
              isPreview: false,
            ),
            CloudScoutScreen(key: const PageStorageKey('scout')),
            TMMyTeams(
              key: const PageStorageKey('tournament-my-teams'),
              tournamentID: tournamentID,
            ),
            ExploreScreen(key: const PageStorageKey('explore')),
          ]
        : <Widget>[
            HomeScreen(key: const PageStorageKey('home')),
            CloudScoutScreen(key: const PageStorageKey('scout')),
            MyTeams(key: const PageStorageKey('my-teams')),
            ExploreScreen(key: const PageStorageKey('explore')),
          ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        selectedIcon: Icon(Icons.home_rounded),
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      if (_isTournamentMode)
        const NavigationDestination(
          selectedIcon: Icon(Icons.emoji_events_rounded),
          icon: Icon(Icons.emoji_events_outlined),
          label: 'Tournament',
        ),
      const NavigationDestination(
        selectedIcon: Icon(Icons.bubble_chart),
        icon: Icon(Icons.bubble_chart_outlined),
        label: 'Scout',
      ),
      const NavigationDestination(
        selectedIcon: Icon(Icons.people_alt_rounded),
        icon: Icon(Icons.people_alt_outlined),
        label: 'My Team',
      ),
      const NavigationDestination(
        selectedIcon: Icon(Icons.explore_rounded),
        icon: Icon(Icons.explore_outlined),
        label: 'Explore',
      ),
    ];

    return Scaffold(
      body: PageStorage(
        bucket: _pageStorageBucket,
        child: IndexedStack(
          index: _selectedIndex,
          children: List.generate(
            screens.length,
            (index) => _visitedIndices.contains(index)
                ? screens[index]
                : const SizedBox.shrink(),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        animationDuration: const Duration(milliseconds: 350),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) {
          if (value != _selectedIndex) {
            setState(() {
              _selectedIndex = value;
              _visitedIndices.add(value);
            });
          }
        },
        destinations: destinations,
      ),
    );
  }
}
