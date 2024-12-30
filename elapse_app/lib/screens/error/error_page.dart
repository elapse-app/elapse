import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(23.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Text("Oops!", style: TextStyle(fontSize: 48)),
            SizedBox(height: 18),
            Text("Something went wrong when trying to load this. We apologize for the inconvenience."),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
