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
      body: CustomScrollView(
        slivers: [
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
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ]),
            maxHeight: 60,
          ),
          const RoundedTop(),
          SliverPadding(
            padding: const EdgeInsets.only(left: 23, right: 23, bottom: 23),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text("Join a Group", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 18),
                  Text("If your team has already created a group, ask a group member for the join code. You can then enter the join code to join the group."),
                  const SizedBox(height: 24),
                  Pinput(
                    length: 8,
                    controller: joinCodeController,
                    defaultPinTheme: PinTheme(
                      width: 45,
                      height: 45,
                      textStyle: TextStyle(fontSize: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                        borderRadius: BorderRadius.circular(12),
                      )
                    ),
                    focusedPinTheme: PinTheme(
                        width: 45,
                        height: 45,
                        textStyle: TextStyle(fontSize: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(12),
                        )
                    ),
                    separatorBuilder: (index) {
                      if (index == 3) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text("—", style: TextStyle(fontSize: 20)),
                        );
                      }
                      return const SizedBox(width: 6);
                    },
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                          (oldVal, newVal) {
                            return TextEditingValue(
                              text: newVal.text.toUpperCase(),
                              selection: newVal.selection,
                            );
                          }
                      ),
                    ]
                  ),
                  const SizedBox(height: 24),
                  LongButton(
                    onPressed: () async {
                      Database database = Database();
                      final currentUser =
                          FirebaseAuth.instance.currentUser;
                      await database
                          .joinTeamGroup("${joinCodeController.text.substring(0, 4)}-${joinCodeController.text.substring(4)}", currentUser!.uid)
                          .then((value) {
                        prefs.setString("teamGroup", jsonEncode(value?.toJson()));
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupSettings(group: value!),
                          )
                        );
                      }).catchError((onError) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error Occured"),
                                content: Text(
                                    "An error occured when creating your account, please try again"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.only(right: 20.0),
                              child: Divider(
                                color: Theme.of(context).colorScheme.surfaceDim,
                                height: 36,
                              )),
                        ),
                        Text("OR", style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.only(left: 20.0),
                              child: Divider(
                                color: Theme.of(context).colorScheme.surfaceDim,
                                height: 36,
                              )),
                        ),
                      ]
                    )
                  ),
                  const SizedBox(
                    width: double.infinity,
                    child: Text("Create a Group", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 18),
                  Text("If you do not have a group to join, you can create a new group."),
                  const SizedBox(height: 24),
                  LongButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupCreatePage(),
                        )
                      );
                    },
                    text: "Create a New Group",
                    gradient: true,
                  ),
                ]
              )
            )
          )
        ]
      )
    );
  }
}