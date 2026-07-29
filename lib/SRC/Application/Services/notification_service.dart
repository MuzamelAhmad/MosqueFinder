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
  static Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
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

    if (times == null) return;
    if (!(await isEnabled())) return;

    // 2. Schedule each prayer
    // Fajr, Asr, Maghrib, Isha are daily
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

      return scheduleTime;
    } catch (e) {
      return null;
    }
  }

  static tz.TZDateTime _nextInstanceOfDay(tz.TZDateTime scheduledDate, int day) {
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
