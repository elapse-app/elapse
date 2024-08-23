import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState(prefs: prefs);
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  _JoinTeamPageState({required this.prefs});
  final SharedPreferences prefs;
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
    widget.prefs.setString("savedTeam",
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EnterDetailsPage(prefs: widget.prefs)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Join Team'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
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
                        fontWeight: FontWeight.normal,
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
                    border: OutlineInputBorder(),
                    labelText: 'Team Number',
                    labelStyle: TextStyle(
                    color: Color.fromARGB(255, 73, 69, 79),
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
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 191, 231, 237),
                        width: 1.0,
                      ),
                    ),
                    onPressed: () {
                      if (buttonLabel == "Search") {
                        searchTeam();
                      } else if (buttonLabel == "Confirm" && selectedTeam != null) {
                        saveTeam(selectedTeam!);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThemeSetup(prefs: prefs),
                            ),
                          );
                      }
                    },
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
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
    );
  }
}