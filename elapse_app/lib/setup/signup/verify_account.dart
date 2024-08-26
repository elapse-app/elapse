import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/signup/create_account.dart';

class VerifyAccount extends StatelessWidget {
  const VerifyAccount({super.key,});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 191, 231, 237),
      appBar: PreferredSize(
        preferredSize: MediaQuery.of(context).size * 0.07,
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 191, 231, 237),
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateAccount()),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text('Sign up',
                  style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
                ),
              ],
            ),
          ),
        ),
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
                    text: 'Create account',
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
                            builder: (context) => EnterDetailsPage(),
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