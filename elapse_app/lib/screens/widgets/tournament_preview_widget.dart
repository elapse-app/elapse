import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:flutter/material.dart';

class TournamentPreviewWidget extends StatelessWidget {
  const TournamentPreviewWidget({super.key, required this.tournamentPreview});

  final TournamentPreview tournamentPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentScreen(
                  tournamentID: tournamentPreview.id,
                  isPreview: true,
                ),
              ),
            );
          },
          child: Container(
            height: 60,
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tournamentPreview.name,
                        style: TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                          "${tournamentPreview.location?.city ?? ""}, ${tournamentPreview.location?.region ?? ""}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Icon(Icons.arrow_forward),
                )
              ],
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceDim,
        )
      ],
    );
  }
}
