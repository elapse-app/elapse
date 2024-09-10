import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/setup/configure/join_team.dart';
import 'package:elapse_app/setup/deprecated/team_setup.dart';
import 'package:elapse_app/setup/signup/verify_account.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/welcome/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/setup/signup/verify_account.dart';

class EnterDetailsPage extends StatelessWidget {
  const EnterDetailsPage({super.key, });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _ageController = TextEditingController();

    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 191, 231, 237),
      // appBar: PreferredSize(
      //   preferredSize: MediaQuery.of(context).size * 0.07,
      //   child: AppBar(
      //     automaticallyImplyLeading: false,
      //     backgroundColor: Color.fromARGB(255, 191, 231, 237),
      //     title: GestureDetector(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: const Row(
      //         children: [
      //           Icon(Icons.arrow_back),
      //           SizedBox(width: 12),
      //           Text('Create account',
      //             style: TextStyle(
      //           fontSize: 24,
      //           fontFamily: 'Manrope',
      //           fontWeight: FontWeight.w600,
      //           color: Color.fromARGB(255, 0, 0, 0),
      //         ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      
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
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 46),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Enter your details',
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
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Please fill in the fields below',
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
              padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
              child: TextFormField(
                controller: _nameController,
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
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 73, 69, 79),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Manrope",
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
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
                  labelText: 'Age',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 73, 69, 79),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Manrope",
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 0),
              child: SizedBox(
                height: 59.0,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 19, 19, 19),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 12, 77, 86),
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 191, 231, 237),
                      width: 1.0,
                      )
                    ),
                  onPressed: () {
                    prefs.setString('name', _nameController.text);
                      prefs.setString('age', _ageController.text);
                    // Use the collected name and age here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JoinTeamPage(),
                      ),
                    );
                  },
                  child: Builder(
                    builder: (BuildContext context) {
                      return Text(
                        'Next',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "Manrope",
                          fontSize: 16,
                          color: Color.fromARGB(255, 12, 77, 86),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
      ),
      ),
        ]
      )
    );
  }
}