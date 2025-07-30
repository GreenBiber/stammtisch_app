import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Settings Keys
  static const String _key1Day = 'notification_1_day';
  static const String _key1Hour = 'notification_1_hour';
  static const String _key30Min = 'notification_30_min';

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('✅ NotificationService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // Hier könnte Navigation zur entsprechenden Seite implementiert werden
  }

  // Permission Request
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOS = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iOS != null) {
        final granted = await iOS.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true; // Fallback für andere Plattformen
  }

  // Settings Getter
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      '1_day': prefs.getBool(_key1Day) ?? true,
      '1_hour': prefs.getBool(_key1Hour) ?? true,
      '30_min': prefs.getBool(_key30Min) ?? false,
    };
  }

  // Settings Setter
  Future<void> updateNotificationSettings({
    bool? oneDayBefore,
    bool? oneHourBefore,
    bool? thirtyMinBefore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (oneDayBefore != null) {
      await prefs.setBool(_key1Day, oneDayBefore);
    }
    if (oneHourBefore != null) {
      await prefs.setBool(_key1Hour, oneHourBefore);
    }
    if (thirtyMinBefore != null) {
      await prefs.setBool(_key30Min, thirtyMinBefore);
    }
    
    print('🔔 Notification settings updated');
  }

  // Event Reminder Notifications
  Future<void> scheduleEventReminders({
    required String eventId,
    required DateTime eventDate,
    required String groupName,
    bool? oneDayBefore,
    bool? oneHourBefore,
    bool? thirtyMinBefore,
  }) async {
    if (!_isInitialized) await initialize();

    final settings = await getNotificationSettings();
    final shouldSend1Day = oneDayBefore ?? settings['1_day']!;
    final shouldSend1Hour = oneHourBefore ?? settings['1_hour']!;
    final shouldSend30Min = thirtyMinBefore ?? settings['30_min']!;

    // Cancel existing notifications for this event
    await cancelEventNotifications(eventId);

    final now = DateTime.now();

    // 1 Tag vorher
    if (shouldSend1Day) {
      final notificationTime = eventDate.subtract(const Duration(days: 1));
      if (notificationTime.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(eventId, '1day'),
          title: '🍺 Stammtisch morgen!',
          body: 'Vergiss nicht: Morgen ist Stammtisch bei $groupName',
          scheduledTime: notificationTime,
          payload: 'event_reminder_1day_$eventId',
        );
      }
    }

    // 1 Stunde vorher
    if (shouldSend1Hour) {
      final notificationTime = eventDate.subtract(const Duration(hours: 1));
      if (notificationTime.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(eventId, '1hour'),
          title: '⏰ Stammtisch in 1 Stunde!',
          body: 'Der Stammtisch bei $groupName beginnt gleich',
          scheduledTime: notificationTime,
          payload: 'event_reminder_1hour_$eventId',
        );
      }
    }

    // 30 Minuten vorher
    if (shouldSend30Min) {
      final notificationTime = eventDate.subtract(const Duration(minutes: 30));
      if (notificationTime.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(eventId, '30min'),
          title: '🏃‍♂️ Stammtisch in 30 Minuten!',
          body: 'Zeit sich fertig zu machen für $groupName',
          scheduledTime: notificationTime,
          payload: 'event_reminder_30min_$eventId',
        );
      }
    }

    print('🔔 Scheduled reminders for event $eventId');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Verwende schedule statt zonedSchedule für Kompatibilität
    await _notifications.schedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      payload: payload,
    );
  }

  // Immediate Notifications
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'immediate',
      'Immediate Notifications',
      channelDescription: 'Immediate notifications for important events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Utility Methods
  int _getNotificationId(String eventId, String type) {
    return '${eventId}_$type'.hashCode.abs();
  }

  Future<void> cancelEventNotifications(String eventId) async {
    await _notifications.cancel(_getNotificationId(eventId, '1day'));
    await _notifications.cancel(_getNotificationId(eventId, '1hour'));
    await _notifications.cancel(_getNotificationId(eventId, '30min'));
    print('🔔 Cancelled notifications for event $eventId');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔔 All notifications cancelled');
  }

  // Demo notifications for testing
  Future<void> sendTestNotification() async {
    await showImmediateNotification(
      title: '🧪 Test Benachrichtigung',
      body: 'Das Benachrichtigungssystem funktioniert!',
      payload: 'test_notification',
    );
  }

  Future<void> scheduleTestReminder() async {
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    
    await _scheduleNotification(
      id: 999999,
      title: '⏰ Test Erinnerung',
      body: 'Das ist eine Test-Erinnerung nach 10 Sekunden',
      scheduledTime: testTime,
      payload: 'test_reminder',
    );
    
    print('🔔 Test reminder scheduled for ${testTime.toString()}');
  }
}