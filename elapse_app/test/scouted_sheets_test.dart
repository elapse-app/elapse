import 'package:elapse_app/classes/ScoutSheet/scout_sheet_data.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/ScoutSheet/scouted_sheet.dart';
import 'package:elapse_app/classes/ScoutSheet/scouted_sheet_repository.dart';
import 'package:elapse_app/main.dart' as app;
import 'package:elapse_app/screens/scout/scouted_sheets.dart';
import 'package:elapse_app/screens/team_screen/team_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.prefs = await SharedPreferences.getInstance();
  });

  ScoutedSheet row(String team) => ScoutedSheet(
      id: team,
      teamId: team == '10K' ? 143646 : 1523,
      teamNumber: team,
      eventId: 64244,
      eventName: 'Test event',
      data: ScoutSheetData.empty(ScoutSheetTemplate.standard)
          .withAnswer('otherNotes', 'Test note for $team'));

  test('table formatting preserves false, zero, and separate same-label fields',
      () {
    expect(ScoutedSheet.answerText(false), 'No');
    expect(ScoutedSheet.answerText(0), '0');
    expect(ScoutedSheet.answerText('  '), '—');
    final template = ScoutSheetTemplate.standard.copyWith(fields: [
      ScoutTemplateField(
          id: 'one', label: 'Notes', type: ScoutFieldType.shortText),
      ScoutTemplateField(
          id: 'two', label: 'Notes', type: ScoutFieldType.shortText),
    ]);
    final sheet = ScoutedSheet(
        id: 'id',
        teamId: 1,
        teamNumber: '1A',
        eventId: 1,
        eventName: 'Event',
        data: ScoutSheetData.empty(template)
            .withAnswer('one', 'First')
            .withAnswer('two', 'Second'));
    expect(sheet.answerColumns.values, ['First', 'Second']);
  });

  testWidgets('table shows both teams and opens the exact selected sheet',
      (tester) async {
    ScoutedSheet? opened;
    await tester.pumpWidget(MaterialApp(
        home: ScoutedSheetsScreen(
            groupId: 'group',
            loadPage: (_, __) async =>
                ScoutedSheetPage([row('10K'), row('1523A')]),
            onOpen: (value) => opened = value)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('10K'), findsOneWidget);
    expect(find.text('1523A'), findsOneWidget);
    expect(find.text('Test note for 10K'), findsOneWidget);
    await tester.tap(find.text('1523A'));
    expect(opened?.id, '1523A');
    expect(app.prefs.getBool('scoutSheets.tableView'), true);
  });

  testWidgets('filtering and paginated loading keep both pages',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ScoutedSheetsScreen(
            groupId: 'group',
            loadPage: (_, cursor) async => cursor == null
                ? ScoutedSheetPage([row('10K')], nextCursor: 'page2')
                : ScoutedSheetPage([row('1523A')]))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load more (1 loaded)'));
    await tester.pumpAndSettle();
    expect(find.text('10K'), findsOneWidget);
    expect(find.text('1523A'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1523a');
    await tester.pumpAndSettle();
    expect(find.text('10K'), findsNothing);
    expect(find.text('1523A'), findsOneWidget);
  });

  testWidgets('failed sheet load has a working retry', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        home: ScoutedSheetsScreen(
            groupId: 'group',
            loadPage: (_, __) async {
              if (++attempts == 1) throw StateError('offline');
              return ScoutedSheetPage([row('10K')]);
            })));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not load your sheets'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('10K'), findsOneWidget);
  });

  testWidgets('team title and back arrow never overlap while scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!),
        home: Scaffold(
            body: CustomScrollView(slivers: [
          TeamPageHeader(teamNumber: '1523W', onSeason: () {}),
          const SliverToBoxAdapter(child: SizedBox(height: 1800)),
        ]))));
    expect(tester.getRect(find.byType(BackButton)).right,
        lessThanOrEqualTo(tester.getRect(find.text('Team 1523W')).left));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    expect(tester.getRect(find.byType(BackButton)).right,
        lessThanOrEqualTo(tester.getRect(find.text('Team 1523W')).left));
    expect(tester.takeException(), isNull);
  });
}
