import 'package:flutter/material.dart';
import 'package:elapse_app/setup/first_page.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'Create an account',
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
                  text: 'An Elapse account gives you',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Center(
              child: RichText(
                text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: ' access to ',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: "Manrope",
                          fontSize: 19,
                          color: Colors.grey[350],
                        ),
                      ),
                      TextSpan(
                        text: 'CloudScout ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Manrope",
                          fontSize: 19,
                          color: const Color.fromARGB(255, 67, 129, 192),
                        ),
                      ),
                      TextSpan(
                        text: 'and more',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: "Manrope",
                          fontSize: 19,
                          color: Colors.grey[350],
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
                          builder: (context) => FirstSetupPage(),
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
              Center(
                child: SizedBox(
                  height: 20.0,
                  width: double.infinity,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Or choose to',
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 16,
                        color: Colors.grey[350],
                      ),
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
                          builder: (context) => FirstSetupPage(),
                        ),
                      );
                    },
                    child: Builder(
                      builder: (BuildContext context) {
                        return Text('Sign in with Google');
                      },
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
                          builder: (context) => FirstSetupPage(),
                        ),
                      );
                    },
                    child: Builder(
                      builder: (BuildContext context) {
                        return Text('Sign in with Apple');
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
                          builder: (context) => FirstSetupPage(),
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
                          builder: (context) => FirstSetupPage(),
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
              SizedBox(height: 20),
            ],
          ),
        ]
      )
    );
  }
}
