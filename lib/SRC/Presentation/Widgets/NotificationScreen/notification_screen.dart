import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Application/Services/notification_service.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final enabled = await NotificationService.isEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permissions if enabling
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          CustomSnackBar.showError(
            context,
            'Permission denied. Please enable "Alarms & Reminders" in settings.',
          );
        }
        return; // Don't toggle if permission failed
      }
    }

    await NotificationService.setEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (mounted) {
      // Re-schedule or cancel based on the new setting
      final state = context.read<ImamCubit>().state;
      if (state is ImamLoaded) {
        NotificationService.schedulePrayerNotifications(state.imam.prayTime);
      }
      
      CustomSnackBar.showSuccess(
        context,
        value ? 'Notifications Enabled ✅' : 'Notifications Disabled ❌',
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
          'Notifications',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
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
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListTile(
                  leading: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: theme.colorScheme.onPrimary,
                  ),
                  title: Text(
                    'Prayer Reminders',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Get notified 5 minutes before each prayer',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: Colors.green,
                    onChanged: _toggleNotifications,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  NotificationService.showTestNotification();
                  CustomSnackBar.showSuccess(
                    context,
                    'Test alert scheduled! Please lock your phone and wait 5 seconds.',
                  );
                },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Test My Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Note: If notifications don\'t appear, ensure "Alarms & Reminders" is enabled in system settings.',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
