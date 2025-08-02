import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! 🍻'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of service and privacy policy'**
  String get agreeTerms;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register here'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login here'**
  String get hasAccount;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroups;

  /// No description provided for @firstGroup.
  ///
  /// In en, this message translates to:
  /// **'Create your first group!'**
  String get firstGroup;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupNotFound;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupAvatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar Image URL (optional)'**
  String get groupAvatar;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get groupSettings;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Members'**
  String memberCount(int count);

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @nextEvent.
  ///
  /// In en, this message translates to:
  /// **'Next Event'**
  String get nextEvent;

  /// No description provided for @participate.
  ///
  /// In en, this message translates to:
  /// **'Participate?'**
  String get participate;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @maybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybe;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @minParticipants.
  ///
  /// In en, this message translates to:
  /// **'not enough participants'**
  String get minParticipants;

  /// No description provided for @participantCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Confirmations'**
  String participantCount(int count);

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDate;

  /// No description provided for @eventStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get eventStatus;

  /// No description provided for @eventParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get eventParticipants;

  /// No description provided for @xpGained.
  ///
  /// In en, this message translates to:
  /// **'XP gained!'**
  String get xpGained;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get levelUp;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked!'**
  String get achievement;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @totalXP.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXP;

  /// No description provided for @xpForAction.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for {action}'**
  String xpForAction(int xp, String action);

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% to next level'**
  String levelProgress(int percent);

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String currentLevel(int level);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {current} → {next}'**
  String nextLevel(int current, int next);

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @restaurantSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Suggestions'**
  String get restaurantSuggestions;

  /// No description provided for @suggestRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Suggest Restaurant'**
  String get suggestRestaurant;

  /// No description provided for @restaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name'**
  String get restaurantName;

  /// No description provided for @restaurantDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get restaurantDescription;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votes;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @voted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get voted;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @suggestedBy.
  ///
  /// In en, this message translates to:
  /// **'Suggested by {name}'**
  String suggestedBy(String name);

  /// No description provided for @calendarOverview.
  ///
  /// In en, this message translates to:
  /// **'Calendar Overview'**
  String get calendarOverview;

  /// No description provided for @selectedDay.
  ///
  /// In en, this message translates to:
  /// **'Selected day: {date}'**
  String selectedDay(String date);

  /// No description provided for @plannedEvents.
  ///
  /// In en, this message translates to:
  /// **'Planned Events'**
  String get plannedEvents;

  /// No description provided for @noEventToday.
  ///
  /// In en, this message translates to:
  /// **'No event on this day'**
  String get noEventToday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String inDays(int days);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered on'**
  String get registeredOn;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last login'**
  String get lastLogin;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @emailExists.
  ///
  /// In en, this message translates to:
  /// **'Email address already registered'**
  String get emailExists;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email address not found'**
  String get userNotFound;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @firstTimer.
  ///
  /// In en, this message translates to:
  /// **'First Timer'**
  String get firstTimer;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @loyaltyChampion.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Champion'**
  String get loyaltyChampion;

  /// No description provided for @generousSoul.
  ///
  /// In en, this message translates to:
  /// **'Generous Soul'**
  String get generousSoul;

  /// No description provided for @bierbaron.
  ///
  /// In en, this message translates to:
  /// **'Beer Baron'**
  String get bierbaron;

  /// No description provided for @foodie.
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get foodie;

  /// No description provided for @restaurantScout.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Scout'**
  String get restaurantScout;

  /// No description provided for @streakMaster.
  ///
  /// In en, this message translates to:
  /// **'Streak Master'**
  String get streakMaster;

  /// No description provided for @perfectYear.
  ///
  /// In en, this message translates to:
  /// **'Perfect Year'**
  String get perfectYear;

  /// No description provided for @lightningFast.
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get lightningFast;

  /// No description provided for @levelMaster.
  ///
  /// In en, this message translates to:
  /// **'Level Master'**
  String get levelMaster;

  /// No description provided for @stammtischGod.
  ///
  /// In en, this message translates to:
  /// **'Group Master'**
  String get stammtischGod;

  /// No description provided for @partyStarter.
  ///
  /// In en, this message translates to:
  /// **'Party Starter'**
  String get partyStarter;

  /// No description provided for @adminPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Points'**
  String get adminPointsTitle;

  /// No description provided for @noGroupSelected.
  ///
  /// In en, this message translates to:
  /// **'No group selected'**
  String get noGroupSelected;

  /// No description provided for @adminRightsRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin rights required'**
  String get adminRightsRequired;

  /// No description provided for @adminPointsInfo.
  ///
  /// In en, this message translates to:
  /// **'Here you can award points to group members.'**
  String get adminPointsInfo;

  /// No description provided for @selectUser.
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get selectUser;

  /// No description provided for @selectAction.
  ///
  /// In en, this message translates to:
  /// **'Select Action'**
  String get selectAction;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @customPoints.
  ///
  /// In en, this message translates to:
  /// **'Custom Points'**
  String get customPoints;

  /// No description provided for @pointsAmount.
  ///
  /// In en, this message translates to:
  /// **'Points Amount'**
  String get pointsAmount;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for awarding points'**
  String get reasonHint;

  /// No description provided for @awardPoints.
  ///
  /// In en, this message translates to:
  /// **'Award Points'**
  String get awardPoints;

  /// No description provided for @recentAwards.
  ///
  /// In en, this message translates to:
  /// **'Recent Awards'**
  String get recentAwards;

  /// No description provided for @noRecentAwards.
  ///
  /// In en, this message translates to:
  /// **'No recent awards'**
  String get noRecentAwards;

  /// No description provided for @pointsAwarded.
  ///
  /// In en, this message translates to:
  /// **'Points awarded'**
  String get pointsAwarded;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @shareNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Sharing not yet implemented'**
  String get shareNotImplemented;

  /// No description provided for @qrCodeNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'QR Code not yet implemented'**
  String get qrCodeNotImplemented;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite Link'**
  String get inviteLink;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @qrCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'QR Code placeholder'**
  String get qrCodePlaceholder;

  /// No description provided for @generateQRCode.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get generateQRCode;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @inviteStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Share the invite link or QR code'**
  String get inviteStep1;

  /// No description provided for @inviteStep2.
  ///
  /// In en, this message translates to:
  /// **'2. New members register'**
  String get inviteStep2;

  /// No description provided for @inviteStep3.
  ///
  /// In en, this message translates to:
  /// **'3. They automatically join the group'**
  String get inviteStep3;

  /// No description provided for @currentMembers.
  ///
  /// In en, this message translates to:
  /// **'Current Members'**
  String get currentMembers;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Enabled'**
  String get notificationsEnabled;

  /// No description provided for @dayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 Day Before'**
  String get dayBefore;

  /// No description provided for @hourBefore.
  ///
  /// In en, this message translates to:
  /// **'1 Hour Before'**
  String get hourBefore;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'30 Minutes Before'**
  String get minutesBefore;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testNotificationSent;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @eventReminders.
  ///
  /// In en, this message translates to:
  /// **'Event Reminders'**
  String get eventReminders;

  /// No description provided for @chatNotifications.
  ///
  /// In en, this message translates to:
  /// **'Chat Notifications'**
  String get chatNotifications;

  /// No description provided for @pointsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Points Notifications'**
  String get pointsNotifications;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get systemNotifications;

  /// No description provided for @weatherBasedSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Weather-based Suggestions'**
  String get weatherBasedSuggestions;

  /// No description provided for @useLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Location'**
  String get useLocation;

  /// No description provided for @fallbackList.
  ///
  /// In en, this message translates to:
  /// **'Fallback Restaurants'**
  String get fallbackList;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions available'**
  String get noSuggestions;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chat will be available soon'**
  String get chatPlaceholder;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @xpEventParticipation.
  ///
  /// In en, this message translates to:
  /// **'Event Participation'**
  String get xpEventParticipation;

  /// No description provided for @xpEventOrganizing.
  ///
  /// In en, this message translates to:
  /// **'Event Organized'**
  String get xpEventOrganizing;

  /// No description provided for @xpFirstToConfirm.
  ///
  /// In en, this message translates to:
  /// **'First to Confirm'**
  String get xpFirstToConfirm;

  /// No description provided for @xpStreakMilestone.
  ///
  /// In en, this message translates to:
  /// **'Streak Milestone'**
  String get xpStreakMilestone;

  /// No description provided for @xpRestaurantSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Suggested'**
  String get xpRestaurantSuggestion;

  /// No description provided for @xpGroupCreation.
  ///
  /// In en, this message translates to:
  /// **'Group Created'**
  String get xpGroupCreation;

  /// No description provided for @xpInviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend Invited'**
  String get xpInviteFriend;

  /// No description provided for @xpCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get xpCustom;

  /// No description provided for @xpBuyRound.
  ///
  /// In en, this message translates to:
  /// **'Bought a round'**
  String get xpBuyRound;

  /// No description provided for @xpPerfectMonth.
  ///
  /// In en, this message translates to:
  /// **'Perfect month'**
  String get xpPerfectMonth;

  /// No description provided for @xpFirstTime.
  ///
  /// In en, this message translates to:
  /// **'First participation'**
  String get xpFirstTime;

  /// No description provided for @xpAdminBonus.
  ///
  /// In en, this message translates to:
  /// **'Admin bonus'**
  String get xpAdminBonus;

  /// No description provided for @qrCodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'QR Code Generated'**
  String get qrCodeGenerated;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @pointCameraAtQR.
  ///
  /// In en, this message translates to:
  /// **'Point camera at QR code'**
  String get pointCameraAtQR;

  /// No description provided for @qrCodeDetected.
  ///
  /// In en, this message translates to:
  /// **'QR Code detected'**
  String get qrCodeDetected;

  /// No description provided for @scannedData.
  ///
  /// In en, this message translates to:
  /// **'Scanned Data'**
  String get scannedData;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @joiningGroup.
  ///
  /// In en, this message translates to:
  /// **'Joining group...'**
  String get joiningGroup;

  /// No description provided for @joinedGroup.
  ///
  /// In en, this message translates to:
  /// **'Joined group successfully'**
  String get joinedGroup;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @invalidQRCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQRCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
