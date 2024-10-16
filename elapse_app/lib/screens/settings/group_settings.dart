import 'dart:convert';

import 'package:elapse_app/screens/settings/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../classes/Groups/teamGroup.dart';
import '../../extras/database.dart';
import '../../main.dart';
import '../widgets/app_bar.dart';
import '../widgets/rounded_top.dart';

class GroupSettings extends StatefulWidget {
  GroupSettings({
    super.key,
    required this.group,
  });

  TeamGroup group;

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  bool isAdmin = false;
  bool editing = false;
  bool generatingCode = false;
  int selectedMemberIndex = -1;
  TextEditingController nameEditController = TextEditingController();
  Database database = Database();

  @override
  void initState() {
    super.initState();

    isAdmin = FirebaseAuth.instance.currentUser?.uid == widget.group.adminId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      ElapseAppBar(
        title: const Text(
          "Group",
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
              height: 175,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      IntrinsicWidth(
                          child: SizedBox(
                        height: 40,
                        child: editing
                            ? TextFormField(
                                controller: nameEditController,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(9),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onFieldSubmitted: (val) {
                                  if (val.isEmpty) {
                                    nameEditController.text = widget.group.groupName!;
                                  }
                                },
                              )
                            : Text("${widget.group.groupName}",
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                      )),
                      isAdmin
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  editing = !editing;
                                  if (editing) {
                                    nameEditController.text = widget.group.groupName!;
                                  } else if (widget.group.groupName != nameEditController.text) {
                                    if (nameEditController.text.isEmpty) return;

                                    widget.group.groupName = nameEditController.text;
                                    prefs.setString("teamGroup", jsonEncode(widget.group.toJson()));
                                    database.updateGroupName(widget.group.groupId!, widget.group.groupName!);
                                  }
                                });
                              },
                              child: Icon(editing ? Icons.done : Icons.edit_outlined,
                                  color: Theme.of(context).colorScheme.secondary, size: 24),
                            )
                          : const SizedBox.shrink(),
                    ]),
                    const SizedBox(height: 23),
                    SizedBox(
                      height: 25,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Allow Join", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                        editing
                            ? Switch(
                                value: widget.group.allowJoin,
                                onChanged: (bool value) async {
                                  await database.updateAllowJoin(widget.group.groupId!, value);
                                  setState(() {
                                    widget.group.allowJoin = value;
                                    prefs.setString("teamGroup", jsonEncode(widget.group.toJson()));
                                  });
                                },
                              )
                            : Text(widget.group.allowJoin ? "Yes" : "No",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))
                      ]),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 25,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Join Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                        const Spacer(),
                        editing
                            ? GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    generatingCode = true;
                                  });
                                  final newCode = await database.generateNewJoinCode(widget.group.groupId!);
                                  setState(() {
                                    widget.group.joinCode = newCode!;
                                    prefs.setString("teamGroup", jsonEncode(widget.group.toJson()));
                                    generatingCode = false;
                                  });
                                },
                                child: generatingCode
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
                                    : Icon(Icons.cached, color: Theme.of(context).colorScheme.secondary),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(width: 5),
                        Text(widget.group.joinCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ])),
          const SizedBox(height: 23),
          const SizedBox(
            width: double.infinity,
            child: Text("Members", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    setState(() {
                      if (!isAdmin) return;
                      selectedMemberIndex = selectedMemberIndex == index ? -1 : index;
                    });
                  },
                  splashColor: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                      height: 60,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 30,
                        ),
                        const SizedBox(width: 5),
                        Text(widget.group.members.values.toList()[index],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        widget.group.members.keys.toList()[index] == widget.group.adminId
                            ? Icon(Icons.manage_accounts_outlined, color: Theme.of(context).colorScheme.secondary)
                            : const SizedBox.shrink(),
                        const SizedBox(width: 8),
                      ])));
            },
            itemCount: widget.group.members.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
          const SizedBox(height: 5),
          isAdmin && selectedMemberIndex != -1
              ? SizedBox(
                  height: 20,
                  child: widget.group.members.keys.toList()[selectedMemberIndex] != widget.group.adminId
                      ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Transfer Admin"),
                                        content: Text.rich(TextSpan(
                                            text: "Are you sure you want to transfer admin to ",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                            children: [
                                              TextSpan(
                                                text: widget.group.members.values.toList()[selectedMemberIndex],
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: "?",
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                              )
                                            ])),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                              child: Text("Transfer",
                                                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                              onPressed: () async {
                                                String id = widget.group.members.keys.toList()[selectedMemberIndex];
                                                await database.promoteNewAdmin(
                                                    widget.group.groupId!, FirebaseAuth.instance.currentUser!.uid, id);
                                                Navigator.pop(context);
                                                setState(() {
                                                  isAdmin = false;
                                                  widget.group.adminId = id;
                                                  prefs.setString("teamGroup", jsonEncode(widget.group.toJson()));
                                                  selectedMemberIndex = -1;
                                                });
                                              })
                                        ],
                                        actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(18)),
                                      );
                                    });
                              },
                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 8),
                                Text("Transfer Admin",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.secondary)),
                              ])),
                          GestureDetector(
                              onTap: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Remove Member"),
                                        content: Text.rich(TextSpan(
                                            text: "Are you sure you want to remove ",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                            children: [
                                              TextSpan(
                                                text: widget.group.members.values.toList()[selectedMemberIndex],
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: " from this group?",
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                              )
                                            ])),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel",
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                              child: Text("Remove",
                                                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                              onPressed: () async {
                                                String id = widget.group.members.keys.toList()[selectedMemberIndex];
                                                await database.removeMember(widget.group.groupId!, id);
                                                Navigator.pop(context);
                                                setState(() {
                                                  widget.group.members.remove(id);
                                                  prefs.setString("teamGroup", jsonEncode(widget.group.toJson()));
                                                  selectedMemberIndex = -1;
                                                });
                                              }),
                                        ],
                                        actionsPadding: const EdgeInsets.only(bottom: 8, right: 16),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(18)),
                                      );
                                    });
                              },
                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                Icon(Icons.person_remove_outlined, color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Text("Remove Member",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.error)),
                              ])),
                        ])
                      : const SizedBox.shrink())
              : const SizedBox(height: 20),
          const SizedBox(height: 15),
          isAdmin
              ? Column(children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text("Manage", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 23),
                  GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Clear Scoutsheets"),
                                content: const Text.rich(TextSpan(
                                    text: "Are you sure you want to ",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                    children: [
                                      TextSpan(
                                        text: "permanently clear",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                        text: " all Scoutsheets?",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                      ),
                                    ])),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel",
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                      child:
                                          Text("Clear", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      onPressed: () {
                                        database.clearScoutsheets(widget.group.groupId!);
                                        Navigator.pop(context);
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
                        Text("Clear Scoutsheets",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.error)),
                        Icon(Icons.contact_page_outlined, color: Theme.of(context).colorScheme.error),
                      ])),
                  const SizedBox(height: 18),
                  GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Clear Match Notes"),
                                content: const Text.rich(TextSpan(
                                    text: "Are you sure you want to ",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                    children: [
                                      TextSpan(
                                        text: "permanently clear",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                        text: " all Match Notes?",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                      ),
                                    ])),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel",
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                      child:
                                          Text("Clear", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      onPressed: () {
                                        database.clearMatchNotes(widget.group.groupId!);
                                        Navigator.pop(context);
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
                        Text("Clear Match Notes",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.error)),
                        Icon(Icons.gamepad_outlined, color: Theme.of(context).colorScheme.error),
                      ])),
                  const SizedBox(height: 18),
                  GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Delete Team Group"),
                                content: const Text.rich(TextSpan(
                                    text: "Are you sure you want to ",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                    children: [
                                      TextSpan(
                                        text: "delete",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                        text: " this group? This action ",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                      ),
                                      TextSpan(
                                        text: "cannot",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                        text: " be undone.\n\n",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                      ),
                                      TextSpan(
                                        text: "All Scoutsheets and Match Notes will be deleted as well.",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ])),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel",
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                      child:
                                          Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      onPressed: () {
                                        Navigator.of(context)
                                          ..pop()
                                          ..pop();
                                        database.deleteTeamGroup(widget.group.groupId!);
                                        prefs.remove("teamGroup");
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
                        Text("Delete Group",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.error)),
                        Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                      ])),
                ])
              : GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Leave Team Group"),
                            content: const Text("Are you sure you want to leave this group?"),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            actions: [
                              TextButton(
                                child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                  child: Text("Leave", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                  onPressed: () {
                                    Navigator.of(context)
                                      ..pop()
                                      ..pop();
                                    Database database = Database();
                                    database.leaveTeamGroup(
                                        widget.group.groupId!, FirebaseAuth.instance.currentUser!.uid);
                                    prefs.remove("teamGroup");
                                  })
                            ],
                            actionsPadding: const EdgeInsets.only(bottom: 8, left: 8),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(18)),
                          );
                        });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Leave Group",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.error)),
                    Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                  ])),
        ])),
      )
    ]));
  }
}
