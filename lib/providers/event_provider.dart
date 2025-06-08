import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

class EventProvider with ChangeNotifier {
  final Map<String, Event> _events = {};

  Event? getEventForGroup(String groupId) => _events[groupId];

  void generateEventForGroup(String groupId) {
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
    saveEvents();
    notifyListeners();
  }

  void setParticipation(String groupId, String userId, String choice) {
    final event = _events[groupId];
    if (event != null) {
      final previousChoice = event.participation[userId];
      event.participation[userId] = choice;
      
      // Trigger callback for XP processing (will be handled in UI)
      saveEvents();
      notifyListeners();
      
      // Debug info
      debugPrint('🎯 Participation changed: $userId -> $choice (was: $previousChoice)');
    }
  }

  // Remove participation (when user leaves group)
  void removeUserParticipation(String groupId, String userId) {
    final event = _events[groupId];
    if (event != null && event.participation.containsKey(userId)) {
      event.participation.remove(userId);
      saveEvents();
      notifyListeners();
    }
  }

  // Remove all events for a group (when group is deleted)
  void removeEventsForGroup(String groupId) {
    if (_events.containsKey(groupId)) {
      _events.remove(groupId);
      saveEvents();
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
  void regenerateEventForGroup(String groupId) {
    if (_events.containsKey(groupId)) {
      _events.remove(groupId);
    }
    generateEventForGroup(groupId);
  }

  // Update event date (admin function)
  void updateEventDate(String groupId, DateTime newDate) {
    final event = _events[groupId];
    if (event != null) {
      final updatedEvent = Event(
        groupId: event.groupId,
        date: newDate,
        participation: event.participation,
      );
      _events[groupId] = updatedEvent;
      saveEvents();
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

  Future<void> loadEvents() async {
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

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading events: $e');
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
}