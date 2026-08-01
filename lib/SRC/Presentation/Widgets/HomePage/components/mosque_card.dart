import 'package:flutter/material.dart';

class MosqueCard extends StatelessWidget {
  final String name;
  final String? distance;
  final String? fajrTime;
  final String? dhuhrTime;
  final String? jummaTime;
  final String? asrTime;
  final String? maghribTime;
  final String? ishaTime;
  final String? currentPrayer;
  final String? distanceSmall;
  final bool? isNext;
  final bool? verified;
  final bool? isImam;

  const MosqueCard({
    super.key,
    required this.name,
    this.distance,
    this.fajrTime,
    this.dhuhrTime,
    this.jummaTime,
    this.asrTime,
    this.maghribTime,
    this.ishaTime,
    this.currentPrayer,
    this.distanceSmall,
    this.isNext = false,
    this.verified = false,
    this.isImam = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFriday = DateTime.now().weekday == DateTime.friday;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha((255 * 0.12).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withAlpha((255 * 0.15).toInt()),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mosque icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(
                    (255 * 0.15).toInt(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mosque,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        if (verified!) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(
                                (255 * 0.07).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Verified",
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (distance != null)
                      Text(
                        distance!,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onPrimary.withAlpha(
                            (255 * 0.7).toInt(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Prayer times row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (fajrTime != null)
                _buildPrayerTime(
                  "Fajr",
                  fajrTime!,
                  currentPrayer == "Fajr",
                  context,
                ),
              if (isFriday && jummaTime != null)
                _buildPrayerTime(
                  "Jumma",
                  jummaTime!,
                  currentPrayer == "Jumma",
                  context,
                )
              else if (dhuhrTime != null)
                _buildPrayerTime(
                  "Dhuhr",
                  dhuhrTime!,
                  currentPrayer == "Dhuhr",
                  context,
                ),
              if (asrTime != null)
                _buildPrayerTime(
                  "Asr",
                  asrTime!,
                  currentPrayer == "Asr",
                  context,
                ),
              if (maghribTime != null)
                _buildPrayerTime(
                  "Maghrib",
                  maghribTime!,
                  currentPrayer == "Maghrib",
                  context,
                ),
              if (ishaTime != null)
                _buildPrayerTime(
                  "Isha",
                  ishaTime!,
                  currentPrayer == "Isha",
                  context,
                ),
            ],
          ),

          if (distanceSmall != null || isNext!) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (distanceSmall != null)
                  Text(
                    distanceSmall!,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withAlpha(
                        (255 * 0.7).toInt(),
                      ),
                      fontSize: 13,
                    ),
                  ),
                if (isNext!)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha((255 * 0.08).toInt()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Next",
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerTime(String label, String time, bool isActive, context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive
                ? Colors.green[300]
                : theme.colorScheme.onPrimary.withAlpha((255 * 0.7).toInt()),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.green[300] : theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 4),
        if (isImam!)
          const Icon(Icons.timelapse_rounded, color: Colors.green, size: 16),
        if (isActive)
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
      ],
    );
  }
}
