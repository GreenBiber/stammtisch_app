import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  bool _isInitialized = false;
  bool _areNotificationsEnabled = false;
  String? _fcmToken;
  Map<String, dynamic> _settings = {};
  Map<String, int> _stats = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  String? get fcmToken => _fcmToken;
  Map<String, dynamic> get settings => _settings;
  Map<String, int> get stats => _stats;

  // Specific setting getters
  bool get eventReminders => _settings['eventReminders'] ?? true;
  bool get chatNotifications => _settings['chatNotifications'] ?? true;
  bool get weeklyDigest => _settings['weeklyDigest'] ?? false;
  int get eventReminderTime => _settings['eventReminderTime'] ?? 24;
  int get dailyReminderTime => _settings['dailyReminderTime'] ?? 18;

  // Initialize notification provider
  Future<void> initialize() async {
    try {
      // Initialize the notification service
      await _notificationService.initialize();
      
      // Load settings and status (with individual error handling)
      try {
        await _loadSettings();
      } catch (e) {
        print('⚠️ Could not load notification settings: $e');
        // Use default settings
        _settings = {
          'eventReminders': true,
          'chatNotifications': true,
          'weeklyDigest': false,
          'eventReminderTime': 24,
          'dailyReminderTime': 18,
        };
      }
      
      try {
        await _checkNotificationStatus();
      } catch (e) {
        print('⚠️ Could not check notification status: $e');
        _areNotificationsEnabled = false;
      }
      
      try {
        await _loadStats();
      } catch (e) {
        print('⚠️ Could not load notification stats: $e');
        _stats = {'sent': 0, 'delivered': 0, 'opened': 0};
      }
      
      _isInitialized = _notificationService.isInitialized;
      _fcmToken = _notificationService.fcmToken;
      
      notifyListeners();
      print('✅ NotificationProvider initialized successfully${_fcmToken == null ? ' (without FCM token)' : ''}');
    } catch (e) {
      print('❌ NotificationProvider initialization failed: $e');
      // Set as initialized anyway so the app can continue
      _isInitialized = true;
      _areNotificationsEnabled = false;
      _settings = {
        'eventReminders': false,
        'chatNotifications': false,
        'weeklyDigest': false,
        'eventReminderTime': 24,
        'dailyReminderTime': 18,
      };
      _stats = {'sent': 0, 'delivered': 0, 'opened': 0};
      notifyListeners();
    }
  }

  // Load notification settings
  Future<void> _loadSettings() async {
    try {
      _settings = await _notificationService.getNotificationSettings();
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load notification settings: $e');
    }
  }

  // Check notification permission status
  Future<void> _checkNotificationStatus() async {
    try {
      _areNotificationsEnabled = await _notificationService.areNotificationsEnabled();
      notifyListeners();
    } catch (e) {
      print('❌ Failed to check notification status: $e');
    }
  }

  // Load notification statistics
  Future<void> _loadStats() async {
    try {
      _stats = await _notificationService.getNotificationStats();
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load notification stats: $e');
    }
  }

  // Update a specific notification setting
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      // Update in service
      await _notificationService.updateNotificationSetting(key, value);
      
      // Update local state
      _settings[key] = value;
      
      // Save all settings
      await _notificationService.saveNotificationSettings(_settings);
      
      notifyListeners();
      print('✅ Notification setting updated: $key = $value');
    } catch (e) {
      print('❌ Failed to update notification setting: $e');
    }
  }

  // Toggle event reminders
  Future<void> toggleEventReminders(bool enabled) async {
    await updateSetting('eventReminders', enabled);
  }

  // Toggle chat notifications
  Future<void> toggleChatNotifications(bool enabled) async {
    await updateSetting('chatNotifications', enabled);
  }

  // Toggle weekly digest
  Future<void> toggleWeeklyDigest(bool enabled) async {
    await updateSetting('weeklyDigest', enabled);
  }

  // Set event reminder time
  Future<void> setEventReminderTime(int hours) async {
    await updateSetting('eventReminderTime', hours);
  }

  // Set daily reminder time
  Future<void> setDailyReminderTime(int hour) async {
    await updateSetting('dailyReminderTime', hour);
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      
      // Refresh stats after sending
      await _loadStats();
      
      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Failed to send test notification: $e');
    }
  }

  // Schedule event reminder
  Future<void> scheduleEventReminder({
    required String eventId,
    required String groupId,
    required String groupName,
    required DateTime eventDate,
  }) async {
    if (!eventReminders) {
      print('📵 Event reminders disabled, skipping');
      return;
    }

    try {
      await _notificationService.scheduleEventReminder(
        eventId: eventId,
        groupId: groupId,
        groupName: groupName,
        eventDate: eventDate,
        hoursBeforeEvent: eventReminderTime,
      );
      
      print('✅ Event reminder scheduled');
    } catch (e) {
      print('❌ Failed to schedule event reminder: $e');
    }
  }

  // Send chat notification to group members
  Future<void> sendChatNotification({
    required String groupId,
    required String groupName,
    required String senderName,
    required String message,
    required List<String> recipientTokens,
  }) async {
    if (!chatNotifications) {
      print('📵 Chat notifications disabled, skipping');
      return;
    }

    try {
      await _notificationService.sendChatNotification(
        groupId: groupId,
        groupName: groupName,
        senderName: senderName,
        message: message,
        recipientTokens: recipientTokens,
      );
      
      // Refresh stats
      await _loadStats();
      
      print('✅ Chat notification sent');
    } catch (e) {
      print('❌ Failed to send chat notification: $e');
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Re-initialize to request permissions
      await _notificationService.initialize();
      await _checkNotificationStatus();
      
      return _areNotificationsEnabled;
    } catch (e) {
      print('❌ Failed to request notification permissions: $e');
      return false;
    }
  }

  // Open system notification settings
  Future<void> openSystemSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      print('❌ Failed to open system settings: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      print('✅ All notifications cleared');
    } catch (e) {
      print('❌ Failed to clear notifications: $e');
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await _loadSettings();
    await _checkNotificationStatus();
    await _loadStats();
  }

  // Format reminder time for display
  String formatReminderTime(int hours) {
    if (hours == 1) {
      return '1 Stunde vorher';
    } else if (hours < 24) {
      return '$hours Stunden vorher';
    } else {
      final days = hours ~/ 24;
      return days == 1 ? '1 Tag vorher' : '$days Tage vorher';
    }
  }

  // Format daily time for display
  String formatDailyTime(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  // Get notification status summary
  String getStatusSummary() {
    if (!_isInitialized) {
      return 'Nicht initialisiert';
    } else if (!_areNotificationsEnabled) {
      return 'Berechtigung verweigert';
    } else {
      int enabledCount = 0;
      if (eventReminders) enabledCount++;
      if (chatNotifications) enabledCount++;
      if (weeklyDigest) enabledCount++;
      
      return '$enabledCount von 3 Benachrichtigungen aktiviert';
    }
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}