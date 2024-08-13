import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

class TournamentPreviewWidget extends StatelessWidget {
  const TournamentPreviewWidget(
      {super.key,
      required this.tournamentPreview,
      this.saveSearch = false,
      this.saveState});

  final TournamentPreview tournamentPreview;
  final bool saveSearch;
  final Function? saveState;

  @override
  Widget build(BuildContext context) {
    String dateString = "";
    if (tournamentPreview.startDate != null &&
        tournamentPreview.endDate != null) {
      if (tournamentPreview.startDate! == tournamentPreview.endDate!) {
        dateString =
            "${tournamentPreview.startDate?.month}/${tournamentPreview.startDate?.day}/${tournamentPreview.startDate?.year}";
      } else {
        dateString =
            "${tournamentPreview.startDate?.month}/${tournamentPreview.startDate?.day}/${tournamentPreview.startDate?.year} - ${tournamentPreview.endDate?.month}/${tournamentPreview.endDate?.day}/${tournamentPreview.endDate?.year}";
      }
    }
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (saveSearch) {
              saveState;
              List<String> recentSearches =
                  prefs.getStringList("recentTournamentSearches") ?? <String>[];

              recentSearches.remove(
                  '{"searchTerm": "${tournamentPreview.name}", "tournamentID": ${tournamentPreview.id}}');
              recentSearches.add(
                  '{"searchTerm": "${tournamentPreview.name}", "tournamentID": ${tournamentPreview.id}}');
              if (recentSearches.length > 10) {
                recentSearches.removeAt(0);
              }

              prefs.setStringList("recentTournamentSearches", recentSearches);
            }
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 4,
                            fit: FlexFit.tight,
                            child: Text(
                                "${tournamentPreview.location?.city ?? ""}, ${tournamentPreview.location?.region ?? ""}  -  $dateString",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ),
                        ],
                      ),
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
