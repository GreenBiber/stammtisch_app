// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome back! 🍻';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get agreeTerms => 'I accept the terms of service and privacy policy';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get logout => 'Logout';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'No account? Register here';

  @override
  String get hasAccount => 'Already have an account? Login here';

  @override
  String get myGroups => 'My Groups';

  @override
  String get createGroup => 'Create Group';

  @override
  String get noGroups => 'No groups yet';

  @override
  String get firstGroup => 'Create your first group!';

  @override
  String get inviteMembers => 'Invite Members';

  @override
  String get groupNotFound => 'Group not found';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupAvatar => 'Avatar Image URL (optional)';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String get groupSettings => 'Group Settings';

  @override
  String memberCount(int count) {
    return '$count Members';
  }

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Member';

  @override
  String get nextEvent => 'Next Event';

  @override
  String get participate => 'Participate?';

  @override
  String get yes => 'Yes';

  @override
  String get maybe => 'Maybe';

  @override
  String get no => 'No';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get minParticipants => 'not enough participants';

  @override
  String participantCount(int count) {
    return '$count Confirmations';
  }

  @override
  String get eventDate => 'Date';

  @override
  String get eventStatus => 'Status';

  @override
  String get eventParticipants => 'Participants';

  @override
  String get xpGained => 'XP gained!';

  @override
  String get levelUp => 'Level Up!';

  @override
  String get achievement => 'Achievement unlocked!';

  @override
  String get level => 'Level';

  @override
  String get streak => 'Streak';

  @override
  String get totalXP => 'Total XP';

  @override
  String xpForAction(int xp, String action) {
    return '+$xp XP for $action';
  }

  @override
  String levelProgress(int percent) {
    return '$percent% to next level';
  }

  @override
  String currentLevel(int level) {
    return 'Level $level';
  }

  @override
  String nextLevel(int current, int next) {
    return 'Level $current → $next';
  }

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get calendar => 'Calendar';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get reminders => 'Reminders';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get restaurantSuggestions => 'Restaurant Suggestions';

  @override
  String get suggestRestaurant => 'Suggest Restaurant';

  @override
  String get restaurantName => 'Restaurant Name';

  @override
  String get restaurantDescription => 'Description (optional)';

  @override
  String get category => 'Category';

  @override
  String get rating => 'Rating';

  @override
  String get votes => 'Votes';

  @override
  String get vote => 'Vote';

  @override
  String get voted => 'Voted';

  @override
  String get details => 'Details';

  @override
  String suggestedBy(String name) {
    return 'Suggested by $name';
  }

  @override
  String get calendarOverview => 'Calendar Overview';

  @override
  String selectedDay(String date) {
    return 'Selected day: $date';
  }

  @override
  String get plannedEvents => 'Planned Events';

  @override
  String get noEventToday => 'No event on this day';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get myProfile => 'My Profile';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get registeredOn => 'Registered on';

  @override
  String get lastLogin => 'Last login';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get emailExists => 'Email address already registered';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get userNotFound => 'Email address not found';

  @override
  String get networkError => 'Network error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get firstTimer => 'First Timer';

  @override
  String get regular => 'Regular';

  @override
  String get loyaltyChampion => 'Loyalty Champion';

  @override
  String get generousSoul => 'Generous Soul';

  @override
  String get bierbaron => 'Beer Baron';

  @override
  String get foodie => 'Foodie';

  @override
  String get restaurantScout => 'Restaurant Scout';

  @override
  String get streakMaster => 'Streak Master';

  @override
  String get perfectYear => 'Perfect Year';

  @override
  String get lightningFast => 'Lightning Fast';

  @override
  String get levelMaster => 'Level Master';

  @override
  String get stammtischGod => 'Group Master';

  @override
  String get partyStarter => 'Party Starter';

  @override
  String get adminPointsTitle => 'Admin Points';

  @override
  String get noGroupSelected => 'No group selected';

  @override
  String get adminRightsRequired => 'Admin rights required';

  @override
  String get adminPointsInfo => 'Here you can award points to group members.';

  @override
  String get selectUser => 'Select User';

  @override
  String get selectAction => 'Select Action';

  @override
  String get points => 'Points';

  @override
  String get customPoints => 'Custom Points';

  @override
  String get pointsAmount => 'Points Amount';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'Reason for awarding points';

  @override
  String get awardPoints => 'Award Points';

  @override
  String get recentAwards => 'Recent Awards';

  @override
  String get noRecentAwards => 'No recent awards';

  @override
  String get pointsAwarded => 'Points awarded';

  @override
  String get unknown => 'Unknown';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get shareNotImplemented => 'Sharing not yet implemented';

  @override
  String get qrCodeNotImplemented => 'QR Code not yet implemented';

  @override
  String get members => 'Members';

  @override
  String get inviteLink => 'Invite Link';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get shareLink => 'Share Link';

  @override
  String get qrCode => 'QR Code';

  @override
  String get qrCodePlaceholder => 'QR Code placeholder';

  @override
  String get generateQRCode => 'Generate QR Code';

  @override
  String get instructions => 'Instructions';

  @override
  String get inviteStep1 => '1. Share the invite link or QR code';

  @override
  String get inviteStep2 => '2. New members register';

  @override
  String get inviteStep3 => '3. They automatically join the group';

  @override
  String get currentMembers => 'Current Members';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get notificationsEnabled => 'Notifications Enabled';

  @override
  String get dayBefore => '1 Day Before';

  @override
  String get hourBefore => '1 Hour Before';

  @override
  String get minutesBefore => '30 Minutes Before';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationSent => 'Test notification sent!';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get eventReminders => 'Event Reminders';

  @override
  String get chatNotifications => 'Chat Notifications';

  @override
  String get pointsNotifications => 'Points Notifications';

  @override
  String get systemNotifications => 'System Notifications';

  @override
  String get weatherBasedSuggestions => 'Weather-based Suggestions';

  @override
  String get useLocation => 'Use Location';

  @override
  String get fallbackList => 'Fallback Restaurants';

  @override
  String get noSuggestions => 'No suggestions available';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get noChatMessages => 'No messages yet';

  @override
  String get initializing => 'Initializing...';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get chatPlaceholder => 'Chat will be available soon';

  @override
  String get language => 'Language';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get xpEventParticipation => 'Event Participation';

  @override
  String get xpEventOrganizing => 'Event Organized';

  @override
  String get xpFirstToConfirm => 'First to Confirm';

  @override
  String get xpStreakMilestone => 'Streak Milestone';

  @override
  String get xpRestaurantSuggestion => 'Restaurant Suggested';

  @override
  String get xpGroupCreation => 'Group Created';

  @override
  String get xpInviteFriend => 'Friend Invited';

  @override
  String get xpCustom => 'Custom';

  @override
  String get xpBuyRound => 'Bought a round';

  @override
  String get xpPerfectMonth => 'Perfect month';

  @override
  String get xpFirstTime => 'First participation';

  @override
  String get xpAdminBonus => 'Admin bonus';

  @override
  String get qrCodeGenerated => 'QR Code Generated';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get pointCameraAtQR => 'Point camera at QR code';

  @override
  String get qrCodeDetected => 'QR Code detected';

  @override
  String get scannedData => 'Scanned Data';

  @override
  String get joinGroup => 'Join Group';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get joiningGroup => 'Joining group...';

  @override
  String get joinedGroup => 'Joined group successfully';

  @override
  String get loginRequired => 'Login required';

  @override
  String get invalidQRCode => 'Invalid QR Code';

  @override
  String get locationPermissionTitle => 'Location Access';

  @override
  String get locationPermissionMessage =>
      'To provide you with the best restaurant suggestions, we would like to access your location.';

  @override
  String get locationBenefitRestaurants => 'Find nearby restaurants';

  @override
  String get locationBenefitWeather => 'Weather-based recommendations';

  @override
  String get locationBenefitRecommendations => 'Personalized suggestions';

  @override
  String get locationPrivacyNote =>
      'Your location is only used for suggestions and is not stored or shared.';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get deny => 'Deny';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationServicesDisabled => 'Location services are disabled';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission permanently denied. Please enable in device settings.';

  @override
  String get enableLocationServices => 'Enable Location Services';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locationNotAvailable => 'Location not available';

  @override
  String get locationPermissionRequired =>
      'Location permission required for this feature';

  @override
  String get reminderDescription =>
      'Configure your notifications and reminders';

  @override
  String get eventRemindersDescription =>
      'Remind me about upcoming Stammtisch events';

  @override
  String get chatNotificationsDescription => 'Notify me about new messages';

  @override
  String get weeklyDigest => 'Weekly Digest';

  @override
  String get weeklyDigestDescription => 'Receive a weekly summary via email';

  @override
  String get reminderTiming => 'Reminder Timing';

  @override
  String get digestTime => 'Delivery Time';

  @override
  String get sundayAt => 'Sundays at';

  @override
  String get testNotificationDescription => 'Send a test notification';

  @override
  String get notificationInfo => 'Notice';

  @override
  String get notificationInfoDescription =>
      'Notifications are managed locally. Push notifications require cloud integration.';

  @override
  String get selectReminderTime => 'Select Reminder Time';

  @override
  String get selectDigestTime => 'Select Delivery Time';

  @override
  String get oneHourBefore => '1 hour before';

  @override
  String hoursBeforeEvent(int hours) {
    return '$hours hours before event';
  }

  @override
  String get oneDayBefore => '1 day before';

  @override
  String daysBeforeEvent(int days) {
    return '$days days before event';
  }

  @override
  String get settingsSaved => 'Settings saved';
}
