import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyAccount extends StatelessWidget {
  const VerifyAccount({super.key, required this.prefs});
  final SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'Verify your email',
                  style: TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 67, 129, 192),
                  ),
                ),
              ),
            )
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'Check your inbox or spam folder',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: "Manrope",
                    fontSize: 19,
                    color: Colors.grey[350],
                  ),
                )
              )
            )
          ),

          //input for user
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  //obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'XXXXXX',
                    labelStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.normal,
                      fontFamily: "Manrope",
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 55.0,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 76, 81, 175),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 76, 81, 175),
                        width: 2.0,
                      )
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnterDetailsPage(prefs: prefs),
                        ),
                      );
                    },
                    child: Builder(
                      builder: (BuildContext context) {
                        return Text('Next',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: "Manrope",
                            fontSize: 19,
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
        ]
      )
      ),
    );
  }
}
