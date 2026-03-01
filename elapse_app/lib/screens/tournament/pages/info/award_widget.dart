import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/main.dart';
import 'package:flutter/material.dart';

class AwardWidget extends StatefulWidget {
  const AwardWidget({super.key, required this.awardIndex});
  final int awardIndex;

  @override
  State<AwardWidget> createState() => _AwardWidgetState();
}

class _AwardWidgetState extends State<AwardWidget> {
  Award? _award;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAward();
  }

  Future<void> _loadAward() async {
    final tournamentId = prefs.getInt("tournamentID");
    if (tournamentId != null && tournamentId != 0) {
      final tournament = await getTournamentFromCache(tournamentId);
      if (tournament != null && mounted && widget.awardIndex < tournament.awards.length) {
        _award = tournament.awards[widget.awardIndex];
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _award == null) {
      return const SizedBox.shrink();
    }
    final award = _award!;

    String winnersString;
    if (award.teamWinners != null && award.teamWinners!.isNotEmpty) {
      winnersString = award.teamWinners!.map((e) => e.teamNumber).join(", ");
    } else if (award.individualWinners != null && award.individualWinners!.isNotEmpty) {
      winnersString = award.individualWinners!.join(", ");
    } else {
      winnersString = "N/A";
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 5,
                child: Text(
                  award.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  award.qualifications.join(", "),
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              )
            ],
          ),
          Text(
            winnersString,
            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
