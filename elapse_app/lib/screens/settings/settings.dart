import 'dart:convert';

import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:provider/provider.dart';

import '../../classes/Team/teamPreview.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const ElapseAppBar(
            title: Text(
              "Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            backNavigation: true,
          ),
          const RoundedTop(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Account Name",
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w600)),
                                        Text("example.email@gmail.com",
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ]),
                                  CircleAvatar(
                                    radius: 32,
                                    child: const Icon(Icons.person, size: 40),
                                  )
                                ]),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(children: [
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: mainTeamId,
                                      menuMaxHeight: 250,
                                      items: getSavedTeams()
                                          .map((e) => DropdownMenuItem(
                                              value: e.teamID,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.group,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
                                                  const SizedBox(width: 15),
                                                  Text("Team ${e.teamNumber}"),
                                                ],
                                              )))
                                          .toList(),
                                      onChanged: (int? value) {
                                        final String savedTeam =
                                            prefs.getString("savedTeam") ?? "";
                                        final List<String> savedTeams =
                                            prefs.getStringList("savedTeams") ??
                                                [];
                                        String selected = savedTeams
                                            .where((e) =>
                                                jsonDecode(e)["teamID"] ==
                                                value)
                                            .toList()[0];
                                        savedTeams.removeWhere((e) =>
                                            jsonDecode(e)["teamID"] == value);
                                        savedTeams.add(savedTeam);
                                        prefs.setStringList(
                                            "savedTeams", savedTeams);
                                        prefs.setString("savedTeam", selected);

                                        setState(() {
                                          mainTeamId = value!;
                                        });
                                      },
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )
                              ]),
                            ),
                            Container(
                              height: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: Material(
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        splashColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.05),
                                        onTap: () {
                                          print("clicked1");
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                                SizedBox(width: 12),
                                                Text("More Teams")
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: VerticalDivider(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 4,
                                    child: Material(
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        splashColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.05),
                                        onTap: () {},
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                                SizedBox(width: 12),
                                                Text("Edit Profile")
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ])),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: double.infinity,
                    child: Text("Tournament",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 25),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Use Live Timing",
                            style: TextStyle(fontSize: 18)),
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
                    child: Text("General",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 25),
                  Consumer<ColorProvider>(
                      builder: (context, colorProvider, snapshot) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                    textAlign: TextAlign
                                        .right, // Align text to the right
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "dark",
                                  child: Text(
                                    "Dark",
                                    textAlign: TextAlign
                                        .right, // Align text to the right
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "light",
                                  child: Text(
                                    "Light",
                                    textAlign: TextAlign
                                        .right, // Align text to the right
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

                              alignment: Alignment
                                  .centerRight, // Keep dropdown button content aligned
                            ),
                          )
                        ]);
                  }),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Default grade",
                            style: TextStyle(fontSize: 18)),
                        DropdownButtonHideUnderline(
                            child: DropdownButton(
                          value: defaultGrade,
                          items: const [
                            DropdownMenuItem(
                                value: "Main Team", child: Text("Main Team")),
                            DropdownMenuItem(
                                value: "Middle School",
                                child: Text("Middle School")),
                            DropdownMenuItem(
                                value: "High School",
                                child: Text("High School")),
                            DropdownMenuItem(
                                value: "College", child: Text("College"))
                          ],
                          onChanged: (String? value) {
                            prefs.setString("defaultGrade", value!);

                            setState(() {
                              defaultGrade = value;
                            });
                          },
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18),
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
                    child: Text("Other",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Version", style: TextStyle(fontSize: 18)),
                          Text("1.0.0",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant))
                        ]),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        width: double.infinity,
                        child: const Text("Send Feedback",
                            style: TextStyle(fontSize: 18)),
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
  final parsed = jsonDecode(savedTeam);
  List<TeamPreview> savedTeamsList = [
    TeamPreview(teamID: parsed["teamID"], teamNumber: parsed["teamNumber"])
  ];

  final List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
  savedTeamsList.addAll(savedTeams.map((e) => TeamPreview(
      teamID: jsonDecode(e)["teamID"],
      teamNumber: jsonDecode(e)["teamNumber"])));

  return savedTeamsList;
}
