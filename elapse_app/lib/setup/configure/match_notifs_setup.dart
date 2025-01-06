import 'package:elapse_app/main.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/tournament_mode_setup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../classes/Team/teamPreview.dart';
import 'dart:convert';

class NotifsSetup extends StatefulWidget {
  const NotifsSetup({
    super.key,
  });

  @override
  State<NotifsSetup> createState() => _NotifsSetupState();
}

class _NotifsSetupState extends State<NotifsSetup> {
  _NotifsSetupState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              ElapseAppBar(
                title: Row(children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ]),
                maxHeight: 60,
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: SafeArea(
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Match Notifications',
                                      style: TextStyle(
                                        fontFamily: "Manrope",
                                        fontSize: 32,
                                        fontWeight: FontWeight.w300,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Get notified before your matches',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/lottie/setup-match-notifs.json',
                                    repeat: true,
                                    reverse: true,
                                    animate: true,
                                  ),
                                ],
                              ),
                              /* Lottie.asset(
                                'assets/lottie/setup-match-notifs.json',
                                repeat: true,
                                reverse: true,
                                animate: true,
                              ), */
                              SizedBox(
                                height: 32,
                              ),
                              Spacer(),
                              LongButton(
                                  centerAlign: true,
                                  useForwardArrow: false,
                                  onPressed: () {
                                    askForNotifPerms();
                                    subToTeamPushNotifs(
                                        getSavedTeams()[0].teamNumber);
                                      setState(() {
                                useMatchNotifs = value;
                              });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TournamentModeSetupPage(),
                                      ),
                                    );
                                  },
                                  text: "Enable Match Notifications"),
                              SizedBox(
                                height: 16,
                              ),
                              LongButton(
                                  centerAlign: true,
                                  useForwardArrow: false,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TournamentModeSetupPage(),
                                      ),
                                    );
                                  },
                                  text: "Maybe Later"),
                              SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]));
  }
}

Future<void> askForNotifPerms() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

List<TeamPreview> getSavedTeams() {
  final String savedTeam = prefs.getString("savedTeam") ?? "";
  List<TeamPreview> savedTeamsList = [];

  final List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
  savedTeamsList.addAll(savedTeams.map((e) => TeamPreview(
      teamID: jsonDecode(e)["teamID"],
      teamNumber: jsonDecode(e)["teamNumber"])));
  savedTeamsList.insert(0, loadTeamPreview(savedTeam));

  return savedTeamsList;
}

Future<void> subToTeamPushNotifs(String teamNum) async {
  try {
    // Subscribing the user to the specified topic
    await FirebaseMessaging.instance.subscribeToTopic(teamNum);
  } catch (e) {
    print('Failed to subscribe to topic: $e');
  }
}
