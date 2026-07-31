import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Muqtadi/muqtadi_cubit.dart';
import 'package:mosque_finder/SRC/Application/Utils/Extensions/padding.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/HomePage/components/live_time.dart';

import 'package:mosque_finder/SRC/Application/Utils/connectivity_helper.dart';

import '../PrayerTimesScreen/prayer_times_screen.dart';
import 'components/LiveLocation/live_location.dart';
import 'components/mosque_card.dart';

class NearbyMosquesScreen extends StatelessWidget {
  const NearbyMosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: BlocBuilder<MuqtadiCubit, MuqtadiState>(
        builder: (context, state) {
          return CustomScrollView(
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
                ).paddingSymmetric(horizontal: 16.w, vertical: 8.h),
              ),
              // Title
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nearby Mosques (1 km radius)",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ).paddingSymmetric(horizontal: 10),
              ),

              if (state is MuqtadiLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (state is MuqtadiError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              if (state is MuqtadiLoaded) ...[
                SliverToBoxAdapter(
                  child: FutureBuilder<bool>(
                    future: ConnectivityHelper.hasInternet(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == false) {
                        return Container(
                          margin: EdgeInsets.all(10.w),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child:  Row(
                            children: [
                              Icon(Icons.cloud_off, color: Colors.orange, size: 20.r),
                              SizedBox(width: 10.w),
                              Text(
                                "Offline: Showing last known mosques",
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                if (state.mosques.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "No mosques found within 1 km.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: state.mosques.length,
                    itemBuilder: (context, index) {
                      final mosque = state.mosques[index];
                      final prayerTimes = mosque['Praytime'];
                      final double distance = mosque['distance_meters'];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrayerTimesScreen(mosqueData: mosque),
                            ),
                          );
                        },
                        child: MosqueCard(
                          name: mosque['mosque name'] ?? 'Unknown Mosque',
                          distance: "${distance.toStringAsFixed(0)} meters",
                          fajrTime: prayerTimes?['fajr'],
                          dhuhrTime: prayerTimes?['dhuhr'],
                          asrTime: prayerTimes?['asr'],
                          ishaTime: prayerTimes?['isha'],
                          verified: true,
                        ).paddingOnly(bottom: 12),
                      );
                    },
                  ),
              ],
              
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          );
        },
      ),
    );
  }
}
