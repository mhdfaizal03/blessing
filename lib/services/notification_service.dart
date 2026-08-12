import 'dart:io';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      tz_data.initializeTimeZones();
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Timezone initialization fallback: $e');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notification tapped: ${response.payload}");
      },
    );

    if (Platform.isAndroid) {
      final android = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    }

    _isInitialized = true;
  }

  /// Alias for schedulePrayerAzan
  Future<void> scheduleAzan({
    required int id,
    required String title,
    required DateTime scheduledDate,
  }) async {
    await schedulePrayerAzan(id: id, title: title, scheduledTime: scheduledDate);
  }

  /// Schedules a prayer Azan alarm at exact scheduledTime with high priority & sound
  Future<void> schedulePrayerAzan({
    required int id,
    required String title,
    required DateTime scheduledTime,
  }) async {
    await init();
    if (scheduledTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'azan_alarm_channel_v2',
      'Azan Prayer Alarms',
      channelDescription: 'Plays Azan audio alert at exact prayer times',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Time for $title Prayer 🕌',
        body: 'Hayya ala-s-Salah! It is time for $title prayer.',
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled $title Azan alarm at $scheduledTime');
    } catch (e) {
      debugPrint('Failed to schedule $title Azan: $e');
    }
  }

  /// Synchronizes prayer notifications with user Settings preferences
  Future<void> syncPrayerNotifications(PrayerTimes prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();

    final fajrEnabled = prefs.getBool('notif_fajr') ?? true;
    final sunriseEnabled = prefs.getBool('notif_sunrise') ?? false;
    final dhuhrEnabled = prefs.getBool('notif_dhuhr') ?? true;
    final asrEnabled = prefs.getBool('notif_asr') ?? true;
    final maghribEnabled = prefs.getBool('notif_maghrib') ?? true;
    final ishaEnabled = prefs.getBool('notif_isha') ?? true;

    if (fajrEnabled) {
      await schedulePrayerAzan(id: 1, title: 'Fajr', scheduledTime: prayerTimes.fajr);
    } else {
      await cancelNotification(1);
    }

    if (sunriseEnabled) {
      await schedulePrayerAzan(id: 2, title: 'Sunrise', scheduledTime: prayerTimes.sunrise);
    } else {
      await cancelNotification(2);
    }

    if (dhuhrEnabled) {
      await schedulePrayerAzan(id: 3, title: 'Dhuhr', scheduledTime: prayerTimes.dhuhr);
    } else {
      await cancelNotification(3);
    }

    if (asrEnabled) {
      await schedulePrayerAzan(id: 4, title: 'Asr', scheduledTime: prayerTimes.asr);
    } else {
      await cancelNotification(4);
    }

    if (maghribEnabled) {
      await schedulePrayerAzan(id: 5, title: 'Maghrib', scheduledTime: prayerTimes.maghrib);
    } else {
      await cancelNotification(5);
    }

    if (ishaEnabled) {
      await schedulePrayerAzan(id: 6, title: 'Isha', scheduledTime: prayerTimes.isha);
    } else {
      await cancelNotification(6);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
