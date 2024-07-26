import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:flutter/material.dart';

class TeamWidget extends StatelessWidget {
  const TeamWidget({
    super.key,
    required this.teamNumber,
    required this.teamID,
    this.teamName,
    this.location,
  });
  final String teamNumber;
  final int teamID;
  final String? teamName;
  final Location? location;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
        height: 60,
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
