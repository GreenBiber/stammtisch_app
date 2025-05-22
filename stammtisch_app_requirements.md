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
  - Saison (z. B. Beachclub nur im Sommer)
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
- Visuell ansprechendes, modernes UI mit „Wow“-Effekt

### Mehrsprachigkeit
- Deutsch & Englisch ab Version 1.0
- Vollständig i18n-fähig für spätere Spracherweiterungen

### Debugfunktion
- Nur für Chefentwickler im Backend zugänglich
- Anonyme Erfassung: App-Fehler, Klickpfade, Ladezeiten
- Nutzer können Fehler melden (z. B. via Bugreport-Button)

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

- Externe Messenger-Anbindung (z. B. WhatsApp)
- Gruppenübergreifende Events
- Trivia, Umfragen im Chat
- Favoritenlisten pro Nutzer
- KI-gestützte Vorschläge
- Sprachausgabe & Screenreader
- Community-Übersetzungen