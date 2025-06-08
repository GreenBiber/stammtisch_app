import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  
  final Locale locale;
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  // Deutsche Übersetzungen
  static const Map<String, String> _localizedStrings = {
    // Auth & Login
    'welcome': 'Willkommen zurück! 🍻',
    'login': 'Anmelden',
    'register': 'Registrieren',
    'email': 'E-Mail',
    'password': 'Passwort',
    'displayName': 'Anzeigename',
    'confirmPassword': 'Passwort bestätigen',
    'agreeTerms': 'Ich akzeptiere die Nutzungsbedingungen und Datenschutzerklärung',
    'rememberMe': 'Angemeldet bleiben',
    'logout': 'Abmelden',
    'forgotPassword': 'Passwort vergessen?',
    'noAccount': 'Noch kein Konto? Hier registrieren',
    'hasAccount': 'Bereits ein Konto? Hier anmelden',
    
    // Groups
    'myGroups': 'Meine Stammtischgruppen',
    'createGroup': 'Gruppe erstellen',
    'noGroups': 'Noch keine Gruppen',
    'firstGroup': 'Erstelle deine erste Stammtischgruppe!',
    'groupName': 'Gruppenname',
    'groupAvatar': 'Avatar-Bild-URL (optional)',
    'leaveGroup': 'Gruppe verlassen',
    'deleteGroup': 'Gruppe löschen',
    'groupSettings': 'Gruppeneinstellungen',
    'memberCount': '%d Mitglieder',
    'admin': 'Admin',
    'member': 'Mitglied',
    
    // Events
    'nextEvent': 'Nächster Stammtisch',
    'participate': 'Teilnehmen?',
    'yes': 'Ja',
    'maybe': 'Vielleicht',
    'no': 'Nein',
    'confirmed': 'Findet statt',
    'cancelled': 'Abgesagt',
    'minParticipants': 'zu wenige Zusagen',
    'participantCount': '%d Zusagen',
    'eventDate': 'Datum',
    'eventStatus': 'Status',
    'eventParticipants': 'Teilnehmer',
    
    // XP & Points
    'xpGained': 'XP erhalten!',
    'levelUp': 'Level Up!',
    'achievement': 'Achievement freigeschaltet!',
    'level': 'Level',
    'streak': 'Streak',
    'totalXP': 'Gesamt XP',
    'xpForAction': '+%d XP für %s',
    'levelProgress': '%d%% zum nächsten Level',
    'currentLevel': 'Level %d',
    'nextLevel': 'Level %d → %d',
    
    // Navigation
    'leaderboard': 'Rangliste',
    'calendar': 'Kalender',
    'restaurants': 'Restaurants',
    'chat': 'Chat',
    'profile': 'Profil',
    'settings': 'Einstellungen',
    'reminders': 'Erinnerungen',
    'suggestions': 'Vorschläge',
    
    // Restaurants
    'restaurantSuggestions': 'Restaurantvorschläge',
    'suggestRestaurant': 'Restaurant vorschlagen',
    'restaurantName': 'Restaurant Name',
    'restaurantDescription': 'Beschreibung (optional)',
    'category': 'Kategorie',
    'rating': 'Bewertung',
    'votes': 'Stimmen',
    'vote': 'Abstimmen',
    'voted': 'Gevotet',
    'details': 'Details',
    'suggestedBy': 'Vorgeschlagen von %s',
    
    // Calendar
    'calendarOverview': 'Kalenderübersicht',
    'selectedDay': 'Ausgewählter Tag: %s',
    'plannedEvents': 'Geplante Events',
    'noEventToday': 'Kein Event an diesem Tag',
    'today': 'Heute',
    'tomorrow': 'Morgen',
    'yesterday': 'Gestern',
    'inDays': 'In %d Tagen',
    'daysAgo': 'Vor %d Tagen',
    
    // Profile
    'myProfile': 'Mein Profil',
    'accountInfo': 'Account-Informationen',
    'registeredOn': 'Registriert am',
    'lastLogin': 'Letzter Login',
    'accountStatus': 'Account-Status',
    'active': 'Aktiv',
    'inactive': 'Inaktiv',
    'editProfile': 'Profil bearbeiten',
    'save': 'Speichern',
    'cancel': 'Abbrechen',
    
    // Common
    'ok': 'OK',
    'close': 'Schließen',
    'delete': 'Löschen',
    'edit': 'Bearbeiten',
    'add': 'Hinzufügen',
    'remove': 'Entfernen',
    'search': 'Suchen',
    'filter': 'Filter',
    'sort': 'Sortieren',
    'refresh': 'Aktualisieren',
    'loading': 'Laden...',
    'error': 'Fehler',
    'success': 'Erfolgreich',
    'warning': 'Warnung',
    'info': 'Information',
    
    // Errors
    'invalidEmail': 'Ungültige E-Mail-Adresse',
    'passwordTooShort': 'Passwort muss mindestens 6 Zeichen lang sein',
    'passwordsDontMatch': 'Passwörter stimmen nicht überein',
    'fieldRequired': 'Dieses Feld ist erforderlich',
    'emailExists': 'E-Mail-Adresse bereits registriert',
    'loginFailed': 'Anmeldung fehlgeschlagen',
    'wrongPassword': 'Falsches Passwort',
    'userNotFound': 'E-Mail-Adresse nicht gefunden',
    'networkError': 'Netzwerkfehler',
    'unknownError': 'Unbekannter Fehler',
    
    // Achievements
    'firstTimer': 'Erstmalig dabei',
    'regular': 'Stammgast',
    'loyaltyChampion': 'Treue-Seele',
    'generousSoul': 'Großzügige Seele',
    'bierbaron': 'Bierbaron',
    'foodie': 'Feinschmecker',
    'restaurantScout': 'Restaurant-Scout',
    'streakMaster': 'Streak-Meister',
    'perfectYear': 'Perfektes Jahr',
    'lightningFast': 'Blitz-Zusager',
    'levelMaster': 'Level-Meister',
    'stammtischGod': 'Stammtisch-Gott',
    'partyStarter': 'Party-Starter',
  };
  
  // Englische Übersetzungen
  static const Map<String, String> _localizedStringsEn = {
    // Auth & Login
    'welcome': 'Welcome back! 🍻',
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'displayName': 'Display Name',
    'confirmPassword': 'Confirm Password',
    'agreeTerms': 'I accept the terms of service and privacy policy',
    'rememberMe': 'Remember me',
    'logout': 'Logout',
    'forgotPassword': 'Forgot password?',
    'noAccount': 'No account? Register here',
    'hasAccount': 'Already have an account? Login here',
    
    // Groups
    'myGroups': 'My Groups',
    'createGroup': 'Create Group',
    'noGroups': 'No groups yet',
    'firstGroup': 'Create your first group!',
    'groupName': 'Group Name',
    'groupAvatar': 'Avatar Image URL (optional)',
    'leaveGroup': 'Leave Group',
    'deleteGroup': 'Delete Group',
    'groupSettings': 'Group Settings',
    'memberCount': '%d Members',
    'admin': 'Admin',
    'member': 'Member',
    
    // Events
    'nextEvent': 'Next Event',
    'participate': 'Participate?',
    'yes': 'Yes',
    'maybe': 'Maybe',
    'no': 'No',
    'confirmed': 'Confirmed',
    'cancelled': 'Cancelled',
    'minParticipants': 'not enough participants',
    'participantCount': '%d Confirmations',
    'eventDate': 'Date',
    'eventStatus': 'Status',
    'eventParticipants': 'Participants',
    
    // XP & Points
    'xpGained': 'XP gained!',
    'levelUp': 'Level Up!',
    'achievement': 'Achievement unlocked!',
    'level': 'Level',
    'streak': 'Streak',
    'totalXP': 'Total XP',
    'xpForAction': '+%d XP for %s',
    'levelProgress': '%d%% to next level',
    'currentLevel': 'Level %d',
    'nextLevel': 'Level %d → %d',
    
    // Navigation
    'leaderboard': 'Leaderboard',
    'calendar': 'Calendar',
    'restaurants': 'Restaurants',
    'chat': 'Chat',
    'profile': 'Profile',
    'settings': 'Settings',
    'reminders': 'Reminders',
    'suggestions': 'Suggestions',
    
    // Restaurants
    'restaurantSuggestions': 'Restaurant Suggestions',
    'suggestRestaurant': 'Suggest Restaurant',
    'restaurantName': 'Restaurant Name',
    'restaurantDescription': 'Description (optional)',
    'category': 'Category',
    'rating': 'Rating',
    'votes': 'Votes',
    'vote': 'Vote',
    'voted': 'Voted',
    'details': 'Details',
    'suggestedBy': 'Suggested by %s',
    
    // Calendar
    'calendarOverview': 'Calendar Overview',
    'selectedDay': 'Selected day: %s',
    'plannedEvents': 'Planned Events',
    'noEventToday': 'No event on this day',
    'today': 'Today',
    'tomorrow': 'Tomorrow',
    'yesterday': 'Yesterday',
    'inDays': 'In %d days',
    'daysAgo': '%d days ago',
    
    // Profile
    'myProfile': 'My Profile',
    'accountInfo': 'Account Information',
    'registeredOn': 'Registered on',
    'lastLogin': 'Last login',
    'accountStatus': 'Account Status',
    'active': 'Active',
    'inactive': 'Inactive',
    'editProfile': 'Edit Profile',
    'save': 'Save',
    'cancel': 'Cancel',
    
    // Common
    'ok': 'OK',
    'close': 'Close',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'remove': 'Remove',
    'search': 'Search',
    'filter': 'Filter',
    'sort': 'Sort',
    'refresh': 'Refresh',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Information',
    
    // Errors
    'invalidEmail': 'Invalid email address',
    'passwordTooShort': 'Password must be at least 6 characters',
    'passwordsDontMatch': 'Passwords do not match',
    'fieldRequired': 'This field is required',
    'emailExists': 'Email address already registered',
    'loginFailed': 'Login failed',
    'wrongPassword': 'Wrong password',
    'userNotFound': 'Email address not found',
    'networkError': 'Network error',
    'unknownError': 'Unknown error',
    
    // Achievements
    'firstTimer': 'First Timer',
    'regular': 'Regular',
    'loyaltyChampion': 'Loyalty Champion',
    'generousSoul': 'Generous Soul',
    'bierbaron': 'Beer Baron',
    'foodie': 'Foodie',
    'restaurantScout': 'Restaurant Scout',
    'streakMaster': 'Streak Master',
    'perfectYear': 'Perfect Year',
    'lightningFast': 'Lightning Fast',
    'levelMaster': 'Level Master',
    'stammtischGod': 'Group Master',
    'partyStarter': 'Party Starter',
  };
  
  String _getValue(String key) {
    if (locale.languageCode == 'en') {
      return _localizedStringsEn[key] ?? key;
    }
    return _localizedStrings[key] ?? key;
  }
  
  // Helper für formatierte Strings
  String _getFormattedValue(String key, List<Object> args) {
    String value = _getValue(key);
    for (int i = 0; i < args.length; i++) {
      value = value.replaceAll('%${i + 1}', args[i].toString());
      value = value.replaceAll('%d', args[i].toString());
      value = value.replaceAll('%s', args[i].toString());
    }
    return value;
  }
  
  // Auth & Login
  String get welcome => _getValue('welcome');
  String get login => _getValue('login');
  String get register => _getValue('register');
  String get email => _getValue('email');
  String get password => _getValue('password');
  String get displayName => _getValue('displayName');
  String get confirmPassword => _getValue('confirmPassword');
  String get agreeTerms => _getValue('agreeTerms');
  String get rememberMe => _getValue('rememberMe');
  String get logout => _getValue('logout');
  String get forgotPassword => _getValue('forgotPassword');
  String get noAccount => _getValue('noAccount');
  String get hasAccount => _getValue('hasAccount');
  
  // Groups
  String get myGroups => _getValue('myGroups');
  String get createGroup => _getValue('createGroup');
  String get noGroups => _getValue('noGroups');
  String get firstGroup => _getValue('firstGroup');
  String get groupName => _getValue('groupName');
  String get groupAvatar => _getValue('groupAvatar');
  String get leaveGroup => _getValue('leaveGroup');
  String get deleteGroup => _getValue('deleteGroup');
  String get groupSettings => _getValue('groupSettings');
  String memberCount(int count) => _getFormattedValue('memberCount', [count]);
  String get admin => _getValue('admin');
  String get member => _getValue('member');
  
  // Events
  String get nextEvent => _getValue('nextEvent');
  String get participate => _getValue('participate');
  String get yes => _getValue('yes');
  String get maybe => _getValue('maybe');
  String get no => _getValue('no');
  String get confirmed => _getValue('confirmed');
  String get cancelled => _getValue('cancelled');
  String get minParticipants => _getValue('minParticipants');
  String participantCount(int count) => _getFormattedValue('participantCount', [count]);
  String get eventDate => _getValue('eventDate');
  String get eventStatus => _getValue('eventStatus');
  String get eventParticipants => _getValue('eventParticipants');
  
  // XP & Points
  String get xpGained => _getValue('xpGained');
  String get levelUp => _getValue('levelUp');
  String get achievement => _getValue('achievement');
  String get level => _getValue('level');
  String get streak => _getValue('streak');
  String get totalXP => _getValue('totalXP');
  String xpForAction(int xp, String action) => _getFormattedValue('xpForAction', [xp, action]);
  String levelProgress(int percent) => _getFormattedValue('levelProgress', [percent]);
  String currentLevel(int level) => _getFormattedValue('currentLevel', [level]);
  String nextLevel(int current, int next) => _getFormattedValue('nextLevel', [current, next]);
  
  // Navigation
  String get leaderboard => _getValue('leaderboard');
  String get calendar => _getValue('calendar');
  String get restaurants => _getValue('restaurants');
  String get chat => _getValue('chat');
  String get profile => _getValue('profile');
  String get settings => _getValue('settings');
  String get reminders => _getValue('reminders');
  String get suggestions => _getValue('suggestions');
  
  // Restaurants
  String get restaurantSuggestions => _getValue('restaurantSuggestions');
  String get suggestRestaurant => _getValue('suggestRestaurant');
  String get restaurantName => _getValue('restaurantName');
  String get restaurantDescription => _getValue('restaurantDescription');
  String get category => _getValue('category');
  String get rating => _getValue('rating');
  String get votes => _getValue('votes');
  String get vote => _getValue('vote');
  String get voted => _getValue('voted');
  String get details => _getValue('details');
  String suggestedBy(String name) => _getFormattedValue('suggestedBy', [name]);
  
  // Calendar
  String get calendarOverview => _getValue('calendarOverview');
  String selectedDay(String date) => _getFormattedValue('selectedDay', [date]);
  String get plannedEvents => _getValue('plannedEvents');
  String get noEventToday => _getValue('noEventToday');
  String get today => _getValue('today');
  String get tomorrow => _getValue('tomorrow');
  String get yesterday => _getValue('yesterday');
  String inDays(int days) => _getFormattedValue('inDays', [days]);
  String daysAgo(int days) => _getFormattedValue('daysAgo', [days]);
  
  // Profile
  String get myProfile => _getValue('myProfile');
  String get accountInfo => _getValue('accountInfo');
  String get registeredOn => _getValue('registeredOn');
  String get lastLogin => _getValue('lastLogin');
  String get accountStatus => _getValue('accountStatus');
  String get active => _getValue('active');
  String get inactive => _getValue('inactive');
  String get editProfile => _getValue('editProfile');
  String get save => _getValue('save');
  String get cancel => _getValue('cancel');
  
  // Common
  String get ok => _getValue('ok');
  String get close => _getValue('close');
  String get delete => _getValue('delete');
  String get edit => _getValue('edit');
  String get add => _getValue('add');
  String get remove => _getValue('remove');
  String get search => _getValue('search');
  String get filter => _getValue('filter');
  String get sort => _getValue('sort');
  String get refresh => _getValue('refresh');
  String get loading => _getValue('loading');
  String get error => _getValue('error');
  String get success => _getValue('success');
  String get warning => _getValue('warning');
  String get info => _getValue('info');
  
  // Errors
  String get invalidEmail => _getValue('invalidEmail');
  String get passwordTooShort => _getValue('passwordTooShort');
  String get passwordsDontMatch => _getValue('passwordsDontMatch');
  String get fieldRequired => _getValue('fieldRequired');
  String get emailExists => _getValue('emailExists');
  String get loginFailed => _getValue('loginFailed');
  String get wrongPassword => _getValue('wrongPassword');
  String get userNotFound => _getValue('userNotFound');
  String get networkError => _getValue('networkError');
  String get unknownError => _getValue('unknownError');
  
  // Achievements
  String get firstTimer => _getValue('firstTimer');
  String get regular => _getValue('regular');
  String get loyaltyChampion => _getValue('loyaltyChampion');
  String get generousSoul => _getValue('generousSoul');
  String get bierbaron => _getValue('bierbaron');
  String get foodie => _getValue('foodie');
  String get restaurantScout => _getValue('restaurantScout');
  String get streakMaster => _getValue('streakMaster');
  String get perfectYear => _getValue('perfectYear');
  String get lightningFast => _getValue('lightningFast');
  String get levelMaster => _getValue('levelMaster');
  String get stammtischGod => _getValue('stammtischGod');
  String get partyStarter => _getValue('partyStarter');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension für einfacheren Zugriff
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}