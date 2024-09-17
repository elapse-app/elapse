import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/setup/signup/login_or_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../team_screen/scoutsheet/edit.dart';
import '../widgets/app_bar.dart';
import '../widgets/rounded_top.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  late String displayName, email;

  @override
  void initState() {
    super.initState();
    ElapseUser currentUser = elapseUserDecode(prefs.getString("currentUser")!);
    displayName = "${currentUser.fname} ${currentUser.lname}";
    email = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: CustomScrollView(slivers: [
          const ElapseAppBar(
            title: Text(
              "Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            backNavigation: true,
          ),
          const RoundedTop(),
          SliverToBoxAdapter(
              child: Container(
                  height: 370,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.symmetric(horizontal: 23),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Edit Account",
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 18),
                        TextFormField(
                            decoration:
                                ElapseInputDecoration(context, "Display Name"),
                            initialValue: displayName,
                            onChanged: (val) {
                              displayName = val;
                            }),
                        const SizedBox(height: 10),
                        TextFormField(
                            decoration: ElapseInputDecoration(context, "Email"),
                            initialValue: email,
                            onChanged: (val) {
                              email = val;
                            }),
                        const SizedBox(height: 18),
                        GestureDetector(
                            onTap: () {
                              FirebaseAuth.instance.currentUser!
                                  .updateDisplayName(displayName);
                              FirebaseAuth.instance.currentUser!
                                  .verifyBeforeUpdateEmail(email);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: const Center(
                                  child: Text("Save",
                                      style: TextStyle(fontSize: 18))),
                            )),
                        const SizedBox(height: 18),
                        GestureDetector(
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpPage(onboarding: false)),
                                  ModalRoute.withName("/"),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: const Center(
                                  child: Text("Sign out",
                                      style: TextStyle(fontSize: 18))),
                            )),
                      ])))
        ]));
  }
}
