import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/screens/team_screen/details/details.dart';
import 'package:elapse_app/screens/team_screen/scoutsheet/closed.dart';
import 'package:elapse_app/screens/team_screen/scoutsheet/edit.dart';
import 'package:elapse_app/screens/team_screen/scoutsheet/empty.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/custom_tab_bar.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen(
      {super.key, required this.teamID, required this.teamNumber, this.team});
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
  @override
  void initState() {
    super.initState();
    teamSave =
        TeamPreview(teamID: widget.teamID, teamNumber: widget.teamNumber);
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
    teamStats = getTrueSkillDataForTeam(widget.teamNumber);
    teamTournaments = fetchTeamTournaments(widget.teamID, 181);
    teamAwards = getAwards(widget.teamID, 181);
    isSaved = alreadySaved();
    displaySave = !isMainTeam();
  }

  bool alreadySaved() {
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    return savedTeams.any((element) {
          return jsonDecode(element)["teamID"] == widget.teamID;
        }) ||
        isMainTeam();
  }

  bool isMainTeam() {
    return jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"] ==
        widget.teamID.toString();
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

  Future<Team>? team;
  Future<VDAStats>? teamStats;
  Future<List<TournamentPreview>>? teamTournaments;
  Future<List<Award>>? teamAwards;

  late bool isSaved;
  late bool displaySave;
  @override
  Widget build(BuildContext context) {
    InputDecoration ElapseInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    List<Widget> DetailsScreen = Details(
        context,
        widget.teamNumber,
        displaySave,
        isSaved,
        toggleSaveTeam,
        widget.team,
        team,
        teamStats,
        teamAwards,
        teamTournaments);

    List<Widget> ScoutSheetClosedScreen =
        ClosedState(context, widget.teamNumber);

    List<Widget> ScoutsheetEditScreen = EditState(context, widget.teamNumber);

    List<Widget> ScoutSheetEmpty = EmptyState(context, () {
      setState(() {
        scoutSheetStateIndex = 2;
      });
      print(scoutSheetStateIndex);
    });

    List<List<Widget>> ScoutSheetScreens = [
      ScoutSheetEmpty,
      ScoutSheetClosedScreen,
      ScoutsheetEditScreen
    ];

    Widget button;

    switch (scoutSheetStateIndex) {
      case 1:
        button = IconButton(
          onPressed: () {
            setState(() {
              scoutSheetStateIndex = 0;
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
          onPressed: () {
            setState(() {
              scoutSheetStateIndex = 0;
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
                      ? DropdownButton(
                          borderRadius: BorderRadius.circular(18),
                          isExpanded: true,
                          value: "Caution Tape",
                          menuMaxHeight: 250,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontFamily: "Manrope",
                              fontSize: 16.25,
                              fontWeight: FontWeight.w500),
                          items: [
                            DropdownMenuItem(
                                value: "Caution Tape",
                                child:
                                    Text("Caution Tape Halloween Qualifier")),
                            DropdownMenuItem(
                                value: "Caution Tap",
                                child: Text("Caution Tape")),
                            DropdownMenuItem(
                                value: "Caution Ta",
                                child: Text("Caution Tape")),
                            DropdownMenuItem(
                                value: "Caution Ta",
                                child: Text("Caution Tape")),
                            DropdownMenuItem(
                                value: "Caution T",
                                child: Text("Caution Tape")),
                            DropdownMenuItem(
                                value: "Caution ", child: Text("Caution Tape")),
                          ],
                          onChanged: (value) => {},
                        )
                      : Text(
                          "Caution Tape",
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
        title: Text(
          "Team Info",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backNavigation: true,
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
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
