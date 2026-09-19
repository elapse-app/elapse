import 'package:elapse_app/classes/Groups/teamGroup.dart';
import 'package:elapse_app/main.dart' as app;
import 'package:elapse_app/screens/settings/setup_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.prefs = await SharedPreferences.getInstance();
  });

  TeamGroup group() => TeamGroup(
      groupId: 'test-group',
      adminId: 'tester',
      members: {'tester': 'Scout'},
      joinCode: 'ABCD-1234',
      groupName: 'Notebook');

  testWidgets(
      'creation validates input and returns the saved group to scouting',
      (tester) async {
    String? name;
    TeamGroup? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                  onPressed: () async {
                    result = await Navigator.push<TeamGroup>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GroupSetupPage(
                                  returnToScouting: true,
                                  createGroup: (value) async {
                                    name = value;
                                    return group();
                                  },
                                )));
                  },
                  child: const Text('Start'),
                ))));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create group & continue scouting'));
    await tester.pumpAndSettle();
    expect(name, isNull);
    expect(find.textContaining('Enter a group name'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, ' Notebook ');
    await tester.tap(find.text('Create group & continue scouting'));
    await tester.pumpAndSettle();
    expect(name, 'Notebook');
    expect(result?.groupId, 'test-group');
    expect(app.prefs.getString('teamGroup'), contains('test-group'));
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('failed creation stays on setup and never stores null',
      (tester) async {
    var completed = false;
    await tester.pumpWidget(MaterialApp(
        home: GroupSetupPage(
            createGroup: (_) async => null,
            onComplete: (_) => completed = true)));
    await tester.enterText(find.byType(TextField).first, 'Notebook');
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not create the group'), findsOneWidget);
    expect(completed, false);
    expect(app.prefs.getString('teamGroup'), isNull);
  });

  testWidgets('join validates short code and accepts pasted hyphenated code',
      (tester) async {
    String? submitted;
    await tester.pumpWidget(MaterialApp(
        home: GroupSetupPage(
            joinGroup: (code) async {
              submitted = code;
              return group();
            },
            onComplete: (_) {})));
    await tester.tap(find.text('Already have an invite code?'));
    await tester.pumpAndSettle();
    final field = find.widgetWithText(TextField, 'Invite code');
    await tester.enterText(field, 'ab');
    await tester.ensureVisible(find.text('Join group'));
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(submitted, isNull);
    expect(find.textContaining('Enter the 8-letter'), findsOneWidget);
    await tester.enterText(field, ' abcd-1234 ');
    await tester.ensureVisible(find.text('Join group'));
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(submitted, 'ABCD-1234');
    expect(app.prefs.getString('teamGroup'), contains('test-group'));
  });
}
