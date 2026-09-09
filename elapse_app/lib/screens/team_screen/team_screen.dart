import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elapse_app/setup/signup/login_or_signup.dart';
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
import 'package:elapse_app/screens/team_screen/team_page_header.dart';
import 'package:elapse_app/screens/widgets/custom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Groups/teamGroup.dart';
import '../widgets/big_error_message.dart';
import '../widgets/long_button.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen(
      {super.key,
      required this.teamID,
      required this.teamNumber,
      this.team,
      this.scoutTemplate,
      this.openScoutSheet = false,
      this.returnAfterSave = false,
      this.initialSheetId,
      this.initialEvent});
  final int teamID;
  final String teamNumber;
  final Team? team;
  final ScoutSheetTemplate? scoutTemplate;
  final bool openScoutSheet;
  final bool returnAfterSave;
  final String? initialSheetId;
  final TournamentPreview? initialEvent;

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
  Future<void>? _answerSave;
  String scoutsheetID = "";
  bool _loadingSheet = false;
  String? _sheetLoadError;
  bool _initialEventPending = true;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.openScoutSheet ? 1 : 0;
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
    final tournaments = <TournamentPreview>[];
    try {
      tournaments.addAll(await fetchTeamTournaments(
        widget.teamID,
        requestedSeason.vrcId,
      ));
    } on Object {
      if (widget.initialEvent == null || !_initialEventPending) rethrow;
    }
    if (!mounted || season.vrcId != requestedSeason.vrcId) return tournaments;

    final requestedEvent = _initialEventPending ? widget.initialEvent : null;
    _initialEventPending = false;
    if (requestedEvent != null &&
        !tournaments.any((event) => event.id == requestedEvent.id)) {
      tournaments.insert(0, requestedEvent);
    }
    final firstTournament = requestedEvent ??
        (tournaments.isEmpty
            ? TournamentPreview(id: 0, name: '')
            : tournaments.first);
    setState(() {
      selectedTournamentIndex = tournaments.isEmpty
          ? 0
          : tournaments.indexWhere((event) => event.id == firstTournament.id);
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
    setState(() {
      _loadingSheet = true;
      _sheetLoadError = null;
    });
    final DocumentSnapshot<Object?>? document;
    try {
      document = widget.initialSheetId != null &&
              requestedTournamentId == widget.initialEvent?.id
          ? await FirebaseFirestore.instance
              .collection('teamGroups')
              .doc(teamGroupID)
              .collection('scoutsheets')
              .doc(widget.initialSheetId)
              .get()
          : await database.getTeamScoutSheetInfo(
              teamGroupID,
              widget.teamID.toString(),
              requestedTournamentId.toString(),
            );
    } on Object {
      if (mounted && selectedTournament.id == requestedTournamentId) {
        setState(() => _sheetLoadError =
            'Could not load this sheet. Retry before creating a new one.');
      }
      return;
    } finally {
      if (mounted && selectedTournament.id == requestedTournamentId) {
        setState(() => _loadingSheet = false);
      }
    }
    if (!mounted || selectedTournament.id != requestedTournamentId) return;

    if (document == null || !document.exists) {
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
    if (!await _flushAnswerSave()) return;
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
        unawaited(database.deleteUploadedPhoto(photo).catchError((_) {}));
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
      unawaited(database.deleteUploadedPhoto(photo).catchError((_) {}));
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

  Future<bool> _flushAnswerSave() async {
    _saveDebounce?.cancel();
    if (_answerSave != null) {
      await _answerSave;
      return _flushAnswerSave();
    }
    if (scoutsheetID.isEmpty) return true;
    final completion = Completer<void>();
    _answerSave = completion.future;
    final sheetId = scoutsheetID;
    final answers = activeScoutSheet.answers;
    try {
      await database.updateTeamScoutSheetAnswers(
        teamGroupID,
        sheetId,
        answers,
      );
      return true;
    } on Object {
      if (mounted && sheetId == scoutsheetID) {
        _showError('Answers could not be saved. Check your connection.');
      }
      return false;
    } finally {
      _answerSave = null;
      completion.complete();
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
    if (_loadingSheet || _sheetLoadError != null) return;
    final template = widget.scoutTemplate ?? await _pickTemplate();
    if (template == null || !mounted) return;

    await _createScoutSheetWithTemplate(template);
  }

  Future<void> _createScoutSheetWithTemplate(
      ScoutSheetTemplate template) async {
    if (teamGroupID.isEmpty ||
        selectedTournament.id == 0 ||
        scoutsheetID.isNotEmpty) return;

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
      // Make the new sheet's team easy to reopen from the Scout tab.
      if (!isSaved) toggleSaveTeam();
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
    final selected = await Navigator.push<ScoutSheetTemplate>(
      context,
      MaterialPageRoute(
        builder: (context) => ScoutTemplateListScreen(
          repository: _templateRepository,
          onUseTemplate: (template) => Navigator.pop(context, template),
        ),
      ),
    );
    if (!mounted || scoutsheetID.isNotEmpty) return;
    if (selected != null &&
        selectedTournament.id != 0 &&
        teamGroupID.isNotEmpty) {
      await _createScoutSheetWithTemplate(selected);
      return;
    }
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
        teamGroupID,
        addPhoto,
        removePhoto,
        activeScoutSheet.photos,
        updateSheet,
        activeScoutSheet);
    List<Widget> ScoutSheetEmpty = selectedTournament.id != 0 &&
            teamGroupID.isNotEmpty
        ? EmptyState(context, _createScoutSheet,
            templateName: widget.scoutTemplate?.name)
        : teamGroupID.isNotEmpty
            ? [
                const SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.all(23),
                  child: Text(
                      'Choose an event above to start a sheet. If no events are listed, try another season using the season selector at the top.'),
                ))
              ]
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
                        message: FirebaseAuth.instance.currentUser == null
                            ? 'Sign in to save scout sheets'
                            : 'Set up your group to save scout sheets',
                        topPadding: 0,
                        textPadding: 5,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                          'Scout sheets are shared with your team group. Create a group or join your teammates, then return here to start this sheet.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      LongButton(
                          onPressed: () async {
                            if (FirebaseAuth.instance.currentUser == null) {
                              await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpPage(),
                                  ));
                              if (!context.mounted) return;
                              setState(() => teamGroupID = _readTeamGroupId());
                              if (teamGroupID.isNotEmpty &&
                                  selectedTournament.id != 0) {
                                await _loadScoutSheet(selectedTournament);
                              }
                              return;
                            }
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const GroupSetupPage(
                                        returnToScouting: true)));
                            if (!context.mounted) return;
                            setState(() {
                              teamGroupID = _readTeamGroupId();
                            });
                            if (teamGroupID.isNotEmpty &&
                                selectedTournament.id != 0) {
                              await _loadScoutSheet(selectedTournament);
                            }
                          },
                          text: FirebaseAuth.instance.currentUser == null
                              ? 'Sign in or create account'
                              : 'Set up a team group')
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
        button = FilledButton.icon(
          label: const Text('Edit sheet'),
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
        );
        break;
      case 2:
        button = FilledButton.icon(
          label: const Text('Save sheet'),
          onPressed: () async {
            final missing = activeScoutSheet.missingRequiredFields;
            if (missing.isNotEmpty) {
              _showError('Complete required field: ${missing.first.label}');
              return;
            }
            if (!await _flushAnswerSave() || !mounted) return;
            try {
              await database.setTeamScoutSheetEditing(
                teamGroupID,
                scoutsheetID,
                false,
              );
              if (mounted) {
                setState(() => scoutSheetStateIndex = 1);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Sheet saved. Reopen it from Scout → My scout sheets.')));
                if (widget.returnAfterSave) Navigator.pop(context);
              }
            } on Object {
              if (mounted) _showError('Could not finish editing.');
            }
          },
          icon: Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.secondary,
          ),
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
        padding: const EdgeInsets.fromLTRB(23, 8, 23, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Scout ${widget.teamNumber}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(scoutSheetStateIndex == 2
              ? 'Fill in the fields below, then tap Save sheet. Changes also save to your team group as you type.'
              : scoutsheetID.isNotEmpty
                  ? 'Saved sheet • ${activeScoutSheet.template.name}. Tap Edit sheet to add notes. Choose another event below to view its sheet.'
                  : '2. Choose an event below, then create your sheet.${widget.scoutTemplate == null ? '' : '\nTemplate: ${widget.scoutTemplate!.name}'}'),
        ]),
      )),
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
            ],
          ),
        ),
      ),
    ];

    if (scoutSheetStateIndex != 0) {
      ScoutSheetScreen.add(SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(23, 12, 23, 8),
        child: button,
      )));
    }
    if (_loadingSheet) {
      ScoutSheetScreen.add(const SliverToBoxAdapter(
          child: Padding(
        padding: EdgeInsets.all(23),
        child: LinearProgressIndicator(),
      )));
    } else if (_sheetLoadError != null) {
      ScoutSheetScreen.add(SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.all(23),
        child: Column(children: [
          Text(_sheetLoadError!),
          TextButton(
              onPressed: () => _loadScoutSheet(selectedTournament),
              child: const Text('Retry loading sheet')),
        ]),
      )));
    } else {
      ScoutSheetScreen.addAll(ScoutSheetScreens[scoutSheetStateIndex]);
    }
    if (scoutSheetStateIndex == 2) {
      ScoutSheetScreen.add(SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.all(23),
        child: button,
      )));
    }

    List<List<Widget>> screens = [DetailsScreen, ScoutSheetScreen];

    List<Widget> MainSlivers = [
      TeamPageHeader(
        teamNumber: widget.teamNumber,
        onSeason: () async {
          if (!await _flushAnswerSave() || !mounted) return;
          final updated = await Navigator.push<Season>(
              context,
              MaterialPageRoute(
                builder: (_) => SeasonFilterPage(selected: season),
              ));
          if (updated == null || !mounted) return;
          setState(() {
            season = updated;
            skillsStats = getWorldSkillsForTeam(season.vrcId, widget.teamID);
            teamStats =
                getTrueSkillDataForTeam(season.vrcId, widget.teamNumber);
            teamTournaments = _fetchTournamentsForSeason(season);
            teamAwards = getAwards(widget.teamID, season.vrcId);
          });
        },
      ),
      CustomTabBar(
          initIndex: widget.openScoutSheet ? 1 : 0,
          tabs: ["Details", "Scout sheet"],
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
