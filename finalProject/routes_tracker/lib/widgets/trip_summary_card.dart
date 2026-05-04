import 'package:flutter/material.dart';

class TripSummaryCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String date;
  final int comparedCount;

  const TripSummaryCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.comparedCount,
  });

  @override
  Widget build(BuildContext context) {
    if (origin.isEmpty || destination.isEmpty || date.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.route_rounded,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                '$origin → $destination',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.query_stats_rounded,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                '$comparedCount departure times compared',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}