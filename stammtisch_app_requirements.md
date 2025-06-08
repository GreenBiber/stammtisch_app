# Anforderungsdokument – Stammtisch-App (Version 1.0)

## Ziel der App
Die App unterstützt einen geschlossenen Freundeskreis bei der monatlichen Organisation ihres Stammtischs. Fokus liegt auf Terminabstimmung, Locationwahl, Kommunikation und spielerischer Interaktion durch Punkte und Avatare.

---

## Version 1.0 – Minimum Viable Product (MVP)

### Benutzerverwaltung
- Registrierung mit E-Mail + Passwort
- Rollen: Admin, Mitglied
- Nutzer kann in mehreren Gruppen aktiv sein
- Gruppenübersicht mit Umschaltmöglichkeit
- Avatarbild (wahlweise automatisch oder manuell generiert)

### Gruppenmanagement
- Gruppen-Ersteller wird automatisch Admin
- Einladung per Einladungslink + optional QR-Code
- Admins können Rollen anderer ändern
- Beitritt nur mit Registrierung

### Termine & Events
- Automatisch gesetzter Stammtisch am 1. Dienstag im Monat
- Admins können Datum manuell ändern
- Mindestteilnehmerzahl: 4 (ansonsten automatische Absage mit Benachrichtigung)
- Kalenderübersicht
- Teilnehmerabstimmung: Ja / Nein / Vielleicht

### Location-Vorschläge
- 3 Vorschläge pro Stammtisch
- Basierend auf:
  - Historie
  - Wetter (über Wetter-API)
  - Saison (z. B. Beachclub nur im Sommer)
- Vorschläge bleiben nach Erstellung fix
- Google Places API mit Anzeige der verbleibenden Freikontingente
- Fallback: interne Favoritenliste bei API-Limit
- Initialkonfiguration durch Admin

### Kommunikation
- In-App-Chat mit Avataranzeige
- Push-Benachrichtigungen bei Neuigkeiten, Terminen, Erinnerungen
- Architektur vorbereitet für spätere externe Chat-Anbindung

### Punkte- und Belohnungssystem
- Admins definieren Kategorien mit Punktwerten
- Punktevergabe durch Admins
- Öffentliche Punkteübersicht
- Beispielkategorien:
  - Privates Event ausgerichtet = 10 Punkte
  - Getränkerunde spendiert = 5 Punkte

### Barrierefreiheit & Design
- Dark Mode
- Hohe Kontraste
- Dynamische Schriftgrößen
- UX optimiert für kleine Geräte
- Visuell ansprechendes, modernes UI mit „Wow"-Effekt

### Mehrsprachigkeit
- Deutsch & Englisch ab Version 1.0
- Vollständig i18n-fähig für spätere Spracherweiterungen

### Debugfunktion
- Nur für Chefentwickler im Backend zugänglich
- Anonyme Erfassung: App-Fehler, Klickpfade, Ladezeiten
- Nutzer können Fehler melden (z. B. via Bugreport-Button)

### Cloud & Sicherheit
- Datenhaltung zentral in sicherer Cloud
- DSGVO-konform
- App weltweit nutzbar

---

## Version 2.0 – Komfortfunktionen

- Restaurant-Reservierungen aus App (optional)
- Finanztracking für Auslagen
- Kalenderintegration (iCal)
- Datenexport: Punktelisten, Events
- Bewertungen zu besuchten Lokalen
- Monatsauswertungen
- Punktestatistiken & Verlauf

---

## Version 3.0+ – Erweiterte Soziale & Technische Tiefe

- Externe Messenger-Anbindung (z. B. WhatsApp)
- Gruppenübergreifende Events
- Trivia, Umfragen im Chat
- Favoritenlisten pro Nutzer
- KI-gestützte Vorschläge
- Sprachausgabe & Screenreader
- Community-Übersetzungen

---

## 📌 Umsetzungsstand (Release v1.0.0+)

Die folgenden Funktionen wurden bis einschließlich **Version 1.0.0** vollständig umgesetzt:

