import 'dart:async';
import 'package:flutter/material.dart';

import '../services/departure_service.dart';
import '../widgets/app_input_decoration.dart';
import '../widgets/header_card.dart';
import '../widgets/status_section.dart';
import '../widgets/best_result_card.dart';
import '../widgets/ranked_results_list.dart';
import '../widgets/footer_note.dart';
import '../widgets/travel_time_bar_chart.dart';
import '../widgets/trip_summary_card.dart';
import '../widgets/arrival_goal_rankings.dart';


class BestDeparturePage extends StatefulWidget {
  const BestDeparturePage({super.key});

  @override
  State<BestDeparturePage> createState() => _BestDeparturePageState();
}

class _BestDeparturePageState extends State<BestDeparturePage> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController targetArrivalController = TextEditingController();

  final DepartureService departureService = DepartureService();

  bool isLoading = false;
  String errorMessage = '';

  String bestDepartureLabel = '';
  String bestDuration = '';
  String bestDepartureTimeRaw = '';
  String bestArrivalLabel = '';

  double loadingProgress = 0.0;
  String loadingMessage = '';
  Timer? loadingTimer;
  
  String tripOrigin = '';
  String tripDestination = '';
  String tripDateDisplay = '';

  TimeOfDay? targetArrivalTime;

  List<Map<String, dynamic>> rankedResults = [];

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    dateController.dispose();
    loadingTimer?.cancel();
    targetArrivalController.dispose();
    super.dispose();
  }

  String calculateTimeSavedText() {
    if (rankedResults.length < 2) {
      return '';
    }

    final durations = rankedResults.map((item) {
      final value = item['durationSeconds'];

      if (value is int) {
        return value;
      }

      if (value is double) {
        return value.round();
      }

      return int.tryParse(value.toString()) ?? 0;
    }).where((seconds) => seconds > 0).toList();

    if (durations.length < 2) {
      return '';
    }

    final fastest = durations.reduce((a, b) => a < b ? a : b);
    final slowest = durations.reduce((a, b) => a > b ? a : b);
    final savedSeconds = slowest - fastest;

    if (savedSeconds <= 0) {
      return '';
    }

    final hours = savedSeconds ~/ 3600;
    final minutes = ((savedSeconds % 3600) / 60).round();

    String savedText;

    if (hours > 0 && minutes > 0) {
      savedText = '$hours hr $minutes min';
    } else if (hours > 0) {
      savedText = '$hours hr';
    } else {
      savedText = '$minutes min';
    }

    return 'Recommended option: leaving at $bestDepartureLabel could save about $savedText compared to the slowest departure time.';
  }

  String convertMMDDYYYYToISO(String input) {
    final parts = input.trim().split('/');

    if (parts.length != 3) {
      throw FormatException('Date must be in MM/DD/YYYY format.');
    }

    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    if (month < 1 || month > 12) {
      throw FormatException('Month must be between 1 and 12.');
    }

    if (day < 1 || day > 31) {
      throw FormatException('Day must be between 1 and 31.');
    }

    final monthString = month.toString().padLeft(2, '0');
    final dayString = day.toString().padLeft(2, '0');

    return '$year-$monthString-$dayString';
  }

  void startLoadingProgress() {
    loadingTimer?.cancel();

    final loadingSteps = [
      'Preparing route search...',
      'Generating possible departure paths...',
      'Checking traffic for all 24 hours...',
      'Comparing travel durations...',
      'Finding the shortest drive time...',
      'Building the travel time chart...',
      'Ranking departure times...',
      'Finishing results...',
    ];

    int step = 0;

    setState(() {
      loadingProgress = 0.05;
      loadingMessage = loadingSteps.first;
    });

    loadingTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;

      if (step < loadingSteps.length) {
        setState(() {
          loadingMessage = loadingSteps[step];

          // Move up to 90%, then wait for the real backend response.
          loadingProgress = ((step + 1) / loadingSteps.length) * 0.9;
        });

        step++;
      } else {
        setState(() {
          loadingMessage = 'Waiting for Google Routes data...';
          loadingProgress = 0.92;
        });
      }
    });
  }

  Future<void> pickTripDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }

    final month = pickedDate.month.toString().padLeft(2, '0');
    final day = pickedDate.day.toString().padLeft(2, '0');
    final year = pickedDate.year.toString();

    setState(() {
      dateController.text = '$month/$day/$year';
    });
  }

  Future<void> pickTargetArrivalTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: targetArrivalTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      targetArrivalTime = pickedTime;
      targetArrivalController.text = pickedTime.format(context);
    });
  }

  Future<void> fetchBestDepartureTime() async {
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();
    final dateInput = dateController.text.trim();

    if (origin.isEmpty || destination.isEmpty || dateInput.isEmpty) {
      setState(() {
        errorMessage = 'Please enter origin, destination, and date.';
        bestDepartureLabel = '';
        bestDuration = '';
        bestDepartureTimeRaw = '';
        bestArrivalLabel = '';
        rankedResults = [];
      });
      return;
    }

    String date;

    try {
      date = convertMMDDYYYYToISO(dateInput);
    } catch (e) {
      setState(() {
        errorMessage = 'Please enter the date as MM/DD/YYYY.';
        bestDepartureLabel = '';
        bestDuration = '';
        bestDepartureTimeRaw = '';
        bestArrivalLabel = '';
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
      bestArrivalLabel = '';
      rankedResults = [];
      loadingProgress = 0.0;
      loadingMessage = 'Starting route calculations...';
    });

    startLoadingProgress();

    try {
      final data = await departureService.fetchBestDepartureTime(
        origin: origin,
        destination: destination,
        date: date,
      );

      loadingTimer?.cancel();

      setState(() {
        loadingProgress = 1.0;
        loadingMessage = 'Route calculations complete!';

        bestDepartureLabel = data['bestDepartureLabel']?.toString() ?? '';
        bestDuration = data['bestDuration']?.toString() ?? '';
        bestDepartureTimeRaw = data['bestDepartureTime']?.toString() ?? '';
        bestArrivalLabel = data['bestArrivalLabel']?.toString() ?? '';
        rankedResults = List<Map<String, dynamic>>.from(data['results'] ?? []);

        tripOrigin = origin;
        tripDestination = destination;
        tripDateDisplay = dateInput;
      });
    } catch (e) {
      loadingTimer?.cancel();
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        loadingProgress = 0.0;
        loadingMessage = '';
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
            readOnly: true,
            onTap: pickTripDate,
            decoration: appInputDecoration(
              label: 'Date',
              hint: 'MM/DD/YYYY',
              icon: Icons.calendar_month_rounded,
            ).copyWith(
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: targetArrivalController,
            readOnly: true,
            onTap: pickTargetArrivalTime,
            decoration: appInputDecoration(
              label: 'Optional Target Arrival Time',
              hint: 'Example: 6:30 PM',
              icon: Icons.alarm_rounded,
            ).copyWith(
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (targetArrivalTime != null)
                    IconButton(
                      tooltip: 'Clear target arrival time',
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        setState(() {
                          targetArrivalTime = null;
                          targetArrivalController.clear();
                        });
                      },
                    ),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
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

  DateTime? buildTargetArrivalDateTime() {
    if (targetArrivalTime == null || tripDateDisplay.isEmpty) {
      return null;
    }

    final parts = tripDateDisplay.split('/');

    if (parts.length != 3) {
      return null;
    }

    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      return null;
    }

    return DateTime(
      year,
      month,
      day,
      targetArrivalTime!.hour,
      targetArrivalTime!.minute,
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
                  loadingProgress: loadingProgress,
                  loadingMessage: loadingMessage,
                ),
                if (!isLoading && errorMessage.isEmpty) ...[
                  TripSummaryCard(
                    origin: tripOrigin,
                    destination: tripDestination,
                    date: tripDateDisplay,
                    comparedCount: rankedResults.length,
                  ),

                  const SizedBox(height: 18),

                  BestResultCard(
                    bestDepartureLabel: bestDepartureLabel,
                    bestDuration: bestDuration,
                    bestDepartureTimeRaw: bestDepartureTimeRaw,
                    bestArrivalLabel: bestArrivalLabel,
                    timeSavedText: calculateTimeSavedText(),
                  ),
                  if (bestDepartureLabel.isNotEmpty) ...[
                    const SizedBox(height: 18),

                    TravelTimeBarChart(
                      rankedResults: rankedResults,
                    ),

                    const SizedBox(height: 18),

                    if (buildTargetArrivalDateTime() != null) ...[
                      ArrivalGoalRankings(
                        rankedResults: rankedResults,
                        targetArrivalTime: buildTargetArrivalDateTime()!,
                      ),
                      const SizedBox(height: 18),
                    ],

                    RankedResultsList(rankedResults: rankedResults),
                  ],
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