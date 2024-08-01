import 'package:elapse_app/providers/color_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

String theme = "system";

class _ThemeSettingsState extends State<ThemeSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                IconButton(
                    padding: EdgeInsets.only(right: 10, bottom: 10, top: 10),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.arrow_back, size: 48)),
                const Text(
                  "Set your Theme",
                  style: TextStyle(
                      fontSize: 64, fontWeight: FontWeight.w500, height: 1),
                ),
                const SizedBox(
                  height: 64,
                ),
                Consumer<ColorProvider>(builder: (
                  context,
                  colorProvider,
                  snapshot,
                ) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 25,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        bottomLeft: Radius.circular(25),
                                      )),
                                ),
                                Container(
                                  height: 50,
                                  width: 25,
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(25),
                                        bottomRight: Radius.circular(25),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                              value: "system",
                              groupValue: theme,
                              onChanged: (value) {
                                colorProvider.setSystem();
                                setState(() {
                                  theme = value!;
                                });
                              }),
                          Text(
                            "System",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 5),
                            ),
                          ),
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                              value: "dark",
                              groupValue: theme,
                              onChanged: (value) {
                                colorProvider.setDark();
                                setState(() {
                                  theme = value!;
                                });
                              }),
                          Text(
                            "Dark",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 5),
                            ),
                          ),
                          SizedBox(height: 15),
                          Radio<String>(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                              value: "light",
                              groupValue: theme,
                              onChanged: (value) {
                                colorProvider.setLight();
                                setState(() {
                                  theme = value!;
                                });
                              }),
                          Text(
                            "Light",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ],
                  );
                }),
                SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    Spacer(),
                    TextButton(
                        style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.secondary)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save theme",
                          style: TextStyle(fontSize: 18),
                        )),
                    Spacer(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
