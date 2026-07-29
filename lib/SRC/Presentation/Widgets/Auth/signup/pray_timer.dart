import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:mosque_finder/SRC/Presentation/Common/CustomTimePicker/custom_time_picker.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';

class PrayTimer extends StatefulWidget {
  final String userId;
  const PrayTimer({super.key, required this.userId});

  @override
  State<PrayTimer> createState() => _PrayTimerState();
}

class _PrayTimerState extends State<PrayTimer> {
  final List<Map<String, dynamic>> _prayerTimes = [
    {'prayName': 'Fajr', 'prayTime': '--:--', 'key': 'fajr'},
    {'prayName': 'Dhuhr', 'prayTime': '--:--', 'key': 'dhuhr'},
    {'prayName': 'Jumma', 'prayTime': '--:--', 'key': 'jumma'},
    {'prayName': 'Asr', 'prayTime': '--:--', 'key': 'asr'},
    {'prayName': 'Maghrib', 'prayTime': '--:--', 'key': 'maghrib'},
    {'prayName': 'Isha', 'prayTime': '--:--', 'key': 'isha'},
  ];

  // ── TimePicker — only updates local list ──
  Future<void> _editTime(int index) async {
    final current = _prayerTimes[index]['prayTime'] as String;
    TimeOfDay initial = TimeOfDay.now();

    try {
      if (current != '--:--') {
        final dt = DateFormat('h:mm a').parse(current);
        initial = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    } catch (e) {
      // Fallback to now if parsing fails
    }

    final picked = await CustomTimePicker.show(
      context,
      initialTime: initial,
    );

    if (picked == null) return;

    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    final formatted = DateFormat('h:mm a').format(dt);

    setState(() {
      _prayerTimes[index]['prayTime'] = formatted;
    });
  }

  bool get _allTimesSet => _prayerTimes.every((p) => p['prayTime'] != '--:--');

  Future<void> _saveAndContinue() async {
    if (!_allTimesSet) {
      CustomSnackBar.showError(context, 'Please set all prayer times first');
      return;
    }

    context.read<ImamCubit>().updatePrayerTimes(
      PrayerTimesModel(
        fajr: _prayerTimes[0]['prayTime'],
        dhuhr: _prayerTimes[1]['prayTime'],
        jumma: _prayerTimes[2]['prayTime'],
        asr: _prayerTimes[3]['prayTime'],
        maghrib: _prayerTimes[4]['prayTime'],
        isha: _prayerTimes[5]['prayTime'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ImamCubit, ImamState>(
      listener: (context, state) {
        // ── Success → navigate ─────────────────
        if (state is PrayerTimesUpdateSuccess) {
          // ✅ Persist login state
          SharedPrefsService.saveUserId(widget.userId);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ImamScreen(userId: widget.userId),
            ),
            (route) => false,
          );
        }

        // ── Error → Snack bar ───────────────────
        if (state is PrayerTimesUpdateError) {
          CustomSnackBar.showError(context, state.message);
        }
        // ✅ No setState here anymore
      },

      child: Scaffold(
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
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  iconTheme: theme.iconTheme,
                  expandedHeight: 150,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Set Pray Timing',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ImamPrayCard(
                        widget: Center(
                          child: Text(
                            'Set your mosque prayer timings',
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
                  itemCount: _prayerTimes.length,
                  itemBuilder: (context, index) {
                    final isSet = _prayerTimes[index]['prayTime'] != '--:--';
                    return ImamPrayCard(
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              _prayerTimes[index]['prayName'],
                              textAlign: TextAlign.left,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _prayerTimes[index]['prayTime'],
                              textAlign: TextAlign.left,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isSet
                                    ? Colors.green
                                    : theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Icon(
                                Icons.edit_calendar_outlined,
                                color: isSet
                                    ? Colors.green
                                    : theme.colorScheme.onPrimary,
                              ),
                              onPressed: () => _editTime(index),
                            ),
                          ),
                        ],
                      ).paddingAll(10),
                    ).paddingOnly(top: 10.h, bottom: 10.h);
                  },
                ),

                // ── Save button — uses BlocBuilder for loading ──
                SliverToBoxAdapter(
                  child: BlocBuilder<ImamCubit, ImamState>(
                    builder: (context, state) {
                      // ✅ Loading from cubit state directly
                      if (state is ImamLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return CustomBotton(
                        text: 'Save & Continue',
                        onTap: _saveAndContinue,
                      ).paddingOnly(top: 20.h, bottom: 20.h);
                    },
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 20.w, vertical: 20.h),
          ),
        ),
      ),
    );
  }
}
