import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/event_provider.dart';
import '../providers/group_provider.dart';
import '../providers/points_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_profile_card.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    return Consumer4<GroupProvider, EventProvider, PointsProvider, AuthProvider>(
      builder: (context, groupProvider, eventProvider, pointsProvider, authProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        final currentUserId = authProvider.currentUserId;
        
        // Check if user has any groups
        if (activeGroup == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.calendarOverview)), // LOKALISIERT
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
                    l10n.locale.languageCode == 'de'
                        ? 'Keine Gruppe ausgewählt'
                        : 'No group selected',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.locale.languageCode == 'de'
                        ? 'Wähle zuerst eine Gruppe aus um den Kalender zu sehen.'
                        : 'Please select a group first to see the calendar.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final event = eventProvider.getEventForGroup(activeGroup.id);
        final userPoints = pointsProvider.getUserPoints(currentUserId, activeGroup.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.locale.languageCode == 'de'
                ? '${activeGroup.name} - Kalender'
                : '${activeGroup.name} - Calendar'),
          ),
          body: Column(
            children: [
              // Profile Card Header (wenn XP vorhanden)
              if (userPoints != null)
                UserProfileCard(
                  groupId: activeGroup.id,
                  showDetailed: false,
                  showProgress: true,
                  heroTagSuffix: 'calendar-header', // EINDEUTIGES TAG
                ),

              // Calendar Widget
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      // Highlight event days
                      markerDecoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.red.shade300,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    eventLoader: (day) {
                      // Show marker on event days
                      if (event != null && isSameDay(day, event.date)) {
                        return [l10n.locale.languageCode == 'de' ? 'Stammtisch' : 'Event'];
                      }
                      return [];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Selected Day Info
              if (_selectedDay != null)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.selectedDay('${_selectedDay!.day}.${_selectedDay!.month}.${_selectedDay!.year}'), // LOKALISIERT
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (event != null && isSameDay(_selectedDay, event.date))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.locale.languageCode == 'de'
                                    ? '🍻 Stammtisch-Tag!'
                                    : '🍻 Event Day!',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                event.isConfirmed 
                                    ? (l10n.locale.languageCode == 'de' ? '✅ Findet statt' : '✅ Confirmed')
                                    : (l10n.locale.languageCode == 'de' ? '❌ Nicht bestätigt' : '❌ Not confirmed'),
                                style: TextStyle(
                                  color: event.isConfirmed ? Colors.green : Colors.red,
                                ),
                              ),
                              Text(l10n.participantCount(event.yesCount)), // LOKALISIERT
                            ],
                          )
                        else
                          Text(
                            l10n.noEventToday, // LOKALISIERT
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Events List with Stats
              Expanded(
                child: Row(
                  children: [
                    // Events List (2/3 der Breite)
                    Expanded(
                      flex: 2,
                      child: Card(
                        margin: const EdgeInsets.only(left: 16, right: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.plannedEvents, // LOKALISIERT
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: event != null
                                    ? ListView(
                                        children: [
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: event.isConfirmed 
                                                  ? Colors.green 
                                                  : Colors.red,
                                              child: const Icon(
                                                Icons.event,
                                                color: Colors.white,
                                              ),
                                            ),
                                            title: Text(l10n.locale.languageCode == 'de' 
                                                ? "Stammtisch" 
                                                : "Event"),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${event.date.day}.${event.date.month}.${event.date.year}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  event.isConfirmed 
                                                      ? l10n.locale.languageCode == 'de'
                                                          ? "✅ Findet statt (${event.yesCount}/4 Zusagen)" 
                                                          : "✅ Confirmed (${event.yesCount}/4 confirmations)"
                                                      : l10n.locale.languageCode == 'de'
                                                          ? "❌ Nicht bestätigt (${event.yesCount}/4 Zusagen)"
                                                          : "❌ Not confirmed (${event.yesCount}/4 confirmations)",
                                                ),
                                                Text(
                                                  _getRelativeTime(event.date),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.info_outline),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Go back to event screen
                                              },
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedDay = event.date;
                                                _focusedDay = event.date;
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.event_busy,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              l10n.locale.languageCode == 'de'
                                                  ? "Kein Event vorhanden"
                                                  : "No event available",
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              l10n.locale.languageCode == 'de'
                                                  ? "Events werden automatisch am ersten Dienstag des Monats erstellt."
                                                  : "Events are automatically created on the first Tuesday of the month.",
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              textAlign: TextAlign.center,
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
                    
                    // User Stats Sidebar (1/3 der Breite) - nur wenn XP vorhanden
                    if (userPoints != null)
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.only(left: 8, right: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.locale.languageCode == 'de' 
                                      ? "Deine Stats"
                                      : "Your Stats",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Detailed Profile Card
                                UserProfileCard(
                                  groupId: activeGroup.id,
                                  showDetailed: true,
                                  showProgress: true,
                                  heroTagSuffix: 'calendar-sidebar', // EINDEUTIGES TAG
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Quick Stats
                                _buildStatRow('🗓️', 
                                    l10n.locale.languageCode == 'de' ? 'Nächstes Event' : 'Next Event', 
                                    event != null 
                                      ? '${event.date.day}.${event.date.month}'
                                      : (l10n.locale.languageCode == 'de' ? 'Keins' : 'None')),
                                const SizedBox(height: 8),
                                _buildStatRow('👥', 
                                    l10n.locale.languageCode == 'de' ? 'Zusagen' : 'Confirmations', 
                                    event != null 
                                      ? '${event.yesCount}/4'
                                      : '-'),
                                const SizedBox(height: 8),
                                _buildStatRow('🎯', 
                                    l10n.locale.languageCode == 'de' ? 'Status' : 'Status', 
                                    event != null && event.isConfirmed
                                      ? (l10n.locale.languageCode == 'de' ? 'Bestätigt' : 'Confirmed')
                                      : (l10n.locale.languageCode == 'de' ? 'Offen' : 'Open')),
                                
                                const SizedBox(height: 16),
                                
                                // Monthly Overview
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.locale.languageCode == 'de'
                                            ? 'Diesen Monat'
                                            : 'This Month',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(l10n.locale.languageCode == 'de'
                                          ? 'Level ${userPoints.currentLevel} erreicht'
                                          : 'Reached Level ${userPoints.currentLevel}'),
                                      Text(l10n.locale.languageCode == 'de'
                                          ? '${userPoints.totalXP} XP gesammelt'
                                          : '${userPoints.totalXP} XP collected'),
                                      if (userPoints.streakCount > 0)
                                        Text('🔥 ${userPoints.streakCount} ${l10n.streak}'), // LOKALISIERT
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getRelativeTime(DateTime eventDate) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final difference = eventDate.difference(now);
    
    if (difference.isNegative) {
      final daysPast = difference.inDays.abs();
      if (daysPast == 0) {
        return l10n.today; // LOKALISIERT
      } else if (daysPast == 1) {
        return l10n.yesterday; // LOKALISIERT
      } else {
        return l10n.daysAgo(daysPast); // LOKALISIERT
      }
    } else {
      final daysUntil = difference.inDays;
      if (daysUntil == 0) {
        return l10n.today; // LOKALISIERT
      } else if (daysUntil == 1) {
        return l10n.tomorrow; // LOKALISIERT
      } else if (daysUntil < 7) {
        return l10n.inDays(daysUntil); // LOKALISIERT
      } else if (daysUntil < 30) {
        final weeks = (daysUntil / 7).floor();
        return l10n.locale.languageCode == 'de'
            ? 'In $weeks ${weeks == 1 ? 'Woche' : 'Wochen'}'
            : 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
      } else {
        final months = (daysUntil / 30).floor();
        return l10n.locale.languageCode == 'de'
            ? 'In $months ${months == 1 ? 'Monat' : 'Monaten'}'
            : 'In $months ${months == 1 ? 'month' : 'months'}';
      }
    }
  }
}