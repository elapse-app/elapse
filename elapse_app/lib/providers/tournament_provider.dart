import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:flutter/material.dart';

class TournamentProvider extends ChangeNotifier {
  Tournament? _tournament;
  Division? _division;

  Tournament? get tournament => _tournament;
  Division? get division => _division;

  void setTournament(Tournament tournament, Division division) {
    _tournament = tournament;
    _division = division;
    notifyListeners();
  }

  void setDivision(Division division) {
    _division = division;
    notifyListeners();
  }

  void clear() {
    _tournament = null;
    _division = null;
    notifyListeners();
  }
}
