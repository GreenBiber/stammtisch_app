import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/points.dart';

class PointsProvider with ChangeNotifier {
  // Map: "userId_groupId" -> UserPoints
  final Map<String, UserPoints> _userPoints = {};
  final List<String> _recentXPGains = []; // Für Animations-Queue

  // Getters
  UserPoints? getUserPoints(String userId, String groupId) {
    final key = '${userId}_$groupId';
    return _userPoints[key];
  }

  List<UserPoints> getGroupLeaderboard(String groupId) {
    return _userPoints.values
        .where((points) => points.groupId == groupId)
        .toList()
        ..sort((a, b) => b.totalXP.compareTo(a.totalXP));
  }

  List<UserPoints> getAllUserPoints(String userId) {
    return _userPoints.values
        .where((points) => points.userId == userId)
        .toList();
  }

  List<String> get recentXPGains => List.unmodifiable(_recentXPGains);

  // XP hinzufügen
  Future<List<String>> awardXP(
    String userId,
    String groupId,
    XPAction action, {
    int? customXP,
    String? customDescription,
  }) async {
    final key = '${userId}_$groupId';
    final currentPoints = _userPoints[key] ?? UserPoints(
      userId: userId,
      groupId: groupId,
      lastActivity: DateTime.now(),
    );

    final xpToAdd = customXP ?? action.baseXP;
    final description = customDescription ?? action.description;
    final newTotalXP = currentPoints.totalXP + xpToAdd;
    final oldLevel = currentPoints.currentLevel;
    final newLevel = UserPoints.calculateLevel(newTotalXP);

    // Action Count für Achievements tracken
    final newActionCounts = Map<String, int>.from(currentPoints.actionCounts);
    final actionKey = action.name;
    newActionCounts[actionKey] = (newActionCounts[actionKey] ?? 0) + 1;

    // Streak berechnen
    int newStreak = currentPoints.streakCount;
    if (action == XPAction.attendEvent) {
      final lastActivity = currentPoints.lastActivity;
      final daysSinceLastActivity = DateTime.now().difference(lastActivity).inDays;
      
      if (daysSinceLastActivity <= 35) { // Etwa ein Monat Toleranz
        newStreak = currentPoints.streakCount + 1;
      } else {
        newStreak = 1; // Streak beginnt neu
      }
    }

    // Achievements prüfen
    final newAchievements = List<String>.from(currentPoints.achievements);
    final unlockedAchievements = _checkForNewAchievements(
      newActionCounts,
      newLevel,
      newStreak,
      currentPoints.achievements,
    );
    newAchievements.addAll(unlockedAchievements);

    // UserPoints aktualisieren
    _userPoints[key] = currentPoints.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      streakCount: newStreak,
      lastActivity: DateTime.now(),
      achievements: newAchievements,
      actionCounts: newActionCounts,
    );

    // XP-Gain für Animation hinzufügen
    _recentXPGains.add('${action.icon} +$xpToAdd XP - $description');
    if (_recentXPGains.length > 5) {
      _recentXPGains.removeAt(0);
    }

    await savePoints();
    notifyListeners();

    // Return Liste der Events für UI-Feedback
    final events = <String>[];
    events.add('xp_gained');
    
    if (newLevel > oldLevel) {
      events.add('level_up');
    }
    
    if (unlockedAchievements.isNotEmpty) {
      events.add('achievement_unlocked');
    }

