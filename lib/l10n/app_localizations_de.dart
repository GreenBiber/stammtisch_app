// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcome => 'Willkommen zurück! 🍻';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get agreeTerms =>
      'Ich akzeptiere die Nutzungsbedingungen und Datenschutzerklärung';

  @override
  String get rememberMe => 'Angemeldet bleiben';

  @override
  String get logout => 'Abmelden';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get noAccount => 'Noch kein Konto? Hier registrieren';

  @override
  String get hasAccount => 'Bereits ein Konto? Hier anmelden';

  @override
  String get myGroups => 'Meine Stammtischgruppen';

  @override
  String get createGroup => 'Gruppe erstellen';

  @override
  String get noGroups => 'Noch keine Gruppen';

  @override
  String get firstGroup => 'Erstelle deine erste Stammtischgruppe!';

  @override
  String get inviteMembers => 'Mitglieder einladen';

  @override
  String get groupNotFound => 'Gruppe nicht gefunden';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get groupAvatar => 'Avatar-Bild-URL (optional)';

  @override
  String get leaveGroup => 'Gruppe verlassen';

  @override
  String get deleteGroup => 'Gruppe löschen';

  @override
  String get groupSettings => 'Gruppeneinstellungen';

  @override
  String memberCount(int count) {
    return '$count Mitglieder';
  }

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Mitglied';

  @override
  String get nextEvent => 'Nächster Stammtisch';

  @override
  String get participate => 'Teilnehmen?';

  @override
  String get yes => 'Ja';

  @override
  String get maybe => 'Vielleicht';

  @override
  String get no => 'Nein';

  @override
  String get confirmed => 'Findet statt';

  @override
  String get cancelled => 'Abgesagt';

  @override
  String get minParticipants => 'zu wenige Zusagen';

  @override
  String participantCount(int count) {
    return '$count Zusagen';
  }

  @override
  String get eventDate => 'Datum';

  @override
  String get eventStatus => 'Status';

  @override
  String get eventParticipants => 'Teilnehmer';

  @override
  String get xpGained => 'XP erhalten!';

  @override
  String get levelUp => 'Level Up!';

  @override
  String get achievement => 'Achievement freigeschaltet!';

  @override
  String get level => 'Level';

  @override
  String get streak => 'Streak';

  @override
  String get totalXP => 'Gesamt XP';

  @override
  String xpForAction(int xp, String action) {
    return '+$xp XP für $action';
  }

  @override
  String levelProgress(int percent) {
    return '$percent% zum nächsten Level';
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
  String get leaderboard => 'Rangliste';

  @override
  String get calendar => 'Kalender';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get suggestions => 'Vorschläge';

  @override
  String get restaurantSuggestions => 'Restaurantvorschläge';

  @override
  String get suggestRestaurant => 'Restaurant vorschlagen';

  @override
  String get restaurantName => 'Restaurant Name';

  @override
  String get restaurantDescription => 'Beschreibung (optional)';

  @override
  String get category => 'Kategorie';

  @override
  String get rating => 'Bewertung';

  @override
  String get votes => 'Stimmen';

  @override
  String get vote => 'Abstimmen';

  @override
  String get voted => 'Gevotet';

  @override
  String get details => 'Details';

  @override
  String suggestedBy(String name) {
    return 'Vorgeschlagen von $name';
  }

  @override
  String get calendarOverview => 'Kalenderübersicht';

  @override
  String selectedDay(String date) {
    return 'Ausgewählter Tag: $date';
  }

  @override
  String get plannedEvents => 'Geplante Events';

  @override
  String get noEventToday => 'Kein Event an diesem Tag';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get yesterday => 'Gestern';

  @override
  String inDays(int days) {
    return 'In $days Tagen';
  }

  @override
  String daysAgo(int days) {
    return 'Vor $days Tagen';
  }

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get accountInfo => 'Account-Informationen';

  @override
  String get registeredOn => 'Registriert am';

  @override
  String get lastLogin => 'Letzter Login';

  @override
  String get accountStatus => 'Account-Status';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sortieren';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolgreich';

  @override
  String get warning => 'Warnung';

  @override
  String get info => 'Information';

  @override
  String get invalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get passwordsDontMatch => 'Passwörter stimmen nicht überein';

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich';

  @override
  String get emailExists => 'E-Mail-Adresse bereits registriert';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get wrongPassword => 'Falsches Passwort';

  @override
  String get userNotFound => 'E-Mail-Adresse nicht gefunden';

  @override
  String get networkError => 'Netzwerkfehler';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get firstTimer => 'Erstmalig dabei';

  @override
  String get regular => 'Stammgast';

  @override
  String get loyaltyChampion => 'Treue-Seele';

  @override
  String get generousSoul => 'Großzügige Seele';

  @override
  String get bierbaron => 'Bierbaron';

  @override
  String get foodie => 'Feinschmecker';

  @override
  String get restaurantScout => 'Restaurant-Scout';

  @override
  String get streakMaster => 'Streak-Meister';

  @override
  String get perfectYear => 'Perfektes Jahr';

  @override
  String get lightningFast => 'Blitz-Zusager';

  @override
  String get levelMaster => 'Level-Meister';

  @override
  String get stammtischGod => 'Stammtisch-Gott';

  @override
  String get partyStarter => 'Party-Starter';

  @override
  String get adminPointsTitle => 'Admin Punktevergabe';

  @override
  String get noGroupSelected => 'Keine Gruppe ausgewählt';

  @override
  String get adminRightsRequired => 'Admin-Rechte erforderlich';

  @override
  String get adminPointsInfo =>
      'Hier können Sie Punkte an Gruppenmitglieder vergeben.';

  @override
  String get selectUser => 'Benutzer auswählen';

  @override
  String get selectAction => 'Aktion auswählen';

  @override
  String get points => 'Punkte';

  @override
  String get customPoints => 'Benutzerdefinierte Punkte';

  @override
  String get pointsAmount => 'Punkteanzahl';

  @override
  String get reason => 'Grund';

  @override
  String get reasonHint => 'Grund für die Punktevergabe';

  @override
  String get awardPoints => 'Punkte vergeben';

  @override
  String get recentAwards => 'Kürzliche Vergaben';

  @override
  String get noRecentAwards => 'Keine kürzlichen Vergaben';

  @override
  String get pointsAwarded => 'Punkte vergeben';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get linkCopied => 'Link kopiert';

  @override
  String get shareNotImplemented => 'Teilen noch nicht implementiert';

  @override
  String get qrCodeNotImplemented => 'QR-Code noch nicht implementiert';

  @override
  String get members => 'Mitglieder';

  @override
  String get inviteLink => 'Einladungslink';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get shareLink => 'Link teilen';

  @override
  String get qrCode => 'QR-Code';

  @override
  String get qrCodePlaceholder => 'QR-Code hier anzeigen';

  @override
  String get generateQRCode => 'QR-Code generieren';

  @override
  String get instructions => 'Anweisungen';

  @override
  String get inviteStep1 => '1. Teile den Einladungslink oder QR-Code';

  @override
  String get inviteStep2 => '2. Neue Mitglieder registrieren sich';

  @override
  String get inviteStep3 => '3. Sie treten automatisch der Gruppe bei';

  @override
  String get currentMembers => 'Aktuelle Mitglieder';

  @override
  String get reminderSettings => 'Erinnerungseinstellungen';

  @override
  String get notificationsEnabled => 'Benachrichtigungen aktiviert';

  @override
  String get dayBefore => '1 Tag vorher';

  @override
  String get hourBefore => '1 Stunde vorher';

  @override
  String get minutesBefore => '30 Minuten vorher';

  @override
  String get testNotification => 'Test-Benachrichtigung senden';

  @override
  String get testNotificationSent => 'Test-Benachrichtigung gesendet';

  @override
  String get notificationTypes => 'Benachrichtigungstypen';

  @override
  String get eventReminders => 'Event-Erinnerungen';

  @override
  String get chatNotifications => 'Chat-Benachrichtigungen';

  @override
  String get pointsNotifications => 'Punkte-Benachrichtigungen';

  @override
  String get systemNotifications => 'System-Benachrichtigungen';

  @override
  String get weatherBasedSuggestions => 'Wetterbasierte Vorschläge';

  @override
  String get useLocation => 'Standort verwenden';

  @override
  String get fallbackList => 'Fallback-Restaurants';

  @override
  String get noSuggestions => 'Keine Vorschläge verfügbar';

  @override
  String get typeMessage => 'Nachricht eingeben...';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get chatPlaceholder => 'Chat wird bald verfügbar sein';

  @override
  String get language => 'Sprache';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get xpEventParticipation => 'Event-Teilnahme';

  @override
  String get xpEventOrganizing => 'Event organisiert';

  @override
  String get xpFirstToConfirm => 'Erster bestätigt';

  @override
  String get xpStreakMilestone => 'Streak-Meilenstein';

  @override
  String get xpRestaurantSuggestion => 'Restaurant vorgeschlagen';

  @override
  String get xpGroupCreation => 'Gruppe erstellt';

  @override
  String get xpInviteFriend => 'Freund eingeladen';

  @override
  String get xpCustom => 'Benutzerdefiniert';

  @override
  String get xpBuyRound => 'Getränkerunde spendiert';

  @override
  String get xpPerfectMonth => 'Perfekter Monat';

  @override
  String get xpFirstTime => 'Erste Teilnahme';

  @override
  String get xpAdminBonus => 'Admin-Bonus';

  @override
  String get qrCodeGenerated => 'QR-Code generiert';

  @override
  String get scanQRCode => 'QR-Code scannen';

  @override
  String get pointCameraAtQR => 'Kamera auf QR-Code richten';

  @override
  String get qrCodeDetected => 'QR-Code erkannt';

  @override
  String get scannedData => 'Gescannte Daten';

  @override
  String get joinGroup => 'Gruppe beitreten';

  @override
  String get scanAgain => 'Erneut scannen';

  @override
  String get joiningGroup => 'Trete Gruppe bei...';

  @override
  String get joinedGroup => 'Gruppe erfolgreich beigetreten';

  @override
  String get loginRequired => 'Anmeldung erforderlich';

  @override
  String get invalidQRCode => 'Ungültiger QR-Code';
}
