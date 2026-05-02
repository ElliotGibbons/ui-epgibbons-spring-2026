import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import 'info_pill.dart';

class BestResultCard extends StatelessWidget {
  final String bestDepartureLabel;
  final String bestDuration;
  final String bestDepartureTimeRaw;

  const BestResultCard({
    super.key,
    required this.bestDepartureLabel,
    required this.bestDuration,
    required this.bestDepartureTimeRaw,
  });

  @override
  Widget build(BuildContext context) {
    if (bestDepartureLabel.isEmpty && bestDuration.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDCFCE7),
            Color(0xFFE0F2FE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Best Departure Time',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              InfoPill(
                title: 'Leave At',
                value: bestDepartureLabel,
                icon: Icons.schedule_rounded,
              ),
              InfoPill(
                title: 'Drive Time',
                value: bestDuration,
                icon: Icons.directions_car_filled_rounded,
              ),
              InfoPill(
                title: 'Date',
                value: formatDateMMDDYYYY(bestDepartureTimeRaw),
                icon: Icons.event_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}