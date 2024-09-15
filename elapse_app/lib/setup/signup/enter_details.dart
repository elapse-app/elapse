import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/join_team.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

class EnterDetailsPage extends StatefulWidget {
  const EnterDetailsPage({
    super.key,
  });

  @override
  State<EnterDetailsPage> createState() => _EnterDetailsPageState();
}

class _EnterDetailsPageState extends State<EnterDetailsPage> {
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
                title: Row(children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ]),
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
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 46),
                        Center(
                          child: Text(
                            'Enter your details',
                            style: TextStyle(
                              fontFamily: "Manrope",
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.secondary,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.25),
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 1.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2.0,
                                ),
                              ),
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.25),
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 1.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2.0,
                                ),
                              ),
                              labelText: 'Age',
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Manrope",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 38),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 23.0),
                          child: LongButton(
                            text: "Continue",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EnterDetailsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ]));
  }
}
