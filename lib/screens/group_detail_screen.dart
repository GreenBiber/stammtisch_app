import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/group.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/l10n.dart';
import 'event_screen.dart';
import 'calendar_screen.dart';
// import 'reminder_settings_screen.dart'; // Temporarily disabled
import 'restaurant_suggestions_screen.dart';
// import 'chat_screen.dart'; // Temporarily disabled
import 'admin_points_screen.dart';
import 'group_invite_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (mounted) {
        await Provider.of<EventProvider>(context, listen: false)
            .generateEventForGroup(widget.group.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUserId = authProvider.currentUserId;
        final isAdmin = widget.group.admins.contains(currentUserId);
        final user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.group.name),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'settings':
                        _showGroupSettings();
                        break;
                      case 'members':
                        _showMemberManagement();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'members',
                      child: ListTile(
                        leading: const Icon(Icons.people),
                        title: Text(context.isGerman
                            ? 'Mitglieder verwalten'
                            : 'Manage Members'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: const Icon(Icons.settings),
                        title: Text(l10n.groupSettings), // LOKALISIERT
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 32,
                          backgroundImage: widget.group.avatarUrl.isNotEmpty
                              ? NetworkImage(widget.group.avatarUrl)
                                  as ImageProvider
                              : null,
                          child: widget.group.avatarUrl.isEmpty
                              ? Text(
                                  widget.group.name
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.group.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.memberCount(
                                    widget.group.members.length), // LOKALISIERT
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    isAdmin
                                        ? Icons.admin_panel_settings
                                        : Icons.person,
                                    size: 16,
                                    color:
                                        isAdmin ? Colors.orange : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAdmin
                                        ? l10n.admin
                                        : l10n.member, // LOKALISIERT
                                    style: TextStyle(
                                      color:
                                          isAdmin ? Colors.orange : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Actions
                Text(
                  context.isGerman ? 'Aktionen' : 'Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Action Buttons Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _ActionCard(
                      icon: Icons.event,
                      title: context.isGerman ? "Stammtisch" : "Event",
                      subtitle: l10n.nextEvent, // LOKALISIERT
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EventScreen()),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.calendar_month,
                      title: l10n.calendar, // LOKALISIERT
                      subtitle: context.isGerman
                          ? "Terminübersicht"
                          : "Schedule Overview",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CalendarScreen()),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.chat_bubble_outline,
                      title: l10n.chat, // LOKALISIERT
                      subtitle: context.isGerman ? "Gruppenchat" : "Group Chat",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          // MaterialPageRoute(builder: (context) => const ChatScreen()), // Temporarily disabled
                          MaterialPageRoute(
                              builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text('Chat')),
                                  body: Center(
                                      child: Text(
                                          'Chat (Firebase erforderlich)')))),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.restaurant,
                      title: l10n.restaurants, // LOKALISIERT
                      subtitle: l10n.suggestions, // LOKALISIERT
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RestaurantSuggestionsScreen(),
                          ),
                        );
                      },
                    ),
                    if (isAdmin)
                      _ActionCard(
                        icon: Icons.star,
                        title: context.isGerman ? 'Punkte' : 'Points',
                        subtitle: context.isGerman
                            ? 'Punkte vergeben'
                            : 'Award Points',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminPointsScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Additional Options
                Text(
                  l10n.settings, // LOKALISIERT
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: Text(l10n.reminders), // LOKALISIERT
                        subtitle: Text(context.isGerman
                            ? "Push-Benachrichtigungen verwalten"
                            : "Manage push notifications"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => const ReminderSettingsScreen(), // Temporarily disabled
                              builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text('Einstellungen')),
                                  body: Center(
                                      child: Text(
                                          'Einstellungen (Firebase erforderlich)'))),
                            ),
                          );
                        },
                      ),
                      if (isAdmin) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.people),
                          title: Text(context.isGerman
                              ? "Mitglieder verwalten"
                              : "Manage Members"),
                          subtitle: Text(l10n.memberCount(
                              widget.group.members.length)), // LOKALISIERT
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showMemberManagement,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.qr_code),
                          title: Text(context.isGerman
                              ? "QR-Code Einladung"
                              : "QR Code Invite"),
                          subtitle: Text(context.isGerman
                              ? "Mitglieder mit QR-Code einladen"
                              : "Invite members with QR code"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupInviteScreen(groupId: widget.group.id),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(l10n.groupSettings), // LOKALISIERT
                          subtitle: Text(context.isGerman
                              ? "Name, Bild und mehr"
                              : "Name, image and more"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showGroupSettings,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // User Info Card
                if (user != null)
                  Card(
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.teal,
                            backgroundImage: user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!) as ImageProvider
                                : null,
                            child: user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty
                                ? Text(
                                    user.initials,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.isGerman
                                ? 'Angemeldet als: ${user.displayName}'
                                : 'Logged in as: ${user.displayName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGroupSettings() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.groupSettings), // LOKALISIERT
        content: Text(context.isGerman
            ? 'Gruppeneinstellungen werden in einer späteren Version verfügbar sein.'
            : 'Group settings will be available in a future version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.ok), // LOKALISIERT
          ),
        ],
      ),
    );
  }

  void _showMemberManagement() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.isGerman
            ? 'Mitglieder - ${widget.group.name}'
            : 'Members - ${widget.group.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  l10n.memberCount(widget.group.members.length)), // LOKALISIERT
              const SizedBox(height: 12),
              ...widget.group.members.map((memberId) {
                final isAdmin = widget.group.admins.contains(memberId);
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.teal,
                    child: Text(
                      memberId ==
                              Provider.of<AuthProvider>(context, listen: false)
                                  .currentUserId
                          ? (context.isGerman ? 'Du' : 'You')
                          : memberId.substring(0, 2).toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    memberId ==
                            Provider.of<AuthProvider>(context, listen: false)
                                .currentUserId
                        ? (context.isGerman
                            ? 'Du (${Provider.of<AuthProvider>(context, listen: false).currentUser?.displayName})'
                            : 'You (${Provider.of<AuthProvider>(context, listen: false).currentUser?.displayName})')
                        : memberId,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: isAdmin
                      ? Chip(
                          label: Text(l10n.admin,
                              style:
                                  const TextStyle(fontSize: 10)), // LOKALISIERT
                          backgroundColor: Colors.orange,
                        )
                      : null,
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close), // LOKALISIERT
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupInviteScreen(groupId: widget.group.id),
                ),
              );
            },
            child:
                Text(context.isGerman ? 'QR-Code Einladung' : 'QR Code Invite'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
