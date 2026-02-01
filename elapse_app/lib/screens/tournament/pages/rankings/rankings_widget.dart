import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/tournament_stats_page.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/vdaStats.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../../classes/Tournament/tskills.dart';

class RankingsWidget extends StatefulWidget {
  const RankingsWidget({
    super.key,
    required this.teamID,
    required this.teamNumber,
    required this.teamName,
    required this.allianceColor,
    this.rank,
    this.sort = "Rank",
    this.skills,
    this.worldSkills,
    this.vda,
  });

  final int teamID;
  final String teamNumber;
  final String teamName;
  final int? rank;
  final Color allianceColor;
  final String sort;
  final TournamentSkills? skills;
  final WorldSkillsStats? worldSkills;
  final VDAStats? vda;

  @override
  State<RankingsWidget> createState() => _RankingsWidgetState();
}

class _RankingsWidgetState extends State<RankingsWidget> {
  Tournament? _tournament;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournament();
  }

  Future<void> _loadTournament() async {
    final tournamentId = prefs.getInt("tournamentID");
    if (tournamentId != null && tournamentId != 0) {
      final tournament = await getTournamentFromCache(tournamentId);
      if (mounted) {
        setState(() {
          _tournament = tournament;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tournament == null) return const SizedBox.shrink();

    int divisionIndex = getTeamDivisionIndex(_tournament!.divisions, widget.teamID);

    Map<int, TeamStats> rankings = _tournament!.divisions[divisionIndex].teamStats!;
    TeamStats stats = rankings[widget.teamID]!;

    String val1 = "${stats.wins}-${stats.losses}-${stats.ties}",
        val2 = "${stats.wp} WP",
        val3 = "${stats.ap} AP",
        val4 = "${stats.sp} SP";
    switch (widget.sort) {
      case "Rank":
      case "AP":
      case "SP":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = "${stats.ap} AP";
        val4 = "${stats.sp} SP";
        break;
      case "AWP":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.ap} AP";
        val3 = "${stats.awp} AWP";
        val4 = "${(stats.awpRate * 100).toStringAsFixed(1)} %";
        break;
      case "OPR":
      case "DPR":
      case "CCWM":
        val1 = "${stats.opr.toStringAsFixed(1)} OPR";
        val2 = "${stats.dpr.toStringAsFixed(1)} DPR";
        val3 = stats.ccwm.toStringAsFixed(1);
        val4 = "CCWM";
        break;
      case "Skills":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = widget.skills != null ? "Rank ${widget.skills?.rank}" : "N/A";
        val4 = widget.skills != null ? "${widget.skills?.score} pts" : "N/A";
        break;
      case "World Skills":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = widget.worldSkills != null ? "Rank ${widget.worldSkills?.rank}" : "N/A";
        val4 = widget.worldSkills != null ? "${widget.worldSkills?.score} pts" : "N/A";
        break;
      case "TrueSkill":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = widget.vda != null ? "Rank ${widget.vda?.trueSkillGlobalRank}" : "N/A";
        val4 = widget.vda != null ? "${widget.vda?.trueSkill}" : "N/A";
        break;
    }

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => tournamentStatsPage(context, widget.teamID, widget.teamNumber, widget.teamName),
        child: SizedBox(
            height: 72,
            child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 37,
                    fit: FlexFit.tight,
                    child: Text(
                      "${widget.rank ?? stats.rank}",
                      maxLines: 1,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1, color: widget.allianceColor),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Flexible(
                    flex: 90,
                    fit: FlexFit.tight,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.teamNumber,
                              style: TextStyle(
                                  fontSize: 32,
                                  height: 1,
                                  letterSpacing: -1.5,
                                  fontWeight: FontWeight.w400,
                                  color: widget.allianceColor)),
                          Text(widget.teamName,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: widget.allianceColor.withAlpha(200),
                                overflow: TextOverflow.fade,
                              ))
                        ]),
                  ),
                  const Spacer(flex: 5),
                  Flexible(
                    flex: 45,
                    fit: FlexFit.tight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(val1,
                            style: const TextStyle(
                              fontSize: 16,
                            )),
                        Text(val2,
                            style: const TextStyle(
                              fontSize: 16,
                            )),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.surfaceDim,
                        )),
                  ),
                  Flexible(
                    flex: 45,
                    fit: FlexFit.tight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(val3,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 16,
                            )),
                        Text(val4,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 16,
                            )),
                      ],
                    ),
                  )
                ])));
  }
}

class EmptyRanking extends StatelessWidget {
  const EmptyRanking({super.key, required this.teamName, required this.teamID, required this.allianceColor});

  final String teamName;
  final int teamID;
  final Color allianceColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamScreen(
              teamID: teamID,
              teamNumber: teamName,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: 72,
        child: Text(
          teamName,
          style: TextStyle(fontSize: 40, height: 1, fontWeight: FontWeight.w400, color: allianceColor),
        ),
      ),
    );
  }
}
