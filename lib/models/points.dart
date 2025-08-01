class UserPoints {
  final String userId;
  final String groupId;
  final int totalXP;
  final int currentLevel;
  final int streakCount;
  final DateTime lastActivity;
  final List<String> achievements;
  final Map<String, int> actionCounts; // Für Achievement-Tracking

  UserPoints({
    required this.userId,
    required this.groupId,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.streakCount = 0,
    required this.lastActivity,
    this.achievements = const [],
    this.actionCounts = const {},
  });

  // Level-Berechnung basierend auf XP
  static int calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2500) return 6;
    if (xp < 4000) return 7;
    if (xp < 6000) return 8;
    if (xp < 10000) return 9;
    return 10; // Max Level
  }

  // XP für nächstes Level
  int get xpForNextLevel {
    switch (currentLevel) {
      case 1: return 100;
      case 2: return 300;
      case 3: return 600;
      case 4: return 1000;
      case 5: return 1500;
      case 6: return 2500;
      case 7: return 4000;
      case 8: return 6000;
      case 9: return 10000;
      default: return totalXP; // Max Level erreicht
    }
  }

  // XP vom aktuellen Level
  int get xpInCurrentLevel {
    switch (currentLevel) {
      case 1: return totalXP;
      case 2: return totalXP - 100;
      case 3: return totalXP - 300;
      case 4: return totalXP - 600;
      case 5: return totalXP - 1000;
      case 6: return totalXP - 1500;
      case 7: return totalXP - 2500;
      case 8: return totalXP - 4000;
      case 9: return totalXP - 6000;
      default: return 0;
    }
  }

  // XP benötigt für nächstes Level
  int get xpNeededForNext {
    if (currentLevel >= 10) return 0;
    return xpForNextLevel - totalXP;
  }

  // Progress für nächstes Level (0.0 - 1.0)
  double get levelProgress {
    if (currentLevel >= 10) return 1.0;
    
    final currentLevelStart = currentLevel == 1 ? 0 : _getLevelStartXP(currentLevel);
    final nextLevelStart = xpForNextLevel;
    final progressInLevel = totalXP - currentLevelStart;
    final totalLevelXP = nextLevelStart - currentLevelStart;
    
    return (progressInLevel / totalLevelXP).clamp(0.0, 1.0);
  }

  int _getLevelStartXP(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 100;
      case 3: return 300;
      case 4: return 600;
      case 5: return 1000;
      case 6: return 1500;
      case 7: return 2500;
      case 8: return 4000;
      case 9: return 6000;
      default: return 10000;
    }
  }

  // Level-Titel
  String get levelTitle {
    switch (currentLevel) {
      case 1: return 'Stammtisch-Neuling';
      case 2: return 'Regelmäßiger Gast';
      case 3: return 'Stammtisch-Profi';
      case 4: return 'Bierbaron';
      case 5: return 'Stammtisch-Veteran';
      case 6: return 'Lokaler Held';
      case 7: return 'Stammtisch-Meister';
      case 8: return 'Legendärer Gast';
      case 9: return 'Stammtisch-Gott';
      default: return 'Unsterbliche Legende';
    }
  }

  // Level-Icon
  String get levelIcon {
    switch (currentLevel) {
      case 1: return '🌱';
      case 2: return '🍺';
      case 3: return '🎯';
      case 4: return '👑';
      case 5: return '⭐';
      case 6: return '🏆';
      case 7: return '💎';
      case 8: return '🔥';
      case 9: return '⚡';
      default: return '🏛️';
    }
  }

  // Haupt-Achievement (höchste Priorität)
  String? get primaryAchievement {
    if (achievements.isEmpty) return null;
    
    // Priorität der Achievements
    const priorityOrder = [
      'stammtisch_god',
      'perfect_year',
      'bierbaron',
      'restaurant_scout',
      'lightning_fast',
      'loyalty_champion',
      'party_starter',
      'streak_master',
    ];
    
    for (final achievement in priorityOrder) {
      if (achievements.contains(achievement)) {
        return achievement;
      }
    }
    
    return achievements.first;
  }

  // Kopie mit neuen Werten
  UserPoints copyWith({
    String? userId,
    String? groupId,
    int? totalXP,
    int? currentLevel,
    int? streakCount,
    DateTime? lastActivity,
    List<String>? achievements,
    Map<String, int>? actionCounts,
  }) {
    return UserPoints(
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      streakCount: streakCount ?? this.streakCount,
      lastActivity: lastActivity ?? this.lastActivity,
      achievements: achievements ?? this.achievements,
      actionCounts: actionCounts ?? this.actionCounts,
    );
  }

  // JSON Serialisierung
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'groupId': groupId,
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'streakCount': streakCount,
      'lastActivity': lastActivity.toIso8601String(),
      'achievements': achievements,
      'actionCounts': actionCounts,
    };
  }

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'],
      groupId: json['groupId'],
      totalXP: json['totalXP'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      streakCount: json['streakCount'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity']),
      achievements: List<String>.from(json['achievements'] ?? []),
      actionCounts: Map<String, int>.from(json['actionCounts'] ?? {}),
    );
  }
}

