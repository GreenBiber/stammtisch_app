import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/points_provider.dart';
import '../models/group.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/sync_status_indicator.dart';
import '../l10n/app_localizations.dart';
import 'chat_screen.dart';
import 'calendar_screen.dart';
import 'event_screen.dart';
import 'restaurant_suggestions_screen.dart';
import 'reminder_settings_screen.dart';
import 'leaderboard_screen.dart';

class GroupTabScreen extends StatefulWidget {
  const GroupTabScreen({super.key});

  @override
  State<GroupTabScreen> createState() => _GroupTabScreenState();
}

class _GroupTabScreenState extends State<GroupTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.brown;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.purple;
      case 6:
        return Colors.red;
      case 7:
        return Colors.pink;
      case 8:
        return Colors.indigo;
      case 9:
        return Colors.amber;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Lokalisierung

    return Consumer3<GroupProvider, AuthProvider, PointsProvider>(
      builder: (context, groupProvider, authProvider, pointsProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        final currentUser = authProvider.currentUser;
        final currentUserId = authProvider.currentUserId;

        // Check if user has any groups
        if (activeGroup == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Localizations.localeOf(context).languageCode == 'de'
                  ? 'Stammtisch-Gruppe'
                  : 'Group'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.group_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Localizations.localeOf(context).languageCode == 'de'
                        ? 'Keine Gruppe ausgewählt'
                        : 'No group selected',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'de'
                        ? 'Wähle zuerst eine Gruppe aus.'
                        : 'Please select a group first.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final isAdmin = activeGroup.admins.contains(currentUserId);
        final userPoints =
            pointsProvider.getUserPoints(currentUserId, activeGroup.id);

        // Build tabs with localization
        final tabs = [
          Tab(
              icon: const Icon(Icons.event),
              text: Localizations.localeOf(context).languageCode == 'de' ? 'Event' : 'Event'),
          Tab(icon: const Icon(Icons.chat), text: l10n.chat), // LOKALISIERT
          Tab(
              icon: const Icon(Icons.calendar_today),
              text: l10n.calendar), // LOKALISIERT
          Tab(
              icon: const Icon(Icons.leaderboard),
              text: l10n.leaderboard), // LOKALISIERT
          Tab(
              icon: const Icon(Icons.restaurant),
              text: Localizations.localeOf(context).languageCode == 'de'
                  ? 'Vorschläge'
                  : 'Suggestions'),
          Tab(
              icon: const Icon(Icons.notifications_active),
              text: Localizations.localeOf(context).languageCode == 'de'
                  ? 'Erinnerung'
                  : 'Reminders'),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activeGroup.name),
                if (currentUser != null)
                  Text(
                    currentUser.displayName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
            actions: [
              // Sync Status Indicator
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SyncStatusIndicator(showLabel: false, iconSize: 16),
              ),
              
              // User Profile Mini-Card (ähnlich wie in event_screen.dart)
              if (userPoints != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getLevelColor(userPoints.currentLevel)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getLevelColor(userPoints.currentLevel),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userPoints.levelIcon,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'L${userPoints.currentLevel}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getLevelColor(userPoints.currentLevel),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${userPoints.totalXP}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(Localizations.localeOf(context).languageCode == 'de'
                            ? 'Admin-Funktionen kommen bald'
                            : 'Admin functions coming soon'),
                      ),
                    );
                  },
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'info':
                      _showGroupInfo(activeGroup, isAdmin);
                      break;
                    case 'leave':
                      _showLeaveGroupDialog(
                        activeGroup,
                        groupProvider,
                        currentUserId,
                        isAdmin,
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'info',
                    child: ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(Localizations.localeOf(context).languageCode == 'de'
                          ? 'Gruppeninfo'
                          : 'Group Info'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'leave',
                    child: ListTile(
                      leading: Icon(
                        isAdmin ? Icons.delete : Icons.exit_to_app,
                        color: Colors.red,
                      ),
                      title: Text(
                        isAdmin
                            ? l10n.deleteGroup
                            : l10n.leaveGroup, // LOKALISIERT
                        style: const TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: tabs,
              isScrollable: true,
              indicatorColor: Colors.teal,
            ),
          ),
          body: Column(
            children: [
              // Profile Card Header (nur wenn XP vorhanden)
              if (userPoints != null)
                UserProfileCard(
                  groupId: activeGroup.id,
                  showDetailed: false,
                  showProgress: true,
                  heroTagSuffix: 'header', // EINDEUTIGES TAG
                ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    EventScreen(),
                    ChatScreen(),
                    CalendarScreen(),
                    LeaderboardScreen(),
                    RestaurantSuggestionsScreen(),
                    ReminderSettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGroupInfo(Group activeGroup, bool isAdmin) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activeGroup.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(
                  Localizations.localeOf(context).languageCode == 'de' ? 'Mitglieder' : 'Members'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'de'
                  ? '${activeGroup.members.length} Personen'
                  : '${activeGroup.members.length} People'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: Text(Localizations.localeOf(context).languageCode == 'de'
                  ? 'Deine Rolle'
                  : 'Your Role'),
              subtitle: Text(isAdmin
                  ? (Localizations.localeOf(context).languageCode == 'de'
                      ? 'Administrator'
                      : 'Administrator')
                  : l10n.member), // LOKALISIERT
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                  Localizations.localeOf(context).languageCode == 'de' ? 'Erstellt' : 'Created'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'de'
                  ? 'Datum wird in späteren Version angezeigt'
                  : 'Date will be shown in future version'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close), // LOKALISIERT
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog(
    Group activeGroup,
    GroupProvider groupProvider,
    String currentUserId,
    bool isAdmin,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdmin
            ? (Localizations.localeOf(context).languageCode == 'de'
                ? 'Gruppe löschen?'
                : 'Delete Group?')
            : (Localizations.localeOf(context).languageCode == 'de'
                ? 'Gruppe verlassen?'
                : 'Leave Group?')),
        content: Text(
          isAdmin
              ? (Localizations.localeOf(context).languageCode == 'de'
                  ? 'Du bist Admin dieser Gruppe. Möchtest du sie komplett löschen? Alle Daten gehen verloren.'
                  : 'You are admin of this group. Do you want to delete it completely? All data will be lost.')
              : (Localizations.localeOf(context).languageCode == 'de'
                  ? 'Möchtest du die Gruppe "${activeGroup.name}" wirklich verlassen?'
                  : 'Do you really want to leave the group "${activeGroup.name}"?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel), // LOKALISIERT
          ),
          ElevatedButton(
            onPressed: () {
              if (isAdmin) {
                groupProvider.deleteGroup(activeGroup.id, currentUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Localizations.localeOf(context).languageCode == 'de'
                        ? 'Gruppe "${activeGroup.name}" wurde gelöscht'
                        : 'Group "${activeGroup.name}" was deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                groupProvider.leaveGroup(activeGroup.id, currentUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Localizations.localeOf(context).languageCode == 'de'
                        ? 'Du hast die Gruppe "${activeGroup.name}" verlassen'
                        : 'You left the group "${activeGroup.name}"'),
                  ),
                );
              }
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to group list
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: Text(isAdmin
                ? l10n.delete
                : (Localizations.localeOf(context).languageCode == 'de'
                    ? 'Verlassen'
                    : 'Leave')), // LOKALISIERT
          ),
        ],
      ),
    );
  }
}
