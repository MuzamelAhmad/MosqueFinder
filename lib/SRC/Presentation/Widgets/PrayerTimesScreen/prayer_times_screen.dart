import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/PrayerTimesScreen/controller/hijri_provider.dart';
import 'package:provider/provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String gregorianDate = "Fetching...";
  String? nextPrayerName;
  String? nextPrayerTimeStr;
  Map<String, String> prayerDisplayTimes = {
    'Fajr': '5:50',
    'Sunrise': '6:00',
    'Dhuhr': '12:30',
    'Asr': '4:30',
    'Maghrib': '6:30',
    'Isha': '8:00',
  }; // name → formatted time (jamaah or prayer)
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    gregorianDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    Provider.of<HijriProvider>(context, listen: false).fetchHijriDate();
    _loadPrayerTimes();
  }

  // String tzName = tz.local.name; // e.g. "Asia/Karachi" on your device
  Future<void> _loadPrayerTimes() async {
    try {
      // Get current location
      final position = await _getLocation();

      // Calculate prayer times using prayers_times package
      String _getCurrentNextPrayer() {
        final now = DateTime.now();
        final formatter = DateFormat('hh:mm a');

        final times = {
          'Fajr': formatter.parse('05:11 AM'),
          'Dhuhr': formatter.parse('12:25 PM'),
          'Asr': formatter.parse('04:35 PM'),
          'Maghrib': formatter.parse('06:16 PM'),
          'Isha': formatter.parse('07:39 PM'),
        };

        for (var entry in times.entries) {
          final prayerTime = entry.value;
          if (now.isBefore(
            prayerTime.copyWith(year: now.year, month: now.month, day: now.day),
          )) {
            return entry.key;
          }
        }
        return 'Fajr (tomorrow)';
      }

      // Find next prayer
      String upcoming = 'Fajr (Tomorrow)';

      if (mounted) {
        setState(() {
          nextPrayerName = _getCurrentNextPrayer();
          nextPrayerTimeStr = prayerDisplayTimes[nextPrayerName];
          upcoming;
          isLoading = false;
        });
      }
    } catch (e) {
      String msg = "Error loading prayer times";
      if (e.toString().contains("denied")) {
        msg = "Location permission denied.\nPlease enable location.";
      } else if (e.toString().contains("disabled")) {
        msg = "Location services are disabled.\nPlease turn them on.";
      } else {
        msg = "Error: ${e.toString()}";
      }

      if (mounted) {
        setState(() {
          errorMessage = msg;
          isLoading = false;
        });
      }
    }
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5E35B1), Color(0xFF283593), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      child: Column(
                        children: [
                          Text(
                            'Prayer Times',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Consumer<HijriProvider>(
                            builder: (context, value, child) {
                              return Text(
                                '$gregorianDate • ${value.hijriDate ?? "Hijri loading..."}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nextPrayerTimeStr ?? '—',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1A237E),
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  nextPrayerName ?? 'Upcoming',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prayer List – shows jamaah times
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: prayerDisplayTimes.entries.map((entry) {
                          final isActive = entry.key == nextPrayerName;
                          return PrayerTile(
                            name: entry.key,
                            time: entry.value,
                            isActive: isActive,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class PrayerTile extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;

  const PrayerTile({
    super.key,
    required this.name,
    required this.time,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF283593)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
