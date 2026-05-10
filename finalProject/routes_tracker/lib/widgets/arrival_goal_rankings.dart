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

  DateTime? parseArrivalLabelToTargetDate(Map<String, dynamic> item) {
    final arrivalLabel = item['arrivalLabel']?.toString() ?? '';

    if (arrivalLabel.isEmpty || arrivalLabel == 'Unknown arrival') {
      return null;
    }

    final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    final match = regex.firstMatch(arrivalLabel.trim());

    if (match == null) {
      return null;
    }

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3)?.toUpperCase();

    if (hour == null || minute == null || period == null) {
      return null;
    }

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(
      widget.targetArrivalTime.year,
      widget.targetArrivalTime.month,
      widget.targetArrivalTime.day,
      hour,
      minute,
    );
  }

  int getSignedArrivalDifferenceMinutes(Map<String, dynamic> item) {
    final arrivalTime = parseArrivalLabelToTargetDate(item);

    if (arrivalTime == null) {
      return 999999;
    }

    return arrivalTime.difference(widget.targetArrivalTime).inMinutes;
  }

  int getAbsoluteArrivalDifferenceMinutes(Map<String, dynamic> item) {
    return getSignedArrivalDifferenceMinutes(item).abs();
  }

  bool arrivesInsideAllowedWindow(Map<String, dynamic> item) {
    final signedMinutes = getSignedArrivalDifferenceMinutes(item);

    // Keep results that arrive from 2 hours early through 30 minutes late.
    return signedMinutes >= -120 && signedMinutes <= 30;
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
    final signedMinutes = getSignedArrivalDifferenceMinutes(item);

    if (signedMinutes == 999999) {
      return 'Unknown arrival match';
    }

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

    final goalRankings = widget.rankedResults
        .where(arrivesInsideAllowedWindow)
        .toList();

        goalRankings.sort((a, b) {
            final aSigned = getSignedArrivalDifferenceMinutes(a);
            final bSigned = getSignedArrivalDifferenceMinutes(b);

            final aAbs = aSigned.abs();
            final bAbs = bSigned.abs();

            final aIsGoodEarly = aSigned >= -45 && aSigned <= 0;
            final bIsGoodEarly = bSigned >= -45 && bSigned <= 0;

            final aIsLate = aSigned > 0;
            final bIsLate = bSigned > 0;

            final aDuration = getDurationSeconds(a);
            final bDuration = getDurationSeconds(b);

            int bucket(int minutes) {
                return (minutes.abs() / 30).floor();
            }

            // Priority 1:
            // Arriving up to 45 minutes early is better than arriving late.
            if (aIsGoodEarly != bIsGoodEarly) {
                return aIsGoodEarly ? -1 : 1;
            }

            // Priority 2:
            // If both are in the 45-minute early window,
            // compare by 30-minute closeness bucket, then shortest travel time.
            if (aIsGoodEarly && bIsGoodEarly) {
                final aBucket = bucket(aSigned);
                final bBucket = bucket(bSigned);

                if (aBucket != bBucket) {
                return aBucket.compareTo(bBucket);
                }

                return aDuration.compareTo(bDuration);
            }

            // Priority 3:
            // If both are late,
            // compare by 30-minute lateness bucket, then shortest travel time.
            if (aIsLate && bIsLate) {
                final aBucket = bucket(aSigned);
                final bBucket = bucket(bSigned);

                if (aBucket != bBucket) {
                return aBucket.compareTo(bBucket);
                }

                return aDuration.compareTo(bDuration);
            }

            // Priority 4:
            // If both are earlier than 45 minutes,
            // compare by 30-minute closeness bucket, then shortest travel time.
            final aBucket = bucket(aSigned);
            final bBucket = bucket(bSigned);

            if (aBucket != bBucket) {
                return aBucket.compareTo(bBucket);
            }

            if (aAbs != bAbs) {
                return aAbs.compareTo(bAbs);
            }

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
                'No departure times arrive between 2 hours early and 30 minutes late for your target arrival time.',
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
                    'These results arrive between 2 hours early and 30 minutes late. They are ranked by closest arrival time, then early arrivals, then shortest travel time.',
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