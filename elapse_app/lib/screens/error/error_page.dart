import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).canvasColor,
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Text("Oops!",
                    style: TextStyle(
                      fontSize: 48,
                      fontFamily: "Montserrat",
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                SizedBox(height: 36),
                Text("Something went wrong when trying to load this. We apologize for the inconvenience.",
                    style: TextStyle(fontSize: 18)),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
