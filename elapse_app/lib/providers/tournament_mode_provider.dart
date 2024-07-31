import 'package:flutter/material.dart';

class TournamentModeProvider extends ChangeNotifier {
  bool _tournamentMode = false;
  bool get tournamentMode => _tournamentMode;

  void setTournamentMode(bool value) {
    _tournamentMode = value;
    notifyListeners();
  }
}
