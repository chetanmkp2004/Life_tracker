import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/habit_provider.dart';
import 'providers/goal_provider.dart';

void main() {
  runApp(const LifeTrackerApp());
}

class LifeTrackerApp extends StatelessWidget {
  const LifeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => GoalProvider()),
      ],
      child: MaterialApp(
        title: 'Life Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}