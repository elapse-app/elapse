import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../classes/Team/teamPreview.dart';
import '../../classes/Tournament/tournament.dart';
import '../../classes/Users/user.dart';
import '../../extras/database.dart';
import '../../main.dart';
import '../../setup/welcome/first_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/long_button.dart';
import '../widgets/rounded_top.dart';
import 'manage_teams.dart';

class AccountSettings extends StatefulWidget {
  AccountSettings({
    super.key,
    required this.user,
  });

  ElapseUser user;

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  int mainTeamId = jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      ElapseAppBar(
        title: const Text(
          "Account",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
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
              child: Column(children: [
            Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(
                    radius: 50,
                  ),
                  const SizedBox(height: 9),
                  Text("${widget.user.fname!} ${widget.user.lname!}",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 9),
                  Text(widget.user.email!, style: const TextStyle(fontSize: 18)),
                ])),
            const SizedBox(height: 23),
            !widget.user.verified!
                ? SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Column(children: [
                      const SizedBox(
                        width: double.infinity,
                        child: Text("Verification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 18),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: "Your account is currently not verified.",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, wordSpacing: -0.5)),
                        TextSpan(
                            text:
                                " You need to verify to get access to group features such as ScoutSheets and MatchNotes.\n\nTo verify your account, click send email and check your inbox for an email asking to verify your Elapse account. Click the link to verify. Once the link has been clicked, click the Verify Account button, and your account will be verified.",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, wordSpacing: -0.5))
                      ])),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                          child: LongButton(
                            onPressed: () => FirebaseAuth.instance.currentUser?.sendEmailVerification(),
                            text: "Send Email",
                            useForwardArrow: false,
                            centerAlign: true,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: LongButton(
                            onPressed: () {
                              if (FirebaseAuth.instance.currentUser!.emailVerified) {
                                Database database = Database();
                                database.verifyUser(widget.user.uid!);
                                widget.user.verified = true;
                                prefs.setString("currentUser", jsonEncode(widget.user.toJson()));
                              }
                            },
                            gradient: true,
                            text: "Verify Account",
                            useForwardArrow: false,
                            centerAlign: true,
                          ),
                        )
                      ]),
                      const SizedBox(height: 36),
                    ]))
                : const SizedBox.shrink(),
            const SizedBox(
              width: double.infinity,
              child: Text("Teams", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
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
                                .map((e) => DropdownMenuItem(value: e.teamID, child: Text("Team ${e.teamNumber}")))
                                .toList(),
                            onChanged: (int? value) {
                              final String savedTeam = prefs.getString("savedTeam") ?? "";
                              final List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
                              String? selected = savedTeams.firstWhereOrNull((e) => jsonDecode(e)["teamID"] == value);
                              if (selected == null) return;

                              Tournament? tournament;
                              if (prefs.getBool("isTournamentMode") ?? false) {
                                tournament = loadTournament(prefs.getString("TMSavedTournament"));
                              }

                              if (tournament != null &&
                                  tournament.teams.singleWhereOrNull((e) => e.id == loadTeamPreview(selected).teamID) !=
                                      null) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Switch main team"),
                                        content: const Text("You will be exiting Tournament Mode."),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                              child: Text("Switch",
                                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                              onPressed: () {
                                                savedTeams.removeWhere((e) => jsonDecode(e)["teamID"] == value);
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
                                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.secondary),
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
                  const Text("Manage Teams", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                  Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ])),
            const SizedBox(height: 36),
            const SizedBox(
              width: double.infinity,
              child: Text("Manage", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 18),
            GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Reset Password"),
                          content: const Text("Please check your email for a link to reset your password."),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          actions: [
                            TextButton(
                              child: Text("Close", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                          actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(18)),
                        );
                      });
                },
                behavior: HitTestBehavior.translucent,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                  Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ])),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Sign out"),
                        content: const Text("Are you sure you want to sign out?"),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        actions: [
                          TextButton(
                            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                              child: Text("Sign out", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FirstSetupPage()),
                                  ((_) => false),
                                );
                                FirebaseAuth.instance.signOut();
                                prefs.remove("currentUser");
                                prefs.remove("savedTeam");
                                prefs.remove("savedTeams");
                                prefs.remove("isTournamentMode");
                                prefs.remove("teamGroup");

                                prefs.setBool("isSetUp", false);
                              })
                        ],
                        actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(18)),
                      );
                    });
              },
              behavior: HitTestBehavior.translucent,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Sign Out", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                Icon(Icons.logout_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Divider(color: Theme.of(context).colorScheme.surfaceDim),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Delete Account"),
                        content: Text.rich(TextSpan(
                            text: "Are you sure you want to ",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                            children: [
                              TextSpan(
                                text: "delete",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: " your account? This action ",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                              ),
                              TextSpan(
                                text: "cannot",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: " be undone.",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                              ),
                            ])),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        actions: [
                          TextButton(
                            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                              child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FirstSetupPage()),
                                  ((_) => false),
                                );
                                Database database = Database();
                                database.deleteCurrentUser();
                                FirebaseAuth.instance.currentUser!.delete();
                                prefs.remove("currentUser");
                                prefs.remove("savedTeam");
                                prefs.remove("savedTeams");
                                prefs.remove("isTournamentMode");
                                prefs.remove("teamGroup");

                                prefs.setBool("isSetUp", false);
                              })
                        ],
                        actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(18)),
                      );
                    });
              },
              behavior: HitTestBehavior.translucent,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Delete Account",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.error)),
                Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
              ]),
            ),
          ])))
    ]));
  }
}
