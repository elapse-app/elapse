import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyAccount extends StatelessWidget {
  const VerifyAccount({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();

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
            SizedBox(height: 46),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Verify your email',
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
                    text: 'Check your inbox or spam folder',
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                  child: TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 211, 211, 211),
                        ),
                      ),
                      labelText: 'XXXXXX',
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
                  padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 0),
                  child: SizedBox(
                    height: 59.0,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 12, 77, 86),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 191, 231, 237),
                      width: 1.0,
                      )
                    ),
                      onPressed: () {
                        final code = _codeController.text;
                        // Use the collected code here
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnterDetailsPage(prefs: prefs),
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
          ],
        ),
      ),
    );
  }
}