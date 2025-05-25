import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'calendar_screen.dart';
import 'event_screen.dart';
import 'restaurant_suggestions_screen.dart';
import 'reminder_settings_screen.dart';

class GroupTabScreen extends StatefulWidget {
  const GroupTabScreen({super.key});

  @override
  State<GroupTabScreen> createState() => _GroupTabScreenState();
}

class _GroupTabScreenState extends State<GroupTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(icon: Icon(Icons.chat), text: 'Chat'),
    Tab(icon: Icon(Icons.event), text: 'Event'),
    Tab(icon: Icon(Icons.calendar_today), text: 'Kalender'),
    Tab(icon: Icon(Icons.restaurant), text: 'Vorschläge'),
    Tab(icon: Icon(Icons.notifications_active), text: 'Erinnerung'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stammtisch-Gruppe'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChatScreen(),
          EventScreen(),
          CalendarScreen(),
          RestaurantSuggestionsScreen(),
          ReminderSettingsScreen(),
        ],
      ),
    );
  }
}
