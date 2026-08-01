import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/PrayerTimesScreen/controller/hijri_provider.dart';
import 'package:provider/provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  final Map<String, dynamic>? mosqueData;
  const PrayerTimesScreen({super.key, this.mosqueData});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String gregorianDate = "Fetching...";
  String? nextPrayerName;
  String? nextPrayerTimeStr;
  Map<String, String> prayerDisplayTimes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    gregorianDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    Provider.of<HijriProvider>(context, listen: false).fetchHijriDate();
    _initializePrayerTimes();
  }

  void _initializePrayerTimes() {
    if (widget.mosqueData != null && widget.mosqueData!['Praytime'] != null) {
      final times = widget.mosqueData!['Praytime'] as Map<String, dynamic>;
      final isFriday = DateTime.now().weekday == DateTime.friday;

      setState(() {
        // Core prayers
        prayerDisplayTimes = {
          'Fajr': times['fajr'] ?? '--:--',
        };

        // Switch Dhuhr/Jumma based on day
        if (isFriday) {
          prayerDisplayTimes['Jumma'] = times['jumma'] ?? '--:--';
        } else {
          prayerDisplayTimes['Dhuhr'] = times['dhuhr'] ?? '--:--';
        }

        prayerDisplayTimes.addAll({
          'Asr': times['asr'] ?? '--:--',
          'Maghrib': times['maghrib'] ?? '--:--',
          'Isha': times['isha'] ?? '--:--',
        });

        _calculateNextPrayer();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    final formatter = DateFormat('h:mm a');
    String? upcomingName;
    String? upcomingTime;

    for (var entry in prayerDisplayTimes.entries) {
      if (entry.value == '--:--') continue;

      try {
        final prayerTime = formatter.parse(entry.value);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        if (now.isBefore(prayerDateTime)) {
          upcomingName = entry.key;
          upcomingTime = entry.value;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    setState(() {
      nextPrayerName = upcomingName ?? 'Fajr (Tomorrow)';
      nextPrayerTimeStr = upcomingTime ?? prayerDisplayTimes['Fajr'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mosqueName = widget.mosqueData?['mosque name'] ?? 'Prayer Times';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : CustomScrollView(
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                        child: Column(
                          children: [
                            Text(
                              mosqueName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Consumer<HijriProvider>(
                              builder: (context, value, child) {
                                return Text(
                                  '$gregorianDate • ${value.hijriDate ?? "Hijri loading..."}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 30.h),
                            
                            // "Next Prayer" Hero Circle
                            Container(
                              padding: EdgeInsets.all(30.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    nextPrayerTimeStr ?? '—',
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    nextPrayerName ?? 'Next Prayer',
                                    style: TextStyle(
                                      color: Colors.greenAccent.shade400,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.all(24.w),
                      sliver: SliverList.builder(
                        itemCount: prayerDisplayTimes.length,
                        itemBuilder: (context, index) {
                          final entry = prayerDisplayTimes.entries.elementAt(index);
                          final isActive = entry.key == nextPrayerName;
                          return _buildPrayerTile(context, entry.key, entry.value, isActive);
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPrayerTile(BuildContext context, String name, String time, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.white.withOpacity(0.15) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive ? Colors.greenAccent.withOpacity(0.5) : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.notifications_active : Icons.access_time,
                color: isActive ? Colors.greenAccent : Colors.white70,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              color: isActive ? Colors.greenAccent : Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
