import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/screens/settings/setup_group.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import '../../classes/Groups/teamGroup.dart';
import '../../classes/Team/teamPreview.dart';
import '../../classes/Tournament/tournament.dart';
import '../../main.dart';
import '../../setup/signup/create_account.dart';
import '../../setup/signup/login_page.dart';
import '../widgets/big_error_message.dart';
import '../widgets/long_button.dart';
import 'account_settings.dart';
import 'group_settings.dart';
import 'manage_teams.dart';

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
  bool autoRefresh = prefs.getBool("autoRefresh") ?? true;
  String defaultGrade = prefs.getString("defaultGrade") ?? "Main Team";
  bool sendLTTelemetry = prefs.getBool("sendLTTelemetry") ?? false;

  ElapseUser? currentUser;
  bool showEmail = false;

  late Future<TeamGroup?> teamGroupFuture;

  @override
  void initState() {
    super.initState();
    if (prefs.getString("currentUser") != null) {
      currentUser = ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!));
      teamGroupFuture = getUserTeamGroup(currentUser!.uid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          if (prefs.getString("currentUser") != null) {
            await FirebaseAuth.instance.currentUser!.reload();
            setState(() {
              currentUser = ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!));
              teamGroupFuture = getUserTeamGroup(currentUser!.uid!);
            });
          }
        },
        child: CustomScrollView(
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
                        height: currentUser != null ? 320 : 400,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: currentUser != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 33,
                                          ),
                                          Text('${currentUser!.fname!} ${currentUser!.lname!}',
                                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                          GestureDetector(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Text(currentUser!.email!,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      foreground: showEmail
                                                          ? (Paint()..color = Theme.of(context).colorScheme.secondary)
                                                          : (Paint()
                                                            ..style = PaintingStyle.fill
                                                            ..color = Colors.grey
                                                            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)),
                                                    )),
                                                Text(showEmail ? "Tap to hide email" : "Tap to show email",
                                                    style: const TextStyle(fontSize: 12)),
                                              ]),
                                              onTap: () {
                                                setState(() {
                                                  showEmail = !showEmail;
                                                });
                                              }),
                                        ]),
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(children: [
                                        Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.secondary),
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
                                                      final List<String> savedTeams =
                                                          prefs.getStringList("savedTeams") ?? [];
                                                      String? selected = savedTeams
                                                          .firstWhereOrNull((e) => jsonDecode(e)["teamID"] == value);
                                                      if (selected == null) return;

                                                      Tournament? tournament;
                                                      if (prefs.getBool("isTournamentMode") ?? false) {
                                                        tournament =
                                                            loadTournament(prefs.getString("TMSavedTournament"));
                                                      }

                                                      if (tournament != null &&
                                                          tournament.teams.singleWhereOrNull(
                                                                  (e) => e.id == loadTeamPreview(selected).teamID) ==
                                                              null) {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: const Text("Switch main team"),
                                                                content:
                                                                    const Text("You will be exiting Tournament Mode."),
                                                                contentPadding: const EdgeInsets.symmetric(
                                                                    horizontal: 24, vertical: 10),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text("Cancel",
                                                                        style: TextStyle(
                                                                            color: Theme.of(context)
                                                                                .colorScheme
                                                                                .secondary)),
                                                                    onPressed: () => Navigator.pop(context),
                                                                  ),
                                                                  TextButton(
                                                                      child: Text("Switch",
                                                                          style: TextStyle(
                                                                              color: Theme.of(context)
                                                                                  .colorScheme
                                                                                  .secondary)),
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
                                                                actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
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
                                                    icon: Icon(Icons.arrow_drop_down,
                                                        color: Theme.of(context).colorScheme.secondary),
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
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Divider(
                                          color: Theme.of(context).colorScheme.surfaceDim,
                                        )),
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AccountSettings(user: currentUser!),
                                            ));
                                        setState(() {
                                          currentUser =
                                              ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!));
                                          mainTeamId = jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"];
                                        });
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        const Text("Account Settings",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                                        Icon(Icons.arrow_forward_outlined,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ]),
                                    ),
                                  ])
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text("Sign Up", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 18),
                                    Text(
                                        "Currently you are using Elapse without an account. To fully utilise Elapse and gain access to ScoutSheets and Match Notes, create an account or login to an existing one.",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                        softWrap: true),
                                    const SizedBox(height: 18),
                                    Row(children: [
                                      Expanded(
                                        child: LongButton(
                                          onPressed: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const CreateAccount(),
                                                ));
                                            if (prefs.getString("currentUser") != null) {
                                              await FirebaseAuth.instance.currentUser!.reload();
                                              setState(() {
                                                currentUser =
                                                    ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!));
                                                teamGroupFuture = getUserTeamGroup(currentUser!.uid!);
                                              });
                                            }
                                          },
                                          text: "Sign Up",
                                          useForwardArrow: false,
                                          centerAlign: true,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: LongButton(
                                          onPressed: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LoginPage(),
                                                ));
                                            if (prefs.getString("currentUser") != null) {
                                              await FirebaseAuth.instance.currentUser!.reload();
                                              setState(() {
                                                currentUser =
                                                    ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!));
                                                teamGroupFuture = getUserTeamGroup(currentUser!.uid!);
                                              });
                                            }
                                          },
                                          gradient: false,
                                          text: "Log In",
                                          useForwardArrow: false,
                                          centerAlign: true,
                                        ),
                                      )
                                    ]),
                                    const SizedBox(height: 13),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Divider(
                                          color: Theme.of(context).colorScheme.surfaceDim,
                                        )),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(children: [
                                        Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.secondary),
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
                                                      final List<String> savedTeams =
                                                          prefs.getStringList("savedTeams") ?? [];
                                                      String? selected = savedTeams
                                                          .firstWhereOrNull((e) => jsonDecode(e)["teamID"] == value);
                                                      if (selected == null) return;

                                                      Tournament? tournament;
                                                      if (prefs.getBool("isTournamentMode") ?? false) {
                                                        tournament =
                                                            loadTournament(prefs.getString("TMSavedTournament"));
                                                      }

                                                      if (tournament != null &&
                                                          tournament.teams.singleWhereOrNull(
                                                                  (e) => e.id == loadTeamPreview(selected).teamID) ==
                                                              null) {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: const Text("Switch main team"),
                                                                content:
                                                                    const Text("You will be exiting Tournament Mode."),
                                                                contentPadding: const EdgeInsets.symmetric(
                                                                    horizontal: 24, vertical: 10),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text("Cancel",
                                                                        style: TextStyle(
                                                                            color: Theme.of(context)
                                                                                .colorScheme
                                                                                .secondary)),
                                                                    onPressed: () => Navigator.pop(context),
                                                                  ),
                                                                  TextButton(
                                                                      child: Text("Switch",
                                                                          style: TextStyle(
                                                                              color: Theme.of(context)
                                                                                  .colorScheme
                                                                                  .secondary)),
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
                                                                actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
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
                                                    icon: Icon(Icons.arrow_drop_down,
                                                        color: Theme.of(context).colorScheme.secondary),
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
                                    const SizedBox(height: 18),
                                    GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ManageTeamPage(),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                          const Text("Manage Teams",
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                                          Icon(Icons.arrow_forward,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                                        ])),
                                  ])),
                    const SizedBox(height: 23),
                    currentUser != null
                        ? Container(
                            height: currentUser!.groupID.isNotEmpty ? 200 : 230,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.all(18),
                            child: FutureBuilder(
                                future: teamGroupFuture,
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                    case ConnectionState.waiting:
                                    case ConnectionState.active:
                                      return const Center(
                                          child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()));
                                    case ConnectionState.done:
                                      if (snapshot.hasError) {
                                        print(snapshot.error);
                                        return const BigErrorMessage(
                                          icon: Icons.people_alt_outlined,
                                          message: "Error loading team group",
                                          topPadding: 0,
                                          textPadding: 10,
                                        );
                                      }

                                      TeamGroup? teamGroup = snapshot.data;

                                      if (teamGroup != null) {
                                        return Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("${teamGroup.groupName}",
                                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 18),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                const Text("Admin",
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                                                Text(teamGroup.members[teamGroup.adminId]!,
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                              ]),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                const Text("Members",
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                                                Text("${teamGroup.members.length}",
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                              ]),
                                              Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: Divider(
                                                    color: Theme.of(context).colorScheme.surfaceDim,
                                                  )),
                                              GestureDetector(
                                                onTap: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => GroupSettings(uid: currentUser!.uid!),
                                                    ),
                                                  );
                                                  setState(() {
                                                    teamGroup = prefs.getString("teamGroup") != null
                                                        ? TeamGroup.fromJson(jsonDecode(prefs.getString("teamGroup")!))
                                                        : null;
                                                  });
                                                },
                                                behavior: HitTestBehavior.translucent,
                                                child:
                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                  const Text("Group Settings",
                                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                                                  Icon(Icons.arrow_forward_outlined,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                ]),
                                              ),
                                            ]);
                                      }

                                      return Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Set Up a Group",
                                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                            const SizedBox(height: 18),
                                            Text(
                                                "Currently you are not part of a group. To get access to ScoutSheets and MatchNotes, create a new group or join an existing one.",
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                softWrap: true),
                                            const SizedBox(height: 18),
                                            LongButton(
                                              onPressed: () async {
                                                if (!FirebaseAuth.instance.currentUser!.emailVerified) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text("Not Verified"),
                                                          content: const Text("Go to account settings?"),
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                          actions: [
                                                            TextButton(
                                                              child: Text("Cancel",
                                                                  style: TextStyle(
                                                                      color: Theme.of(context).colorScheme.secondary)),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                            TextButton(
                                                                child: Text("Yes",
                                                                    style: TextStyle(
                                                                        color:
                                                                            Theme.of(context).colorScheme.secondary)),
                                                                onPressed: () => Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          AccountSettings(user: currentUser!),
                                                                    )))
                                                          ],
                                                          actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Theme.of(context).colorScheme.primary),
                                                              borderRadius: BorderRadius.circular(18)),
                                                        );
                                                      });
                                                  return;
                                                }
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => GroupSetupPage(),
                                                    ));
                                                setState(() {
                                                  teamGroup = prefs.getString("teamGroup") != null
                                                      ? TeamGroup.fromJson(jsonDecode(prefs.getString("teamGroup")!))
                                                      : null;
                                                });
                                              },
                                              gradient: true,
                                              text: "Get Started",
                                            )
                                          ]);
                                  }
                                }),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 32),
                    const SizedBox(
                      width: double.infinity,
                      child: Text("Tournament", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 25),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Use Live Timing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
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
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Send Live Timing Telemetry",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                      Switch(
                        value: sendLTTelemetry,
                        onChanged: (bool? value) {
                          prefs.setBool("sendLTTelemetry", value!);
                          setState(() {
                            sendLTTelemetry = value;
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
                      child: Text("General", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 25),
                    Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
                      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
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
                                fontWeight: FontWeight.w400),
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
                      const Text("Default grade", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary, fontSize: 18, fontWeight: FontWeight.w400),
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
                      child: Text("Other", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Version", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                        Text("${appInfo.version} (Build ${appInfo.buildNumber})",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurfaceVariant))
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
                          child: Text("Send Feedback", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
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

  return savedTeamsList;
}
