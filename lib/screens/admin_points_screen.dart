import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/points_provider.dart';
import '../models/points.dart';
import '../l10n/app_localizations.dart';

class AdminPointsScreen extends StatefulWidget {
  const AdminPointsScreen({super.key});

  @override
  State<AdminPointsScreen> createState() => _AdminPointsScreenState();
}

class _AdminPointsScreenState extends State<AdminPointsScreen> {
  String? _selectedUserId;
  XPAction? _selectedAction;
  int _customPoints = 0;
  String _customReason = '';
  final _reasonController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer3<AuthProvider, GroupProvider, PointsProvider>(
      builder: (context, authProvider, groupProvider, pointsProvider, child) {
        final user = authProvider.currentUser;
        final group = groupProvider.getActiveGroup(context);

        if (user == null || group == null) {
          return Scaffold(
            appBar:
                AppBar(title: Text(l10n?.adminPointsTitle ?? 'Admin Punkte')),
            body: Center(
                child:
                    Text(l10n?.noGroupSelected ?? 'Keine Gruppe ausgewählt')),
          );
        }

        if (!group.isAdmin(user.id)) {
          return Scaffold(
            appBar:
                AppBar(title: Text(l10n?.adminPointsTitle ?? 'Admin Punkte')),
            body: Center(
                child: Text(
                    l10n?.adminRightsRequired ?? 'Admin-Rechte erforderlich')),
          );
        }

        final members =
            group.members.where((memberId) => memberId != user.id).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n?.adminPointsTitle ?? 'Punkte vergeben'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(l10n),
                const SizedBox(height: 20),
                _buildUserSelection(members, groupProvider, l10n),
                const SizedBox(height: 20),
                _buildActionSelection(l10n),
                const SizedBox(height: 20),
                _buildCustomPointsSection(l10n),
                const SizedBox(height: 30),
                _buildAwardButton(pointsProvider, l10n),
                const SizedBox(height: 30),
                _buildRecentAwards(pointsProvider, groupProvider, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 32),
            const SizedBox(height: 8),
            Text(
              l10n?.adminPointsInfo ??
                  'Als Admin kannst du Mitgliedern Punkte für besondere Leistungen vergeben.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSelection(List<String> members, GroupProvider groupProvider,
      AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.selectUser ?? 'Benutzer auswählen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...members.map((memberId) {
              final user = groupProvider.getUserById(memberId);
              return RadioListTile<String>(
                title: Text(user?.displayName ?? 'Unbekannt'),
                subtitle: Text('@${user?.email ?? ''}'),
                value: memberId,
                groupValue: _selectedUserId,
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSelection(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.selectAction ?? 'Aktion auswählen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...XPAction.values.map((action) {
              if (action == XPAction.custom) return const SizedBox.shrink();

              return RadioListTile<XPAction>(
                title: Text(_getActionName(action, l10n)),
                subtitle: Text('${action.points} ${l10n?.points ?? 'Punkte'}'),
                value: action,
                groupValue: _selectedAction,
                onChanged: (value) {
                  setState(() {
                    _selectedAction = value;
                    _customPoints = 0;
                    _customReason = '';
                    _reasonController.clear();
                    _pointsController.clear();
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPointsSection(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<XPAction>(
                  value: XPAction.custom,
                  groupValue: _selectedAction,
                  onChanged: (value) {
                    setState(() {
                      _selectedAction = value;
                    });
                  },
                ),
                Text(
                  l10n?.customPoints ?? 'Benutzerdefinierte Punkte',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (_selectedAction == XPAction.custom) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n?.pointsAmount ?? 'Anzahl Punkte',
                  hintText: '1-50',
                ),
                onChanged: (value) {
                  setState(() {
                    _customPoints = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: l10n?.reason ?? 'Grund',
                  hintText:
                      l10n?.reasonHint ?? 'Warum werden diese Punkte vergeben?',
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    _customReason = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAwardButton(
      PointsProvider pointsProvider, AppLocalizations? l10n) {
    final canAward = _selectedUserId != null &&
        ((_selectedAction != null && _selectedAction != XPAction.custom) ||
            (_selectedAction == XPAction.custom &&
                _customPoints > 0 &&
                _customReason.trim().isNotEmpty));

    return ElevatedButton.icon(
      onPressed: canAward ? () => _awardPoints(pointsProvider, l10n) : null,
      icon: const Icon(Icons.star),
      label: Text(l10n?.awardPoints ?? 'Punkte vergeben'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildRecentAwards(PointsProvider pointsProvider,
      GroupProvider groupProvider, AppLocalizations? l10n) {
    // This would show recent manual point awards by admins
    // For now, just show a placeholder
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.recentAwards ?? 'Kürzliche Vergaben',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.noRecentAwards ?? 'Noch keine manuellen Punktevergaben.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _awardPoints(PointsProvider pointsProvider, AppLocalizations? l10n) {
    if (_selectedUserId == null) return;

    final points = _selectedAction == XPAction.custom
        ? _customPoints
        : (_selectedAction?.points ?? 0);
    final reason = _selectedAction == XPAction.custom
        ? _customReason
        : _getActionName(_selectedAction!, l10n);

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.getActiveGroup(context);
    if (group != null) {
      if (_selectedAction == XPAction.custom) {
        pointsProvider.awardXP(
          _selectedUserId!,
          group.id,
          XPAction.custom,
          customXP: points,
          customDescription: _customReason,
        );
      } else {
        pointsProvider.awardXP(_selectedUserId!, group.id, _selectedAction!);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${l10n?.pointsAwarded ?? 'Punkte vergeben'}: $points für $reason'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset form
    setState(() {
      _selectedUserId = null;
      _selectedAction = null;
      _customPoints = 0;
      _customReason = '';
      _reasonController.clear();
      _pointsController.clear();
    });
  }

  String _getActionName(XPAction action, AppLocalizations? l10n) {
    switch (action) {
      case XPAction.attendEvent:
        return l10n?.xpEventParticipation ?? 'Stammtisch besucht';
      case XPAction.organizeEvent:
        return l10n?.xpEventOrganizing ?? 'Event organisiert';
      case XPAction.earlyConfirmation:
        return l10n?.xpFirstToConfirm ?? 'Früh zugesagt';
      case XPAction.streakBonus:
        return l10n?.xpStreakMilestone ?? 'Streak-Bonus';
      case XPAction.suggestRestaurant:
        return l10n?.xpRestaurantSuggestion ?? 'Restaurant vorgeschlagen';
      case XPAction.buyRound:
        return l10n?.xpBuyRound ?? 'Getränkerunde spendiert';
      case XPAction.perfectMonth:
        return l10n?.xpPerfectMonth ?? 'Perfekter Monat';
      case XPAction.firstTime:
        return l10n?.xpFirstTime ?? 'Erste Teilnahme';
      case XPAction.adminBonus:
        return l10n?.xpAdminBonus ?? 'Admin-Bonus';
      case XPAction.custom:
        return l10n?.xpCustom ?? 'Benutzerdefiniert';
    }
  }
}
