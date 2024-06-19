import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Tournament/award.dart';

class SeasonStats {
  VDAStats vdaStats;

  List<Award> awards;

  SeasonStats({
    required this.vdaStats,
    required this.awards,
  });
}
