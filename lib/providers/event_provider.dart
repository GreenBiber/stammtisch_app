import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';
import '../services/sync_service.dart';

class EventProvider with ChangeNotifier {
  final Map<String, Event> _events = {};
  final SyncService _syncService = SyncService();
  
  /// Zeigt an, ob Events mit der Cloud synchronisiert werden
  bool get isCloudSynced => _syncService.status == SyncStatus.online;
  
  /// Aktueller Sync-Status
  SyncStatus get syncStatus => _syncService.status;

  Event? getEventForGroup(String groupId) => _events[groupId];

  Future<void> generateEventForGroup(String groupId) async {
    final now = DateTime.now();
    final firstTuesday = _nextFirstTuesday(now);
    final existing = _events[groupId];

    if (existing != null &&
        existing.date.year == firstTuesday.year &&
        existing.date.month == firstTuesday.month) {
      return; // Event für diesen Monat existiert bereits
    }

    final newEvent = Event(
      groupId: groupId,
      date: firstTuesday,
      participation: {},
    );

    _events[groupId] = newEvent;
    
    // Hybrid-Speicherung: Lokal + Cloud
    await _saveEventHybrid(newEvent, '${groupId}_${firstTuesday.year}_${firstTuesday.month}');
    notifyListeners();
  }

  Future<void> setParticipation(String groupId, String userId, String choice) async {
    final event = _events[groupId];
    if (event != null) {
      final previousChoice = event.participation[userId];
      event.participation[userId] = choice;
      
      // Hybrid-Speicherung: Lokal + Cloud
      await _saveEventHybrid(event, '${groupId}_${event.date.year}_${event.date.month}');
      notifyListeners();
      
      // Debug info
      debugPrint('🎯 Participation changed: $userId -> $choice (was: $previousChoice)');
    }
  }

  // Remove participation (when user leaves group)
  Future<void> removeUserParticipation(String groupId, String userId) async {
    final event = _events[groupId];
    if (event != null && event.participation.containsKey(userId)) {
      event.participation.remove(userId);
      await _saveEventHybrid(event, '${groupId}_${event.date.year}_${event.date.month}');
      notifyListeners();
    }
  }

  // Remove all events for a group (when group is deleted)
  Future<void> removeEventsForGroup(String groupId) async {
    if (_events.containsKey(groupId)) {
      _events.remove(groupId);
      await saveEvents();
      notifyListeners();
    }
  }

  // Get all events for multiple groups (useful for calendar overview)
  List<Event> getEventsForGroups(List<String> groupIds) {
    return groupIds
        .where((groupId) => _events.containsKey(groupId))
        .map((groupId) => _events[groupId]!)
        .toList();
  }

  // Get upcoming events (within next 30 days)
  List<Event> getUpcomingEvents(List<String> groupIds) {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    
    return getEventsForGroups(groupIds)
        .where((event) => 
            event.date.isAfter(now) && 
            event.date.isBefore(thirtyDaysFromNow))
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Force regenerate event for group (admin function)
  Future<void> regenerateEventForGroup(String groupId) async {
    if (_events.containsKey(groupId)) {
      _events.remove(groupId);
    }
    await generateEventForGroup(groupId);
  }

  // Update event date (admin function)
  Future<void> updateEventDate(String groupId, DateTime newDate) async {
    final event = _events[groupId];
    if (event != null) {
      final updatedEvent = Event(
        groupId: event.groupId,
        date: newDate,
        participation: event.participation,
      );
      _events[groupId] = updatedEvent;
      await _saveEventHybrid(updatedEvent, '${groupId}_${newDate.year}_${newDate.month}');
      notifyListeners();
    }
  }

  DateTime _nextFirstTuesday(DateTime reference) {
    DateTime first = DateTime(reference.year, reference.month, 1);
    while (first.weekday != DateTime.tuesday) {
      first = first.add(const Duration(days: 1));
    }
    
    // If the first Tuesday has already passed this month, get next month's first Tuesday
    if (first.isBefore(reference)) {
      final nextMonth = reference.month == 12 
          ? DateTime(reference.year + 1, 1, 1)
          : DateTime(reference.year, reference.month + 1, 1);
      return _nextFirstTuesday(nextMonth);
    }
    
    return first;
  }

  Future<void> saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _events.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString('events', json.encode(map));
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  /// Lädt Events hybrid (Cloud + lokaler Fallback)
  Future<void> loadEvents() async {
    try {
      await _syncService.initialize();
      
      // Events für alle bekannten Gruppen laden
      // Da wir nicht alle Gruppen kennen, laden wir zuerst lokal
      await _loadEventsLocal();
      
      debugPrint('📥 Events geladen: ${_events.length} Events');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading events: $e');
      // Fallback zu alter Methode
      await _loadEventsLocal();
    }
  }
  
  /// Lädt Events aus lokaler Speicherung (Legacy-Fallback)
  Future<void> _loadEventsLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('events');
      if (jsonString == null) return;

      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      _events.clear();
      decoded.forEach((key, value) {
        try {
          _events[key] = Event.fromJson(value);
        } catch (e) {
          debugPrint('Error loading event for group $key: $e');
        }
      });
    } catch (e) {
      debugPrint('Error loading local events: $e');
    }
  }

  // Debug function to get all events (for development)
  Map<String, Event> getAllEvents() => Map.unmodifiable(_events);

  // Statistics functions
  int getTotalEventsCount() => _events.length;

  int getConfirmedEventsCount() => 
      _events.values.where((event) => event.isConfirmed).length;

  int getUserParticipationCount(String userId) {
    int count = 0;
    for (final event in _events.values) {
      if (event.participation[userId] == 'yes') {
        count++;
      }
    }
    return count;
  }
  
  /// Manueller Sync mit Cloud erzwingen
  Future<void> forceSyncToCloud() async {
    try {
      await _syncService.forceSyncToCloud();
      debugPrint('✅ Events erfolgreich in Cloud synchronisiert');
    } catch (e) {
      debugPrint('❌ Cloud-Sync fehlgeschlagen: $e');
      rethrow;
    }
  }
  
  /// Sync-Status Stream für UI-Updates
  Stream<SyncStatus> get syncStatusStream => _syncService.statusStream;
  
  /// Cleanup beim Provider-Dispose
  @override
  void dispose() {
    // SyncService wird global verwendet, nicht hier disposed
    super.dispose();
  }

  /// Speichert ein Event hybrid (lokal + Cloud via SyncService)
  Future<void> _saveEventHybrid(Event event, String eventId) async {
    try {
      await _syncService.saveEvent(event, eventId: eventId);
      debugPrint('✅ Event gespeichert (hybrid): $eventId');
    } catch (e) {
      debugPrint('❌ Hybrid Event-Speicherung fehlgeschlagen: $e');
      // Fallback: Nur lokal speichern
      await saveEvents();
    }
  }

  /// Lädt Events für eine spezifische Gruppe (hybrid)
  Future<void> loadEventsForGroup(String groupId) async {
    try {
      final groupEvents = await _syncService.getGroupEvents(groupId);
      
      // Events in lokalen Cache laden
      for (final event in groupEvents) {
        _events[event.groupId] = event;
      }
      
      notifyListeners();
      debugPrint('📥 Events für Gruppe $groupId geladen: ${groupEvents.length} Events');
    } catch (e) {
      debugPrint('❌ Fehler beim Laden der Events für Gruppe $groupId: $e');
    }
  }
}