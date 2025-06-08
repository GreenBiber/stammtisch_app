import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../models/group.dart';
import '../widgets/language_switcher.dart';
import '../l10n/app_localizations.dart';
import 'group_form_screen.dart';
import 'group_tab_screen.dart';
import 'profile_screen.dart' as profile;

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    return Consumer2<GroupProvider, AuthProvider>(
      builder: (context, groupProvider, authProvider, child) {
        final currentUserId = authProvider.currentUserId;
        final groups = groupProvider.getUserGroups(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myGroups), // LOKALISIERT
            actions: [
              // Language Switcher
              const LanguageSwitcher(isCompact: true),
              const SizedBox(width: 8),
              // Profile Button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const profile.ProfileScreen()),
                  );
                },
                icon: const Icon(Icons.account_circle),
              ),
            ],
          ),
          body: groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_add,
                        size: 64,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noGroups, // LOKALISIERT
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.firstGroup, // LOKALISIERT
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GroupFormScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.locale.languageCode == 'de'
                            ? 'Erste Gruppe erstellen'
                            : 'Create first group'), // LOKALISIERT
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final isAdmin = groupProvider.isCurrentUserAdmin(group, currentUserId);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          group.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isAdmin ? l10n.admin : l10n.member), // LOKALISIERT
                            Text(
                              l10n.memberCount(group.members.length), // LOKALISIERT
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: group.avatarUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    group.avatarUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Text(group.name.substring(0, 1).toUpperCase()),
                                  ),
                                )
                              : Text(
                                  group.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'leave':
                                _showLeaveGroupDialog(
                                  context,
                                  group,
                                  groupProvider,
                                  currentUserId,
                                  isAdmin,
                                  l10n,
                                );
                                break;
                              case 'settings':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.locale.languageCode == 'de'
                                        ? 'Gruppeneinstellungen kommen bald'
                                        : 'Group settings coming soon'),
                                  ),
                                );
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (isAdmin)
                              PopupMenuItem(
                                value: 'settings',
                                child: ListTile(
                                  leading: const Icon(Icons.settings),
                                  title: Text(l10n.settings), // LOKALISIERT
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
                                  isAdmin ? l10n.deleteGroup : l10n.leaveGroup, // LOKALISIERT
                                  style: const TextStyle(color: Colors.red),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          groupProvider.switchGroup(group);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupTabScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupFormScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showLeaveGroupDialog(
    BuildContext context,
    Group group,
    GroupProvider groupProvider,
    String currentUserId,
    bool isAdmin,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdmin ? l10n.deleteGroup : l10n.leaveGroup), // LOKALISIERT
        content: Text(
          isAdmin
              ? (l10n.locale.languageCode == 'de'
                  ? 'Du bist Admin dieser Gruppe. Möchtest du sie komplett löschen? Alle Daten gehen verloren.'
                  : 'You are admin of this group. Do you want to delete it completely? All data will be lost.')
              : (l10n.locale.languageCode == 'de'
                  ? 'Möchtest du die Gruppe "${group.name}" wirklich verlassen?'
                  : 'Do you really want to leave the group "${group.name}"?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel), // LOKALISIERT
          ),
          ElevatedButton(
            onPressed: () {
              if (isAdmin) {
                groupProvider.deleteGroup(group.id, currentUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.locale.languageCode == 'de'
                        ? 'Gruppe "${group.name}" wurde gelöscht'
                        : 'Group "${group.name}" was deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                groupProvider.leaveGroup(group.id, currentUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.locale.languageCode == 'de'
                        ? 'Du hast die Gruppe "${group.name}" verlassen'
                        : 'You left the group "${group.name}"'),
                  ),
                );
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isAdmin ? l10n.delete : l10n.locale.languageCode == 'de' ? 'Verlassen' : 'Leave'),
          ),
        ],
      ),
    );
  }
}