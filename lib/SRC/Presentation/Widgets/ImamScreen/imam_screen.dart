import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:mosque_finder/SRC/Presentation/CustomDrawer/customize_drawer_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Common/CustomTimePicker/custom_time_picker.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';
import 'package:mosque_finder/SRC/Application/Services/notification_service.dart';

class ImamScreen extends StatefulWidget {
  final String userId;
  const ImamScreen({super.key, required this.userId});

  @override
  State<ImamScreen> createState() => _ImamScreenState();
}

class _ImamScreenState extends State<ImamScreen> {
  // ✅ Cache the last loaded imam to keep UI "sticky" during updates
  ImamModel? _cachedImam;
  
  // ✅ Flag to prevent multiple "No Internet" dialogs from stacking
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    context.read<ImamCubit>().getImamData();
  }

  // ── Time picker + update via cubit ──────────
  Future<void> _selectTime(BuildContext context, String prayerKey) async {
    final TimeOfDay? picked = await CustomTimePicker.show(
      context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    // Format as "4:30 PM" — 12-hour format
    final now = DateTime.now();
    final dt =
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    final formatted = DateFormat('h:mm a').format(dt);

    if (context.mounted) {
      // ✅ Call cubit to update single prayer time
      context.read<ImamCubit>().updateSinglePrayerTime(
            prayerKey: prayerKey,
            newTime: formatted,
          );
    }
  }

  void _showNoInternetDialog(BuildContext context, String message) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 10),
            Text('No Internet', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogShowing = false;
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) => _isDialogShowing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ImamCubit, ImamState>(
      listener: (context, state) {
        // ── Cache data when it arrives ──────
        if (state is ImamLoaded) {
          _cachedImam = state.imam;
          // ✅ Schedule notifications whenever data is loaded/updated
          NotificationService.schedulePrayerNotifications(state.imam.prayTime).then((_) async {
            if (await NotificationService.isEnabled() && !(await NotificationService.hasPermissions())) {
              if (mounted) {
                 CustomSnackBar.showError(context, 'Please enable "Alarms & Reminders" for prayer alerts');
              }
            }
          });
        }

        // ── Show Snack bar on error ─────────
        if (state is SinglePrayerTimeUpdateError) {
          CustomSnackBar.showError(context, state.message);
        }

        // ── Success Feedback ────────────────
        if (state is SinglePrayerTimeUpdateSuccess) {
          CustomSnackBar.showSuccess(context, 'Prayer time updated ✅');
        }

        // ── Offline Error ───────────────────
        if (state is ImamNoInternetError) {
          _showNoInternetDialog(context, state.message);
        }
      },
      builder: (context, state) {
        // Preference: Use current state data, fallback to cache
        final imamToShow = (state is ImamLoaded) ? state.imam : _cachedImam;

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
          // ✅ Drawer uses cached imam if available
          drawer: imamToShow != null
              ? CustomizeDrawerScreen(imam: imamToShow)
              : null,
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
              child: _buildBody(context, state, theme, imamToShow),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ImamState state, ThemeData theme,
      ImamModel? imamToShow) {
    // ── 1. Show Full Screen Loader ONLY if we have NO data at all
    if (state is ImamLoading && imamToShow == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── 2. Show Error ONLY if we have no cached data to fall back on
    if (state is ImamError && imamToShow == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: theme.colorScheme.onPrimary, size: 48),
            SizedBox(height: 12.h),
            Text(state.message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onPrimary)),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => context.read<ImamCubit>().getImamData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // ── 3. Render Dashboard if we have an Imam (either current or cached)
    if (imamToShow != null) {
      final prayerJson = imamToShow.prayTime;

      final prayerList = [
        {'name': 'Fajr', 'key': 'fajr', 'time': prayerJson?.fajr ?? '--:--'},
        {'name': 'Dhuhr', 'key': 'dhuhr', 'time': prayerJson?.dhuhr ?? '--:--'},
        {'name': 'Jumma', 'key': 'jumma', 'time': prayerJson?.jumma ?? '--:--'},
        {'name': 'Asr', 'key': 'asr', 'time': prayerJson?.asr ?? '--:--'},
        {
          'name': 'Maghrib',
          'key': 'maghrib',
          'time': prayerJson?.maghrib ?? '--:--'
        },
        {'name': 'Isha', 'key': 'isha', 'time': prayerJson?.isha ?? '--:--'},
      ];

      return Stack(
        children: [
          CustomScrollView(
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
                      imamToShow.imamName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ImamPrayCard(
                      widget: Center(
                        child: Text(
                          imamToShow.mosqueName,
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
                  final isSet = time != '--:--';

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
                              // ✅ Fixed: Green when set, not when empty
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
                              // ✅ Fixed: Green when set, not when empty
                              color: isSet
                                  ? Colors.green
                                  : theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => _selectTime(context, key),
                          ),
                        ),
                      ],
                    ).paddingAll(10),
                  ).paddingOnly(top: 10.h, bottom: 10.h);
                },
              ),
            ],
          ).paddingSymmetric(horizontal: 20.w, vertical: 20.h),

          // ── Optional: Show a small indicator if we are refreshing in background
          if (state is ImamLoading && imamToShow != null)
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
      );
    }

    return const SizedBox.shrink();
  }
}
