import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elapse_app/classes/Filters/season.dart';
import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/ScoutSheet/scoutSheetUi.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Team/world_skills.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/screens/settings/setup_group.dart';
import 'package:elapse_app/screens/team_screen/details/details.dart';
import 'package:elapse_app/screens/team_screen/scoutsheet/closed.dart';
import 'package:elapse_app/screens/team_screen/scoutsheet/edit.dart';
import 'package:elapse_app/screens/team_screen/scoutsheet/empty.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/custom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Groups/teamGroup.dart';
import '../widgets/big_error_message.dart';
import '../widgets/long_button.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.teamID, required this.teamNumber, this.team});
  final int teamID;
  final String teamNumber;
  final Team? team;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late TeamPreview teamSave;

  bool locationLoaded = false;
  bool isEditing = false;
  int pageIndex = 0;
  int scoutSheetStateIndex = 0;
  int selectedTournamentIndex = 0;
  String selectedTournamentName = "";
  String teamGroupID = prefs.getString("teamGroup") != null
      ? TeamGroup.fromJson(jsonDecode(prefs.getString("teamGroup")!)).groupId!
      : "";
  TournamentPreview selectedTournament = TournamentPreview(id: 0, name: "");
  ScoutSheetUI activeScoutSheet = ScoutSheetUI(
    intakeType: "",
    numMotors: "",
    RPM: "",
    otherNotes: "",
    photos: [],
    autonNotes: "",
  );

  Future<Tournament>? tournament;
  Future<Team>? team;
  Future<VDAStats?>? teamStats;
  Future<WorldSkillsStats>? skillsStats;
  Future<List<TournamentPreview>>? teamTournaments;
  Future<List<Award>>? teamAwards;
  Future<DocumentSnapshot<Object?>?>? scoutSheet;

  late Season season;
  Database database = Database();
  String scoutsheetID = "";

  @override
  void initState() {
    super.initState();
    teamSave = TeamPreview(teamID: widget.teamID, teamNumber: widget.teamNumber);
    isSaved = false;
    displaySave = true;
    team = fetchTeam(widget.teamID).then(
      (value) {
        setState(() {
          teamSave.location = value.location;
          teamSave.teamName = value.teamName;
          locationLoaded = true;
        });
        return value;
      },
    );
    season = seasons[0];
    teamStats = getTrueSkillDataForTeam(season.vrcId, widget.teamNumber);
    skillsStats = getWorldSkillsForTeam(season.vrcId, widget.teamID);
    teamAwards = getAwards(widget.teamID, season.vrcId);

    teamTournaments = fetchTeamTournaments(widget.teamID, season.vrcId).then(
      (value) {
        if (value.isNotEmpty && teamGroupID.isNotEmpty) {
          setState(() {
            selectedTournament = value[0];
          });
          scoutSheet =
              database.getTeamScoutSheetInfo(teamGroupID, widget.teamID.toString(), value[0].id.toString()).then(
            (value) {
              if (value != null) {
                print(value.data());
                Map<String, dynamic> sheet = value.data() as Map<String, dynamic>;
                Map<String, dynamic> specs = sheet["properties"]["Specs"];
                setState(() {
                  scoutsheetID = value.id;
                  scoutSheetStateIndex = 1;
                  activeScoutSheet = ScoutSheetUI(
                      intakeType: specs["intakeType"] ?? "",
                      numMotors: specs["numMotors"] ?? "",
                      RPM: specs["RPM"] ?? "",
                      otherNotes: specs["otherNotes"] ?? "",
                      photos: specs["photos"] ?? [],
                      autonNotes: specs["numMotors"] ?? "");
                });
                return value;
              } else {
                setState(() {
                  scoutSheetStateIndex = 0;
                });
              }
              return null;
            },
          );
        }
        return value;
      },
    );
    teamAwards = getAwards(widget.teamID, season.vrcId);
    isSaved = alreadySaved();
    displaySave = !isMainTeam();

    if (prefs.getBool("isTournamentMode") ?? false) {
      tournament = TMTournamentDetails(prefs.getInt("tournamentID") ?? 0);
    }
  }

  bool alreadySaved() {
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    return savedTeams.any((element) {
          return jsonDecode(element)["teamID"] == widget.teamID;
        }) ||
        isMainTeam();
  }

  bool isMainTeam() {
    return jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"] == widget.teamID.toString();
  }

  void toggleSaveTeam() {
    if (!locationLoaded) {
      return;
    }
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    if (isSaved) {
      savedTeams.removeWhere((test) {
        return jsonDecode(test)["teamID"] == widget.teamID;
      });
    } else {
      savedTeams.add(jsonEncode(teamSave.toJson()));
    }
    prefs.setStringList("savedTeams", savedTeams);
    setState(() {
      isSaved = !isSaved;
    });
  }

  List<File> photos = [];

  void addPhoto(String photo) {
    setState(() {
      activeScoutSheet.photos.add(photo);
      database.addPhoto(teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), photo);
    });
  }

  void removePhoto(int index) async {
    await database.deletePhoto(
        teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), activeScoutSheet.photos[index]);
    setState(() {
      activeScoutSheet.photos.removeAt(index);
    });
  }

  void updateSheet(String property, String value) async {
    switch (property) {
      case "intakeType":
        setState(() {
          activeScoutSheet.intakeType = value;
        });
        await database.updateProperty(
            teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), "Specs", activeScoutSheet.toMap());
        break;
      case "numMotors":
        setState(() {
          activeScoutSheet.numMotors = value;
        });
        await database.updateProperty(
            teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), "Specs", activeScoutSheet.toMap());
        break;
      case "RPM":
        setState(() {
          activeScoutSheet.RPM = value;
        });
        await database.updateProperty(
            teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), "Specs", activeScoutSheet.toMap());
        break;
      case "otherNotes":
        setState(() {
          activeScoutSheet.otherNotes = value;
        });
        await database.updateProperty(
            teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), "Specs", activeScoutSheet.toMap());
        break;
      case "autonNotes":
        setState(() {
          activeScoutSheet.autonNotes = value;
        });
        await database.updateProperty(
            teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), "Specs", activeScoutSheet.toMap());
        break;
    }
  }

  late bool isSaved;
  late bool displaySave;
  @override
  Widget build(BuildContext context) {
    List<Widget> DetailsScreen =
        Details(context, widget.teamNumber, teamSave, displaySave, isSaved, toggleSaveTeam, () {
      setState(() {});
    }, widget.team, team, teamStats, teamAwards, teamTournaments, tournament, skillsStats);

    List<Widget> ScoutSheetClosedScreen = ClosedState(
        context, widget.teamNumber, activeScoutSheet, widget.teamID.toString(), selectedTournament.id.toString(),
        () async {
      await database.removeTeamScoutSheet(widget.teamID.toString(), teamGroupID, selectedTournament.id.toString());
      setState(() {
        scoutSheetStateIndex = 0;
        activeScoutSheet = ScoutSheetUI(
          intakeType: "",
          numMotors: "",
          RPM: "",
          otherNotes: "",
          photos: [],
          autonNotes: "",
        );
      });
      Navigator.pop(context);
    });
    List<Widget> ScoutsheetEditScreen = EditState(
        context, widget.teamNumber, addPhoto, removePhoto, activeScoutSheet.photos, updateSheet, activeScoutSheet);
    List<Widget> ScoutSheetEmpty = selectedTournament.id != 0 && teamGroupID.isNotEmpty
        ? EmptyState(context, () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Creating Scoutsheet"),
                  content: Text("You will be able to edit once the scoutsheet is created"),
                );
              },
            );
            await database
                .createTeamScoutSheet(teamGroupID, widget.teamID.toString(), selectedTournament.id.toString())
                .then(
              (id) async {
                await database.updateMemberEditing(
                    teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), true);
                print(id);
                Navigator.pop(context);
                setState(() {
                  scoutsheetID = id;
                  scoutSheetStateIndex = 2;
                });
              },
            );
          })
        : [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                margin: EdgeInsets.only(left: 23, right: 23, top: 8),
                padding: EdgeInsets.all(18),
                alignment: Alignment.center,
                child: Column(children: [
                  BigErrorMessage(
                    icon: Icons.people_alt_outlined,
                    message: "Not in a team group",
                    topPadding: 0,
                    textPadding: 5,
                  ),
                  const SizedBox(height: 18),
                  LongButton(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => GroupSetupPage()));
                        setState(() {
                          teamGroupID = prefs.getString("teamGroup") ?? "";
                        });
                      },
                      text: "Set Up a Team Group")
                ]),
              ),
            )
          ];

    List<Widget> ScoutSheetCurrentlyEditing = [
      SliverToBoxAdapter(child: Text("ScoutSheet is currently being edited from another member"))
    ];

    List<List<Widget>> ScoutSheetScreens = [ScoutSheetEmpty, ScoutSheetClosedScreen, ScoutsheetEditScreen];

    Widget button;

    switch (scoutSheetStateIndex) {
      case 1:
        button = IconButton(
          onPressed: () {
            setState(() {
              scoutSheetStateIndex = 2;
            });
          },
          icon: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).colorScheme.secondary,
          ),
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
        );
        break;
      case 2:
        button = IconButton(
          onPressed: () async {
            await database.updateMemberEditing(
                teamGroupID, widget.teamID.toString(), selectedTournament.id.toString(), false);
            setState(() {
              scoutSheetStateIndex = 1;
            });
          },
          icon: Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.secondary,
          ),
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
        );
        break;
      default:
        button = IconButton(
          onPressed: () {},
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.crop_square_sharp,
            color: Colors.transparent,
          ),
          padding: EdgeInsets.all(8),
        );
        break;
    }

    List<Widget> ScoutSheetScreen = [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 23.0, right: 11),
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  height: 32,
                  padding: const EdgeInsets.only(left: 9),
                  alignment: Alignment.centerLeft,
                  child: scoutSheetStateIndex == 1 || scoutSheetStateIndex == 0
                      ? FutureBuilder<Object>(
                          future: teamTournaments,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                "Loading...",
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: "Manrope",
                                    fontSize: 15.9,
                                    fontWeight: FontWeight.w500),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                "Error occured",
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: "Manrope",
                                    fontSize: 15.9,
                                    fontWeight: FontWeight.w500),
                              );
                            }
                            List<TournamentPreview> tournaments = snapshot.data as List<TournamentPreview>;
                            if (tournaments.isEmpty) {
                              return Text(
                                "No Tournaments",
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: "Manrope",
                                    fontSize: 15.9,
                                    fontWeight: FontWeight.w500),
                              );
                            }
                            tournaments.sort((a, b) => (a.startDate != null && b.startDate != null)
                                ? ((a.startDate!.compareTo(DateTime.now()) < b.startDate!.compareTo(DateTime.now()))
                                    ? 1
                                    : -1)
                                : -1);
                            return DropdownButtonHideUnderline(
                              child: DropdownButton(
                                borderRadius: BorderRadius.circular(18),
                                isExpanded: true,
                                value: tournaments[selectedTournamentIndex].id,
                                menuMaxHeight: 250,
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: "Manrope",
                                    fontSize: 15.9,
                                    letterSpacing: 0.25,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface),
                                items: tournaments.map((tournament) {
                                  return DropdownMenuItem(
                                    value: tournament.id,
                                    child: Text(
                                      tournament.name,
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily: "Manrope",
                                          fontSize: 15.9,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => {
                                  setState(
                                    () {
                                      selectedTournamentIndex =
                                          tournaments.indexWhere((element) => element.id == value);
                                      selectedTournament = tournaments[selectedTournamentIndex];
                                      if (teamGroupID.isNotEmpty) {
                                        scoutSheet = database
                                            .getTeamScoutSheetInfo(
                                                teamGroupID, widget.teamID.toString(), selectedTournament.id.toString())
                                            .then(
                                          (value) {
                                            if (value != null) {
                                              setState(() {
                                                scoutsheetID = value.id;
                                                scoutSheetStateIndex = 1;
                                              });
                                            } else {
                                              setState(() {
                                                scoutSheetStateIndex = 0;
                                              });
                                            }
                                            return value;
                                          },
                                        );
                                      }
                                    },
                                  ),
                                },
                              ),
                            );
                          })
                      : Text(
                          selectedTournament.name,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontFamily: "Manrope",
                              fontSize: 15.9,
                              fontWeight: FontWeight.w500),
                        ),
                ),
              ),
              Flexible(flex: 2, fit: FlexFit.tight, child: SizedBox()),
              Flexible(fit: FlexFit.tight, child: button)
            ],
          ),
        ),
      ),
    ];

    ScoutSheetScreen.addAll(ScoutSheetScreens[scoutSheetStateIndex]);

    List<List<Widget>> screens = [DetailsScreen, ScoutSheetScreen];

    List<Widget> MainSlivers = [
      ElapseAppBar(
        title: const Text(
          "Team Info",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backNavigation: true,
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () async {
                    Season updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeasonFilterPage(selected: season),
                      ),
                    );
                    setState(() {
                      season = updated;
                      skillsStats = getWorldSkillsForTeam(season.vrcId, widget.teamID);
                      teamStats = getTrueSkillDataForTeam(season.vrcId, widget.teamNumber);
                      teamTournaments = fetchTeamTournaments(widget.teamID, season.vrcId);
                      teamAwards = getAwards(widget.teamID, season.vrcId);
                    });
                  },
                  child: Row(children: [
                    const Icon(Icons.event_note),
                    const SizedBox(width: 4),
                    Text(
                      season.name.substring(10),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_right)
                  ]))
            ],
          ),
        ),
      ),
      CustomTabBar(
          tabs: ["Details", "Scoutsheet"],
          onPressed: (value) {
            setState(() {
              pageIndex = value;
            });
          }),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: MainSlivers + screens[pageIndex],
      ),
    );
  }
}

class TeamBio extends StatelessWidget {
  const TeamBio({
    super.key,
    required this.grade,
    required this.location,
    required this.teamName,
    required this.organization,
  });

  final String grade;
  final Location location;
  final String teamName;
  final String organization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getGrade(grade),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Grade",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getLocation(location),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Location",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 12,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Team Name",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String getGrade(String? grade) {
  if (grade == "High School") {
    return "HS";
  } else if (grade == "Middle School") {
    return "MS";
  } else if (grade == "College") {
    return "CG";
  } else {
    return "NG";
  }
}

String getLocation(Location? location) {
  if (location?.city != null) {
    return "${location!.city}, ${location.region}";
  } else {
    return "No Location";
  }
}
