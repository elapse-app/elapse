import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_filter.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../../../classes/Team/vdaStats.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../../classes/Tournament/tskills.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({
    super.key,
    required this.searchQuery,
    required this.sort,
    required this.divisionIndex,
    required this.filter,
    required this.skills,
    required this.worldSkills,
    required this.vda,
  });

  final String searchQuery;
  final int divisionIndex;
  final String sort;
  final TournamentRankingsFilter filter;
  final Map<int, TournamentSkills> skills;
  final List<WorldSkillsStats> worldSkills;
  final List<VDAStats>? vda;

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tournament == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final tournament = _tournament!;
    List<Team> teams = tournament.teams;
    List<TeamPreview> savedTeams = [];
    if (widget.filter.saved) {
      final String savedTeam = prefs.getString("savedTeam") ?? "";
      TeamPreview savedTeamPreview =
          TeamPreview(teamID: jsonDecode(savedTeam)["teamID"], teamNumber: jsonDecode(savedTeam)["teamNumber"]);
      List<String> savedTeamsString = prefs.getStringList("savedTeams") ?? [];
      savedTeams.add(savedTeamPreview);
      savedTeams.addAll(savedTeamsString
          .map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"]))
          .toList());
      teams = tournament.teams.where((element) => savedTeams.any((element2) => element2.teamID == element.id)).toList();
    } else {
      teams = tournament.teams;
    }

    List<TeamPreview> scoutedTeams = [];
    if (widget.filter.scouted) {
      teams = tournament.teams.where((e) => scoutedTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    List<TeamPreview> pickListTeams = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
    if (widget.filter.onPicklist) {
      teams = tournament.teams.where((e) => pickListTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    Map<int, TeamStats>? rankings = tournament.divisions[widget.divisionIndex].teamStats;

    if (rankings == null || rankings.isEmpty) {
      return SliverToBoxAdapter(
        child: BigErrorMessage(icon: Icons.format_list_numbered_outlined, message: "Rankings not available"),
      );
    }

    List<Team> divisionTeams = teams.where((e) => rankings[e.id] != null).toList();
    if (widget.sort == "Rank") {
      divisionTeams.sort((a, b) {
        return rankings[a.id]!.rank.compareTo(rankings[b.id]!.rank);
      });
    } else if (widget.sort == "AP") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.ap.compareTo(rankings[a.id]!.ap);
      });
    } else if (widget.sort == "SP") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.sp.compareTo(rankings[a.id]!.sp);
      });
    } else if (widget.sort == "AWP") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.awp.compareTo(rankings[a.id]!.awp);
      });
    } else if (widget.sort == "OPR") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.opr.compareTo(rankings[a.id]!.opr);
      });
    } else if (widget.sort == "DPR") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.dpr.compareTo(rankings[a.id]!.dpr) * -1;
      });
    } else if (widget.sort == "CCWM") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.ccwm.compareTo(rankings[a.id]!.ccwm);
      });
    } else if (widget.sort == "Skills") {
      divisionTeams.sort((a, b) {
        return widget.skills[b.id]?.score.compareTo(widget.skills[a.id]?.score ?? 0) ?? 0;
      });
    } else if (widget.sort == "World Skills") {
      divisionTeams.sort((a, b) {
        return widget.worldSkills
            .singleWhere((e) => e.teamId == b.id, orElse: () {
              return WorldSkillsStats(teamId: b.id, teamNum: b.teamNumber ?? "");
            })
            .score
            .compareTo(widget.worldSkills.singleWhere((e) => e.teamId == a.id, orElse: () {
              return WorldSkillsStats(teamId: b.id, teamNum: b.teamNumber ?? "");
            }).score);
      });
    } else if (widget.sort == "TrueSkill") {
      if (widget.vda != null) {
        divisionTeams.sort((a, b) {
          final vdaB = widget.vda!.singleWhereOrNull((e) => e.id == b.id);
          final vdaA = widget.vda!.singleWhereOrNull((e) => e.id == a.id);
          return (vdaB?.trueSkill ?? 0).compareTo(vdaA?.trueSkill ?? 0);
        });
      } else {
        divisionTeams.sort((a, b) {
          return rankings[a.id]!.rank.compareTo(rankings[b.id]!.rank);
        });
      }
    }

    if (widget.searchQuery.isNotEmpty) {
      divisionTeams = divisionTeams
          .where((e) =>
              e.teamNumber!.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
              e.teamName!.toLowerCase().contains(widget.searchQuery.toLowerCase()))
          .toList();
    } else {
      divisionTeams = divisionTeams;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final team = divisionTeams[index];
          final teamStats = rankings[team.id];
          if (teamStats == null) {
            return const SizedBox();
          }

          return Column(
            children: [
              RankingsWidget(
                teamID: team.id,
                teamNumber: team.teamNumber!,
                teamName: team.teamName!,
                rank: index + 1,
                sort: widget.sort,
                allianceColor: Theme.of(context).colorScheme.onSurface,
                skills: widget.skills[team.id],
                worldSkills: widget.worldSkills.firstWhereOrNull((e) => e.teamId == team.id),
                vda: widget.vda?.firstWhereOrNull((e) => e.id == team.id),
              ),
              Divider(
                color: Theme.of(context).colorScheme.surfaceDim,
                height: 3,
              )
            ],
          );
        }, childCount: divisionTeams.length),
      ),
    );
  }
}
