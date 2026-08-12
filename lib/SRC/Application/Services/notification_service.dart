import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notifEnabledKey = 'notifications_enabled';

  // ✅ Initialize
  static Future<void> init() async {
    tz.initializeTimeZones();
    final TimezoneInfo timezone =  await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezone.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    debugPrint('NOTIF: Local timezone set to $timeZoneName');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tapping on notification if needed
      },
    );

    // Create a high-priority channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_reminders_high',
      'Prayer Reminders',
      description: 'Provides timely alerts before prayer starting.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ✅ Request Permissions
  static Future<bool> requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    // Request standard notification permission
    final bool? granted = await androidPlugin.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    // Note: requestExactAlarmsPermission might not return true immediately on some devices
    await androidPlugin.requestExactAlarmsPermission();

    // Check again after request
    final bool hasExact = await hasPermissions();

    return (granted ?? false) && hasExact;
  }

  // ✅ Check if permissions are granted
  static Future<bool> hasPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    // Check notification permission (Android 13+)
    final bool? notifGranted = await androidPlugin.areNotificationsEnabled();
    
    // Check exact alarm permission (Android 12+)
    final bool? canSchedule = await androidPlugin.canScheduleExactNotifications();
    
    return (notifGranted ?? false) && (canSchedule ?? false);
  }

  // ✅ Check if enabled
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifEnabledKey) ?? true;
  }

  // ✅ Set enabled
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, enabled);
  }

  // ✅ Schedule all prayer notifications
  static Future<void> schedulePrayerNotifications(PrayerTimesModel? times) async {
    // 1. Clear existing
    await _notificationsPlugin.cancelAll();

    if (times == null) {
      debugPrint('NOTIF: No times provided to schedule');
      return;
    }
    if (!(await isEnabled())) {
      debugPrint('NOTIF: Notifications are disabled by user');
      return;
    }

    // Check permissions before scheduling
    if (!(await hasPermissions())) {
      debugPrint('NOTIF: Cannot schedule because permissions are missing');
      return;
    }

    debugPrint('NOTIF: Scheduling high-priority alerts...');

    // 2. Schedule each prayer
    await _scheduleDaily(1, 'Fajr', times.fajr);
    await _scheduleDaily(4, 'Asr', times.asr);
    await _scheduleDaily(5, 'Maghrib', times.maghrib);
    await _scheduleDaily(6, 'Isha', times.isha);

    // Dhuhr: Sat-Thu
    await _scheduleSpecificDays(2, 'Dhuhr', times.dhuhr, [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.saturday,
      DateTime.sunday
    ]);

    // Jumma: Friday only
    await _scheduleSpecificDays(3, 'Jumma', times.jumma, [DateTime.friday]);
    
    debugPrint('NOTIF: All alerts scheduled successfully ✅');
  }

  static Future<void> _scheduleDaily(int id, String name, String timeStr) async {
    if (timeStr == '--:--') return;

    final scheduleTime = _getScheduleTime(timeStr);
    if (scheduleTime == null) return;

    debugPrint('NOTIF: Scheduled $name for $scheduleTime (Daily High Priority)');

    await _notificationsPlugin.zonedSchedule(
      id,
      'Prayer Reminder',
      '$name prayer starts in 5 minutes. Join the community.',
      scheduleTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminders_high',
          'Prayer Reminders',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: false,
          enableVibration: true,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> _scheduleSpecificDays(int id, String name, String timeStr, List<int> days) async {
    if (timeStr == '--:--') return;

    final baseTime = _getScheduleTime(timeStr);
    if (baseTime == null) return;

    for (int day in days) {
      final scheduledDate = _nextInstanceOfDay(baseTime, day);

      debugPrint('NOTIF: Scheduled $name for $scheduledDate (Weekly ID: $day)');

      await _notificationsPlugin.zonedSchedule(
        id * 10 + day, // Unique ID for each day
        'Prayer Reminder',
        '$name prayer starts in 5 minutes. Ready for Jama\'at?',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminders_high',
            'Prayer Reminders',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static tz.TZDateTime? _getScheduleTime(String timeStr) {
    try {
      final dt = DateFormat('h:mm a').parse(timeStr);
      final now = tz.TZDateTime.now(tz.local);

      var scheduleTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        dt.hour,
        dt.minute,
      ).subtract(const Duration(minutes: 5)); // 5 minutes before

      // If the 5-min alert time has already passed today, set it for tomorrow
      if (scheduleTime.isBefore(now)) {
        debugPrint('NOTIF: $timeStr has passed today, scheduling for tomorrow');
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      debugPrint('NOTIF: Final schedule calculation for $timeStr -> $scheduleTime');
      return scheduleTime;
    } catch (e) {
      debugPrint('NOTIF: Error parsing time $timeStr -> $e');
      return null;
    }
  }

  static tz.TZDateTime _nextInstanceOfDay(tz.TZDateTime scheduledDate, int day) {
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    // Final check for past calculation
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}
