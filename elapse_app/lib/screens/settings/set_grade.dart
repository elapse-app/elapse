import 'dart:convert';

import 'package:elapse_app/providers/color_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/Team/team.dart';
import '../../main.dart';

class GradeSettings extends StatefulWidget {
  GradeSettings({super.key});

  String gradeLevel = prefs.getString("defaultGrade") ?? "Main Team";

  @override
  State<GradeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<GradeSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                IconButton(
                    padding: EdgeInsets.only(right: 10, bottom: 10, top: 10),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.arrow_back, size: 48)),
                const Text(
                  "Set your Default Grade Level",
                  style: TextStyle(
                      fontSize: 64, fontWeight: FontWeight.w500, height: 1),
                ),
                const SizedBox(
                  height: 64,
                ),
                Consumer<ColorProvider>(builder: (
                    context,
                    colorProvider,
                    snapshot,
                    ) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.settings, size: 75),
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                              Theme.of(context).colorScheme.secondary,
                              value: "Default",
                              groupValue: widget.gradeLevel,
                              onChanged: (value) {
                                setState(() {
                                  widget.gradeLevel = value!;
                                });
                              }),
                          Text(
                            "Default",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                              Theme.of(context).colorScheme.secondary,
                              value: "Middle School",
                              groupValue: widget.gradeLevel,
                              onChanged: (value) {
                                setState(() {
                                  widget.gradeLevel = value!;
                                });
                              }),
                          Text(
                            "Middle\nSchool",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color:
                                  Theme.of(context).colorScheme.onSurface,
                                  width: 5),
                            ),
                          ),
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                              Theme.of(context).colorScheme.secondary,
                              value: "High School",
                              groupValue: widget.gradeLevel,
                              onChanged: (value) {
                                setState(() {
                                  widget.gradeLevel = value!;
                                });
                              }),
                          Text(
                            "High School",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color:
                                  Theme.of(context).colorScheme.onSurface,
                                  width: 5),
                            ),
                          ),
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                              Theme.of(context).colorScheme.secondary,
                              value: "College",
                              groupValue: widget.gradeLevel,
                              onChanged: (value) {
                                setState(() {
                                  widget.gradeLevel = value!;
                                });
                              }),
                          Text(
                            "College",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ],
                  );
                }),
                SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    Spacer(),
                    TextButton(
                        style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.secondary)),
                        onPressed: () async {
                          if (widget.gradeLevel == "Default") {
                            prefs.setString("defaultGrade", (await fetchTeam(jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"])).grade!.name);
                          } else {
                            prefs.setString("defaultGrade", widget.gradeLevel);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save default grade level",
                          style: TextStyle(fontSize: 18),
                        )),
                    Spacer(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
