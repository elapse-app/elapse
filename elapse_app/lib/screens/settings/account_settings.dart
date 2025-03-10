import 'dart:convert';

import 'package:elapse_app/screens/settings/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../classes/Team/teamPreview.dart';
import '../../classes/Tournament/tournament.dart';
import '../../classes/Users/user.dart';
import '../../extras/auth.dart';
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
            widget.user.verified == false
                ? SizedBox(
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
                                " You need to verify to get access to CloudScout.\n\nTo verify your account, click send email. Check your inbox for a verification email. Click the link in the email to verify your account.",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, wordSpacing: -0.5))
                      ])),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                          child: LongButton(
                            onPressed: () {
                              FirebaseAuth.instance.currentUser?.sendEmailVerification().then((e) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Email Sent"),
                                        content: const Text("Check your inbox for a verification email."),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Close",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    });
                              }).catchError((e) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Error Occurred"),
                                        content: const Text(
                                            "An error occured while trying to verify your email. Try again later."),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Close",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    });
                              });
                            },
                            text: "Send Email",
                            useForwardArrow: false,
                            centerAlign: true,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: LongButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.currentUser!.reload();
                              if (FirebaseAuth.instance.currentUser!.emailVerified) {
                                Database database = Database();
                                database.verifyUser(widget.user.uid!);
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Verification Complete"),
                                        content: const Text("You now have access to CloudScout."),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Finish",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    });
                                setState(() {
                                  widget.user.verified = true;
                                  prefs.setString("currentUser", jsonEncode(widget.user.toJson()));
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Not Verified"),
                                        content: const Text("Please click the link in your email to verify."),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Close",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    });
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
            buildTeamDropdown(
                context,
                mainTeamId,
                (value) => setState(() {
                      mainTeamId = value;
                    })),
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
                                clearPrefs();
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
                                Navigator.pop(context);
                                TextEditingController passwordController = TextEditingController();
                                String? error;
                                final passKey = GlobalKey<FormState>();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(builder: (context, setState) {
                                      return AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: Column(mainAxisSize: MainAxisSize.min, children: [
                                          Text("Enter your password to complete the deletion process."),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            key: passKey,
                                            controller: passwordController,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(9),
                                                borderSide: BorderSide(
                                                  color:
                                                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                                                  width: 2.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(9),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  width: 2.0,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).colorScheme.error,
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).colorScheme.error,
                                                  width: 2.0,
                                                ),
                                              ),
                                              labelText: 'Password',
                                              labelStyle: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Manrope",
                                                fontSize: 16,
                                              ),
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                error = "";
                                              });
                                            },
                                            obscureText: true,
                                            autovalidateMode: error == null
                                                ? AutovalidateMode.onUserInteraction
                                                : AutovalidateMode.always,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              if (error == "invalid-credential") {
                                                return "Incorrect Password";
                                              }
                                              if (error == "too-many-requests") {
                                                return "Too many attempts. Try again later.";
                                              }
                                              if (error?.isNotEmpty ?? false) {
                                                return "An unexpected error occurred";
                                              }
                                              return null;
                                            },
                                          ),
                                        ]),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text("Delete",
                                                style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                            onPressed: () async {
                                              try {
                                                await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
                                                    EmailAuthProvider.credential(
                                                        email: FirebaseAuth.instance.currentUser!.email!,
                                                        password: passwordController.text));
                                              } on FirebaseAuthException catch (e) {
                                                setState(() {
                                                  error = e.code;
                                                });
                                                return;
                                              }
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const FirstSetupPage()),
                                                ((_) => false),
                                              );
                                              Database database = Database();
                                              database.deleteCurrentUser();
                                              FirebaseAuth.instance.currentUser!.delete();
                                              clearPrefs();
                                            },
                                          ),
                                        ],
                                        actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(18)),
                                      );
                                    });
                                  },
                                );
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