// XP-Aktionen Enum
enum XPAction {
  attendEvent(50, 'Stammtisch besucht', '🍺'),
  organizeEvent(100, 'Event organisiert', '🎉'),
  buyRound(25, 'Getränkerunde spendiert', '🍻'),
  suggestRestaurant(10, 'Restaurant vorgeschlagen', '🍕'),
  earlyConfirmation(15, 'Früh zugesagt', '⚡'),
  perfectMonth(200, 'Perfekter Monat', '🏆'),
  streakBonus(30, 'Streak-Bonus', '🔥'),
  firstTime(20, 'Erste Teilnahme', '🌟'),
  adminBonus(0, 'Admin-Bonus', '👑'), // Variable XP
  custom(0, 'Benutzerdefiniert', '⚙️'); // Variable XP

  const XPAction(this.baseXP, this.description, this.icon);
  
  final int baseXP;
  final String description;
  final String icon;

  // Getter für Kompatibilität
  int get points => baseXP;
}

// Achievement Definitionen
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredValue;
  final String category;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.category,
  });

  static const List<Achievement> allAchievements = [
    // Teilnahme Achievements
    Achievement(
      id: 'first_timer',
      name: 'Erstmalig dabei',
      description: 'Erstes Mal beim Stammtisch',
      icon: '🌟',
      requiredValue: 1,
      category: 'participation',
    ),
    Achievement(
      id: 'regular',
      name: 'Stammgast',
      description: '5x beim Stammtisch gewesen',
      icon: '🍺',
      requiredValue: 5,
      category: 'participation',
    ),
    Achievement(
      id: 'loyalty_champion',
      name: 'Treue-Seele',
      description: '12 Monate dabei',
      icon: '💎',
      requiredValue: 12,
      category: 'participation',
    ),
    
    // Getränke Achievements
    Achievement(
      id: 'generous_soul',
      name: 'Großzügige Seele',
      description: '5x eine Runde ausgegeben',
      icon: '🍻',
      requiredValue: 5,
      category: 'drinks',
    ),
    Achievement(
      id: 'bierbaron',
      name: 'Bierbaron',
      description: '10x eine Runde ausgegeben',
      icon: '👑',
      requiredValue: 10,
      category: 'drinks',
    ),
    
    // Restaurant Achievements
    Achievement(
      id: 'foodie',
      name: 'Feinschmecker',
      description: '3 Restaurants vorgeschlagen',
      icon: '🍕',
      requiredValue: 3,
      category: 'restaurants',
    ),
    Achievement(
      id: 'restaurant_scout',
      name: 'Restaurant-Scout',
      description: '10 Restaurants vorgeschlagen',
      icon: '🗺️',
      requiredValue: 10,
      category: 'restaurants',
    ),
    
    // Streak Achievements
    Achievement(
      id: 'streak_master',
      name: 'Streak-Meister',
      description: '5x in Folge dabei',
      icon: '🔥',
      requiredValue: 5,
      category: 'streak',
    ),
    Achievement(
      id: 'perfect_year',
      name: 'Perfektes Jahr',
      description: '12x in Folge dabei',
      icon: '⭐',
      requiredValue: 12,
      category: 'streak',
    ),
    
    // Speed Achievements
    Achievement(
      id: 'lightning_fast',
      name: 'Blitz-Zusager',
      description: '10x innerhalb 24h geantwortet',
      icon: '⚡',
      requiredValue: 10,
      category: 'speed',
    ),
    
    // Level Achievements  
    Achievement(
      id: 'level_master',
      name: 'Level-Meister',
      description: 'Level 5 erreicht',
      icon: '🏆',
      requiredValue: 5,
      category: 'level',
    ),
    Achievement(
      id: 'stammtisch_god',
      name: 'Stammtisch-Gott',
      description: 'Level 10 erreicht',
      icon: '🏛️',
      requiredValue: 10,
      category: 'level',
    ),
    
    // Organisation Achievements
    Achievement(
      id: 'party_starter',
      name: 'Party-Starter',
      description: '3 Events organisiert',
      icon: '🎉',
      requiredValue: 3,
      category: 'organization',
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}