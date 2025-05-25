import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/group.dart';

class GroupProvider with ChangeNotifier {
  final String currentUserId = 'me';

  List<Group> _groups = [];
  Group? _activeGroup;

  List<Group> get groups =>
      _groups.where((g) => g.members.contains(currentUserId)).toList();

  Group get activeGroup => _activeGroup ?? _groups.first;

  Future<void> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final storedGroups = prefs.getString('groups');
    final storedActiveId = prefs.getString('activeGroupId');

    if (storedGroups != null) {
      final List<dynamic> jsonList = json.decode(storedGroups);
      _groups = jsonList.map((e) => Group.fromJson(e)).toList();

      if (storedActiveId != null) {
        _activeGroup = _groups.firstWhere(
          (g) => g.id == storedActiveId,
          orElse: () => _groups.first,
        );
      } else {
        _activeGroup = _groups.first;
      }
    } else {
      // Initialgruppe nur beim ersten Start
      _groups = [
        Group(
          id: '1',
          name: 'Dienstagsrunde 🍻',
          avatarUrl: '',
          members: [currentUserId],
          admins: [currentUserId],
        )
      ];
      _activeGroup = _groups.first;
      await saveGroups();
    }

    notifyListeners();
  }

  Future<void> saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _groups.map((g) => g.toJson()).toList();
    await prefs.setString('groups', json.encode(jsonList));
    await prefs.setString('activeGroupId', _activeGroup?.id ?? '');
  }

  void switchGroup(Group newGroup) {
    _activeGroup = newGroup;
    saveGroups();
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    _activeGroup = group;
    saveGroups();
    notifyListeners();
  }

  void leaveGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.members.remove(currentUserId);
    if (_activeGroup?.id == groupId) {
      _activeGroup = groups.isNotEmpty ? groups.first : null;
    }
    saveGroups();
    notifyListeners();
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    if (_activeGroup?.id == groupId) {
      _activeGroup = groups.isNotEmpty ? groups.first : null;
    }
    saveGroups();
    notifyListeners();
  }

  bool isCurrentUserAdmin(Group group) => group.admins.contains(currentUserId);
}
