import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routes Tracker',
      home: const TravelPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  String result = '';
  bool isLoading = false;

  Future<void> getTravelTime() async {
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      setState(() {
        result = 'Please enter both an origin and a destination.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      final url =
          'http://127.0.0.1:3000/api/travel-time'
          '?origin=${Uri.encodeComponent(origin)}'
          '&destination=${Uri.encodeComponent(destination)}';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        setState(() {
          result = 'Error: ${data['error'] ?? 'Request failed'}';
        });
        return;
      }

      setState(() {
        result =
            'From: ${data['origin']}\n'
            'To: ${data['destination']}\n'
            'Distance: ${data['distanceText']}\n'
            'Time: ${data['durationText']}';
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: 'Origin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : getTravelTime,
              child: const Text('Get Travel Time'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && result.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(result),
              ),
          ],
        ),
      ),
    );
  }
}