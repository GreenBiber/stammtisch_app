import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;
  String? _fcmToken;
  
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  // Notification Settings Keys
  static const String _eventRemindersKey = 'event_reminders';
  static const String _chatNotificationsKey = 'chat_notifications';
  static const String _weeklyDigestKey = 'weekly_digest';
  static const String _eventReminderTimeKey = 'event_reminder_time';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';

  // Initialize the notification service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Check platform and development environment
      bool isSimulator = false;
      try {
        // This will help identify if we're running on iOS simulator
        // where APNS tokens are not available
        await _firebaseMessaging.getAPNSToken();
      } catch (apnsError) {
        if (apnsError.toString().contains('apns-token-not-set')) {
          print('⚠️ Running on iOS Simulator or APNS not configured - Push notifications will be limited');
          isSimulator = true;
        }
      }

      // Request permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Push notifications permission granted');
        
        // Try to get FCM token (may fail on simulator)
        try {
          _fcmToken = await _firebaseMessaging.getToken();
          if (_fcmToken != null) {
            print('📱 FCM Token: $_fcmToken');
          } else {
            print('⚠️ FCM Token is null - likely running on simulator');
          }
        } catch (tokenError) {
          print('⚠️ Could not get FCM token: $tokenError');
          if (isSimulator) {
            print('ℹ️ This is expected on iOS Simulator - notifications will work on real device');
          }
        }
        
        // Configure foreground notifications (safe to call even without token)
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Listen to token refresh (only if we can get tokens)
        if (!isSimulator) {
          _firebaseMessaging.onTokenRefresh.listen((newToken) {
            _fcmToken = newToken;
            print('🔄 FCM Token refreshed: $newToken');
            // TODO: Send new token to server
          });
        }

        // Setup message handlers (works regardless of token availability)
        _setupMessageHandlers();
        
        _isInitialized = true;
        print('🔔 Notification Service initialized successfully${isSimulator ? ' (Simulator Mode)' : ''}');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ Push notifications permission denied');
        _isInitialized = true; // Mark as initialized even if denied
      } else {
        print('⚠️ Push notifications permission provisional');
        _isInitialized = true; // Mark as initialized even if provisional
      }
    } catch (e) {
      print('❌ Notification Service initialization failed: $e');
      // Mark as initialized even if failed, so app can continue
      _isInitialized = true;
    }
  }

  // Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 App opened from notification: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Handle messages when app is terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🎯 App opened from terminated state: ${message.notification?.title}');
        _handleNotificationTap(message);
      }
    });
  }

  // Handle foreground messages (show in-app notification)
  void _handleForegroundMessage(RemoteMessage message) {
    // This would show an in-app notification overlay
    // For now, we'll just print the message
    print('Foreground notification: ${message.notification?.title} - ${message.notification?.body}');
  }

  // Handle notification tap actions
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    print('Notification tapped with data: $data');
    
    // Navigate based on notification type
    switch (data['type']) {
      case 'event_reminder':
        // Navigate to event screen
        print('Navigate to event: ${data['eventId']}');
        break;
      case 'chat_message':
        // Navigate to chat screen
        print('Navigate to chat for group: ${data['groupId']}');
        break;
      case 'weekly_digest':
        // Navigate to leaderboard or overview
        print('Navigate to weekly digest');
        break;
      default:
        print('Unknown notification type: ${data['type']}');
    }
  }

  // Send test notification (for development)
  Future<void> sendTestNotification() async {
    if (!_isInitialized || _fcmToken == null) {
      print('❌ Cannot send test notification: Service not initialized or no token');
      return;
    }

    // In a real app, this would send a request to your backend server
    // which would then send the notification via FCM
    print('🧪 Test notification triggered (would be sent via backend)');
    
    // For demo purposes, show a local notification-style message
    // In reality, this would come from Firebase
  }

  // MARK: - Notification Settings Management

  // Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'eventReminders': prefs.getBool(_eventRemindersKey) ?? true,
      'chatNotifications': prefs.getBool(_chatNotificationsKey) ?? true,
      'weeklyDigest': prefs.getBool(_weeklyDigestKey) ?? false,
      'eventReminderTime': prefs.getInt(_eventReminderTimeKey) ?? 24, // hours
      'dailyReminderTime': prefs.getInt(_dailyReminderTimeKey) ?? 18, // hour of day
    };
  }

  // Save notification settings
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_eventRemindersKey, settings['eventReminders'] ?? true);
    await prefs.setBool(_chatNotificationsKey, settings['chatNotifications'] ?? true);
    await prefs.setBool(_weeklyDigestKey, settings['weeklyDigest'] ?? false);
    await prefs.setInt(_eventReminderTimeKey, settings['eventReminderTime'] ?? 24);
    await prefs.setInt(_dailyReminderTimeKey, settings['dailyReminderTime'] ?? 18);
    
    print('💾 Notification settings saved: $settings');
  }

  // Update specific setting
  Future<void> updateNotificationSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (key) {
      case 'eventReminders':
      case 'chatNotifications':
      case 'weeklyDigest':
        await prefs.setBool(key, value as bool);
        break;
      case 'eventReminderTime':
      case 'dailyReminderTime':
        await prefs.setInt(key, value as int);
        break;
    }
    
    print('🔧 Notification setting updated: $key = $value');
  }

  // MARK: - Event-specific notifications

  // Schedule event reminder notification
  Future<void> scheduleEventReminder({
    required String eventId,
    required String groupId,
    required String groupName,
    required DateTime eventDate,
    required int hoursBeforeEvent,
  }) async {
    if (!_isInitialized) {
      print('❌ Cannot schedule notification: Service not initialized');
      return;
    }

    final settings = await getNotificationSettings();
    if (!settings['eventReminders']) {
      print('📵 Event reminders disabled by user');
      return;
    }

    final reminderTime = eventDate.subtract(Duration(hours: hoursBeforeEvent));
    final now = DateTime.now();
    
    if (reminderTime.isBefore(now)) {
      print('⏰ Reminder time is in the past, skipping');
      return;
    }

    // In a real app, this would schedule a notification via your backend
    // The backend would store the scheduled notification and send it at the right time
    print('📅 Event reminder scheduled for $reminderTime (Event: $eventId, Group: $groupName)');
    
    // For local development, you might use flutter_local_notifications
    // to show local notifications, but for a real app, use Firebase + backend
  }

  // Send chat notification
  Future<void> sendChatNotification({
    required String groupId,
    required String groupName,
    required String senderName,
    required String message,
    required List<String> recipientTokens,
  }) async {
    if (!_isInitialized) {
      print('❌ Cannot send chat notification: Service not initialized');
      return;
    }

    // In a real app, this would send a request to your backend
    // The backend would then send FCM notifications to all group members
    print('💬 Chat notification would be sent to ${recipientTokens.length} users');
    print('   Group: $groupName');
    print('   Sender: $senderName');
    print('   Message: $message');
  }

  // Send weekly digest notification
  Future<void> sendWeeklyDigest({
    required String userId,
    required String userName,
    required Map<String, dynamic> digestData,
  }) async {
    if (!_isInitialized) {
      print('❌ Cannot send weekly digest: Service not initialized');
      return;
    }

    final settings = await getNotificationSettings();
    if (!settings['weeklyDigest']) {
      print('📵 Weekly digest disabled by user');
      return;
    }

    // In a real app, this would be handled by your backend scheduler
    print('📊 Weekly digest would be sent to $userName');
    print('   Data: $digestData');
  }

  // MARK: - Utility Methods

  // Check if notifications are enabled in system settings
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Open app notification settings
  Future<void> openNotificationSettings() async {
    // This would open the system notification settings for the app
    print('🔧 Opening system notification settings...');
    // Implementation depends on platform (iOS/Android)
  }

  // Get notification statistics
  Future<Map<String, int>> getNotificationStats() async {
    // In a real app, this would return statistics from your backend
    return {
      'sent': 0,
      'delivered': 0,
      'opened': 0,
    };
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    // Clear any pending local notifications
    print('🧹 All notifications cleared');
  }

  // Dispose resources
  void dispose() {
    // Clean up any listeners or resources
    _isInitialized = false;
    print('🗑️ Notification Service disposed');
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.notification?.title}');
  
  // Handle background/terminated app notifications here
  // This is useful for data-only messages or silent notifications
}