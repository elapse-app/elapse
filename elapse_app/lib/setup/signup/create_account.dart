import 'package:elapse_app/setup/signup/verify_account.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        child: Form(
          key: _formKey,
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
                      text: 'Use your email',
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
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'We\'ll send you a verification code',
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
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.fromLTRB(23, 16, 23, 1),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 211, 211, 211),
                      ),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 35, 35, 35),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Manrope",
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(23, 8, 23, 16),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 211, 211, 211),
                      ),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 35, 35, 35),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Manrope",
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6 || value.length > 12) {
                      return 'Password must be 6-12 characters';
                    }
                    return null;
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                  child: RichText(
                    text: TextSpan(
                      text: '6-12 characters',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontFamily: "Manrope",
                        fontSize: 10,
                        color: Color.fromARGB(255, 35, 35, 35),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(23.0),
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
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save email and password to SharedPreferences
                        widget.prefs.setString('email', _emailController.text);
                        widget.prefs.setString('password', _passwordController.text);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyAccount(prefs: widget.prefs),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Create with email',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: "Manrope",
                        fontSize: 19,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}