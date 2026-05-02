import 'package:flutter/material.dart';

import '../services/departure_service.dart';
import '../widgets/app_input_decoration.dart';
import '../widgets/header_card.dart';
import '../widgets/status_section.dart';
import '../widgets/best_result_card.dart';
import '../widgets/ranked_results_list.dart';
import '../widgets/footer_note.dart';

class BestDeparturePage extends StatefulWidget {
  const BestDeparturePage({super.key});

  @override
  State<BestDeparturePage> createState() => _BestDeparturePageState();
}

class _BestDeparturePageState extends State<BestDeparturePage> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final DepartureService departureService = DepartureService();

  bool isLoading = false;
  String errorMessage = '';

  String bestDepartureLabel = '';
  String bestDuration = '';
  String bestDepartureTimeRaw = '';

  List<Map<String, dynamic>> rankedResults = [];

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> fetchBestDepartureTime() async {
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();
    final date = dateController.text.trim();

    if (origin.isEmpty || destination.isEmpty || date.isEmpty) {
      setState(() {
        errorMessage = 'Please enter origin, destination, and date.';
        bestDepartureLabel = '';
        bestDuration = '';
        bestDepartureTimeRaw = '';
        rankedResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      bestDepartureLabel = '';
      bestDuration = '';
      bestDepartureTimeRaw = '';
      rankedResults = [];
    });

    try {
      final data = await departureService.fetchBestDepartureTime(
        origin: origin,
        destination: destination,
        date: date,
      );

      setState(() {
        bestDepartureLabel = data['bestDepartureLabel']?.toString() ?? '';
        bestDuration = data['bestDuration']?.toString() ?? '';
        bestDepartureTimeRaw = data['bestDepartureTime']?.toString() ?? '';
        rankedResults = List<Map<String, dynamic>>.from(data['results'] ?? []);
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildInputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your start, destination, and date to compare departure times.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: originController,
            decoration: appInputDecoration(
              label: 'Origin',
              hint: 'Example: San Diego, CA',
              icon: Icons.trip_origin_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: destinationController,
            decoration: appInputDecoration(
              label: 'Destination',
              hint: 'Example: Denver, CO',
              icon: Icons.location_on_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: dateController,
            decoration: appInputDecoration(
              label: 'Date',
              hint: 'YYYY-MM-DD',
              icon: Icons.calendar_month_rounded,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading ? null : fetchBestDepartureTime,
              icon: const Icon(Icons.search_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Calculate Best Departure Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes Tracker'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeaderCard(),
                const SizedBox(height: 20),
                buildInputSection(),
                const SizedBox(height: 18),
                StatusSection(
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                ),
                if (!isLoading && errorMessage.isEmpty) ...[
                  BestResultCard(
                    bestDepartureLabel: bestDepartureLabel,
                    bestDuration: bestDuration,
                    bestDepartureTimeRaw: bestDepartureTimeRaw,
                  ),
                  if (bestDepartureLabel.isNotEmpty) const SizedBox(height: 18),
                  RankedResultsList(rankedResults: rankedResults),
                ],
                const FooterNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}