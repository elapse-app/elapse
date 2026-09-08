import 'dart:async';

import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_template_repository.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/screens/scout/start_scouting.dart';
import 'package:elapse_app/screens/scout/templates/scout_template_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('template actions remain usable on small screens with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final repository =
        ScoutTemplateRepository(await SharedPreferences.getInstance());
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.5)),
        child: child!,
      ),
      home: ScoutTemplateListScreen(repository: repository),
    ));
    await tester.scrollUntilVisible(
        find.text('Use template').hitTestable(), 150);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use template'));
    await tester.pumpAndSettle();
    expect(find.text('1. Choose a team'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Use template opens team selection without changing the default',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository =
        ScoutTemplateRepository(await SharedPreferences.getInstance());
    await tester.pumpWidget(
        MaterialApp(home: ScoutTemplateListScreen(repository: repository)));
    expect(find.textContaining('A template is a blank form.'), findsOneWidget);
    await tester.tap(find.text('Use template'));
    await tester.pumpAndSettle();
    expect(find.text('1. Choose a team'), findsOneWidget);
    expect(find.text('Using: Robot overview'), findsOneWidget);
    expect(repository.loadDefaultTemplate().id, ScoutSheetTemplate.standard.id);
    expect(find.byType(ScoutTemplateListScreen), findsNothing);
    expect(find.widgetWithText(TextField, 'e.g. 1523W'), findsOneWidget);
  });

  testWidgets('in-sheet template manager returns the selected form',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository =
        ScoutTemplateRepository(await SharedPreferences.getInstance());
    ScoutSheetTemplate? selected;
    await tester.pumpWidget(MaterialApp(
        home: ScoutTemplateListScreen(
            repository: repository,
            onUseTemplate: (value) => selected = value)));
    await tester.tap(find.text('Use template'));
    await tester.pumpAndSettle();
    expect(selected, ScoutSheetTemplate.standard);
    expect(find.byType(StartScoutingScreen), findsNothing);
  });

  testWidgets(
      'team selection preserves the chosen template and normalized search',
      (tester) async {
    String? query;
    TeamPreview? selectedTeam;
    ScoutSheetTemplate? selectedTemplate;
    final template = ScoutSheetTemplate.standard
        .copyWith(id: 'custom', name: 'Custom pit form', isBuiltIn: false);
    await tester.pumpWidget(MaterialApp(
        home: StartScoutingScreen(
      template: template,
      searchTeams: (value) async {
        query = value;
        return [
          TeamPreview(teamID: 143646, teamNumber: '10K', teamName: 'Knockout')
        ];
      },
      onTeamSelected: (team, form) {
        selectedTeam = team;
        selectedTemplate = form;
      },
    )));
    await tester.enterText(find.byType(TextField), ' 10k ');
    await tester.tap(find.text('Find team'));
    await tester.pumpAndSettle();
    expect(query, '10K');
    await tester.tap(find.text('10K'));
    expect(selectedTeam?.teamID, 143646);
    expect(selectedTemplate, same(template));
  });

  testWidgets('empty query and no results explain the next action',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: StartScoutingScreen(
      template: ScoutSheetTemplate.standard,
      searchTeams: (_) async {
        calls++;
        return [];
      },
    )));
    await tester.tap(find.text('Find team'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Enter a team number, like 1523W.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'UNKNOWN');
    await tester.tap(find.text('Find team'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No teams found.'), findsOneWidget);
  });

  testWidgets('failed search can be retried', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: StartScoutingScreen(
      template: ScoutSheetTemplate.standard,
      searchTeams: (_) async {
        if (++calls == 1) throw StateError('offline');
        return [TeamPreview(teamID: 1, teamNumber: '1A')];
      },
    )));
    await tester.enterText(find.byType(TextField), '1A');
    await tester.tap(find.text('Find team'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Check your connection'), findsOneWidget);
    await tester.tap(find.text('Find team'));
    await tester.pumpAndSettle();
    expect(find.text('1A'), findsWidgets);
    expect(find.textContaining('Check your connection'), findsNothing);
  });

  testWidgets('leaving during search does not update disposed state',
      (tester) async {
    final pending = Completer<List<TeamPreview>>();
    await tester.pumpWidget(MaterialApp(
        home: StartScoutingScreen(
      template: ScoutSheetTemplate.standard,
      searchTeams: (_) => pending.future,
    )));
    await tester.enterText(find.byType(TextField), '10K');
    await tester.tap(find.text('Find team'));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    pending.complete([]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
