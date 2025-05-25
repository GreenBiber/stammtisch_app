import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool remind1Day = false;
  bool remind1Hour = false;
  bool remind30Min = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      remind1Day = prefs.getBool('remind1Day') ?? false;
      remind1Hour = prefs.getBool('remind1Hour') ?? false;
      remind30Min = prefs.getBool('remind30Min') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remind1Day', remind1Day);
    await prefs.setBool('remind1Hour', remind1Hour);
    await prefs.setBool('remind30Min', remind30Min);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erinnerungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('1 Tag vorher erinnern'),
            value: remind1Day,
            onChanged: (val) {
              setState(() => remind1Day = val);
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('1 Stunde vorher erinnern'),
            value: remind1Hour,
            onChanged: (val) {
              setState(() => remind1Hour = val);
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('30 Minuten vorher erinnern'),
            value: remind30Min,
            onChanged: (val) {
              setState(() => remind30Min = val);
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
