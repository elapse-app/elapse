import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

class TeamWidget extends StatelessWidget {
  const TeamWidget({
    super.key,
    required this.teamNumber,
    required this.teamID,
    this.teamName,
    this.location,
    this.saveSearch = false,
    this.saveState,
  });
  final String teamNumber;
  final int teamID;
  final String? teamName;
  final Location? location;
  final bool saveSearch;
  final Function? saveState;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (saveSearch) {
          saveState;
          List<String> recentSearches =
              prefs!.getStringList("recentTeamSearches") ?? <String>[];

          recentSearches
              .remove('{"searchTerm": "$teamNumber", "teamID": $teamID}');
          recentSearches
              .add('{"searchTerm": "$teamNumber", "teamID": $teamID}');
          if (recentSearches.length > 10) {
            recentSearches.removeAt(0);
          }

          prefs!.setStringList("recentTeamSearches", recentSearches);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamScreen(
              teamID: teamID,
              teamName: teamNumber,
            ),
          ),
        );
      },
      child: Container(
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Text(teamNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            Flexible(
              flex: 7,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(teamName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  Text(
                      '${location?.city ?? ""}${location?.city != null ? "," : ""} ${location?.region ?? ""}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.65),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
