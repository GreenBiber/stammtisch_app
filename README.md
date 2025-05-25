# Stammtisch App 🍻

Eine mobile Flutter-App zur Organisation privater Stammtisch-Gruppen mit Fokus auf Benutzerfreundlichkeit, Gruppentreue und einfache Verwaltung von Treffen.

---

## 📱 Hauptfunktionen in Version 1.0.0

- 🧑‍🤝‍🧑 **Gruppenverwaltung**
  - Gruppen erstellen, wechseln, verlassen oder (als Admin) löschen
  - Avatarbilder automatisch generiert
  - Gruppenliste mit aktivem Status

- 📆 **Terminplanung**
  - Automatische Terminlogik: immer der 1. Dienstag im Monat
  - Gruppenspezifische Termine

- 📋 **Teilnahme-Abstimmung**
  - Nutzer geben zu jedem Termin ihre Teilnahme bekannt (Ja / Vielleicht / Nein)
  - Mindestanzahlprüfung (ab 4 Teilnehmer gilt der Termin als bestätigt)
  - Übersicht, wer welchen Status gewählt hat

- 💾 **Persistente Speicherung**
  - Alle Gruppen, Termine und Teilnahmen bleiben beim App-Neustart erhalten
  - Speicherung über `shared_preferences` lokal auf dem Gerät

- 🌙 **Dark Mode & Mehrsprachigkeit**
  - Standard-Dark-Theme mit Material 3
  - Technisch vorbereitet für DE / EN (automatische Lokalisierung)

---

## 🧱 Technisches Setup

- Framework: Flutter 3.x
- State Management: `provider`
- Lokale Speicherung: `shared_preferences`
- Lokalisierung: `flutter_localizations`
- Struktur: Modularer Aufbau mit `models`, `providers`, `screens`, `widgets`

---

## 🚀 Projektstart (lokal)

```bash
git clone https://github.com/dein-benutzername/stammtisch_app.git
cd stammtisch_app
flutter pub get
flutter run
