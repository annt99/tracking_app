import 'package:flutter/material.dart';
import 'package:tracking_app/src/screens/test_screen.dart';
import 'package:tracking_app/src/screens/tracking_service.dart';

import 'src/screens/tracking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TrackingService.instance.getTrackingState();
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWidget(),
    );
  }
}
