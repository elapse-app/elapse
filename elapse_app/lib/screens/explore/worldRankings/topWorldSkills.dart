import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../classes/Filters/season.dart';
import '../../../classes/Team/world_skills.dart';
import '../../team_screen/team_screen.dart';
import '../../widgets/big_error_message.dart';

class TopWorldSkills extends StatefulWidget {
  TopWorldSkills({
    super.key,
  });

  late Future<List<WorldSkillsStats>> rankings;

  @override
  State<TopWorldSkills> createState() => _TopWorldSkillsState();
}

class _TopWorldSkillsState extends State<TopWorldSkills> {
  @override
  void initState() {
    super.initState();
    widget.rankings = getWorldSkillsRankings(seasons[0].vrcId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.rankings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 100,
                width: 100,
                child: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            return _LoadedTopWorldSkills(
                rankings: snapshot.data as List<WorldSkillsStats>);
          } else {
            return const Center(
              child: BigErrorMessage(
                icon: Icons.emoji_events,
                message: "Unable to load world skills rankings",
                topPadding: 15,
                textPadding: 10,
              ),
            );
          }
        });
  }
}

class _LoadedTopWorldSkills extends StatelessWidget {
  const _LoadedTopWorldSkills({required this.rankings});

  final List<WorldSkillsStats> rankings;

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return const Center(
        child: BigErrorMessage(
          icon: Icons.emoji_events_outlined,
          message: "No world skills rankings",
          topPadding: 15,
          textPadding: 10,
        ),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 5),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.all(8),
                      child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 2,
                              child: Text("${rankings[index].rank}",
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 6,
                              child: Text(rankings[index].teamNum,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400)),
                            ),
                            const Spacer(),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 4,
                              child: Text("${rankings[index].score}",
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400)),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: SizedBox(
                                  height: 50,
                                  child: VerticalDivider(
                                      width: 3,
                                      thickness: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceDim)),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 3,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("${rankings[index].driver}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.sports_esports_outlined),
                                ]
                              )
                            ),
                            Flexible(
                                fit: FlexFit.tight,
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("${rankings[index].auton}",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400)),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.data_object),
                                    ]
                                )
                            ),
                          ]),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamScreen(
                                teamID: rankings[index].teamId,
                                teamName: rankings[index].teamNum),
                          ));
                    }),
                index != 10
                    ? Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )
                    : Container(),
              ]);
        });
  }
}
