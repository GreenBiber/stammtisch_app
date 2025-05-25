import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/group_provider.dart';
import 'group_form_screen.dart';
import 'group_tab_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groups = groupProvider.groups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Stammtischgruppen'),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return ListTile(
            title: Text(group.name),
            subtitle: Text(group.admins.contains(groupProvider.currentUserId)
                ? 'Admin'
                : 'Mitglied'),
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(group.name.substring(0, 1).toUpperCase()),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                final isAdmin = groupProvider.isCurrentUserAdmin(group);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Gruppe verlassen?'),
                    content: Text(isAdmin
                        ? 'Du bist Admin dieser Gruppe. Möchtest du sie komplett löschen?'
                        : 'Möchtest du die Gruppe wirklich verlassen?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Abbrechen'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isAdmin) {
                            groupProvider.deleteGroup(group.id);
                          } else {
                            groupProvider.leaveGroup(group.id);
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Ja'),
                      ),
                    ],
                  ),
                );
              },
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
  }
}
