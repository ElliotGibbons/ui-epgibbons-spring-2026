import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

class ArrivalGoalRankings extends StatefulWidget {
  final List<Map<String, dynamic>> rankedResults;
  final DateTime targetArrivalTime;

  const ArrivalGoalRankings({
    super.key,
    required this.rankedResults,
    required this.targetArrivalTime,
  });

  @override
  State<ArrivalGoalRankings> createState() => _ArrivalGoalRankingsState();
}

class _ArrivalGoalRankingsState extends State<ArrivalGoalRankings> {
  bool isExpanded = false;

  int getArrivalDifferenceMinutes(Map<String, dynamic> item) {
    final arrivalRaw = item['arrivalTime']?.toString() ?? '';

    if (arrivalRaw.isEmpty) {
      return 999999;
    }

    try {
      final arrivalTime = DateTime.parse(arrivalRaw).toLocal();
      return arrivalTime
          .difference(widget.targetArrivalTime)
          .inMinutes
          .abs();
    } catch (e) {
      return 999999;
    }
  }

  int getDurationSeconds(Map<String, dynamic> item) {
    final value = item['durationSeconds'];

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    return int.tryParse(value.toString()) ?? 999999;
  }

    String formatDifferenceForItem(Map<String, dynamic> item) {
        final arrivalRaw = item['arrivalTime']?.toString() ?? '';

        if (arrivalRaw.isEmpty) {
            return 'Unknown arrival match';
        }

        try {
            final arrivalTime = DateTime.parse(arrivalRaw).toLocal();
            final signedMinutes =
                arrivalTime.difference(widget.targetArrivalTime).inMinutes;

            if (signedMinutes == 0) {
            return 'Arrives exactly on time';
            }

            final absMinutes = signedMinutes.abs();
            final hours = absMinutes ~/ 60;
            final minutes = absMinutes % 60;

            String timeText;

            if (hours > 0 && minutes > 0) {
            timeText = '$hours hr $minutes min';
            } else if (hours > 0) {
            timeText = '$hours hr';
            } else {
            timeText = '$minutes min';
            }

            if (signedMinutes < 0) {
            return 'Arrives $timeText early';
            }

            return 'Arrives $timeText late';
        } catch (e) {
            return 'Unknown arrival match';
        }
    }

  String formatTargetTime(DateTime dateTime) {
    var hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rankedResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final goalRankings = widget.rankedResults.where((item) {
        final arrivalRaw = item['arrivalTime']?.toString() ?? '';

        if (arrivalRaw.isEmpty) {
            return false;
        }

        try {
            final arrivalTime = DateTime.parse(arrivalRaw).toLocal();

            final minutesAfterTarget =
                arrivalTime.difference(widget.targetArrivalTime).inMinutes;

            // Keep anything before the target time.
            // Keep anything up to 30 minutes after the target time.
            // Throw away anything more than 30 minutes late.
            return minutesAfterTarget <= 30;
        } catch (e) {
            return false;
        }
        }).toList();

        goalRankings.sort((a, b) {
        final aDifference = getArrivalDifferenceMinutes(a);
        final bDifference = getArrivalDifferenceMinutes(b);

        if (aDifference != bDifference) {
            return aDifference.compareTo(bDifference);
        }

        final aDuration = getDurationSeconds(a);
        final bDuration = getDurationSeconds(b);

        return aDuration.compareTo(bDuration);
        });

        if (goalRankings.isEmpty) {
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
                child: const Row(
                children: [
                    Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                    child: Text(
                        'No departure times arrive within 30 minutes after your target arrival time.',
                        style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        ),
                    ),
                    ),
                ],
                ),
            );
            }

    
    final best = goalRankings.first;
    final bestDeparture = best['departureLabel']?.toString() ?? 'Unknown time';
    final bestArrival = best['arrivalLabel']?.toString() ?? 'Unknown arrival';
    final bestDuration = best['durationText']?.toString() ?? 'Unknown duration';
    final bestDifferenceText = formatDifferenceForItem(best);

    return Container(
      width: double.infinity,
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
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.alarm_on_rounded,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Best Times for ${formatTargetTime(widget.targetArrivalTime)} Arrival',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 30,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Text(
                  'Best match: leave at $bestDeparture, arrive around $bestArrival, drive time $bestDuration. $bestDifferenceText. Tap to view all matches.',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.35,
                  ),
                ),
              ),
            ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'These results are ranked first by closest arrival time, then by shortest travel time.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Column(
                    children: List.generate(goalRankings.length, (index) {
                      final item = goalRankings[index];

                      final departure =
                          item['departureLabel']?.toString() ?? 'Unknown time';
                      final arrival =
                          item['arrivalLabel']?.toString() ?? 'Unknown arrival';
                      final duration =
                          item['durationText']?.toString() ?? 'Unknown duration';
                      final rawTime = item['departureTime']?.toString() ?? '';
                      final formattedDate = formatDateMMDDYYYY(rawTime);

                      final rank = index + 1;
                      final differenceText = formatDifferenceForItem(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: rank == 1
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: rank == 1
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: rank == 1
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFCBD5E1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  color: rank == 1
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Leave at $departure',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Estimated arrival: $arrival',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Target match: $differenceText',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Predicted drive time: $duration',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: $formattedDate',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}