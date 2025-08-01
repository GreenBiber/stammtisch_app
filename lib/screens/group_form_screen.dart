import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/group.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/l10n.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final currentUserId = authProvider.currentUserId;

    final group = Group(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      avatarUrl: _avatarController.text.trim().isEmpty
          ? ''
          : _avatarController.text.trim(),
      members: [currentUserId], // Echter User wird Mitglied
      admins: [currentUserId], // Echter User wird Admin
    );

    groupProvider.addGroup(group);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.isGerman
            ? 'Gruppe "${group.name}" wurde erstellt! 🎉'
            : 'Group "${group.name}" was created! 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.isGerman
            ? 'Neue Gruppe erstellen'
            : 'Create New Group'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Info Card
                  Card(
                    color: Colors.teal.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.group_add,
                              size: 48, color: Colors.teal),
                          const SizedBox(height: 12),
                          Text(
                            context.isGerman
                                ? 'Neue Stammtischgruppe'
                                : 'New Group',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.isGerman
                                ? 'Du wirst automatisch Admin der neuen Gruppe und kannst andere Mitglieder einladen.'
                                : 'You will automatically become admin of the new group and can invite other members.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.groupName, // LOKALISIERT
                      prefixIcon: const Icon(Icons.group),
                      helperText: context.isGerman
                          ? 'z.B. "Dienstagsrunde 🍻" oder "Büro-Stammtisch"'
                          : 'e.g. "Tuesday Group 🍻" or "Office Regulars"',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.isGerman
                            ? 'Bitte Gruppennamen eingeben'
                            : 'Please enter group name';
                      }
                      if (value.trim().length < 2) {
                        return context.isGerman
                            ? 'Gruppenname muss mindestens 2 Zeichen lang sein'
                            : 'Group name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _avatarController,
                    decoration: InputDecoration(
                      labelText: context.l10n.groupAvatar, // LOKALISIERT
                      prefixIcon: const Icon(Icons.image),
                      helperText: context.isGerman
                          ? 'Link zu einem Gruppenbild'
                          : 'Link to a group image',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final uri = Uri.tryParse(value);
                        if (uri == null || !uri.isAbsolute) {
                          return context.isGerman
                              ? 'Ungültige URL'
                              : 'Invalid URL';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.create),
                    label: Text(context.l10n.createGroup), // LOKALISIERT
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current User Info
                  Card(
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            context.isGerman
                                ? 'Erstellt von: ${authProvider.currentUser?.displayName ?? "Unbekannt"}'
                                : 'Created by: ${authProvider.currentUser?.displayName ?? "Unknown"}',
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
      ),
    );
  }
}
