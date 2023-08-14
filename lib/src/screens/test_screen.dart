import 'package:flutter/material.dart';
import 'package:tracking_app/src/screens/tracking_screen.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: TextButton(
            child: const Text(
              'Tracking Screen',
              style: TextStyle(fontSize: 25, color: Colors.blue),
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TrackingScreen()))));
  }
}
