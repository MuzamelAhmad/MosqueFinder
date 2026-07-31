import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notifEnabledKey = 'notifications_enabled';

  // ✅ Initialize
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // ✅ Request Permissions
  static Future<bool> requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    // Request standard notification permission
    final bool? granted = await androidPlugin.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    final bool? exactGranted =
        await androidPlugin.requestExactAlarmsPermission();

    return (granted ?? false) && (exactGranted ?? false);
  }

  // ✅ Check if permissions are granted
  static Future<bool> hasPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    final bool? canSchedule =
        await androidPlugin.canScheduleExactNotifications();
    return canSchedule ?? false;
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
  static Future<void> schedulePrayerNotifications(
      PrayerTimesModel? times) async {
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

    debugPrint('NOTIF: Scheduling new alerts...');

    // 2. Schedule each prayer
    _scheduleDaily(1, 'Fajr', times.fajr);
    _scheduleDaily(4, 'Asr', times.asr);
    _scheduleDaily(5, 'Maghrib', times.maghrib);
    _scheduleDaily(6, 'Isha', times.isha);

    // Dhuhr: Mon-Thu, Sat, Sun
    _scheduleSpecificDays(2, 'Dhuhr', times.dhuhr, [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.saturday,
      DateTime.sunday
    ]);

    // Jumma: Friday only
    _scheduleSpecificDays(3, 'Jumma', times.jumma, [DateTime.friday]);
  }

  static Future<void> _scheduleDaily(int id, String name, String timeStr) async {
    if (timeStr == '--:--') return;

    final scheduleTime = _getScheduleTime(timeStr);
    if (scheduleTime == null) return;

    debugPrint('NOTIF: Scheduled $name for $scheduleTime (Daily)');

    await _notificationsPlugin.zonedSchedule(
      id,
      'Prayer Reminder',
      '$name prayer will start in 5 minutes',
      scheduleTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminders',
          'Prayer Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> _scheduleSpecificDays(
      int id, String name, String timeStr, List<int> days) async {
    if (timeStr == '--:--') return;

    final baseTime = _getScheduleTime(timeStr);
    if (baseTime == null) return;

    for (int day in days) {
      final scheduledDate = _nextInstanceOfDay(baseTime, day);

      debugPrint('NOTIF: Scheduled $name for $scheduledDate (Day ID: $day)');

      await _notificationsPlugin.zonedSchedule(
        id * 10 + day, // Unique ID for each day
        'Prayer Reminder',
        '$name prayer will start in 5 minutes',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminders',
            'Prayer Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
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

      // ✅ If the scheduled time is in the past (already happened today), move to tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

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
    // Safety check for dayOfWeekAndTime: if the final calculated time is in the past, add a week
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}