### ✅ **Vollständig implementiert**
- **Benutzerverwaltung**: Registrierung, Rollen, Multi-Gruppen-Support
- **Gruppenmanagement**: Erstellung, Admin-Rechte, Mitgliederverwaltung  
- **Termine & Events**: Automatische Erstellung (1. Dienstag), Abstimmung, Mindestanzahl
- **Kalenderansicht**: Monatsübersicht mit Event-Markierungen
- **Erinnerungsfunktion**: Konfigurierbare Push-Benachrichtigungen (1 Tag, 1h, 30 Min)
- **Chat-Interface**: In-App-Chat mit Avatar-Anzeige (Demo-Version)
- **XP-System**: Vollständiges Punkte-, Level- und Achievement-System
- **Rangliste**: Leaderboard mit Statistiken und Level-Verteilung
- **Restaurant-Voting**: Vorschläge und Abstimmungssystem (mit Dummy-Daten)
- **Mehrsprachigkeit**: Vollständige DE/EN Lokalisierung aller UI-Elemente
- **Modern UI**: Dark Mode, responsive Design, Animationen
- **Lokale Datenspeicherung**: SharedPreferences für alle App-Daten
- **Tab-Navigation**: Strukturierte Gruppenseitennavigation

### 🔶 **Teilweise implementiert**
- **Location-Vorschläge**: Dummy-Daten mit Voting *(fehlt: Google Places API, Wetter-API)*
- **Punkte-System**: Automatische XP-Vergabe *(fehlt: Admin-UI für manuelle Punktevergabe)*
- **Push-Benachrichtigungen**: UI-Einstellungen *(fehlt: Echte Push-Integration)*

### ❌ **Noch nicht umgesetzt**
- **Google Places API**: Integration für echte Restaurant-Vorschläge
- **Wetter-API**: Kontextuelle Location-Empfehlungen basierend auf Wetter
- **Cloud-Backend**: Zentrale Datenhaltung (aktuell nur lokal)
- **QR-Code Einladungen**: Für einfachen Gruppenbeitritt
- **Admin-Punktevergabe**: UI für manuelle Punkte-Zuteilung
- **Bug-Report System**: Fehlermeldefunktion für Nutzer
- **Debug-Dashboard**: Entwickler-Analytics

---

## 📊 **Entwicklungsfortschritt Version 1.0**

| Kategorie | Status | Fortschritt |
|-----------|--------|-------------|
| **Core Features** | ✅ Vollständig | 100% |
| **UI/UX & Design** | ✅ Vollständig | 100% |
| **Lokalisierung** | ✅ Vollständig | 100% |
| **XP-System** | ✅ Vollständig | 100% |
| **Location-Features** | 🔶 Teilweise | 60% |
| **Cloud-Integration** | ❌ Fehlend | 0% |
| **APIs (Places, Wetter)** | ❌ Fehlend | 0% |

**Gesamt-Fortschritt Version 1.0: ~75%**

---

## 🎯 **Nächste Prioritäten für MVP-Abschluss**

### **Kritisch (Must-Have für v1.0)**
1. **Google Places API Integration**
   - Echte Restaurant-Suche und -Vorschläge
   - API-Kontingent-Anzeige und Fallback-System
   
2. **Wetter-API Integration** 
   - Kontextuelle Vorschläge basierend auf Wettervorhersage
   - Saison-abhängige Location-Filterung

3. **Cloud-Backend Implementation**
   - Firebase/Supabase für zentrale Datenhaltung
   - User-Synchronisation zwischen Geräten
   - DSGVO-konforme Datenspeicherung

4. **Admin-Punktevergabe UI**
   - Interface für manuelle XP-Zuteilung durch Admins
   - Kategorie-Management für Punktesystem

### **Wichtig (Should-Have für v1.0)**
5. **QR-Code Gruppeneinladungen**
6. **Echte Push-Benachrichtigungen**
7. **Bug-Report System**

### **Optional (Nice-to-Have)**
8. **Debug-Dashboard für Entwickler**

---

# 🚀 Erweiterte Roadmap ab Version 2.x (Visionär & technisch geplant)

## Version 2.0 – Die soziale Evolution

