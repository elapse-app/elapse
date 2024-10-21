import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../extras/database.dart';
import '../../main.dart';
import '../widgets/app_bar.dart';
import '../widgets/long_button.dart';
import '../widgets/rounded_top.dart';
import 'create_group.dart';
import 'group_settings.dart';

class GroupSetupPage extends StatefulWidget {
  @override
  State<GroupSetupPage> createState() => _GroupSetupPageState();
}

class _GroupSetupPageState extends State<GroupSetupPage> {
  TextEditingController joinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      ElapseAppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 12),
          Text('Setup',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              )),
        ]),
        maxHeight: 60,
      ),
      const RoundedTop(),
      SliverPadding(
          padding: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
          sliver: SliverToBoxAdapter(
              child: Column(children: [
            const SizedBox(
              width: double.infinity,
              child: Text("Join a Group", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 18),
            Text(
                "If your team has already created a group, ask a group member for the join code. You can then enter the join code to join the group.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
            const SizedBox(height: 24),
            Pinput(
                length: 8,
                controller: joinCodeController,
                defaultPinTheme: PinTheme(
                    width: 45,
                    height: 45,
                    textStyle: TextStyle(fontSize: 24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                      borderRadius: BorderRadius.circular(9),
                    )),
                focusedPinTheme: PinTheme(
                    width: 45,
                    height: 45,
                    textStyle: TextStyle(fontSize: 24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(9),
                    )),
                separatorBuilder: (index) {
                  if (index == 3) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text("—", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300)),
                    );
                  }
                  return const SizedBox(width: 5);
                },
                showCursor: false,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldVal, newVal) {
                    return TextEditingValue(
                      text: newVal.text.toUpperCase(),
                      selection: newVal.selection,
                    );
                  }),
                ]),
            const SizedBox(height: 18),
            LongButton(
              onPressed: () async {
                Database database = Database();
                final currentUser = FirebaseAuth.instance.currentUser;
                await database
                    .joinTeamGroup("${joinCodeController.text.substring(0, 4)}-${joinCodeController.text.substring(4)}",
                        currentUser!.uid)
                    .then((value) async {
                      if (value == null) {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Invalid Join Code"),
                                content: const Text("Unable to find a team group with this join code."),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                actions: [
                                  TextButton(
                                    child: Text("Close",
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                                actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                    borderRadius: BorderRadius.circular(18)),
                              );
                            });
                        setState(() {
                          joinCodeController.text = "";
                        });
                        return;
                      }
                  prefs.setString("teamGroup", jsonEncode(value.toJson()));
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupSettings(uid: currentUser.uid),
                      ));
                }).catchError((onError) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Error Occurred"),
                          content: Text("An error occurred when creating joining the team group, please try again"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                ))
                          ],
                        );
                      });
                });
              },
              text: "Join the Group",
              gradient: true,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 23),
                child: Row(children: [
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(right: 18),
                        child: Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          height: 36,
                        )),
                  ),
                  Text("OR", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 18),
                        child: Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          height: 36,
                        )),
                  ),
                ])),
            const SizedBox(
              width: double.infinity,
              child: Text("Create a Group", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 18),
            Text("If you do not have a group to join, you can create a new group.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
            const SizedBox(height: 18),
            LongButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCreatePage(),
                    ));
              },
              text: "Create a New Group",
              gradient: true,
            ),
          ])))
    ]));
  }
}
