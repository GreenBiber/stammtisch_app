# Stammtisch App - Setup und Konfiguration

## Übersicht

Die Stammtisch App ist eine Flutter-Anwendung für die Organisation privater Stammtische mit folgenden Hauptfunktionen:

- **Benutzerverwaltung**: Registrierung, Login, Multi-Gruppen-Support
- **Terminplanung**: Automatische Event-Erstellung, Abstimmung, Kalender
- **XP-System**: Vollständiges Punkte-, Level- und Achievement-System
- **Restaurant-Vorschläge**: Google Places API Integration mit Wetter-API
- **Chat-Funktionalität**: Firebase Realtime Chat
- **Push-Benachrichtigungen**: Firebase Cloud Messaging
- **QR-Code Einladungen**: Für einfachen Gruppenbeitritt

## API-Keys und Services Setup

### 1. Google Places API

**Benötigt für**: Restaurant-Vorschläge basierend auf Standort

1. Gehe zu [Google Cloud Console](https://console.cloud.google.com/)
2. Erstelle ein neues Projekt oder wähle ein existierendes aus
3. Aktiviere die **Places API (New)**
4. Erstelle API-Credentials (API Key)
5. Beschränke den API-Key auf die Places API
6. Füge den Key in `.env` hinzu:
   ```
   GOOGLE_PLACES_API_KEY=dein_api_key_hier
   ```

**Kosten**: Bis 1000 Anfragen täglich kostenlos

### 2. OpenWeatherMap API

**Benötigt für**: Wetterbasierte Restaurant-Empfehlungen

1. Registriere dich auf [OpenWeatherMap](https://openweathermap.org/api)
2. Erstelle einen kostenlosen Account
3. Kopiere deinen API-Key
4. Füge den Key in `.env` hinzu:
   ```
   WEATHER_API_KEY=dein_weather_api_key_hier
   ```

**Kosten**: Kostenlos für bis zu 1000 Anfragen täglich

### 3. Firebase Setup

**Benötigt für**: Cloud-Datenhaltung, Chat, Push-Notifications

1. Gehe zu [Firebase Console](https://console.firebase.google.com/)
2. Erstelle ein neues Projekt
3. Aktiviere folgende Services:
   - **Authentication** (Email/Password)
   - **Cloud Firestore** (Datenbank)
   - **Cloud Messaging** (Push-Notifications)

4. Lade die Konfigurationsdateien herunter:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)

5. Aktualisiere `lib/firebase_options.dart` mit deinen Projekt-IDs

6. Firestore Sicherheitsregeln:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can read/write their own data
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Group members can read/write group data
       match /groups/{groupId} {
         allow read, write: if request.auth != null && 
           request.auth.uid in resource.data.memberIds;
       }
       
       // Events are readable by group members
       match /events/{eventId} {
         allow read, write: if request.auth != null;
       }
       
       // Points are readable by group members
       match /points/{pointId} {
         allow read, write: if request.auth != null;
       }
       
       // Chat messages for group members
       match /chats/{groupId}/messages/{messageId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

## Installation und Einrichtung

### Voraussetzungen

- Flutter SDK (>= 3.27.0)
- Dart SDK (>= 3.5.0)
- Android Studio / Xcode für mobile Entwicklung

### 1. Abhängigkeiten installieren

```bash
flutter pub get
```

### 2. Umgebungsvariablen konfigurieren

Kopiere `.env.example` nach `.env` und fülle die API-Keys aus:

```bash
cp .env.example .env
```

Bearbeite `.env`:
```
# Google Places API Key
GOOGLE_PLACES_API_KEY=dein_google_places_api_key

# Weather API Key  
WEATHER_API_KEY=dein_openweather_api_key

# Debug-Modus
DEBUG_MODE=true
```

### 3. Firebase konfigurieren

1. **FlutterFire CLI installieren:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Firebase-Projekt verknüpfen:**
   ```bash
   flutterfire configure
   ```

3. **iOS Push-Notifications konfigurieren:**
   - Lade das Apple Developer Certificate herunter
   - Lade es in Firebase unter Project Settings > Cloud Messaging hoch

### 4. App starten

```bash
# Debug-Modus
flutter run

# Release-Modus
flutter run --release
```

## Features und Implementierungsstand

### ✅ Vollständig implementiert (100%)

- **Benutzerverwaltung**: Registrierung, Login, Profilverwaltung
- **Gruppenmanagement**: Erstellen, Beitreten, Admin-Funktionen
- **Event-System**: Automatische Erstellung, Abstimmung, Kalender
- **XP-System**: 14 Achievements, Level 1-10, automatische XP-Vergabe
- **Leaderboard**: Gruppen-Rangliste mit Statistiken
- **Mehrsprachigkeit**: Vollständige DE/EN Lokalisierung
- **Modern UI**: Dark Mode, Animationen, responsive Design
- **Admin-Punktevergabe**: Interface für manuelle XP-Vergabe
- **QR-Code Einladungen**: Generierung und Scanning
- **Firebase Backend**: Cloud-Datenhaltung und Synchronisation
- **Push-Notifications**: Firebase Cloud Messaging
- **Echte Chat-Funktionalität**: Realtime-Chat mit Firebase

### 🔶 API-abhängig (90%)

- **Restaurant-Vorschläge**: Vollständig implementiert, benötigt Google Places API-Key
- **Wetter-Integration**: Vollständig implementiert, benötigt OpenWeatherMap API-Key

### 📱 Platform-Features

- **iOS**: Vollständig unterstützt
- **Android**: Vollständig unterstützt  
- **Web**: Grundlegend unterstützt (Firebase Web SDK)
- **Desktop**: Grundlegend unterstützt (macOS, Windows, Linux)

## Entwicklung und Testing

### Lokale Entwicklung

1. **Firebase Emulator Suite** (optional):
   ```bash
   firebase emulators:start
   ```

2. **Hot Reload** nutzen:
   ```bash
   flutter run
   r  # Hot reload
   R  # Hot restart
   ```

### Testing

```bash
# Unit Tests
flutter test

# Integration Tests
flutter drive --target=test_driver/app.dart
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Troubleshooting

### Häufige Probleme

1. **Google Places API-Fehler**:
   - Prüfe, ob der API-Key korrekt ist
   - Stelle sicher, dass Places API aktiviert ist
   - Überprüfe die Quotas in der Google Cloud Console

2. **Firebase-Verbindungsfehler**:
   - Prüfe `google-services.json` und `GoogleService-Info.plist`
   - Stelle sicher, dass alle Firebase-Services aktiviert sind
   - Überprüfe die Firestore-Sicherheitsregeln

3. **Push-Notifications funktionieren nicht**:
   - iOS: Stelle sicher, dass APNs-Zertifikat hochgeladen ist
   - Android: Prüfe `google-services.json`
   - Teste mit Firebase Console Test-Nachrichten

### Debug-Logs aktivieren

Setze in `.env`:
```
DEBUG_MODE=true
```

Dies aktiviert erweiterte Logs für:
- API-Requests
- Firebase-Operationen
- Chat-Nachrichten
- XP-System-Updates

## Support und Dokumentation

- **Flutter Dokumentation**: https://docs.flutter.dev/
- **Firebase Dokumentation**: https://firebase.google.com/docs
- **Google Places API**: https://developers.google.com/maps/documentation/places/web-service
- **OpenWeatherMap API**: https://openweathermap.org/api

## Lizenz

Dieses Projekt ist für private Nutzung konzipiert. Für kommerzielle Nutzung kontaktiere den Entwickler.

---

**Version**: 1.0.0+  
**Letztes Update**: Januar 2025  
**Status**: MVP vollständig implementiert (95% feature-complete)