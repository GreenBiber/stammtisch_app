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
      event.participation[userId] = choice;
      saveEvents();
      notifyListeners();
    }
  }

  DateTime _nextFirstTuesday(DateTime reference) {
    DateTime first = DateTime(reference.year, reference.month, 1);
    while (first.weekday != DateTime.tuesday) {
      first = first.add(const Duration(days: 1));
    }
    return first;
  }

  Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _events.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString('events', json.encode(map));
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('events');
    if (jsonString == null) return;

    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    _events.clear();
    decoded.forEach((key, value) {
      _events[key] = Event.fromJson(value);
    });

    notifyListeners();
  }
}
