import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elapse_app/classes/Filters/season.dart';
import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_sheet_data.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_template_repository.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Team/world_skills.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/screens/settings/setup_group.dart';
import 'package:elapse_app/screens/scout/templates/scout_template_list.dart';
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
  int pageIndex = 0;
  int scoutSheetStateIndex = 0;
  int selectedTournamentIndex = 0;
  late String teamGroupID;
  TournamentPreview selectedTournament = TournamentPreview(id: 0, name: "");
  ScoutSheetData activeScoutSheet =
      ScoutSheetData.empty(ScoutSheetTemplate.standard);

  Future<Tournament>? tournament;
  Future<Team>? team;
  Future<VDAStats?>? teamStats;
  Future<WorldSkillsStats>? skillsStats;
  Future<List<TournamentPreview>>? teamTournaments;
  Future<List<Award>>? teamAwards;

  late Season season;
  final Database database = Database();
  late final ScoutTemplateRepository _templateRepository;
  Timer? _saveDebounce;
  bool _savingAnswers = false;
  String scoutsheetID = "";

  @override
  void initState() {
    super.initState();
    _templateRepository = ScoutTemplateRepository(prefs);
    teamGroupID = _readTeamGroupId();
    activeScoutSheet = ScoutSheetData.empty(
      _templateRepository.loadDefaultTemplate(),
    );
    teamSave =
        TeamPreview(teamID: widget.teamID, teamNumber: widget.teamNumber);
    isSaved = false;
    displaySave = true;
    team = fetchTeam(widget.teamID).then(
      (value) {
        if (!mounted) return value;
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

    teamTournaments = _fetchTournamentsForSeason(season);
    isSaved = alreadySaved();
    displaySave = !isMainTeam();

    if (prefs.getBool("isTournamentMode") ?? false) {
      tournament = TMTournamentDetails(prefs.getInt("tournamentID") ?? 0);
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    if (scoutsheetID.isNotEmpty && activeScoutSheet.answers.isNotEmpty) {
      unawaited(
        database
            .updateTeamScoutSheetAnswers(
              teamGroupID,
              scoutsheetID,
              activeScoutSheet.answers,
            )
            .catchError((_) {}),
      );
    }
    super.dispose();
  }

  bool alreadySaved() {
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    return savedTeams.any((element) {
          return jsonDecode(element)["teamID"] == widget.teamID;
        }) ||
        isMainTeam();
  }

  bool isMainTeam() {
    return tryLoadTeamPreview(prefs.getString('savedTeam'))?.teamID ==
        widget.teamID;
  }

  String _readTeamGroupId() {
    final encodedGroup = prefs.getString('teamGroup');
    if (encodedGroup == null || encodedGroup.isEmpty) return '';
    try {
      return TeamGroup.fromJson(jsonDecode(encodedGroup)).groupId ?? '';
    } on Object {
      return '';
    }
  }

  Future<List<TournamentPreview>> _fetchTournamentsForSeason(
    Season requestedSeason,
  ) async {
    final tournaments = await fetchTeamTournaments(
      widget.teamID,
      requestedSeason.vrcId,
    );
    if (!mounted || season.vrcId != requestedSeason.vrcId) return tournaments;

    final firstTournament = tournaments.isEmpty
        ? TournamentPreview(id: 0, name: '')
        : tournaments.first;
    setState(() {
      selectedTournamentIndex = 0;
      selectedTournament = firstTournament;
      scoutsheetID = '';
      scoutSheetStateIndex = 0;
      activeScoutSheet = ScoutSheetData.empty(
        _templateRepository.loadDefaultTemplate(),
      );
    });
    if (firstTournament.id != 0 && teamGroupID.isNotEmpty) {
      unawaited(_loadScoutSheet(firstTournament));
    }
    return tournaments;
  }

  Future<void> _loadScoutSheet(TournamentPreview tournament) async {
    if (teamGroupID.isEmpty || tournament.id == 0) return;
    final requestedTournamentId = tournament.id;
    final DocumentSnapshot<Object?>? document;
    try {
      document = await database.getTeamScoutSheetInfo(
        teamGroupID,
        widget.teamID.toString(),
        requestedTournamentId.toString(),
      );
    } on Object {
      if (mounted && selectedTournament.id == requestedTournamentId) {
        _showError('Could not load this scout sheet.');
      }
      return;
    }
    if (!mounted || selectedTournament.id != requestedTournamentId) return;

    if (document == null) {
      setState(() {
        scoutsheetID = '';
        scoutSheetStateIndex = 0;
        activeScoutSheet = ScoutSheetData.empty(
          _templateRepository.loadDefaultTemplate(),
        );
      });
      return;
    }

    final rawData = document.data();
    final data = rawData is Map
        ? ScoutSheetData.fromFirestore(Map<String, dynamic>.from(rawData))
        : ScoutSheetData.empty(ScoutSheetTemplate.standard);
    final documentId = document.id;
    setState(() {
      scoutsheetID = documentId;
      scoutSheetStateIndex = 1;
      activeScoutSheet = data;
    });
  }

  Future<void> _selectTournament(
    List<TournamentPreview> tournaments,
    int tournamentId,
  ) async {
    await _flushAnswerSave();
    final index = tournaments.indexWhere((event) => event.id == tournamentId);
    if (index < 0 || !mounted) return;
    setState(() {
      selectedTournamentIndex = index;
      selectedTournament = tournaments[index];
      scoutsheetID = '';
      scoutSheetStateIndex = 0;
      activeScoutSheet = ScoutSheetData.empty(
        _templateRepository.loadDefaultTemplate(),
      );
    });
    await _loadScoutSheet(tournaments[index]);
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

  void addPhoto(String photo) {
    if (scoutsheetID.isEmpty || activeScoutSheet.photos.length >= 6) return;
    final previous = activeScoutSheet;
    setState(() {
      activeScoutSheet = activeScoutSheet.withPhotos(
        [...activeScoutSheet.photos, photo],
      );
    });
    unawaited(
      database
          .addTeamScoutSheetPhoto(teamGroupID, scoutsheetID, photo)
          .catchError((Object error) {
        if (mounted) {
          setState(() => activeScoutSheet = previous);
          _showError('Could not save that photo.');
        }
      }),
    );
  }

  Future<void> removePhoto(int index) async {
    if (scoutsheetID.isEmpty || index >= activeScoutSheet.photos.length) return;
    final previous = activeScoutSheet;
    final photo = activeScoutSheet.photos[index];
    setState(() {
      final updatedPhotos = [...activeScoutSheet.photos]..removeAt(index);
      activeScoutSheet = activeScoutSheet.withPhotos(updatedPhotos);
    });
    try {
      await database.deleteTeamScoutSheetPhoto(
        teamGroupID,
        scoutsheetID,
        photo,
      );
    } on Object {
      if (!mounted) return;
      setState(() => activeScoutSheet = previous);
      _showError('Could not remove that photo.');
    }
  }

  void updateSheet(String fieldId, Object? value) {
    setState(() {
      activeScoutSheet = activeScoutSheet.withAnswer(fieldId, value);
    });
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 450),
      () => unawaited(_flushAnswerSave()),
    );
  }

  Future<void> _flushAnswerSave() async {
    _saveDebounce?.cancel();
    if (_savingAnswers || scoutsheetID.isEmpty) return;
    _savingAnswers = true;
    final sheetId = scoutsheetID;
    final answers = activeScoutSheet.answers;
    try {
      await database.updateTeamScoutSheetAnswers(
        teamGroupID,
        sheetId,
        answers,
      );
    } on Object {
      if (mounted && sheetId == scoutsheetID) {
        _showError('Answers could not be saved. Check your connection.');
      }
    } finally {
      _savingAnswers = false;
      if (mounted &&
          sheetId == scoutsheetID &&
          !identical(answers, activeScoutSheet.answers)) {
        _saveDebounce = Timer(
          const Duration(milliseconds: 200),
          () => unawaited(_flushAnswerSave()),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createScoutSheet() async {
    final template = await _pickTemplate();
    if (template == null || !mounted) return;

    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 18),
            Expanded(child: Text('Creating scout sheet…')),
          ],
        ),
      ),
    );

    try {
      final id = await database.createTeamScoutSheet(
        teamGroupID,
        widget.teamID.toString(),
        selectedTournament.id.toString(),
        template,
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        scoutsheetID = id;
        activeScoutSheet = ScoutSheetData.empty(template);
        scoutSheetStateIndex = 2;
      });
    } on Object {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showError('Could not create the scout sheet.');
    }
  }

  Future<ScoutSheetTemplate?> _pickTemplate() {
    final templates = _templateRepository.loadTemplates();
    final defaultTemplate = _templateRepository.loadDefaultTemplate();
    return showModalBottomSheet<ScoutSheetTemplate>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Text(
                'Choose a template',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final template in templates)
              ListTile(
                leading: Icon(
                  template.id == defaultTemplate.id
                      ? Icons.star_rounded
                      : Icons.description_outlined,
                ),
                title: Text(template.name),
                subtitle: Text('${template.fields.length} fields'),
                onTap: () => Navigator.pop(sheetContext, template),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Manage templates'),
              onTap: () {
                Navigator.pop(sheetContext);
                unawaited(_openTemplateManager());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTemplateManager() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ScoutTemplateListScreen(
          repository: _templateRepository,
        ),
      ),
    );
    if (!mounted || scoutsheetID.isNotEmpty) return;
    setState(() {
      activeScoutSheet = ScoutSheetData.empty(
        _templateRepository.loadDefaultTemplate(),
      );
    });
  }

  late bool isSaved;
  late bool displaySave;
  @override
  Widget build(BuildContext context) {
    List<Widget> DetailsScreen = Details(context, widget.teamNumber, teamSave,
        displaySave, isSaved, toggleSaveTeam, () {
      setState(() {});
    }, widget.team, team, teamStats, teamAwards, teamTournaments, tournament,
        skillsStats);

    List<Widget> ScoutSheetClosedScreen = ClosedState(
        context,
        widget.teamNumber,
        activeScoutSheet,
        widget.teamID.toString(),
        selectedTournament.id.toString(), () async {
      if (scoutsheetID.isEmpty) return;
      await database.removeTeamScoutSheetById(teamGroupID, scoutsheetID);
      if (!mounted) return;
      setState(() {
        scoutsheetID = '';
        scoutSheetStateIndex = 0;
        activeScoutSheet = ScoutSheetData.empty(
          _templateRepository.loadDefaultTemplate(),
        );
      });
    });
    List<Widget> ScoutsheetEditScreen = EditState(
        context,
        widget.teamNumber,
        addPhoto,
        removePhoto,
        activeScoutSheet.photos,
        updateSheet,
        activeScoutSheet);
    List<Widget> ScoutSheetEmpty =
        selectedTournament.id != 0 && teamGroupID.isNotEmpty
            ? EmptyState(context, _createScoutSheet)
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
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GroupSetupPage()));
                            if (!context.mounted) return;
                            setState(() {
                              teamGroupID = _readTeamGroupId();
                            });
                            if (teamGroupID.isNotEmpty &&
                                selectedTournament.id != 0) {
                              await _loadScoutSheet(selectedTournament);
                            }
                          },
                          text: "Set Up a Team Group")
                    ]),
                  ),
                )
              ];

    List<List<Widget>> ScoutSheetScreens = [
      ScoutSheetEmpty,
      ScoutSheetClosedScreen,
      ScoutsheetEditScreen
    ];

    Widget button;

    switch (scoutSheetStateIndex) {
      case 1:
        button = IconButton(
          tooltip: 'Edit scout sheet',
          onPressed: () async {
            if (scoutsheetID.isEmpty) return;
            try {
              await database.setTeamScoutSheetEditing(
                teamGroupID,
                scoutsheetID,
                true,
              );
              if (mounted) setState(() => scoutSheetStateIndex = 2);
            } on Object {
              if (mounted) _showError('Could not start editing.');
            }
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
          tooltip: 'Finish editing',
          onPressed: () async {
            final missing = activeScoutSheet.missingRequiredFields;
            if (missing.isNotEmpty) {
              _showError('Complete required field: ${missing.first.label}');
              return;
            }
            await _flushAnswerSave();
            try {
              await database.setTeamScoutSheetEditing(
                teamGroupID,
                scoutsheetID,
                false,
              );
              if (mounted) setState(() => scoutSheetStateIndex = 1);
            } on Object {
              if (mounted) _showError('Could not finish editing.');
            }
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                            List<TournamentPreview> tournaments =
                                snapshot.data as List<TournamentPreview>;
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
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
                                onChanged: (value) {
                                  if (value != null) {
                                    unawaited(
                                      _selectTournament(tournaments, value),
                                    );
                                  }
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
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () async {
                    final updated = await Navigator.push<Season>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeasonFilterPage(selected: season),
                      ),
                    );
                    if (updated == null || !context.mounted) return;
                    setState(() {
                      season = updated;
                      skillsStats =
                          getWorldSkillsForTeam(season.vrcId, widget.teamID);
                      teamStats = getTrueSkillDataForTeam(
                          season.vrcId, widget.teamNumber);
                      teamTournaments = _fetchTournamentsForSeason(season);
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Grade",
                    style: TextStyle(
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
                    style: TextStyle(
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
                    style: TextStyle(
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
