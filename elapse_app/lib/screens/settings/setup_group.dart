import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../classes/Groups/teamGroup.dart';
import '../../extras/database.dart';
import '../../main.dart';
import 'group_settings.dart';

class GroupSetupPage extends StatefulWidget {
  const GroupSetupPage(
      {super.key,
      this.returnToScouting = false,
      this.createGroup,
      this.joinGroup,
      this.onComplete});

  final bool returnToScouting;
  final Future<TeamGroup?> Function(String)? createGroup;
  final Future<TeamGroup?> Function(String)? joinGroup;
  final ValueChanged<TeamGroup>? onComplete;

  @override
  State<GroupSetupPage> createState() => _GroupSetupPageState();
}

class _GroupSetupPageState extends State<GroupSetupPage> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool join}) async {
    if (_busy) return;
    final name = _name.text.trim();
    final code = _code.text.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    if (join
        ? !RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)
        : name.isEmpty || name.length > 80) {
      setState(() => _error = join
          ? 'Enter the 8-letter/digit invite code, like ABCD-1234.'
          : 'Enter a group name (1–80 characters).');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final normalized =
          join ? '${code.substring(0, 4)}-${code.substring(4)}' : name;
      final handler = join ? widget.joinGroup : widget.createGroup;
      TeamGroup? group;
      if (handler != null) {
        group = await handler(normalized);
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null)
          throw StateError('Sign in before creating or joining a group.');
        final db = Database();
        if (join) {
          group = await db.joinTeamGroup(normalized, user.uid);
        } else {
          final profile = await db.getUserInfo(user.uid);
          if (profile == null)
            throw StateError(
                'Could not load your account. Check your connection, then try again.');
          group = await db.createTeamGroup(
              user.uid,
              name,
              profile['firstName']?.toString() ?? 'Scout',
              profile['lastName']?.toString() ?? '');
        }
      }
      if (!mounted) return;
      if (group == null || group.groupId == null) {
        throw StateError(join
            ? 'Could not join. Check the invite code, your connection, and whether the group accepts new members.'
            : 'Could not create the group. Check your connection and try again.');
      }
      if (!await prefs.setString('teamGroup', jsonEncode(group.toJson()))) {
        throw StateError(
            'Your group was saved online, but could not be selected on this device. Reopen Settings to select it.');
      }
      if (!mounted) return;
      if (widget.onComplete != null) {
        widget.onComplete!(group);
      } else if (widget.returnToScouting) {
        Navigator.pop(context, group);
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => GroupSettings(
                    uid: FirebaseAuth.instance.currentUser!.uid)));
      }
    } on Object catch (error) {
      if (mounted)
        setState(
            () => _error = error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: Scaffold(
          appBar: AppBar(title: const Text('Save with a group')),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            const Text(
                'A group is where your scout sheets live. You can create one just for yourself—you do not need an invite code or teammates.'),
            const SizedBox(height: 20),
            Text('New to scouting? Start here',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
                controller: _name,
                enabled: !_busy,
                maxLength: 80,
                decoration: const InputDecoration(
                    labelText: 'Group name',
                    hintText: 'e.g. My scouting notebook',
                    border: OutlineInputBorder()),
                onSubmitted: (_) => _submit(join: false)),
            FilledButton(
                onPressed: _busy ? null : () => _submit(join: false),
                child: Text(widget.returnToScouting
                    ? 'Create group & continue scouting'
                    : 'Create group')),
            const SizedBox(height: 20),
            ExpansionTile(
                title: const Text('Already have an invite code?'),
                children: [
                  TextField(
                      controller: _code,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                          labelText: 'Invite code', hintText: 'ABCD-1234'),
                      onSubmitted: (_) => _submit(join: true)),
                  OutlinedButton(
                      onPressed: _busy ? null : () => _submit(join: true),
                      child: const Text('Join group')),
                ]),
            if (_busy)
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator())),
            if (_error != null)
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
          ]),
        ),
      );
}
