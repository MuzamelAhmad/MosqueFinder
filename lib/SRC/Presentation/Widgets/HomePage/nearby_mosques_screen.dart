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

class NearbyMosquesScreen extends StatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen>
    with WidgetsBindingObserver {
  // ✅ Local cache to keep the list visible during refreshes
  List<Map<String, dynamic>>? _cachedMosques;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final cubit = context.read<MuqtadiCubit>();
      if (cubit.state is MuqtadiError) {
        cubit.fetchNearbyMosques();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: BlocBuilder<MuqtadiCubit, MuqtadiState>(
        builder: (context, state) {
          // Update cache when data arrives
          if (state is MuqtadiLoaded) {
            _cachedMosques = state.mosques;
          }

          final mosquesToShow = _cachedMosques;

          return RefreshIndicator(
            onRefresh: () => context.read<MuqtadiCubit>().fetchNearbyMosques(),
            color: theme.colorScheme.primary,
            backgroundColor: Colors.white,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // 1. Header Section
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
                                  fontSize: 22.sp,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const LiveCityWidget(),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                                onPressed: () => context.read<MuqtadiCubit>().fetchNearbyMosques(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16.w, vertical: 8.h),
                    ),

                    // 2. Title Section
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Nearby Mosques (1 km)",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ).paddingSymmetric(horizontal: 16.w),
                    ),

                    // 3. Offline Indicator
                    SliverToBoxAdapter(
                      child: FutureBuilder<bool>(
                        future: ConnectivityHelper.hasInternet(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == false) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_off_rounded, color: Colors.orangeAccent, size: 20.r),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "Offline: Showing saved results",
                                    style: TextStyle(color: Colors.orangeAccent, fontSize: 12.sp, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    // 4. Loading/Error/Data Logic
                    if (state is MuqtadiLoading && mosquesToShow == null)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      )
                    else if (state is MuqtadiError && mosquesToShow == null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off_rounded, color: Colors.white70, size: 48.r),
                                SizedBox(height: 16.h),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton(
                                  onPressed: () => context.read<MuqtadiCubit>().fetchNearbyMosques(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white10,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: const Text("Try Again"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (mosquesToShow != null) ...[
                      if (mosquesToShow.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              "No mosques found within 1 km.",
                              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          sliver: SliverList.builder(
                            itemCount: mosquesToShow.length,
                            itemBuilder: (context, index) {
                              final mosque = mosquesToShow[index];
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
                                  distance: "${distance.toStringAsFixed(0)} meters away",
                                  fajrTime: prayerTimes?['fajr'],
                                  dhuhrTime: prayerTimes?['dhuhr'],
                                  jummaTime: prayerTimes?['jumma'],
                                  asrTime: prayerTimes?['asr'],
                                  maghribTime: prayerTimes?['maghrib'],
                                  ishaTime: prayerTimes?['isha'],
                                  verified: mosque['verified'] ?? true,
                                ).paddingOnly(bottom: 16.h),
                              );
                            },
                          ),
                        ),
                    ],

                    SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                  ],
                ),

                // 5. Background Refresh Indicator (Sleek bar at top)
                if (state is MuqtadiLoading && mosquesToShow != null)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
