import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../models/points.dart';
import '../l10n/app_localizations.dart';

class AdminPointsScreen extends StatefulWidget {
  const AdminPointsScreen({super.key});

  @override
  State<AdminPointsScreen> createState() => _AdminPointsScreenState();
}

class _AdminPointsScreenState extends State<AdminPointsScreen> {
  final _customPointsController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _selectedUserId;
  XPAction? _selectedAction;

  @override
  void dispose() {
    _customPointsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer3<PointsProvider, AuthProvider, GroupProvider>(
      builder: (context, pointsProvider, authProvider, groupProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        final currentUserId = authProvider.currentUserId;
        
        if (activeGroup == null || !activeGroup.admins.contains(currentUserId)) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.locale.languageCode == 'de' ? 'Punkte verwalten' : 'Manage Points'),
            ),
            body: const Center(
              child: Text('Nur Admins können Punkte verwalten'),
            ),
          );
        }

        final groupMembers = activeGroup.members.where((id) => id != currentUserId).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.locale.languageCode == 'de' ? 'Punkte verwalten' : 'Manage Points'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Info Card
                Card(
                  color: Colors.orange.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.locale.languageCode == 'de' ? 'Admin-Bereich' : 'Admin Area',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                l10n.locale.languageCode == 'de' 
                                    ? 'Hier kannst du Punkte für Gruppenmitglieder vergeben'
                                    : 'Here you can award points to group members',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // User Selection
                Text(
                  l10n.locale.languageCode == 'de' ? 'Mitglied auswählen' : 'Select Member',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: groupMembers.map((memberId) {
                      final userPoints = pointsProvider.getUserPoints(memberId, activeGroup.id);
                      final isSelected = _selectedUserId == memberId;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.teal.withOpacity(0.1),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            memberId.substring(0, 2).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(memberId),
                        subtitle: userPoints != null 
                            ? Text('Level ${userPoints.level} • ${userPoints.totalXP} XP')
                            : Text(l10n.locale.languageCode == 'de' ? 'Noch keine Punkte' : 'No points yet'),
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: Colors.teal)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedUserId = isSelected ? null : memberId;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

                if (_selectedUserId != null) ...[
                  const SizedBox(height: 24),

                  // Action Selection
                  Text(
                    l10n.locale.languageCode == 'de' ? 'Punktevergabe-Grund' : 'Points Award Reason',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: [
                        // Predefined Actions
                        ...XPAction.values.where((action) => action != XPAction.adminBonus).map((action) {
                          final isSelected = _selectedAction == action;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.teal.withOpacity(0.1),
                            leading: Icon(
                              _getActionIcon(action),
                              color: isSelected ? Colors.teal : null,
                            ),
                            title: Text(_getActionTitle(action, l10n.locale.languageCode == 'de')),
                            subtitle: Text('${action.xpReward} XP'),
                            trailing: isSelected 
                                ? const Icon(Icons.check_circle, color: Colors.teal)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedAction = isSelected ? null : action;
                                if (isSelected) {
                                  _customPointsController.clear();
                                  _reasonController.clear();
                                }
                              });
                            },
                          );
                        }).toList(),

                        const Divider(),

                        // Custom Points
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(l10n.locale.languageCode == 'de' ? 'Benutzerdefiniert' : 'Custom'),
                          subtitle: Text(l10n.locale.languageCode == 'de' 
                              ? 'Eigene Punkte und Grund eingeben' 
                              : 'Enter custom points and reason'),
                          onTap: () {
                            _showCustomPointsDialog();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Award Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedAction != null || _customPointsController.text.isNotEmpty) 
                          ? _awardPoints 
                          : null,
                      icon: const Icon(Icons.star),
                      label: Text(l10n.locale.languageCode == 'de' ? 'Punkte vergeben' : 'Award Points'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getActionIcon(XPAction action) {
    switch (action) {
      case XPAction.organizeEvent:
        return Icons.event;
      case XPAction.suggestRestaurant:
        return Icons.restaurant;
      case XPAction.buyRound:
        return Icons.local_bar;
      case XPAction.attendEvent:
        return Icons.check_circle;
      case XPAction.earlyConfirmation:
        return Icons.flash_on;
      case XPAction.perfectMonth:
        return Icons.star;
      case XPAction.streakBonus:
        return Icons.local_fire_department;
      case XPAction.firstTime:
        return Icons.celebration;
      case XPAction.adminBonus:
        return Icons.star;
    }
  }

  String _getActionTitle(XPAction action, bool isGerman) {
    switch (action) {
      case XPAction.organizeEvent:
        return isGerman ? 'Event organisiert' : 'Event organized';
      case XPAction.suggestRestaurant:
        return isGerman ? 'Restaurant vorgeschlagen' : 'Restaurant suggested';
      case XPAction.buyRound:
        return isGerman ? 'Getränkerunde spendiert' : 'Bought drinks round';
      case XPAction.attendEvent:
        return isGerman ? 'Event-Teilnahme' : 'Event attendance';
      case XPAction.earlyConfirmation:
        return isGerman ? 'Früh zugesagt' : 'Early confirmation';
      case XPAction.perfectMonth:
        return isGerman ? 'Perfekter Monat' : 'Perfect month';
      case XPAction.streakBonus:
        return isGerman ? 'Streak-Bonus' : 'Streak bonus';
      case XPAction.firstTime:
        return isGerman ? 'Erste Teilnahme' : 'First participation';
      case XPAction.adminBonus:
        return isGerman ? 'Admin-Bonus' : 'Admin bonus';
    }
  }

  void _showCustomPointsDialog() {
    final l10n = context.l10n;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.locale.languageCode == 'de' ? 'Benutzerdefinierte Punkte' : 'Custom Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customPointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.locale.languageCode == 'de' ? 'Punkte' : 'Points',
                hintText: l10n.locale.languageCode == 'de' ? 'z.B. 15' : 'e.g. 15',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.locale.languageCode == 'de' ? 'Grund' : 'Reason',
                hintText: l10n.locale.languageCode == 'de' 
                    ? 'z.B. Getränkerunde spendiert' 
                    : 'e.g. Bought drinks for everyone',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.locale.languageCode == 'de' ? 'Abbrechen' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _selectedAction = null; // Clear predefined selection
              });
            },
            child: Text(l10n.locale.languageCode == 'de' ? 'OK' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _awardPoints() async {
    if (_selectedUserId == null) return;

    final l10n = context.l10n;
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final activeGroup = groupProvider.getActiveGroup(context);

    if (activeGroup == null) return;

    int points;
    String reason;

    if (_selectedAction != null) {
      points = _selectedAction!.xpReward;
      reason = _getActionTitle(_selectedAction!, l10n.locale.languageCode == 'de');
    } else {
      final customPoints = int.tryParse(_customPointsController.text);
      if (customPoints == null || customPoints <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locale.languageCode == 'de' 
                ? 'Bitte gib gültige Punkte ein' 
                : 'Please enter valid points'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_reasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locale.languageCode == 'de' 
                ? 'Bitte gib einen Grund ein' 
                : 'Please enter a reason'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      points = customPoints;
      reason = _reasonController.text.trim();
    }

    // Award points
    if (_selectedAction != null) {
      await pointsProvider.awardXP(
        _selectedUserId!,
        activeGroup.id,
        _selectedAction!,
      );
    } else {
      await pointsProvider.awardCustomXP(
        _selectedUserId!,
        activeGroup.id,
        points,
        reason: reason,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locale.languageCode == 'de' 
              ? '$points Punkte für $_selectedUserId vergeben!' 
              : '$points points awarded to $_selectedUserId!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _selectedUserId = null;
        _selectedAction = null;
        _customPointsController.clear();
        _reasonController.clear();
      });
    }
  }
}