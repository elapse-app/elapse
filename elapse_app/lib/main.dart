import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // runApp(MyApp(
  //   prefs: prefs,
  // ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ColorProvider(prefs: prefs),
      child: MyApp(prefs: prefs),
    ),
  );
}

class MyApp extends StatefulWidget {
  final prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      bool systemDefined = false;
      ColorScheme systemTheme =
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? darkScheme
              : lightScheme;
      ;

      if (widget.prefs.getString("theme") == "system") {
        print("system");
        systemDefined = true;
      }
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: systemDefined ? systemTheme : colorProvider.colorScheme,
          fontFamily: "Manrope",
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(title: Text("Nice")),
          body: Container(
              child: Row(
            children: [
              TextButton(
                  onPressed: () {
                    colorProvider.setLight();
                  },
                  child: const Text("Light")),
              TextButton(
                  onPressed: () {
                    colorProvider.setDark();
                  },
                  child: const Text("Dark")),
              TextButton(
                  onPressed: () {
                    colorProvider.setSystem();
                  },
                  child: const Text("System"))
            ],
          )),
        ),
      );
    });
  }
}
