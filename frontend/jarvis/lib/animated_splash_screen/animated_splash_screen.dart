import 'package:flutter/material.dart';
import 'package:jarvis/main.dart';

import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 2500,
        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/life_tracker_splash.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Life Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
          ],
        ),
        nextScreen: LifeTrackerApp(),
        backgroundColor: Colors.white,
      ),
    );
  }
}
