import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationType {
  eventReminder,
  newMessage,
  pointsAwarded,
  eventCreated,
  eventCancelled,
}

class NotificationSettings {
  final bool enabled;
  final bool eventReminders;
  final bool chatMessages;
  final bool pointsUpdates;
  final int reminderHours;
  final int reminderMinutes;

  NotificationSettings({
    this.enabled = true,
    this.eventReminders = true,
    this.chatMessages = true,
    this.pointsUpdates = true,
    this.reminderHours = 24,
    this.reminderMinutes = 30,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      eventReminders: json['eventReminders'] ?? true,
      chatMessages: json['chatMessages'] ?? true,
      pointsUpdates: json['pointsUpdates'] ?? true,
      reminderHours: json['reminderHours'] ?? 24,
      reminderMinutes: json['reminderMinutes'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'eventReminders': eventReminders,
      'chatMessages': chatMessages,
      'pointsUpdates': pointsUpdates,
      'reminderHours': reminderHours,
      'reminderMinutes': reminderMinutes,
    };
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? eventReminders,
    bool? chatMessages,
    bool? pointsUpdates,
    int? reminderHours,
    int? reminderMinutes,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      eventReminders: eventReminders ?? this.eventReminders,
      chatMessages: chatMessages ?? this.chatMessages,
      pointsUpdates: pointsUpdates ?? this.pointsUpdates,
      reminderHours: reminderHours ?? this.reminderHours,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}

class NotificationService {
  static NotificationService? _instance;
  NotificationService._();

  factory NotificationService() {
    _instance ??= NotificationService._();
    return _instance!;
  }

  static const String _settingsKey = 'notification_settings';
  NotificationSettings _settings = NotificationSettings();

  NotificationSettings get settings => _settings;

  Future<void> initialize() async {
    await _loadSettings();
    
    // Initialize push notifications if enabled
    if (_settings.enabled) {
      await _initializePushNotifications();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = 
            Map<String, dynamic>.from(
                prefs.getString(_settingsKey) != null 
                    ? {} // Parse JSON here in real implementation
                    : {}
            );
        _settings = NotificationSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    
    // Update push notification configuration
    if (_settings.enabled) {
      await _initializePushNotifications();
    } else {
      await _disablePushNotifications();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, _settings.toJson().toString());
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  Future<void> _initializePushNotifications() async {
    // TODO: Initialize Firebase Cloud Messaging or similar
    // This is a placeholder for the actual push notification setup
    debugPrint('🔔 Push notifications initialized (placeholder)');
  }

  Future<void> _disablePushNotifications() async {
    // TODO: Disable push notifications
    debugPrint('🔕 Push notifications disabled (placeholder)');
  }

  Future<void> scheduleEventReminder({
    required String eventId,
    required DateTime eventDate,
    required String eventTitle,
  }) async {
    if (!_settings.enabled || !_settings.eventReminders) return;

    final reminderDate = eventDate.subtract(Duration(
      hours: _settings.reminderHours,
      minutes: _settings.reminderMinutes,
    ));

    // TODO: Schedule local notification
    debugPrint('📅 Event reminder scheduled for $reminderDate: $eventTitle');
  }

  Future<void> showPointsNotification({
    required String userId,
    required int points,
    required String reason,
  }) async {
    if (!_settings.enabled || !_settings.pointsUpdates) return;

    // TODO: Show local notification
    debugPrint('⭐ Points notification: +$points for $reason');
  }

  Future<void> showChatNotification({
    required String groupName,
    required String senderName,
    required String message,
  }) async {
    if (!_settings.enabled || !_settings.chatMessages) return;

    // TODO: Show local notification
    debugPrint('💬 Chat notification from $senderName in $groupName: $message');
  }

  Future<void> cancelEventReminder(String eventId) async {
    // TODO: Cancel scheduled notification
    debugPrint('❌ Event reminder cancelled for $eventId');
  }

  Future<void> cancelAllNotifications() async {
    // TODO: Cancel all scheduled notifications
    debugPrint('🚫 All notifications cancelled');
  }

  Future<bool> requestPermissions() async {
    // TODO: Request notification permissions from system
    debugPrint('🔐 Notification permissions requested (placeholder)');
    return true; // Placeholder
  }

  Future<bool> hasPermissions() async {
    // TODO: Check if notifications are permitted
    return true; // Placeholder
  }

  // Methoden für ReminderSettingsScreen-Kompatibilität
  Future<Map<String, bool>> getNotificationSettings() async {
    return {
      '1_day': _settings.reminderHours >= 24,
      '1_hour': _settings.reminderHours >= 1 || _settings.reminderMinutes >= 60,
      '30_min': _settings.reminderMinutes >= 30,
    };
  }

  Future<void> updateNotificationSettings({
    required bool oneDayBefore,
    required bool oneHourBefore, 
    required bool thirtyMinBefore,
  }) async {
    // Bestimme die Reminder-Einstellungen basierend auf den Schaltern
    int reminderHours = 0;
    int reminderMinutes = 0;
    
    if (oneDayBefore) {
      reminderHours = 24;
    } else if (oneHourBefore) {
      reminderHours = 1;
    } else if (thirtyMinBefore) {
      reminderMinutes = 30;
    }

    final newSettings = _settings.copyWith(
      reminderHours: reminderHours,
      reminderMinutes: reminderMinutes,
    );
    
    await updateSettings(newSettings);
  }

  Future<void> sendTestNotification() async {
    // TODO: Echte Test-Benachrichtigung senden
    debugPrint('🔔 Test notification sent (placeholder)');
  }
}