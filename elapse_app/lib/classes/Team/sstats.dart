import 'package:elapse_app/classes/Tournament/award.dart';

class SeasonStats {
  double opr;
  double dpr;
  double ccwm;
  double trueSkill;
  int tsRank;

  int? wsScore;
  int? wsRank;

  List<Award> awards;

  SeasonStats({
    required this.opr,
    required this.dpr,
    required this.ccwm,
    required this.trueSkill,
    required this.tsRank,
    required this.awards,
    this.wsScore,
    this.wsRank,
  });
}
