# Firebase Setup für Stammtisch App

## Übersicht

Diese Anleitung erklärt, wie Firebase als Cloud-Backend für die Stammtisch App eingerichtet wird. Firebase ermöglicht:

- ✅ Zentrale Datenspeicherung in der Cloud
- ✅ Benutzer-Authentifizierung
- ✅ Echtzeit-Synchronisation zwischen Geräten
- ✅ DSGVO-konforme Datenhaltung

## 1. Firebase Projekt erstellen

### Schritt 1: Firebase Console
1. Gehe zu [Firebase Console](https://console.firebase.google.com/)
2. Klicke auf "Projekt hinzufügen"
3. Projekt-Name: `stammtisch-app-[dein-name]`
4. Google Analytics: Optional (empfohlen für Nutzungsstatistiken)

### Schritt 2: Firebase Services aktivieren
In der Firebase Console, aktiviere folgende Services:

#### Authentication
- Gehe zu "Authentication" > "Sign-in method"
- Aktiviere "E-Mail/Passwort"
- Setze authorisierte Domains (localhost für Development)

#### Firestore Database
- Gehe zu "Firestore Database" > "Datenbank erstellen"
- Wähle "Start im Testmodus" für Development
- Region: `europe-west3` (Frankfurt) für DSGVO-Konformität

#### Storage
- Gehe zu "Storage" > "Erste Schritte"
- Wähle dieselbe Region wie Firestore

## 2. Flutter App konfigurieren

### Schritt 1: Firebase CLI installieren
```bash
npm install -g firebase-tools
firebase login
```

### Schritt 2: FlutterFire CLI installieren
```bash
dart pub global activate flutterfire_cli
```

### Schritt 3: Firebase für Flutter konfigurieren
```bash
cd /path/to/stammtisch_app
flutterfire configure
```

- Wähle dein Firebase Projekt
- Wähle Plattformen: iOS, Android, Web
- Dies erstellt automatisch `firebase_options.dart`

### Schritt 4: main.dart anpassen
Füge Firebase Initialisierung hinzu:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialisieren
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Rest der App...
}
```

## 3. Firestore Sicherheitsregeln

### Entwicklungs-Regeln (firebase/firestore.rules)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Benutzer können nur ihre eigenen Daten lesen/schreiben
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Gruppen: Nur Mitglieder können lesen, nur Admins können schreiben
    match /groups/{groupId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.members;
      allow write: if request.auth != null && 
        request.auth.uid in resource.data.admins;
    }
    
    // Events: Gruppenmitglieder können lesen/schreiben
    match /events/{eventId} {
      allow read, write: if request.auth != null;
      // TODO: Erweiterte Berechtigungen basierend auf Gruppenmitgliedschaft
    }
    
    // Punkte: Benutzer können eigene lesen, Admins können schreiben
    match /points/{pointsId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
      // TODO: Admin-Berechtigung für Punktevergabe
    }
  }
}
```

### Regeln deployen
```bash
firebase deploy --only firestore:rules
```

## 4. Migration von lokalen Daten

Die App enthält bereits einen `FirebaseService` mit Sync-Funktionalität:

```dart
// In AuthProvider oder einem Migration-Service
final firebaseService = FirebaseService();
await firebaseService.syncLocalDataToFirebase(
  users: localUsers,
  groups: localGroups,
  events: localEvents,
  pointsData: localPointsData,
);
```

## 5. Environment-spezifische Konfiguration

### .env erweitern
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=stammtisch-app-[dein-name]
FIREBASE_REGION=europe-west3

# Development flags
DEBUG_MODE=true
USE_FIREBASE=true
USE_LOCAL_STORAGE=false
```

## 6. Testing & Development

### Firestore Emulator (Optional)
Für lokale Entwicklung:

```bash
firebase init emulators
firebase emulators:start --only firestore
```

In der App:
```dart
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## 7. Produktions-Deployment

### Sicherheitsregeln verschärfen
- Granulare Berechtigungen pro Collection
- Rate Limiting für API-Calls
- Input Validation

### Monitoring einrichten
- Firebase Performance Monitoring
- Firebase Crashlytics
- Custom Analytics Events

## 8. DSGVO-Konformität

### Datenschutz-Features
- ✅ EU-Region (Frankfurt) für Datenspeicherung
- ✅ Benutzer können Daten löschen
- ✅ Transparente Datennutzung
- ✅ Opt-out für Analytics

### Implementierung
```dart
// Benutzerdaten löschen (DSGVO Art. 17)
Future<void> deleteUserData(String userId) async {
  await FirebaseFirestore.instance.doc('users/$userId').delete();
  await FirebaseAuth.instance.currentUser?.delete();
}
```

## 9. Kosten-Übersicht

### Firebase Free Tier (Spark Plan)
- Firestore: 50,000 reads, 20,000 writes/Tag
- Authentication: Unlimited
- Storage: 1 GB

### Für Production (Blaze Plan)
- Pay-as-you-go nach Nutzung
- Geschätzte Kosten für 100 aktive Benutzer: ~5-10€/Monat

## 10. Nächste Schritte

1. ✅ Firebase Projekt erstellen
2. ✅ FlutterFire konfigurieren
3. ✅ Sicherheitsregeln einrichten
4. ✅ Migration von lokalen Daten testen
5. ✅ Production Deployment vorbereiten

---

**Status**: Vorbereitet für Firebase Integration
**Version**: 1.0.0+
**Letzte Aktualisierung**: Januar 2025