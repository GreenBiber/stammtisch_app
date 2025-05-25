import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/group_provider.dart';


class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupId = Provider.of<GroupProvider>(context).activeGroup.id;
    final eventProvider = Provider.of<EventProvider>(context);
    final event = eventProvider.getEventForGroup(groupId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stammtisch')),
        body: const Center(child: Text('Kein Termin vorhanden')),
      );
    }

    final dateStr = "${event.date.day}.${event.date.month}.${event.date.year}";
    final status = event.isConfirmed
        ? "✅ Findet statt"
        : "❌ Abgesagt (zu wenige Zusagen)";

    Map<String, String> participation = event.participation;
    final yes = participation.entries.where((e) => e.value == 'yes').toList();
    final maybe = participation.entries.where((e) => e.value == 'maybe').toList();
    final no = participation.entries.where((e) => e.value == 'no').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nächster Stammtisch')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📅 Termin: $dateStr", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(status, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 30),
              const Text("Teilnehmen?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => eventProvider.setParticipation(groupId, 'me', 'yes'),
                    child: const Text('Ja'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => eventProvider.setParticipation(groupId, 'me', 'maybe'),
                    child: const Text('Vielleicht'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => eventProvider.setParticipation(groupId, 'me', 'no'),
                    child: const Text('Nein'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Zugesagt: ${event.yesCount} / 4"),
              const SizedBox(height: 30),
              const Divider(),
              const Text("🧑‍🤝‍🧑 Teilnehmerübersicht", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (yes.isNotEmpty) Text("✔️ Zugesagt:"),
              ...yes.map((e) => Text("- ${e.key}")),
              if (maybe.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("❔ Vielleicht:"),
                ...maybe.map((e) => Text("- ${e.key}")),
              ],
              if (no.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("❌ Abgesagt:"),
                ...no.map((e) => Text("- ${e.key}")),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
