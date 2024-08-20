import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/signup/create_account.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key, required this.prefs});
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
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
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
                    text: 'Create an account',
                    style: TextStyle(
                      fontFamily: "Manrope",
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: const Color.fromARGB(255, 12, 77, 86),
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
                    text: 'An Elapse account gives you',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                        color: Color.fromARGB(255, 117, 117, 117),
                      ),
                  )
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: ' access to ',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                            color: Color.fromARGB(255, 117, 117, 117),
                          ),
                        ),
                        TextSpan(
                          text: 'CloudScout ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Manrope",
                            fontSize: 16,
                            color: const Color.fromARGB(255, 12, 77, 86),
                          ),
                        ),
                        TextSpan(
                          text: 'and more',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                            color: Color.fromARGB(255, 117, 117, 117),
                          ),
                        ),
                      ],
                    ),
                )
              )
            ),

            //buttons for user
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 6.0,),
                  child: SizedBox(
                    height: 59.0,
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
                            builder: (context) => CreateAccount(prefs: prefs),
                          ),
                        );
                      },
                      child: Builder(
                        builder: (BuildContext context) {
                          return Text('Sign up with email');
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height:20),
                Center(
                  child: SizedBox(
                    height: 18.0,
                    width: double.infinity,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Or choose to',
                        style: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 117, 117, 117),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height:20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 6.0,),
                  child: SizedBox(
                    height: 59.0,
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
                          return Text('Sign up with Google');
                        },
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 6.0,),
                  child: SizedBox(
                    height: 59.0,
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
                          return Text('Sign up with Apple');
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 6.0,),
                  child: SizedBox(
                    height: 59.0,
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
                            builder: (context) => FirstSetupPage(prefs: prefs),
                          ),
                        );
                      },
                      child: Builder(
                        builder: (BuildContext context) {
                          return Text('Existing user? Sign in here');
                        },
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 6.0,),
                  child: SizedBox(
                    height: 59.0,
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
                            builder: (context) => FirstSetupPage(prefs: prefs),
                          ),
                        );
                      },
                      child: Builder(
                        builder: (BuildContext context) {
                          return Text('Use elapse without an account');
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
