import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String checkInChannelId = 'safeher_checkin';
  static const String checkInChannelName = 'SafeHer Check-In';
  static const String actionImSafe = 'IM_SAFE';

  final _checkInActionSink = StreamController<CheckInAction>.broadcast();
  Stream<CheckInAction> get checkInActions => _checkInActionSink.stream;

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'SAFEHER_CHECKIN',
          actions: [
            DarwinNotificationAction.plain(
              actionImSafe,
              "I'm Safe",
              options: const {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Android channel
    const channel = AndroidNotificationChannel(
      checkInChannelId,
      checkInChannelName,
      description: 'Check-in reminders and actions',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // On Android 13+, show the notifications permission dialog
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Ask for exact-alarm permission when needed (Android 12+).
  // Plugin will launch the system screen where the user can allow it.
  Future<bool> _requestExactAlarmPermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;
    final android =
    _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    try {
      final granted = await android.requestExactAlarmsPermission();
      // Some versions return null if not applicable (e.g., < API 31)
      return granted ?? true;
    } catch (_) {
      // If the API isn't available, just continue; we’ll fallback if needed
      return false;
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    // For background action handling if needed
  }

  Future<void> _onTap(NotificationResponse response) async {
    if (response.actionId == actionImSafe) {
      _checkInActionSink.add(CheckInAction.imSafe);
    }
  }

  /// Public helper that prefers exact alarms but gracefully falls back if not allowed.
  Future<void> scheduleCheckInReminderSmart({
    required int notificationId,
    required DateTime when,
  }) async {
    try {
      await _schedule(
        id: notificationId,
        when: when,
        mode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e) {
      // If exact alarms aren’t permitted, ask once and retry, else fallback to inexact.
      if (e.code == 'exact_alarms_not_permitted') {
        final ok = await _requestExactAlarmPermissionIfNeeded();
        if (ok) {
          // User may have enabled it; retry exact once
          await _schedule(
            id: notificationId,
            when: when,
            mode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } else {
          // Fallback (slight drift possible)
          await _schedule(
            id: notificationId,
            when: when,
            mode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required AndroidScheduleMode mode,
  }) async {
    final tzTime = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      'Check-in Reminder',
      'Are you safe? Tap to confirm.',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          checkInChannelId,
          checkInChannelName,
          importance: Importance.high,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              NotificationService.actionImSafe,
              "I'm Safe",
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'SAFEHER_CHECKIN',
        ),
      ),
      androidScheduleMode: mode,
      payload: 'checkin',
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}

enum CheckInAction { imSafe }
