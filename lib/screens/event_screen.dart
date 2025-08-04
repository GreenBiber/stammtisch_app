import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/points_provider.dart';
import '../widgets/xp_animation.dart';
import '../widgets/user_profile_card.dart';
import '../models/points.dart';
import '../l10n/l10n.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final GlobalKey<XPAnimationOverlayState> _overlayKey = GlobalKey();
  bool _isProcessingXP = false;

  @override
  Widget build(BuildContext context) {
    // Lokalisierung
    final l10n = AppLocalizations.of(context)!;

    return Consumer4<GroupProvider, EventProvider, AuthProvider,
        PointsProvider>(
      builder: (context, groupProvider, eventProvider, authProvider,
          pointsProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        final currentUserId = authProvider.currentUserId;

        // Check if user has any groups
        if (activeGroup == null) {
          return Scaffold(
            appBar:
                AppBar(title: Text(context.isGerman ? 'Stammtisch' : 'Event')),
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
                    context.isGerman
                        ? 'Keine Gruppe ausgewählt'
                        : 'No group selected',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.isGerman
                        ? 'Wähle zuerst eine Gruppe aus oder erstelle eine neue.'
                        : 'First select a group or create a new one.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final event = eventProvider.getEventForGroup(activeGroup.id);

        if (event == null) {
          return Scaffold(
            appBar:
                AppBar(title: Text(context.isGerman ? 'Stammtisch' : 'Event')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.isGerman
                        ? 'Kein Termin vorhanden'
                        : 'No event available',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.isGerman
                        ? 'Für die Gruppe "${activeGroup.name}" wurde noch kein Event erstellt.'
                        : 'No event has been created for group "${activeGroup.name}" yet.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await eventProvider.generateEventForGroup(activeGroup.id);
                    },
                    icon: const Icon(Icons.add_circle),
                    label: Text(
                        context.isGerman ? 'Event erstellen' : 'Create Event'),
                  ),
                ],
              ),
            ),
          );
        }

        final dateStr =
            "${event.date.day}.${event.date.month}.${event.date.year}";
        final status = event.isConfirmed
            ? (context.isGerman ? "✅ Findet statt" : "✅ Confirmed")
            : (context.isGerman
                ? "❌ Abgesagt (zu wenige Zusagen)"
                : "❌ Cancelled (not enough participants)");

        // Get current user's participation status
        final userParticipation = event.participation[currentUserId];
        final userPoints =
            pointsProvider.getUserPoints(currentUserId, activeGroup.id);

        // Separate participants by response
        final participants = event.participation.entries.toList();
        final yes = participants.where((e) => e.value == 'yes').toList();
        final maybe = participants.where((e) => e.value == 'maybe').toList();
        final no = participants.where((e) => e.value == 'no').toList();

        return XPAnimationOverlay(
          key: _overlayKey,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.isGerman
                  ? '${activeGroup.name} - Stammtisch'
                  : '${activeGroup.name} - Event'),
              actions: [
                // User Profile Mini-Card
                if (userPoints != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getLevelColor(userPoints.currentLevel)
                              .withOpacity(0.2),
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
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Card (wenn XP vorhanden)
                    if (userPoints != null)
                      UserProfileCard(
                        groupId: activeGroup.id,
                        showDetailed: false,
                        heroTagSuffix: 'event',
                      ),

                    const SizedBox(height: 16),

                    // Event Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: event.isConfirmed
                                      ? Colors.green
                                      : Colors.red,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "📅 $dateStr",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: event.isConfirmed
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Progress Indicator für Mindestanzahl
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.isGerman
                                        ? "Zusagen: ${event.yesCount} / 4"
                                        : "Confirmations: ${event.yesCount} / 4"),
                                    Text(
                                      "${((event.yesCount / 4) * 100).toInt()}%",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (event.yesCount / 4).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    event.isConfirmed
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  minHeight: 8,
                                ),
                              ],
                            ),

                            if (userParticipation != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      _getParticipationColor(userParticipation)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getParticipationColor(
                                        userParticipation),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getParticipationIcon(userParticipation),
                                      color: _getParticipationColor(
                                          userParticipation),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.isGerman
                                          ? "Deine Antwort: ${_getParticipationText(userParticipation)}"
                                          : "Your response: ${_getParticipationText(userParticipation)}",
                                      style: TextStyle(
                                        color: _getParticipationColor(
                                            userParticipation),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Participation Buttons
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.participate, // LOKALISIERT
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),

                            // XP Info Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.isGerman
                                              ? 'XP-Belohnungen'
                                              : 'XP Rewards',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          context.isGerman
                                              ? '🍺 Zusage: +${XPAction.attendEvent.baseXP} XP  |  ⚡ Früh dran: +${XPAction.earlyConfirmation.baseXP} XP'
                                              : '🍺 Confirm: +${XPAction.attendEvent.baseXP} XP  |  ⚡ Early: +${XPAction.earlyConfirmation.baseXP} XP',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isProcessingXP
                                        ? null
                                        : () => _setParticipation(
                                              'yes',
                                              eventProvider,
                                              pointsProvider,
                                              activeGroup.id,
                                              currentUserId,
                                              event.date,
                                            ),
                                    icon: _isProcessingXP
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.check),
                                    label: Text(l10n.yes), // LOKALISIERT
                                    style: userParticipation == 'yes'
                                        ? ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.green),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.white),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isProcessingXP
                                        ? null
                                        : () => _setParticipation(
                                              'maybe',
                                              eventProvider,
                                              pointsProvider,
                                              activeGroup.id,
                                              currentUserId,
                                              event.date,
                                            ),
                                    icon: const Icon(Icons.help),
                                    label: Text(l10n.maybe), // LOKALISIERT
                                    style: userParticipation == 'maybe'
                                        ? ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.orange),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.white),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isProcessingXP
                                        ? null
                                        : () => _setParticipation(
                                              'no',
                                              eventProvider,
                                              pointsProvider,
                                              activeGroup.id,
                                              currentUserId,
                                              event.date,
                                            ),
                                    icon: const Icon(Icons.close),
                                    label: Text(l10n.no), // LOKALISIERT
                                    style: userParticipation == 'no'
                                        ? ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.red),
                                            foregroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.white),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Participants Overview
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isGerman
                                  ? "🧑‍🤝‍🧑 Teilnehmerübersicht"
                                  : "🧑‍🤝‍🧑 Participants Overview",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            if (yes.isNotEmpty) ...[
                              _buildParticipantSection(
                                context.isGerman
                                    ? "✔️ Zugesagt (${yes.length}):"
                                    : "✔️ Confirmed (${yes.length}):",
                                yes,
                                Colors.green,
                                pointsProvider,
                                activeGroup.id,
                              ),
                              if (maybe.isNotEmpty || no.isNotEmpty)
                                const SizedBox(height: 12),
                            ],
                            if (maybe.isNotEmpty) ...[
                              _buildParticipantSection(
                                context.isGerman
                                    ? "❔ Vielleicht (${maybe.length}):"
                                    : "❔ Maybe (${maybe.length}):",
                                maybe,
                                Colors.orange,
                                pointsProvider,
                                activeGroup.id,
                              ),
                              if (no.isNotEmpty) const SizedBox(height: 12),
                            ],
                            if (no.isNotEmpty) ...[
                              _buildParticipantSection(
                                context.isGerman
                                    ? "❌ Abgesagt (${no.length}):"
                                    : "❌ Declined (${no.length}):",
                                no,
                                Colors.red,
                                pointsProvider,
                                activeGroup.id,
                              ),
                            ],
                            if (participants.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    context.isGerman
                                        ? "Noch keine Antworten erhalten.\nSei der Erste und sammle Bonus-XP! 🌟"
                                        : "No responses received yet.\nBe the first and earn bonus XP! 🌟",
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipantSection(
    String title,
    List<MapEntry<String, String>> participants,
    Color color,
    PointsProvider pointsProvider,
    String groupId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...participants.map((participant) {
          final userPoints =
              pointsProvider.getUserPoints(participant.key, groupId);
          final isCurrentUser = participant.key ==
              Provider.of<AuthProvider>(context, listen: false).currentUserId;

          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              children: [
                if (userPoints != null) ...[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getLevelColor(userPoints.currentLevel),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${userPoints.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userPoints.levelIcon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    isCurrentUser
                        ? (context.isGerman ? 'Du' : 'You')
                        : _getUserDisplayName(participant.key),
                    style: TextStyle(
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (userPoints != null)
                  Text(
                    '${userPoints.totalXP} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _setParticipation(
    String choice,
    EventProvider eventProvider,
    PointsProvider pointsProvider,
    String groupId,
    String userId,
    DateTime eventDate,
  ) async {
    if (_isProcessingXP) return;

    setState(() {
      _isProcessingXP = true;
    });

    try {
      // Setze Teilnahme
      await eventProvider.setParticipation(groupId, userId, choice);

      // Vergib XP bei Zusage
      if (choice == 'yes') {
        final events =
            await pointsProvider.awardXP(userId, groupId, XPAction.attendEvent);

        // Prüfe ob früh zugesagt (mehr als 7 Tage vor Event)
        final daysUntilEvent = eventDate.difference(DateTime.now()).inDays;
        if (daysUntilEvent >= 7) {
          final earlyEvents = await pointsProvider.awardXP(
              userId, groupId, XPAction.earlyConfirmation);
          events.addAll(earlyEvents);
        }

        // Zeige Animationen
        _showXPAnimations(events, pointsProvider, userId, groupId);
      }

      // Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getParticipationFeedback(choice)),
            backgroundColor: _getParticipationColor(choice),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.isGerman ? 'Fehler: $e' : 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingXP = false;
      });
    }
  }

  void _showXPAnimations(
    List<String> events,
    PointsProvider pointsProvider,
    String userId,
    String groupId,
  ) {
    // Lokalisierung bereits über Build Context verfügbar

    if (events.contains('xp_gained')) {
      _overlayKey.currentState?.showXPGain(context.isGerman
          ? '🍺 +${XPAction.attendEvent.baseXP} XP - Teilnahme bestätigt!'
          : '🍺 +${XPAction.attendEvent.baseXP} XP - Participation confirmed!');
    }

    if (events.contains('level_up')) {
      final userPoints = pointsProvider.getUserPoints(userId, groupId);
      if (userPoints != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _overlayKey.currentState
              ?.showLevelUp(userPoints.currentLevel, userPoints.levelTitle);
        });
      }
    }

    if (events.contains('achievement_unlocked')) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _overlayKey.currentState?.showAchievementUnlock(
              context.isGerman ? 'Neues Achievement!' : 'New Achievement!',
              '🏆',
              context.isGerman
                  ? 'Du hast ein Achievement freigeschaltet!'
                  : 'You unlocked an achievement!');
        }
      });
    }
  }

  String _getParticipationText(String participation) {
    switch (participation) {
      case 'yes':
        return context.isGerman ? 'Zugesagt ✅' : 'Confirmed ✅';
      case 'maybe':
        return context.isGerman ? 'Vielleicht ❔' : 'Maybe ❔';
      case 'no':
        return context.isGerman ? 'Abgesagt ❌' : 'Declined ❌';
      default:
        return context.isGerman ? 'Unbekannt' : 'Unknown';
    }
  }

  String _getParticipationFeedback(String participation) {
    switch (participation) {
      case 'yes':
        return context.isGerman
            ? 'Super! Du bist dabei! 🍺 (+${XPAction.attendEvent.baseXP} XP)'
            : 'Great! You\'re in! 🍺 (+${XPAction.attendEvent.baseXP} XP)';
      case 'maybe':
        return context.isGerman
            ? 'Okay, lass uns wissen wenn du dich entscheidest!'
            : 'Okay, let us know when you decide!';
      case 'no':
        return context.isGerman
            ? 'Schade! Vielleicht beim nächsten Mal.'
            : 'Too bad! Maybe next time.';
      default:
        return context.isGerman ? 'Antwort gespeichert.' : 'Response saved.';
    }
  }

  Color _getParticipationColor(String participation) {
    switch (participation) {
      case 'yes':
        return Colors.green;
      case 'maybe':
        return Colors.orange;
      case 'no':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getParticipationIcon(String participation) {
    switch (participation) {
      case 'yes':
        return Icons.check_circle;
      case 'maybe':
        return Icons.help;
      case 'no':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
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

  String _getUserDisplayName(String userId) {
    // TODO: In einer späteren Version sollten wir hier echte Benutzernamen anzeigen
    if (userId.length > 10) {
      return '${userId.substring(0, 10)}...';
    }
    return userId;
  }
}
