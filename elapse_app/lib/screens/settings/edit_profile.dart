import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../team_screen/scoutsheet/edit.dart';
import '../widgets/app_bar.dart';
import '../widgets/rounded_top.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late String displayName, email;

  @override
  void initState() {
    super.initState();
    displayName = FirebaseAuth.instance.currentUser!.displayName!;
    email = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const ElapseAppBar(
            title: Text("Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
            backNavigation: true,
          ),
          const RoundedTop(),
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Edit Profile", style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 18),
                  TextFormField(
                    decoration: ElapseInputDecoration(context, "Display Name"),
                    initialValue: displayName,
                    onChanged: (val) {
                      displayName = val;
                    }
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: ElapseInputDecoration(context, "Email"),
                    initialValue: email,
                    onChanged: (val) {
                      email = val;
                    }
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
                      FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(email);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.secondary),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: const Center(child: Text("Save", style: TextStyle(fontSize: 18))),
                    )
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }
}