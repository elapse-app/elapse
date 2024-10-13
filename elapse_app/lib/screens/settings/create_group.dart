import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../classes/Users/user.dart';
import '../../extras/database.dart';
import '../../main.dart';
import '../widgets/app_bar.dart';
import '../widgets/long_button.dart';
import '../widgets/rounded_top.dart';
import 'group_settings.dart';

class GroupCreatePage extends StatefulWidget {
  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  TextEditingController groupNameController = TextEditingController(), teamNumberController = TextEditingController();

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
                  Text('Create',
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
                              child: Text("Enter Details", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Enter your group name and your team number."),
                            ),
                            const SizedBox(height: 23),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: groupNameController,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
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
                                  labelText: 'Group Name',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Manrope",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: teamNumberController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
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
                                  labelText: 'Team Number',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Manrope",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 23),
                            LongButton(
                              onPressed: () async {
                                Database database = Database();
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                ElapseUser currentElapseUser = elapseUserDecode(
                                    prefs.getString("currentUser")!);
                                await database
                                    .createTeamGroup(
                                    currentUser!.uid,
                                    groupNameController.text,
                                    teamNumberController.text,
                                    currentElapseUser.fname ?? "",
                                    currentElapseUser.lname ?? "")
                                    .then((value) {
                                  print(value?.toJson());
                                  prefs.setString("teamGroup", jsonEncode(value?.toJson()));
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupSettings(group: value!),
                                    ),
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
                              text: "Create a New Group",
                              gradient: true,
                            )
                          ]
                      )
                  )
              )
            ]
        )
    );
  }
}