import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TravelTimeBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> rankedResults;

  const TravelTimeBarChart({
    super.key,
    required this.rankedResults,
  });

  @override
  State<TravelTimeBarChart> createState() => _TravelTimeBarChartState();
}

class _TravelTimeBarChartState extends State<TravelTimeBarChart> {
  final ScrollController chartScrollController = ScrollController();

  @override
  void dispose() {
    chartScrollController.dispose();
    super.dispose();
  }

  void scrollChartWithMouseWheel(PointerScrollEvent event) {
    if (!chartScrollController.hasClients) return;

    final newOffset =
        chartScrollController.offset + event.scrollDelta.dy;

    final clampedOffset = newOffset.clamp(
      chartScrollController.position.minScrollExtent,
      chartScrollController.position.maxScrollExtent,
    );

    chartScrollController.jumpTo(clampedOffset);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rankedResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedByDeparture = [...widget.rankedResults];

    sortedByDeparture.sort((a, b) {
      final aTime = a['departureTime']?.toString() ?? '';
      final bTime = b['departureTime']?.toString() ?? '';
      return aTime.compareTo(bTime);
    });

    final durations = sortedByDeparture.map((item) {
      final value = item['durationSeconds'];

      if (value is int) {
        return value.toDouble();
      }

      if (value is double) {
        return value;
      }

      return double.tryParse(value.toString()) ?? 0.0;
    }).toList();

    final maxDuration = durations.reduce((a, b) => a > b ? a : b);
    final minDuration = durations.reduce((a, b) => a < b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Travel Time by Departure Time',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Y-axis shows travel time. X-axis shows the time you leave.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Use your mouse wheel while hovering over the chart to scroll sideways.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 24),

          Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                scrollChartWithMouseWheel(pointerSignal);
              }
            },
            child: Scrollbar(
              controller: chartScrollController,
              thumbVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: chartScrollController,
                scrollDirection: Axis.horizontal,
                primary: false,
                child: SizedBox(
                  height: 330,
                  width: sortedByDeparture.length * 80.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(sortedByDeparture.length, (index) {
                      final item = sortedByDeparture[index];

                      final label =
                          item['departureLabel']?.toString() ?? 'Unknown';

                      final durationText =
                          item['durationText']?.toString() ?? 'Unknown';

                      final durationSeconds = durations[index];

                      final barHeight = maxDuration == 0
                          ? 0.0
                          : (durationSeconds / maxDuration) * 190;

                      final isBest = durationSeconds == minDuration;

                      return SizedBox(
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                durationText,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isBest
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isBest
                                      ? const Color(0xFF15803D)
                                      : Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Tooltip(
                                message: '$label\nDrive time: $durationText',
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  height: barHeight,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: isBest
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFF2563EB),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fastest travel time',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Other departure times',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}