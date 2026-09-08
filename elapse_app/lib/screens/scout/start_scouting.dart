import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:flutter/material.dart';

/// A template is a form definition, not a filled-in sheet. Select its subject
/// before opening the event-specific sheet; never create cloud data on search.
class StartScoutingScreen extends StatefulWidget {
  const StartScoutingScreen({
    super.key,
    required this.template,
    this.searchTeams = fetchTeamPreview,
    this.onTeamSelected,
  });

  final ScoutSheetTemplate template;
  final Future<List<TeamPreview>> Function(String) searchTeams;
  final void Function(TeamPreview, ScoutSheetTemplate)? onTeamSelected;

  @override
  State<StartScoutingScreen> createState() => _StartScoutingScreenState();
}

class _StartScoutingScreenState extends State<StartScoutingScreen> {
  final _query = TextEditingController();
  List<TeamPreview> _teams = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  int _request = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _query.text.trim().toUpperCase();
    final request = ++_request;
    if (query.isEmpty) {
      setState(() {
        _loading = false;
        _teams = [];
        _error = 'Enter a team number, like 1523W.';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _teams = [];
    });
    try {
      final teams = await widget.searchTeams(query);
      if (!mounted || request != _request) return;
      setState(() {
        _teams = teams;
        _searched = true;
        _loading = false;
      });
    } on Object {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _error = 'Could not find teams. Check your connection and try again.';
      });
    }
  }

  void _openTeam(TeamPreview team) {
    if (widget.onTeamSelected != null) {
      widget.onTeamSelected!(team, widget.template);
      return;
    }
    Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute(
            builder: (_) => TeamScreen(
                  teamID: team.teamID,
                  teamNumber: team.teamNumber,
                  scoutTemplate: widget.template,
                  openScoutSheet: true,
                  returnAfterSave: true,
                )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Start scouting')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('1. Choose a team',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Using: ${widget.template.name}'),
            const SizedBox(height: 8),
            const Text(
                'Next, choose an event and tap Create scout sheet. Your answers are saved with that team and event in your team group. Existing sheets keep their original template.'),
            const SizedBox(height: 20),
            TextField(
              controller: _query,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                  labelText: 'Team number',
                  hintText: 'e.g. 1523W',
                  border: OutlineInputBorder()),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Find team')),
            if (_loading)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator())),
            if (_error != null)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(_error!, semanticsLabel: _error)),
            if (!_loading && _error == null && _searched && _teams.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                      'No teams found. Check the team number and try again.')),
            for (final team in _teams)
              Card(
                  child: ListTile(
                title: Text(team.teamNumber),
                subtitle: Text(team.teamName ?? 'Open scout sheet'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openTeam(team),
              )),
          ],
        ),
      );
}
