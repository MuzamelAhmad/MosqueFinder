import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommonTimerInput extends StatefulWidget {
  const CommonTimerInput({super.key});

  @override
  State<CommonTimerInput> createState() => _CommonTimerInputState();
}

class _CommonTimerInputState extends State<CommonTimerInput> {
  final supabase = Supabase.instance.client;

  // 1. State list — will be updated from Supabase
  List<Map<String, dynamic>> prayerTimes = [
    {'prayName': 'Fajr', 'prayTime': '5:50'},
    {'prayName': 'Dhuhr', 'prayTime': '12:30'},
    {'prayName': 'Asr', 'prayTime': '4:30'},
    {'prayName': 'Maghrib', 'prayTime': '6:30'},
    {'prayName': 'Isha', 'prayTime': '8:00'},
  ];

  bool _isLoading = false;

  // 2. Fetch latest times from Supabase on init
  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('prayer_times')       // 👈 your Supabase table name
          .select()
          .single();

      if (response != null) {
        setState(() {
          prayerTimes = [
            {'prayName': 'Fajr',    'prayTime': response['fajr']},
            {'prayName': 'Dhuhr',   'prayTime': response['dhuhr']},
            {'prayName': 'Asr',     'prayTime': response['asr']},
            {'prayName': 'Maghrib', 'prayTime': response['maghrib']},
            {'prayName': 'Isha',    'prayTime': response['isha']},
          ];
        });
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. Show TimePicker and save to Supabase
  Future<void> _editTime(int index) async {
    final current = prayerTimes[index]['prayTime'] as String;
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null) return; // user cancelled

    final formatted =
        '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';

    // 4. Update UI immediately (optimistic update)
    setState(() {
      prayerTimes[index]['prayTime'] = formatted;
    });

    // 5. Save to Supabase
    final columnName = prayerTimes[index]['prayName'].toString().toLowerCase();
    try {
      await supabase
          .from('prayer_times')       // 👈 your Supabase table name
          .update({columnName: formatted})
          .eq('id', 1);              // 👈 your row identifier
    } catch (e) {
      debugPrint('Update error: $e');
      // Rollback UI if save failed
      _fetchPrayerTimes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
      slivers: [
        SliverAppBar(
          iconTheme: theme.iconTheme,
          expandedHeight: 150,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Column(
            children: [
              Text(
                'Pray Timing',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              ImamPrayCard(
                widget: Center(
                  child: Text(
                    'Edit The Pray Timings',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverList.builder(
          itemCount: prayerTimes.length,
          itemBuilder: (context, index) {
            return ImamPrayCard(
              widget: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        prayerTimes[index]['prayName'],
                        textAlign: TextAlign.left,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        prayerTimes[index]['prayTime'],
                        textAlign: TextAlign.left,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        // 6. Tap to edit
                        onPressed: () => _editTime(index),
                      ),
                    ),
                  ],
                ).paddingAll(10),
              ),
            ).paddingOnly(top: 10.h, bottom: 10.h);
          },
        ),
      ],
    ).paddingSymmetric(horizontal: 20.w, vertical: 20.h);
  }
}