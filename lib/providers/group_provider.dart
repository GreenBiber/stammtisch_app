import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/group.dart';
import 'auth_provider.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  Group? _activeGroup;

  // Dynamically get current user ID from AuthProvider
  String getCurrentUserId(BuildContext context) {
    return Provider.of<AuthProvider>(context, listen: false).currentUserId;
  }

  List<Group> getUserGroups(BuildContext context) {
    final currentUserId = getCurrentUserId(context);
    return _groups.where((g) => g.members.contains(currentUserId)).toList();
  }

  Group? getActiveGroup(BuildContext context) {
    final userGroups = getUserGroups(context);
    if (_activeGroup != null && userGroups.contains(_activeGroup)) {
      return _activeGroup;
    }
    return userGroups.isNotEmpty ? userGroups.first : null;
  }

  // Backward compatibility getters (sollten nur mit Context verwendet werden)
  List<Group> get groups => _groups;
  Group? get activeGroup => _activeGroup;

  Future<void> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final storedGroups = prefs.getString('groups');
    final storedActiveId = prefs.getString('activeGroupId');

    if (storedGroups != null) {
      final List<dynamic> jsonList = json.decode(storedGroups);
      _groups = jsonList.map((e) => Group.fromJson(e)).toList();

      if (storedActiveId != null) {
        try {
          _activeGroup = _groups.firstWhere((g) => g.id == storedActiveId);
        } catch (e) {
          // Fallback if stored active group doesn't exist anymore
          _activeGroup = _groups.isNotEmpty ? _groups.first : null;
        }
      } else if (_groups.isNotEmpty) {
        _activeGroup = _groups.first;
      }
    }

    notifyListeners();
  }

  Future<void> initializeDefaultGroup(String currentUserId) async {
    if (_groups.isEmpty) {
      // Create default group only if no groups exist
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

  void leaveGroup(String groupId, String currentUserId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.members.remove(currentUserId);
    
    // If user was admin, remove admin status too
    group.admins.remove(currentUserId);
    
    // If active group is being left, switch to another group
    if (_activeGroup?.id == groupId) {
      final userGroups = _groups.where((g) => g.members.contains(currentUserId)).toList();
      _activeGroup = userGroups.isNotEmpty ? userGroups.first : null;
    }
    
    saveGroups();
    notifyListeners();
  }

  void deleteGroup(String groupId, String currentUserId) {
    _groups.removeWhere((g) => g.id == groupId);
    
    if (_activeGroup?.id == groupId) {
      final userGroups = _groups.where((g) => g.members.contains(currentUserId)).toList();
      _activeGroup = userGroups.isNotEmpty ? userGroups.first : null;
    }
    
    saveGroups();
    notifyListeners();
  }

  bool isCurrentUserAdmin(Group group, String currentUserId) => group.admins.contains(currentUserId);

  // Method to join a group (for future invite functionality)
  void joinGroup(String groupId, String currentUserId) {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!group.members.contains(currentUserId)) {
        group.members.add(currentUserId);
        saveGroups();
        notifyListeners();
      }
    } catch (e) {
      // Group not found - handle gracefully
    }
  }

  // Method to add member to group (admin function)
  void addMemberToGroup(String groupId, String memberId, String currentUserId) {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      
      // Only admins can add members
      if (group.admins.contains(currentUserId) && !group.members.contains(memberId)) {
        group.members.add(memberId);
        saveGroups();
        notifyListeners();
      }
    } catch (e) {
      // Group not found - handle gracefully
    }
  }

  // Method to promote member to admin
  void promoteToAdmin(String groupId, String memberId, String currentUserId) {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      
      // Only admins can promote others
      if (group.admins.contains(currentUserId) && 
          group.members.contains(memberId) && 
          !group.admins.contains(memberId)) {
        group.admins.add(memberId);
        saveGroups();
        notifyListeners();
      }
    } catch (e) {
      // Group not found - handle gracefully
    }
  }

  // Method to remove admin status
  void removeAdmin(String groupId, String memberId, String currentUserId) {
    try {
      final group = _groups.firstWhere((g) => g.id == groupId);
      
      // Only admins can remove admin status, and there must be at least one admin left
      if (group.admins.contains(currentUserId) && 
          group.admins.contains(memberId) && 
          group.admins.length > 1) {
        group.admins.remove(memberId);
        saveGroups();
        notifyListeners();
      }
    } catch (e) {
      // Group not found - handle gracefully
    }
  }
}