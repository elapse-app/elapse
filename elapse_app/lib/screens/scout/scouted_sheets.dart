import 'package:elapse_app/classes/ScoutSheet/scouted_sheet.dart';
import 'package:elapse_app/classes/ScoutSheet/scouted_sheet_repository.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:flutter/material.dart';

class ScoutedSheetsScreen extends StatefulWidget {
  const ScoutedSheetsScreen(
      {super.key, required this.groupId, this.loadPage, this.onOpen});
  final String groupId;
  final Future<ScoutedSheetPage> Function(String, Object?)? loadPage;
  final ValueChanged<ScoutedSheet>? onOpen;

  @override
  State<ScoutedSheetsScreen> createState() => _ScoutedSheetsScreenState();
}

class _ScoutedSheetsScreenState extends State<ScoutedSheetsScreen> {
  final _repository = ScoutedSheetRepository();
  List<ScoutedSheet> _sheets = [];
  Object? _cursor;
  bool _busy = false;
  String? _error;
  String _filter = '';
  late bool _table;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _table = prefs.getBool('scoutSheets.tableView') ?? false;
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final page = await (widget.loadPage ?? _repository.load)(
          widget.groupId, more ? _cursor : null);
      if (!mounted) return;
      setState(() {
        final byId = {
          if (more)
            for (final sheet in _sheets) sheet.id: sheet,
          for (final sheet in page.sheets) sheet.id: sheet
        };
        _sheets = byId.values.toList();
        _cursor = page.nextCursor;
      });
    } on Object {
      if (mounted)
        setState(() => _error =
            'Could not load your sheets. Check your connection and group access, then retry.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(ScoutedSheet sheet) async {
    if (widget.onOpen != null) {
      widget.onOpen!(sheet);
      return;
    }
    await Navigator.push<void>(
        context,
        MaterialPageRoute(
            builder: (_) => TeamScreen(
                  teamID: sheet.teamId,
                  teamNumber: sheet.teamNumber,
                  openScoutSheet: true,
                  initialSheetId: sheet.id,
                  initialEvent: TournamentPreview(
                      id: sheet.eventId, name: sheet.eventName),
                )));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _sheets
        .where((sheet) =>
            '${sheet.teamNumber} ${sheet.eventName} ${sheet.data.template.name}'
                .toLowerCase()
                .contains(_filter.toLowerCase()))
        .toList()
      ..sort((a, b) => _ascending
          ? a.teamNumber.compareTo(b.teamNumber)
          : b.teamNumber.compareTo(a.teamNumber));
    final fields =
        {for (final sheet in visible) ...sheet.answerColumns.keys}.toList();
    final labels = {for (final sheet in visible) ...sheet.columnLabels};
    return Scaffold(
      appBar: AppBar(title: const Text('My scout sheets'), actions: [
        IconButton(
            tooltip: 'Refresh sheets',
            onPressed: _busy ? null : () => _load(),
            icon: const Icon(Icons.refresh))
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text(
            'Saved in your team group. Open a row or card to review or edit that team’s sheet.'),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: false,
                  icon: Icon(Icons.view_list),
                  label: Text('List')),
              ButtonSegment(
                  value: true,
                  icon: Icon(Icons.table_chart_outlined),
                  label: Text('Table')),
            ],
            selected: {
              _table
            },
            onSelectionChanged: (selection) {
              setState(() => _table = selection.single);
              prefs.setBool('scoutSheets.tableView', _table);
            }),
        const SizedBox(height: 12),
        TextField(
            decoration: const InputDecoration(
                labelText: 'Filter loaded sheets',
                hintText: 'Team, event or template',
                prefixIcon: Icon(Icons.search)),
            onChanged: (value) => setState(() => _filter = value)),
        const SizedBox(height: 12),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) ...[
          Text(_error!),
          TextButton(
              onPressed: () =>
                  _load(more: _sheets.isNotEmpty && _cursor != null),
              child: const Text('Retry')),
        ],
        if (!_busy && _sheets.isEmpty && _error == null)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                  'No scout sheets yet. Go back to Scout and tap Start scouting to create your first one.')),
        if (_sheets.isNotEmpty && visible.isEmpty)
          const Text('No loaded sheets match this filter.'),
        if (visible.isNotEmpty && _table) ...[
          const Text(
              'Swipe horizontally for all answers. Tap a team to open its sheet.'),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                sortColumnIndex: 0,
                sortAscending: _ascending,
                columns: [
                  DataColumn(
                      label: const Text('Team'),
                      onSort: (_, ascending) =>
                          setState(() => _ascending = ascending)),
                  const DataColumn(label: Text('Event')),
                  const DataColumn(label: Text('Template')),
                  const DataColumn(label: Text('Updated')),
                  for (final field in fields)
                    DataColumn(
                        label: SizedBox(
                            width: 180,
                            child: Text(labels[field] ?? field,
                                maxLines: 2, overflow: TextOverflow.ellipsis))),
                ],
                rows: [
                  for (final sheet in visible)
                    DataRow(onSelectChanged: (_) => _open(sheet), cells: [
                      DataCell(Text(sheet.teamNumber)),
                      DataCell(Tooltip(
                          message: sheet.eventName,
                          child: SizedBox(
                              width: 180,
                              child: Text(sheet.eventName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis)))),
                      DataCell(Text(sheet.data.template.name)),
                      DataCell(Text(sheet.updatedLabel)),
                      for (final field in fields)
                        DataCell(Tooltip(
                            message: sheet.answerColumns[field] ?? '—',
                            child: SizedBox(
                                width: 180,
                                child: Text(sheet.answerColumns[field] ?? '—',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)))),
                    ])
                ],
              )),
        ],
        if (!_table)
          for (final sheet in visible)
            Card(
                child: ListTile(
              title: Text(sheet.teamNumber),
              subtitle: Text(
                  '${sheet.eventName}\n${sheet.data.template.name} • ${sheet.updatedLabel}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(sheet),
            )),
        if (_cursor != null)
          TextButton(
              onPressed: _busy ? null : () => _load(more: true),
              child: Text('Load more (${_sheets.length} loaded)')),
      ]),
    );
  }
}
