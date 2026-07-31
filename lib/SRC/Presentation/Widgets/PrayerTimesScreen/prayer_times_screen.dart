import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      setState(() {
        prayerDisplayTimes = {
          'Fajr': times['fajr'] ?? '--:--',
          'Dhuhr': times['dhuhr'] ?? '--:--',
          'Jumma': times['jumma'] ?? '--:--',
          'Asr': times['asr'] ?? '--:--',
          'Maghrib': times['maghrib'] ?? '--:--',
          'Isha': times['isha'] ?? '--:--',
        };
        _calculateNextPrayer();
        isLoading = false;
      });
    } else {
      // Fallback for direct navigation if needed
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

    // Filter out keys like 'Jumma' for calculation if it's not Friday, 
    // or handle appropriately. For simplicity, we check all.
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5E35B1), Color(0xFF283593), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                      child: Column(
                        children: [
                          Text(
                            mosqueName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
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
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A237E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextPrayerName ?? 'Next Prayer',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Prayer List
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
        color: isActive ? const Color(0xFF283593) : Colors.white.withOpacity(0.95),
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
