import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/CustomDrawer/customize_drawer_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';

class ImamScreen extends StatefulWidget {
  final String userId;
  const ImamScreen({super.key, required this.userId});

  @override
  State<ImamScreen> createState() => _ImamScreenState();
}

class _ImamScreenState extends State<ImamScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ImamCubit>().getImamData();
  }

  // ── Time picker + update via cubit ──────────
  Future<void> _selectTime(BuildContext context, String prayerKey) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    // Format as "4:30" — consistent with your Supabase data
    final formatted =
        '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';

    if (context.mounted) {
      // ✅ Call cubit to update single prayer time
      context.read<ImamCubit>().updateSinglePrayerTime(
        prayerKey: prayerKey,
        newTime: formatted,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Welcome Imam',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomizeDrawerScreen(),
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
          child: BlocConsumer<ImamCubit, ImamState>(
            listener: (context, state) {
              // ── Show snackbar on error ─────────
              if (state is SinglePrayerTimeUpdateError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }

              // ── Success — data already refreshed
              //    in cubit via ImamLoaded ─────────
              if (state is SinglePrayerTimeUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Prayer time updated ✅'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              // ── Loading ────────────────────────
              if (state is ImamLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // ── Error ──────────────────────────
              if (state is ImamError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onPrimary,
                        size: 48,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ImamCubit>().getImamData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // ── Data Loaded ────────────────────
              if (state is ImamLoaded) {
                final imam = state.imam;
                final prayerJson = imam.prayTime;

                // ✅ Prayer list with key for update
                final prayerList = [
                  {
                    'name': 'Fajr',
                    'key': 'fajr',
                    'time': prayerJson?.fajr ?? '--:--',
                  },
                  {
                    'name': 'Dhuhr',
                    'key': 'dhuhr',
                    'time': prayerJson?.dhuhr ?? '--:--',
                  },
                  {
                    'name': 'Jumma',
                    'key': 'jumma',
                    'time': prayerJson?.jumma ?? '--:--',
                  },
                  {
                    'name': 'Asr',
                    'key': 'asr',
                    'time': prayerJson?.asr ?? '--:--',
                  },
                  {
                    'name': 'Maghrib',
                    'key': 'maghrib',
                    'time': prayerJson?.maghrib ?? '--:--',
                  },
                  {
                    'name': 'Isha',
                    'key': 'isha',
                    'time': prayerJson?.isha ?? '--:--',
                  },
                ];

                return CustomScrollView(
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
                            imam.imamName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ImamPrayCard(
                            widget: Center(
                              child: Text(
                                imam.mosqueName,
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
                      itemCount: prayerList.length,
                      itemBuilder: (context, index) {
                        final time = prayerList[index]['time']!;
                        final key = prayerList[index]['key']!;
                        final name = prayerList[index]['name']!;
                        final isSet = time != '--:--'; // ✅ fixed logic

                        return ImamPrayCard(
                          widget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.left,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  time,
                                  textAlign: TextAlign.left,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color:
                                        isSet // ✅ green when set
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
                                    color:
                                        isSet // ✅ green when set
                                        ? Colors.green
                                        : theme.colorScheme.onPrimary,
                                  ),
                                  // ✅ pass key correctly
                                  onPressed: () => _selectTime(context, key),
                                ),
                              ),
                            ],
                          ).paddingAll(10),
                        ).paddingOnly(top: 10.h, bottom: 10.h);
                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 20.w, vertical: 20.h);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
