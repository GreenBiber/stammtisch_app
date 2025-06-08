import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/points.dart';
import '../models/user.dart';
import '../providers/points_provider.dart';
import '../providers/auth_provider.dart';

class UserProfileCard extends StatelessWidget {
  final String? groupId;
  final bool showDetailed;
  final bool showProgress;
  final VoidCallback? onTap;
  final String? heroTagSuffix; // NEU: Eindeutige Hero Tags

  const UserProfileCard({
    super.key,
    this.groupId,
    this.showDetailed = true,
    this.showProgress = true,
    this.onTap,
    this.heroTagSuffix, // NEU: Optional suffix für Hero Tag
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PointsProvider>(
      builder: (context, authProvider, pointsProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        final userPoints = groupId != null 
            ? pointsProvider.getUserPoints(user.id, groupId!)
            : null;

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: userPoints != null ? 6 : 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: userPoints != null
                    ? LinearGradient(
                        colors: [
                          _getLevelColor(userPoints.currentLevel).withOpacity(0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: showDetailed && userPoints != null
                    ? _buildDetailedProfile(user, userPoints)
                    : _buildSimpleProfile(user, userPoints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedProfile(User user, UserPoints userPoints) {
    // Eindeutiges Hero Tag mit Suffix
    final heroTag = heroTagSuffix != null 
        ? 'user-avatar-${user.id}-$heroTagSuffix'
        : 'user-avatar-${user.id}-detailed';
        
    return Column(
      children: [
        // Avatar und Basis-Info
        Row(
          children: [
            Stack(
              children: [
                Hero(
                  tag: heroTag, // GEÄNDERT: Eindeutiges Tag
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: _getLevelColor(userPoints.currentLevel),
                    backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!) as ImageProvider
                        : null,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Text(
                            user.initials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                // Level Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getLevelColor(userPoints.currentLevel),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _getLevelColor(userPoints.currentLevel).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${userPoints.currentLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        userPoints.levelIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          userPoints.levelTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: _getLevelColor(userPoints.currentLevel),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (userPoints.primaryAchievement != null) ...[
                    const SizedBox(height: 4),
                    _buildAchievementChip(userPoints.primaryAchievement!),
                  ],
                ],
              ),
            ),
            // Quick Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${userPoints.totalXP}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                if (userPoints.streakCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${userPoints.streakCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),

        if (showProgress) ...[
          const SizedBox(height: 16),

          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level ${userPoints.currentLevel} → ${userPoints.currentLevel + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${userPoints.xpNeededForNext} XP bis Level-Up',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: userPoints.levelProgress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getLevelColor(userPoints.currentLevel),
                            _getLevelColor(userPoints.currentLevel + 1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(userPoints.levelProgress * 100).toInt()}% zum nächsten Level',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                '🔥',
                'Streak',
                '${userPoints.streakCount}',
                Colors.red,
              ),
              _buildStatItem(
                '🏆',
                'Achievements',
                '${userPoints.achievements.length}',
                Colors.purple,
              ),
              _buildStatItem(
                '📊',
                'Rank',
                '#1', // TODO: Echten Rang berechnen
                Colors.blue,
              ),
              _buildStatItem(
                '⚡',
                'Total XP',
                '${userPoints.totalXP}',
                Colors.amber,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleProfile(User user, UserPoints? userPoints) {
    // Eindeutiges Hero Tag mit Suffix
    final heroTag = heroTagSuffix != null 
        ? 'user-avatar-${user.id}-$heroTagSuffix'
        : 'user-avatar-${user.id}-simple';
        
    return Row(
      children: [
        Hero(
          tag: heroTag, // GEÄNDERT: Eindeutiges Tag
          child: Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: userPoints != null 
                    ? _getLevelColor(userPoints.currentLevel)
                    : Colors.grey,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!) as ImageProvider
                    : null,
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              if (userPoints != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getLevelColor(userPoints.currentLevel),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${userPoints.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (userPoints != null) ...[
                Row(
                  children: [
                    Text(
                      userPoints.levelIcon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userPoints.levelTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getLevelColor(userPoints.currentLevel),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                const Text(
                  'Kein XP in dieser Gruppe',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        if (userPoints != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Level ${userPoints.currentLevel}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${userPoints.totalXP} XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (userPoints.streakCount > 0)
                Text(
                  '🔥 ${userPoints.streakCount}',
                  style: const TextStyle(fontSize: 10),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildAchievementChip(String achievementId) {
    final achievement = Achievement.getById(achievementId);
    if (achievement == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Text(
        '${achievement.icon} ${achievement.name}',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.purple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
      ],
    );
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