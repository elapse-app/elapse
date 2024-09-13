import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/main.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key,});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  _JoinTeamPageState();
  final TextEditingController _teamController = TextEditingController();
  Future<List<TeamPreview>>? teamSearch;
  String searchQuery = "";
  String buttonLabel = "Search";
  TeamPreview? selectedTeam;

  void searchTeam() async {
    setState(() {
      searchQuery = _teamController.text;
      teamSearch = fetchTeamPreview(searchQuery);
    });

    final teams = await teamSearch;
    if (teams != null && teams.isNotEmpty) {
      setState(() {
        selectedTeam = teams.first;
        buttonLabel = "Confirm";
      });
    } else {
      setState(() {
        selectedTeam = null;
        buttonLabel = "Search";
      });
    }
  }

  void saveTeam(TeamPreview team) {
    prefs.setString("savedTeam",
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterDetailsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Theme.of(context).colorScheme.primary,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          ElapseAppBar(
            title: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                      Text('Sign up',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ]
                ),
            maxHeight: 60,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Container(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Team details',
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 12, 77, 86),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Get personalized info for your team',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                  child: TextFormField(
                  controller: _teamController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 187, 51, 51),
                        width: 1.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 187, 51, 51),
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Team Number',
                    labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Manrope",
                    fontSize: 16,
                  ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<TeamPreview>>(
                future: teamSearch,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Text('Press confirm to continue');
                  } else {
                    return Text('');
                  }
                },
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                child: SizedBox(
                  height: 59.0,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 76, 81, 175),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.0,
                      ),
                    ),
                    onPressed: () {
                      if (buttonLabel == "Search") {
                        searchTeam();
                      } else if (buttonLabel == "Confirm" && selectedTeam != null) {
                        saveTeam(selectedTeam!);
                        //prefs.setString('savedTeam', _teamController.text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThemeSetup(),
                            ),
                          );
                      }
                    },
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                        color: Color.fromARGB(255, 12, 77, 86),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height:38,
              ),
            ],
          ),
        ),
      ),
      ),
      ),
        ]
      )
    );
  }
}