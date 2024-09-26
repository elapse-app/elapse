import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/screens/settings/add_teams.dart';
import 'package:elapse_app/screens/settings/edit_account.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/setup/signup/login_or_signup.dart';
import 'package:elapse_app/setup/welcome/first_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import '../../classes/Team/teamPreview.dart';
import '../../classes/Tournament/tournament.dart';
import '../../classes/Tournament/tournament_preview.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

String theme = "system";

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsScreenState();

  int mainTeamId = jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"];
  bool useLiveTiming = prefs.getBool("useLiveTiming") ?? true;
  String defaultGrade = prefs.getString("defaultGrade") ?? "Main Team";

  ElapseUser currentUser = elapseUserDecode(prefs.getString("currentUser")!);
  bool showEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: const Text(
              "Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            backNavigation: true,
            background: Padding(
                padding: const EdgeInsets.only(left: 23, top: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    ))),
          ),
          const RoundedTop(),
          SliverPadding(
            padding: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                      height: FirebaseAuth.instance.currentUser != null ? 320 : 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FirebaseAuth.instance.currentUser != null
                                ? Column(children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${currentUser.fname!} ${currentUser.lname!}',
                                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                                            GestureDetector(
                                              child: Text(currentUser.email!,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    foreground: showEmail ? null : (Paint()
                                                      ..style = PaintingStyle.fill
                                                      ..color = Colors.grey
                                                      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)),
                                                  )),
                                              onTap: () {
                                                setState(() {
                                                  showEmail = !showEmail;
                                                });
                                              }
                                            )
                                          ]),
                                      CircleAvatar(
                                        radius: 32,
                                      )
                                    ]),
                                    const SizedBox(height: 18),
                                    GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text("Sign out"),
                                                  content: const Text("Are you sure you want to sign out?"),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                  actions: [
                                                    ElevatedButton(
                                                      child: Text("Cancel",
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.secondary)),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                    ElevatedButton(
                                                        child: const Text("Sign out",
                                                            style: TextStyle(color: Colors.redAccent)),
                                                        onPressed: () {
                                                          Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => const FirstSetupPage()),
                                                            ((_) => false),
                                                          );
                                                          FirebaseAuth.instance.signOut();
                                                          prefs.remove("currentUser");
                                                          prefs.remove("savedTeam");
                                                          prefs.remove("savedTeams");
                                                          prefs.remove("isTournamentMode");

                                                          prefs.setBool("isSetUp", false);
                                                        })
                                                  ],
                                                  actionsPadding: const EdgeInsets.only(bottom: 8),
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                      borderRadius: BorderRadius.circular(18)),
                                                );
                                              });
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.redAccent),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Center(child: Text("Sign out", style: TextStyle(fontSize: 18))),
                                        )),
                                  ])
                                : const SizedBox.shrink(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.secondary),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(children: [
                                Icon(Icons.group, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: getSavedTeams().length > 1
                                      ? DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            isExpanded: true,
                                            value: mainTeamId,
                                            items: getSavedTeams()
                                                .map((e) => DropdownMenuItem(
                                                    value: e.teamID, child: Text("Team ${e.teamNumber}")))
                                                .toList(),
                                            onChanged: (int? value) {
                                              final String savedTeam = prefs.getString("savedTeam") ?? "";
                                              final List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
                                              String? selected =
                                                  savedTeams.firstWhereOrNull((e) => jsonDecode(e)["teamID"] == value);
                                              if (selected == null) return;

                                              Tournament? tournament;
                                              if (prefs.getBool("isTournamentMode") ?? false) {
                                                tournament = loadTournament(prefs.getString("TMSavedTournament"));
                                              }

                                              if (tournament != null &&
                                                  !tournament.teams.contains(loadTeamPreview(selected))) {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text("Switch main team"),
                                                        content: const Text("You will be exiting Tournament Mode."),
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                        actions: [
                                                          ElevatedButton(
                                                            child: Text("Cancel",
                                                                style: TextStyle(
                                                                    color: Theme.of(context).colorScheme.secondary)),
                                                            onPressed: () => Navigator.pop(context),
                                                          ),
                                                          ElevatedButton(
                                                              child: Text("Switch",
                                                                  style: TextStyle(
                                                                      color: Theme.of(context).colorScheme.secondary)),
                                                              onPressed: () {
                                                                savedTeams.removeWhere(
                                                                    (e) => jsonDecode(e)["teamID"] == value);
                                                                savedTeams.add(savedTeam);
                                                                prefs.setStringList("savedTeams", savedTeams);
                                                                prefs.setString("savedTeam", selected);

                                                                setState(() {
                                                                  mainTeamId = value!;
                                                                });

                                                                prefs.setBool("isTournamentMode", false);
                                                                prefs.remove("tournament-${tournament!.id}");
                                                                prefs.remove("TMSavedTournament");
                                                                myAppKey.currentState!.reloadApp();
                                                                Navigator.pop(context);
                                                              })
                                                        ],
                                                        actionsPadding: const EdgeInsets.only(bottom: 8),
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Theme.of(context).colorScheme.primary),
                                                            borderRadius: BorderRadius.circular(18)),
                                                      );
                                                    });
                                              } else {
                                                savedTeams.removeWhere((e) => jsonDecode(e)["teamID"] == value);
                                                savedTeams.add(savedTeam);
                                                prefs.setStringList("savedTeams", savedTeams);
                                                prefs.setString("savedTeam", selected);

                                                setState(() {
                                                  mainTeamId = value!;
                                                });
                                              }
                                            },
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context).colorScheme.secondary),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text("Team ${getSavedTeams()[0].teamNumber}",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(context).colorScheme.secondary))),
                                )
                              ]),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 10,
                                    child: GestureDetector(
                                      child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                        Icon(Icons.add),
                                        Text("Add Teams", textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                                      ]),
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const AddTeamPage(),
                                            ));
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  const Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: SizedBox(
                                      height: 50,
                                      child: VerticalDivider(width: 3, thickness: 0.5),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 10,
                                    child: FirebaseAuth.instance.currentUser != null
                                        ? GestureDetector(
                                            child: const Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Icon(Icons.edit),
                                                  Text("Edit Account",
                                                      textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                                                ]),
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const EditAccountPage(),
                                                  ));
                                              setState(() {});
                                            },
                                          )
                                        : GestureDetector(
                                            child:
                                                const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                              Icon(Icons.login),
                                              Text("Login", textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                                            ]),
                                            onTap: () async {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const SignUpPage(),
                                                  ));
                                              setState(() {});
                                            },
                                          ),
                                  ),
                                ])),
                          ])),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: double.infinity,
                    child: Text("Tournament", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 25),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Use Live Timing", style: TextStyle(fontSize: 18)),
                    Switch(
                      value: useLiveTiming,
                      onChanged: (bool? value) {
                        prefs.setBool("useLiveTiming", value!);
                        setState(() {
                          useLiveTiming = value;
                        });
                      },
                    )
                  ]),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: double.infinity,
                    child: Text("General", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 25),
                  Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
                    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Theme", style: TextStyle(fontSize: 18)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          elevation: 2,
                          value: theme,
                          items: const [
                            DropdownMenuItem(
                              value: "system",
                              child: Text(
                                "Follow system",
                                textAlign: TextAlign.right, // Align text to the right
                              ),
                            ),
                            DropdownMenuItem(
                              value: "dark",
                              child: Text(
                                "Dark",
                                textAlign: TextAlign.right, // Align text to the right
                              ),
                            ),
                            DropdownMenuItem(
                              value: "light",
                              child: Text(
                                "Light",
                                textAlign: TextAlign.right, // Align text to the right
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            switch (value) {
                              case "system":
                                colorProvider.setSystem();
                                break;
                              case "dark":
                                colorProvider.setDark();
                                break;
                              case "light":
                                colorProvider.setLight();
                                break;
                              default:
                                colorProvider.setSystem();
                                break;
                            }

                            setState(() {
                              theme = value!;
                            });
                          },
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18,
                          ),
                          icon: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(23),

                          alignment: Alignment.centerRight, // Keep dropdown button content aligned
                        ),
                      )
                    ]);
                  }),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text("Default grade", style: TextStyle(fontSize: 18)),
                    DropdownButtonHideUnderline(
                        child: DropdownButton(
                      value: defaultGrade,
                      items: const [
                        DropdownMenuItem(value: "Main Team", child: Text("Main Team")),
                        DropdownMenuItem(value: "Middle School", child: Text("Middle School")),
                        DropdownMenuItem(value: "High School", child: Text("High School")),
                        DropdownMenuItem(value: "College", child: Text("College"))
                      ],
                      onChanged: (String? value) {
                        prefs.setString("defaultGrade", value!);

                        setState(() {
                          defaultGrade = value;
                        });
                      },
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 18),
                      icon: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(10),
                      alignment: Alignment.centerRight,
                    )),
                  ]),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: double.infinity,
                    child: Text("Other", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Version", style: TextStyle(fontSize: 18)),
                      Text("${appInfo.version} (Build ${appInfo.buildNumber})",
                          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant))
                    ]),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("https://forms.gle/MF3K7JYG572AQvKh8"));
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Text("Send Feedback", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

List<TeamPreview> getSavedTeams() {
  final String savedTeam = prefs.getString("savedTeam") ?? "";
  List<TeamPreview> savedTeamsList = [];

  final List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
  savedTeamsList.addAll(
      savedTeams.map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"])));
  savedTeamsList.insert(0, loadTeamPreview(savedTeam));

  print(savedTeamsList[0].teamID);

  return savedTeamsList;
}
