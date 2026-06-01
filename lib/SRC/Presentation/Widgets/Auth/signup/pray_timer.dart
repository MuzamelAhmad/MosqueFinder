import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';

class PrayTimer extends StatefulWidget {
  final String userId; // 👈 received from SignupScreen

  const PrayTimer({super.key, required this.userId});

  @override
  State<PrayTimer> createState() => _PrayTimerState();
}

class _PrayTimerState extends State<PrayTimer> {
  final List<Map<String, dynamic>> _prayerTimes = [
    {'prayName': 'Fajr', 'prayTime': '--:--', 'key': 'fajr'},
    {'prayName': 'Dhuhr', 'prayTime': '--:--', 'key': 'dhuhr'},
    {'prayName': 'jumma', 'prayTime': '--:--', 'key': 'jumma'},
    {'prayName': 'Asr', 'prayTime': '--:--', 'key': 'asr'},
    {'prayName': 'Maghrib', 'prayTime': '--:--', 'key': 'maghrib'},
    {'prayName': 'Isha', 'prayTime': '--:--', 'key': 'isha'},
  ];

  bool _isSaving = false;

  // ── Show TimePicker and update local list ──
  Future<void> _editTime(int index) async {
    final current = _prayerTimes[index]['prayTime'] as String;
    final parts = current.split(':');

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
    );

    if (picked == null) return;

    // Update local UI only — not saved yet
    setState(() {
      _prayerTimes[index]['prayTime'] =
          '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  // ── Check all times are set ────────────────
  bool get _allTimesSet => _prayerTimes.every((p) => p['prayTime'] != '--:--');

  // ── Save all times to Supabase ─────────────
  Future<void> _saveAndContinue() async {
    if (!_allTimesSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set all prayer times first')),
      );
      return;
    }

    // Build PrayerTimesModel from local list
    final prayerTimesModel = PrayerTimesModel(
      fajr: _prayerTimes[0]['prayTime'],
      dhuhr: _prayerTimes[1]['prayTime'],
      jumma: _prayerTimes[2]['prayTime'],
      asr: _prayerTimes[3]['prayTime'],
      maghrib: _prayerTimes[4]['prayTime'],
      isha: _prayerTimes[5]['prayTime'],
    );

    // Save via cubit
    context.read<ImamCubit>().updatePrayerTimes(prayerTimesModel);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ImamCubit, ImamState>(
      listener: (context, state) {
        // ── Success → go to ImamScreen ─────────
        if (state is PrayerTimesUpdateSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ImamScreen(userId: widget.userId),
            ),
            (route) => false, // 👈 clears signup stack
          );
        }

        // ── Error ──────────────────────────────
        if (state is PrayerTimesUpdateError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        // ── Loading state ──────────────────────
        setState(() => _isSaving = state is ImamLoading);
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
                // ── AppBar ─────────────────────────────
                SliverAppBar(
                  automaticallyImplyLeading: false, // no back button
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

                // ── Prayer Time List ───────────────────
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
                                // green when set, default when not
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
                                // green when set
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

                // ── Save Button ────────────────────────
                SliverToBoxAdapter(
                  child: _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : CustomBotton(
                          text: 'Save & Continue',
                          onTap: _saveAndContinue,
                        ).paddingOnly(top: 20.h, bottom: 20.h),
                ),
              ],
            ).paddingSymmetric(horizontal: 20.w, vertical: 20.h),
          ),
        ),
      ),
    );
  }
}
