import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Application/Utils/Extensions/padding.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/HomePage/components/live_time.dart';

import '../PrayerTimesScreen/prayer_times_screen.dart';
import 'components/LiveLocation/live_location.dart';
import 'components/mosque_card.dart';

class NearbyMosquesScreen extends StatelessWidget {
  const NearbyMosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header: Time + City + More button
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LiveClock(
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LiveCityWidget(),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 8),
          ),
          // Title
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nearby Mosques",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ).paddingSymmetric(horizontal: 10),
          ),

          // Mosque list
          SliverList(
            delegate: SliverChildListDelegate([
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrayerTimesScreen(),
                    ),
                  );
                },
                child: const MosqueCard(
                  name: "Faisal Mosque",
                  distance: "2.5 km",
                  fajrTime: "4:45 AM",
                  distanceSmall: "500 m",
                  isNext: true,
                  verified: false,
                ),
              ),
              const SizedBox(height: 12),
              const MosqueCard(
                name: "Grand Jamia Masid",
                distance: "500 m",
                fajrTime: "4:45 AM",
                dhuhrTime: "1:30 PM",
                asrTime: "4:30 PM",
                ishaTime: "8:00 PM",
                currentPrayer: "Asr",
                verified: false,
              ),
              const SizedBox(height: 12),
              const MosqueCard(
                name: "Grand Jamia Masid",
                distance: null,
                fajrTime: "4:30 AM",
                dhuhrTime: "1:30 PM (Jama'at)",
                asrTime: "4:15 PM",
                ishaTime: "8:35 PM",
                currentPrayer: "Asr",
                verified: true,
              ),
              const SizedBox(height: 12),
              const MosqueCard(
                name: "Badashi Mosque",
                distance: null,
                asrTime: "4:15 PM",
                ishaTime: "8:00 PM",
                currentPrayer: "Isha",
                verified: true,
              ),
              const SizedBox(height: 12),
              const MosqueCard(
                name: "Fajr Mosque", // probably typo in screenshot
                distance: null,
                fajrTime: "4:45 AM",
                ishaTime: "8:00 PM",
                verified: true,
              ),
              const SizedBox(height: 80), // space for bottom nav
            ]),
          ),
        ],
      ),
    );
  }
}
