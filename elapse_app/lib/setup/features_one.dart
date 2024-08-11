import 'package:flutter/material.dart';
import 'package:elapse_app/setup/first_page.dart'; // Import the FirstSetupPage

class FirstFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FirstSetupPage()),
              );
            },
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FirstSetupPage()),
              );
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text('Welcome'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Centered Title',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Centered Subtitle',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            width: 100,
            color: Colors.grey,
            child: Center(child: Text('Demo Phone')),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
}