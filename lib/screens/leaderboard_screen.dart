import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../models/points.dart';
import '../widgets/user_profile_card.dart';
import '../l10n/app_localizations.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    return Consumer3<PointsProvider, GroupProvider, AuthProvider>(
      builder: (context, pointsProvider, groupProvider, authProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        
        if (activeGroup == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.leaderboard)), // LOKALISIERT
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.locale.languageCode == 'de' 
                      ? 'Keine Gruppe ausgewählt'
                      : 'No group selected'),
                ],
              ),
            ),
          );
        }

        final leaderboard = pointsProvider.getGroupLeaderboard(activeGroup.id);
        final currentUserId = authProvider.currentUserId;
        final groupStats = pointsProvider.getGroupStats(activeGroup.id);

        // Build tabs with localization
        final tabs = [
          Tab(icon: const Icon(Icons.leaderboard), text: l10n.leaderboard), // LOKALISIERT
          Tab(icon: const Icon(Icons.analytics), text: l10n.locale.languageCode == 'de' ? 'Statistiken' : 'Statistics'),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.locale.languageCode == 'de' 
                ? '${activeGroup.name} - Rangliste'
                : '${activeGroup.name} - Leaderboard'),
            bottom: TabBar(
              controller: _tabController,
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardTab(leaderboard, currentUserId),
              _buildStatsTab(groupStats, activeGroup.name),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab(List<UserPoints> leaderboard, String currentUserId) {
    final l10n = context.l10n;
    
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.locale.languageCode == 'de' 
                  ? 'Noch keine XP-Daten'
                  : 'No XP data yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.locale.languageCode == 'de'
                  ? 'Nehmt am Stammtisch teil um XP zu sammeln!'
                  : 'Participate in events to earn XP!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Top 3 Podium
        if (leaderboard.isNotEmpty)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            child: _buildPodium(leaderboard.take(3).toList()),
          ),

        // Restliche Plätze
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final userPoints = leaderboard[index];
              final isCurrentUser = userPoints.userId == currentUserId;
              final rank = index + 1;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isCurrentUser ? Colors.teal.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getRankColor(rank),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _getLevelColor(userPoints.currentLevel),
                        child: Text(
                          userPoints.levelIcon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    isCurrentUser ? (l10n.locale.languageCode == 'de' ? 'Du' : 'You') : userPoints.userId, // TODO: Echte Namen
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${userPoints.levelTitle} (${l10n.level} ${userPoints.currentLevel})'), // LOKALISIERT
                      if (userPoints.achievements.isNotEmpty)
                        Text(
                          l10n.locale.languageCode == 'de'
                              ? '🏆 ${userPoints.achievements.length} Achievements'
                              : '🏆 ${userPoints.achievements.length} Achievements',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${userPoints.totalXP} XP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (userPoints.streakCount > 0)
                        Text(
                          '🔥 ${userPoints.streakCount}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<UserPoints> topThree) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2. Platz
        if (topThree.length > 1)
          _buildPodiumPlace(topThree[1], 2, 120),
        
        // 1. Platz
        if (topThree.isNotEmpty)
          _buildPodiumPlace(topThree[0], 1, 150),
        
        // 3. Platz
        if (topThree.length > 2)
          _buildPodiumPlace(topThree[2], 3, 100),
      ],
    );
  }

  Widget _buildPodiumPlace(UserPoints userPoints, int place, double height) {
    final l10n = context.l10n;
    final colors = [Colors.amber, Colors.grey, Colors.orange];
    final icons = ['👑', '🥈', '🥉'];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          icons[place - 1],
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 24,
          backgroundColor: _getLevelColor(userPoints.currentLevel),
          child: Text(
            userPoints.levelIcon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userPoints.userId == Provider.of<AuthProvider>(context, listen: false).currentUserId
              ? (l10n.locale.languageCode == 'de' ? 'Du' : 'You')
              : userPoints.userId, // TODO: Echte Namen
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: colors[place - 1],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$place',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${userPoints.totalXP}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(Map<String, dynamic> groupStats, String groupName) {
    final l10n = context.l10n;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.locale.languageCode == 'de' 
                ? 'Gruppen-Statistiken'
                : 'Group Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Overview Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _StatsCard(
                title: l10n.locale.languageCode == 'de' ? 'Mitglieder' : 'Members',
                value: '${groupStats['totalMembers']}',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _StatsCard(
                title: l10n.locale.languageCode == 'de' ? 'Gesamt XP' : 'Total XP',
                value: '${groupStats['totalXP']}',
                icon: Icons.star,
                color: Colors.orange,
              ),
              _StatsCard(
                title: l10n.locale.languageCode == 'de' ? 'Ø Level' : 'Avg Level',
                value: '${groupStats['averageLevel'].toStringAsFixed(1)}',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              _StatsCard(
                title: l10n.locale.languageCode == 'de' ? 'Beste Streak' : 'Best Streak',
                value: '${groupStats['highestStreak']}',
                icon: Icons.local_fire_department,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          // Achievement Overview
          Text(
            l10n.locale.languageCode == 'de'
                ? 'Achievement-Übersicht'
                : 'Achievement Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        l10n.locale.languageCode == 'de'
                            ? 'Gesamt Achievements: ${groupStats['totalAchievements']}'
                            : 'Total Achievements: ${groupStats['totalAchievements']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: groupStats['totalMembers'] > 0 
                        ? (groupStats['totalAchievements'] / (Achievement.allAchievements.length * groupStats['totalMembers'])).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    groupStats['totalMembers'] > 0
                        ? l10n.locale.languageCode == 'de'
                            ? '${((groupStats['totalAchievements'] / (Achievement.allAchievements.length * groupStats['totalMembers'])) * 100).toStringAsFixed(1)}% aller möglichen Achievements freigeschaltet'
                            : '${((groupStats['totalAchievements'] / (Achievement.allAchievements.length * groupStats['totalMembers'])) * 100).toStringAsFixed(1)}% of all possible achievements unlocked'
                        : l10n.locale.languageCode == 'de'
                            ? 'Noch keine Achievements freigeschaltet'
                            : 'No achievements unlocked yet',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Level Distribution
          Text(
            l10n.locale.languageCode == 'de'
                ? 'Level-Verteilung'
                : 'Level Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Consumer<PointsProvider>(
            builder: (context, pointsProvider, child) {
              final activeGroup = Provider.of<GroupProvider>(context).getActiveGroup(context);
              if (activeGroup == null) return const SizedBox.shrink();
              
              final leaderboard = pointsProvider.getGroupLeaderboard(activeGroup.id);
              
              if (leaderboard.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_up, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          l10n.locale.languageCode == 'de'
                              ? 'Noch keine Level-Daten'
                              : 'No level data yet',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.locale.languageCode == 'de'
                              ? 'Sammelt XP um eure Level zu steigern!'
                              : 'Earn XP to increase your levels!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final levelCounts = <int, int>{};
              for (final userPoints in leaderboard) {
                levelCounts[userPoints.currentLevel] = (levelCounts[userPoints.currentLevel] ?? 0) + 1;
              }

              final sortedLevels = levelCounts.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: sortedLevels.map((entry) {
                      final level = entry.key;
                      final count = entry.value;
                      final percentage = (count / leaderboard.length) * 100;
                      
                      final dummyUserPoints = UserPoints(
                        userId: '',
                        groupId: '',
                        currentLevel: level,
                        lastActivity: DateTime.now(),
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getLevelColor(level),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '$level',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dummyUserPoints.levelIcon,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        dummyUserPoints.levelTitle,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(level)),
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey.shade400;
      case 3: return Colors.orange;
      default: return Colors.blue;
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Colors.brown;
      case 2: return Colors.grey;
      case 3: return Colors.orange;
      case 4: return Colors.blue;
      case 5: return Colors.purple;
      case 6: return Colors.red;
      case 7: return Colors.pink;
      case 8: return Colors.indigo;
      case 9: return Colors.amber;
      default: return Colors.deepPurple;
    }
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}