import 'package:elapse_app/classes/Tournament/tskills.dart';

class TournamentStats {
  double opr;
  double dpr;
  double ccwm;

  int rank;
  int wins;
  int losses;
  int ties;
  int wp;
  int ap;
  int sp;

  TournamentSkills? tournamentSkills;

  TournamentStats({
    required this.opr,
    required this.dpr,
    required this.ccwm,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.wp,
    required this.ap,
    required this.sp,
    this.tournamentSkills,
  });
}
