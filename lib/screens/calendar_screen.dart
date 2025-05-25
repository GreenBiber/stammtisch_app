import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/event_provider.dart';
import '../providers/group_provider.dart';

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
    final groupId = Provider.of<GroupProvider>(context).activeGroup.id;
    final event = Provider.of<EventProvider>(context).getEventForGroup(groupId);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalenderübersicht')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Geplante Events",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (event != null)
            ListTile(
              leading: const Icon(Icons.event),
              title: Text("Stammtisch"),
              subtitle: Text(
                "${event.date.day}.${event.date.month}.${event.date.year} – ${event.isConfirmed ? "✅ findet statt" : "❌ nicht bestätigt"}",
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Kein Event vorhanden"),
            ),
        ],
      ),
    );
  }
}