    return events;
  }

  // Admin Bonus XP vergeben
  Future<void> awardAdminBonus(
    String userId,
    String groupId,
    int xp,
    String reason,
  ) async {
    await awardXP(
      userId,
      groupId,
      XPAction.adminBonus,
      customXP: xp,
      customDescription: reason,
    );
  }

  // Direkte XP-Vergabe für Admin-Interface
  Future<List<String>> awardCustomXP(
    String userId,
    String groupId,
    int xpAmount, {
    String? reason,
  }) async {
    return await awardXP(
      userId,
      groupId,
      XPAction.adminBonus,
      customXP: xpAmount,
      customDescription: reason ?? 'Admin-Bonus',
    );
  }

  // Streak zurücksetzen (bei verpasstem Event)
  Future<void> resetStreak(String userId, String groupId) async {
    final key = '${userId}_$groupId';
    final currentPoints = _userPoints[key];
    if (currentPoints != null && currentPoints.streakCount > 0) {
      _userPoints[key] = currentPoints.copyWith(streakCount: 0);
      await savePoints();
      notifyListeners();
    }
  }

  // Achievements prüfen
  List<String> _checkForNewAchievements(
    Map<String, int> actionCounts,
    int level,
    int streak,
    List<String> currentAchievements,
  ) {
    final newAchievements = <String>[];

    for (final achievement in Achievement.allAchievements) {
      if (currentAchievements.contains(achievement.id)) continue;

      bool unlocked = false;

      switch (achievement.category) {
        case 'participation':
          final attendCount = actionCounts['attendEvent'] ?? 0;
          unlocked = attendCount >= achievement.requiredValue;
          break;
        
        case 'drinks':
          final drinkCount = actionCounts['buyRound'] ?? 0;
          unlocked = drinkCount >= achievement.requiredValue;
          break;
        
        case 'restaurants':
          final restaurantCount = actionCounts['suggestRestaurant'] ?? 0;
          unlocked = restaurantCount >= achievement.requiredValue;
          break;
        
        case 'streak':
          unlocked = streak >= achievement.requiredValue;
          break;
        
        case 'speed':
          final earlyCount = actionCounts['earlyConfirmation'] ?? 0;
          unlocked = earlyCount >= achievement.requiredValue;
          break;
        
        case 'level':
          unlocked = level >= achievement.requiredValue;
          break;
        
        case 'organization':
          final organizeCount = actionCounts['organizeEvent'] ?? 0;
          unlocked = organizeCount >= achievement.requiredValue;
          break;
      }

      if (unlocked) {
        newAchievements.add(achievement.id);
      }
    }

    return newAchievements;
  }

  // Monats-Champion berechnen
  UserPoints? getMonthlyChampion(String groupId) {
    // TODO: Hier würden wir monatliche XP-Gains tracken
    // Für jetzt nehmen wir den mit den meisten Gesamt-XP
    return getGroupLeaderboard(groupId).isNotEmpty
        ? getGroupLeaderboard(groupId).first
        : null;
  }

  // Statistics
  Map<String, dynamic> getGroupStats(String groupId) {
    final groupPoints = _userPoints.values
        .where((points) => points.groupId == groupId)
        .toList();

    if (groupPoints.isEmpty) {
      return {
        'totalMembers': 0,
        'averageLevel': 0.0,
        'totalXP': 0,
        'highestStreak': 0,
        'totalAchievements': 0,
      };
    }

    final totalXP = groupPoints.fold<int>(0, (sum, p) => sum + p.totalXP);
    final averageLevel = groupPoints.fold<double>(0, (sum, p) => sum + p.currentLevel) / groupPoints.length;
    final highestStreak = groupPoints.fold<int>(0, (max, p) => p.streakCount > max ? p.streakCount : max);
    final totalAchievements = groupPoints.fold<int>(0, (sum, p) => sum + p.achievements.length);

    return {
      'totalMembers': groupPoints.length,
      'averageLevel': averageLevel,
      'totalXP': totalXP,
      'highestStreak': highestStreak,
      'totalAchievements': totalAchievements,
    };
  }

  // XP-Gains Animation Queue leeren
  void clearRecentXPGains() {
    _recentXPGains.clear();
    notifyListeners();
  }

  // Speichern/Laden
  Future<void> savePoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _userPoints.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString('user_points', json.encode(map));
    } catch (e) {
      debugPrint('Error saving points: $e');
    }
  }

  Future<void> loadPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_points');
      if (jsonString == null) return;

      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      _userPoints.clear();
      decoded.forEach((key, value) {
        try {
          _userPoints[key] = UserPoints.fromJson(value);
        } catch (e) {
          debugPrint('Error loading points for $key: $e');
        }
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading points: $e');
    }
  }

  // Debug-Funktionen
  void resetAllPoints() {
    _userPoints.clear();
    savePoints();
    notifyListeners();
  }

  void debugAwardTestXP(String userId, String groupId) {
    // Für Testing - vergibt verschiedene XP-Aktionen
    awardXP(userId, groupId, XPAction.attendEvent);
    Future.delayed(const Duration(milliseconds: 500), () {
      awardXP(userId, groupId, XPAction.buyRound);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      awardXP(userId, groupId, XPAction.suggestRestaurant);
    });
  }
}