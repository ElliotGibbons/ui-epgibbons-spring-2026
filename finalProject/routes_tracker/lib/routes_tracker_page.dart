import 'package:flutter/material.dart';
import 'pages/best_departure_page.dart';

class RoutesTrackerApp extends StatelessWidget {
  const RoutesTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routes Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: const BestDeparturePage(),
    );
  }
}