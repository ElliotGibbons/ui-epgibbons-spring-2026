import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import 'info_pill.dart';

class BestResultCard extends StatelessWidget {
  final String bestDepartureLabel;
  final String bestDuration;
  final String bestDepartureTimeRaw;
  final String bestArrivalLabel;
  final String timeSavedText;

  const BestResultCard({
    super.key,
    required this.bestDepartureLabel,
    required this.bestDuration,
    required this.bestDepartureTimeRaw,
    required this.bestArrivalLabel,
    required this.timeSavedText,
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
              const Expanded(
                child: Text(
                  'Recommended Departure Time',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
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
                title: 'Arrive At',
                value: bestArrivalLabel.isEmpty
                    ? 'Unknown arrival'
                    : bestArrivalLabel,
                icon: Icons.flag_rounded,
              ),
              InfoPill(
                title: 'Date',
                value: formatDateMMDDYYYY(bestDepartureTimeRaw),
                icon: Icons.event_rounded,
              ),
            ],
          ),

          if (timeSavedText.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.savings_rounded,
                    color: Color(0xFF15803D),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      timeSavedText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF14532D),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}