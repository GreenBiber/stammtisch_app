import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/group.dart';
import '../providers/group_provider.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final group = Group(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
        members: ['me'], // aktiver Nutzer wird automatisch Mitglied
        admins: ['me'],  // wird auch automatisch Admin
      );

      Provider.of<GroupProvider>(context, listen: false).addGroup(group);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gruppe "${group.name}" wurde erstellt.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neue Gruppe erstellen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gruppenname'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte Gruppennamen eingeben';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: 'Avatar-Bild-URL (optional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Gruppe erstellen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
