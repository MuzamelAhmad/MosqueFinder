import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:mosque_finder/SRC/Presentation/Common/Dialogs/professional_dialog.dart';
import 'package:mosque_finder/SRC/Presentation/CustomDrawer/customize_drawer_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Common/CustomTimePicker/custom_time_picker.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';
import 'package:mosque_finder/SRC/Application/Services/notification_service.dart';
import 'package:mosque_finder/SRC/Presentation/Common/Agreement/agreement_dialog.dart';
import 'package:mosque_finder/SRC/Application/Utils/connectivity_helper.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AgreementDialog.show(context);
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    final bool hasPerms = await NotificationService.hasPermissions();
    if (!hasPerms && mounted) {
      // Prompt user to enable alerts if they haven't yet
      _showPermissionPrompt();
    }
  }

  void _showPermissionPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo.shade900,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.white),
            SizedBox(width: 12),
            Text('Enable Alerts', style: TextStyle(color: Colors.white)),
          ],
        ),
        content:  Text(
          'To ensure you never miss a Jama\'at, Salah 360 needs permission to set precise prayer alarms.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white54,)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white54,)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await NotificationService.requestPermissions();
              // Re-schedule once granted
              final state = context.read<ImamCubit>().state;
              if (state is ImamLoaded) {
                NotificationService.schedulePrayerNotifications(
                    state.imam.prayTime);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child:  Text('Enable',style:Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white54,)),
          ),
        ],
      ),
    );
  }

  // ── Time picker + update via cubit ──────────
  Future<void> _selectTime(BuildContext context, String prayerKey) async {
    final TimeOfDay? picked = await CustomTimePicker.show(
      context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    // ✅ Format as "4:30 PM" — 12-hour format (Professional)
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
    ProfessionalDialog.show(
      context: context,
      title: 'No Internet',
      content: message,
      icon: Icons.wifi_off_rounded,
      iconColor: Colors.orangeAccent,
      actions: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _isDialogShowing = false;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
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

        // ── Email Resend Feedback ───────────
        if (state is ImamEmailResendSuccess) {
          CustomSnackBar.showSuccess(context, 'Verification email sent! Check your inbox.');
        }
        if (state is ImamEmailResendError) {
          CustomSnackBar.showError(context, state.message);
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
                fontSize: 18.sp,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => context.read<ImamCubit>().getImamData(),
              ),
            ],
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          // Drawer uses cached imam if available
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    // ── 1.5 Show Verification Pending ─────
    if (state is ImamEmailUnverified) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_unread_rounded, color: Colors.amberAccent, size: 64.r),
              SizedBox(height: 24.h),
              Text(
                'Verification Required',
                style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Text(
                'Please confirm your email address (${state.email}) to start managing prayer times.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () => context.read<ImamCubit>().checkEmailVerification(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
                child: const Text('I\'ve Verified'),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => context.read<ImamCubit>().resendVerificationEmail(state.email),
                child: Text('Resend Verification Link', style: TextStyle(color: Colors.blueAccent.shade100)),
              ),
            ],
          ),
        ),
      );
    }

    // ── 2. Show Error ONLY if we have no cached data to fall back on
    if (state is ImamError && imamToShow == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: theme.colorScheme.onPrimary, size: 48.r),
            SizedBox(height: 12.h),
            Text(state.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onPrimary, fontSize: 14.sp)),
            SizedBox(height: 20.h),
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
              // Offline Tag
              SliverToBoxAdapter(
                child: FutureBuilder<bool>(
                  future: ConnectivityHelper.hasInternet(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == false) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                              "Offline Mode: Showing saved timings",
                              style: TextStyle(color: Colors.orangeAccent, fontSize: 13.sp, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              SliverAppBar(
                automaticallyImplyLeading: false,
                iconTheme: theme.iconTheme,
                expandedHeight: 140.h,
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
                        fontSize: 20.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ImamPrayCard(
                      widget: Center(
                        child: Text(
                          imamToShow.mosqueName,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
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
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            time,
                            textAlign: TextAlign.left,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSet
                                  ? Colors.greenAccent.shade400
                                  : theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_calendar_rounded,
                              color: isSet
                                  ? Colors.greenAccent.shade400
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
          ).paddingSymmetric(horizontal: 20.w, vertical: 10.h),

          // ── Background Refresh Indicator
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
