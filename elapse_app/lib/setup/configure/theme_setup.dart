import 'package:elapse_app/main.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/match_notifs_setup.dart';
import 'package:elapse_app/setup/configure/tournament_mode_setup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSetup extends StatefulWidget {
  const ThemeSetup({
    super.key,
  });

  @override
  State<ThemeSetup> createState() => _ThemeSetupState();
}

class _ThemeSetupState extends State<ThemeSetup> {
  _ThemeSetupState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: CustomScrollView(physics: const NeverScrollableScrollPhysics(), slivers: [
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
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23.0),
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 0,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Personalize Elapse',
                                  style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Choose a theme you want to use',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Manrope",
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          Column(
                            children: [
                              LongButton(
                                  onPressed: () {
                                    Provider.of<ColorProvider>(context, listen: false).setSystem();
                                    print(prefs.getString("theme"));
                                  },
                                  gradient: prefs.getString("theme") == "system",
                                  text: "System"),
                              SizedBox(height: 15),
                              LongButton(
                                  onPressed: () {
                                    Provider.of<ColorProvider>(context, listen: false).setLight();
                                    print(prefs.getString("theme"));
                                  },
                                  gradient: prefs.getString("theme") == "light",
                                  text: "Light"),
                              SizedBox(height: 15),
                              LongButton(
                                  onPressed: () {
                                    Provider.of<ColorProvider>(context, listen: false).setDark();
                                    print(prefs.getString("theme"));
                                  },
                                  gradient: prefs.getString("theme") == "dark",
                                  text: "Dark"),
                            ],
                          ),
                          SizedBox(
                            height: 32,
                          ),
                          Spacer(),
                          LongButton(
                              centerAlign: true,
                              useForwardArrow: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => 
                                    // ---- THE FOLLOWING IS MATCH NOTIFICATIONS CODE. UNCOMMENT TO ENABLE MATCH NOTIFICATIONS UI ---- //
                                    
                                      NotifsSetup(),
                                    
                                    //TournamentModeSetupPage(),
                                  ),
                                );
                              },
                              text: "Next"),
                          SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]));
  }
}