- 🧠 **Stammtisch-Bot (Basisfunktionen)**
  - Begrüßt Mitglieder beim Öffnen der App
  - Fragt Teilnahme automatisiert ab („Hey Max, bist du dabei nächsten Dienstag?")
  - Kommentiert Abstimmungen, erinnert freundlich
  - Technisch: Lokale Bot-Logik + später KI-Anbindung vorbereitet

- 💬 **Gruppeninterner Chat (pro Gruppe)**
  - Jede Gruppe hat ihren eigenen In-App-Gruppenchat (ähnlich WhatsApp)
  - Nachrichtenansicht mit Avataren, Zeitstempeln und optionalem Bot
  - Keine externe Kommunikation (Telegram/WhatsApp) in Version 2.0!
  - Architektur vorbereitet für spätere Messenger-Anbindung (optional ab 2.2+)

- 🏆 **Punktesystem mit RPG-Charakter**
  - Punkte für Aktionen wie:
    - Teilnahme, Gastgeberrolle, Vorschläge, Spontane Hilfe
  - Admins können zusätzliche Punkte vergeben
  - Realtime-Berechnung + Badge-Engine vorbereitet

- 🎖 **Titel & Badges**
  - Beispiel-Titel: „Bierbaron", „Treue-Ritter", „König der Vorschläge"
  - Verliehen durch Aktionen oder Punkte-Meilensteine
  - Sichtbar im Profil, Chat und Ranking

- 📊 **Leaderboard & Gruppenerfolge**
  - Monatsübersicht der aktivsten Mitglieder
  - Vergleich mehrerer Gruppen (optional)

- 📸 **Galerie & Timeline**
  - Foto-Upload pro Event (1–3 Bilder)
  - Chronologische Timeline: Ort, Teilnehmer, Highlights, Punkte

---

## Version 2.1 – Intelligente Empfehlungen & Komfort

- ☀️ **Kontextuelle Restaurantvorschläge**
  - Google Places API + Wetterdaten + Historie
  - „Heute 23 Grad – wie wär's mit dem Beachclub?"
  - Vorschläge bleiben stabil nach Generierung

- 📍 **Stammtisch-Radar**
  - Übersichtskarte aller geplanten Events
  - Orte & Uhrzeiten interaktiv einsehbar

- 🔁 **Terminflexibilität mit Bot-Logik**
  - Wenn Mindestanzahl nicht erreicht → Alternativtermin vorschlagen
  - Event wird dynamisch verschoben (nur mit Zustimmung)

- 📦 **Cloud-Datenspeicherung**
  - Supabase oder Firebase: Gruppen, Events, Punkte zentral speichern
  - Plattformübergreifend nutzbar

---

## Version 2.2 – Kommunikation & Erweiterbarkeit

- ✉️ **Externe Messenger-Anbindung (optional!)**
  - Telegram Bot & WhatsApp Web-Webhook
  - Events und Abstimmungen als Nachrichten senden
  - Stammtisch-Bot kann antworten („Noah kommt auch mit – schön wär's!")
  - **Nur aktivierbar durch Admin – optional!**

- 🧾 **Finanz-Tracking**
  - „Wer hat was ausgelegt?" → einfache Aufteilung
  - Erinnerung an offene Beträge + Historie

- 🗓️ **Kalender-Sync**
  - iCal/Google Calendar Integration
  - Stammtischtermine direkt eintragen

- 🧙 **KI-gestützte Komfortfunktionen**
  - Vorschläge per Prompt („Bot, gib uns 3 coole Orte für heute Abend")
  - Automatische Event-Zusammenfassungen

---

## Optional & Nice-to-have (ab Version 2.3+)

- 🌐 Web-App-Frontend (Flutter Web)
- 🧭 Sprachausgabe & Chatbot per Sprache
- 🧩 Community-Übersetzungssystem
- 🔗 Teilen von Events als Link + QR-Code
- 🧪 A/B-Test-System für neue Features

---

**Version: 1.0.0+**  
**Letzte Aktualisierung: Januar 2025**  
**Status: Erweiterte MVP-Implementierung (75% v1.0 Feature-Complete)**