class VDAStats {
  int id;
  String teamNum;
  double opr;
  double dpr;
  double ccwm;

  double trueSkill;
  int trueSkillGlobalRank;
  int trueSkillRegionRank;

  int? skillsScore;
  int? maxAuto;
  int? maxDriver;

  int? worldSkillsRank;
  int? regionSkillsRank;

  VDAStats({
    required this.id,
    required this.teamNum,
    required this.opr,
    required this.dpr,
    required this.ccwm,
    required this.trueSkill,
    required this.trueSkillGlobalRank,
    required this.trueSkillRegionRank,
    this.skillsScore,
    this.maxAuto,
    this.maxDriver,
    this.worldSkillsRank,
    this.regionSkillsRank,
  });

  factory VDAStats.fromJson(Map<String, dynamic> json) {
    return VDAStats(
      id: json["id"].truncate(),
      teamNum: json["team_number"],
      opr: json["opr"],
      dpr: json["dpr"],
      ccwm: json["ccwm"],
      trueSkill: json["trueskill"],
      trueSkillGlobalRank: json["ts_ranking"],
      trueSkillRegionRank: json["ts_ranking_region"],
      skillsScore: json["score_total_max"]?.truncate(),
      maxAuto: json["score_auto_max"]?.truncate(),
      maxDriver: json["score_driver_max"]?.truncate(),
      worldSkillsRank: json["world_skills_rank"]?.truncate(),
      regionSkillsRank: json["region_grade_skills_rank"]?.truncate(),
    );
  }
}
