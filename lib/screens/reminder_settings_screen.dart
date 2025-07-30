import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool remind1Day = false;
  bool remind1Hour = false;
  bool remind30Min = false;
  bool isLoading = true;
  bool _permissionsGranted = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    _permissionsGranted = await _notificationService.requestPermissions();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getNotificationSettings();
    setState(() {
      remind1Day = settings['1_day'] ?? true;
      remind1Hour = settings['1_hour'] ?? true;
      remind30Min = settings['30_min'] ?? false;
      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _notificationService.updateNotificationSettings(
      oneDayBefore: remind1Day,
      oneHourBefore: remind1Hour,
      thirtyMinBefore: remind30Min,
    );
    
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locale.languageCode == 'de'
            ? 'Erinnerungseinstellungen gespeichert!'
            : 'Reminder settings saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reminders)), // LOKALISIERT
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders), // LOKALISIERT
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: l10n.save, // LOKALISIERT
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          l10n.locale.languageCode == 'de'
                              ? 'Push-Benachrichtigungen'
                              : 'Push Notifications',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.locale.languageCode == 'de'
                          ? 'Lege fest, wann du an bevorstehende Stammtisch-Events erinnert werden möchtest.'
                          : 'Set when you want to be reminded of upcoming events.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Reminder Settings
            Text(
              l10n.locale.languageCode == 'de'
                  ? 'Erinnerungszeiten'
                  : 'Reminder Times',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.orange),
                    title: Text(l10n.locale.languageCode == 'de'
                        ? '1 Tag vorher erinnern'
                        : 'Remind 1 day before'),
                    subtitle: Text(l10n.locale.languageCode == 'de'
                        ? 'Erhalte eine Benachrichtigung 24 Stunden vor dem Event'
                        : 'Receive a notification 24 hours before the event'),
                    trailing: Switch(
                      value: remind1Day,
                      onChanged: (val) {
                        setState(() => remind1Day = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.blue),
                    title: Text(l10n.locale.languageCode == 'de'
                        ? '1 Stunde vorher erinnern'
                        : 'Remind 1 hour before'),
                    subtitle: Text(l10n.locale.languageCode == 'de'
                        ? 'Erhalte eine Benachrichtigung 1 Stunde vor dem Event'
                        : 'Receive a notification 1 hour before the event'),
                    trailing: Switch(
                      value: remind1Hour,
                      onChanged: (val) {
                        setState(() => remind1Hour = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.red),
                    title: Text(l10n.locale.languageCode == 'de'
                        ? '30 Minuten vorher erinnern'
                        : 'Remind 30 minutes before'),
                    subtitle: Text(l10n.locale.languageCode == 'de'
                        ? 'Erhalte eine Benachrichtigung 30 Minuten vor dem Event'
                        : 'Receive a notification 30 minutes before the event'),
                    trailing: Switch(
                      value: remind30Min,
                      onChanged: (val) {
                        setState(() => remind30Min = val);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Additional Settings
            Text(
              l10n.locale.languageCode == 'de'
                  ? 'Weitere Einstellungen'
                  : 'Additional Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_paused),
                    title: Text(l10n.locale.languageCode == 'de'
                        ? 'Stummschalten'
                        : 'Mute Notifications'),
                    subtitle: Text(l10n.locale.languageCode == 'de'
                        ? 'Alle Benachrichtigungen temporär deaktivieren'
                        : 'Temporarily disable all notifications'),
                    trailing: Switch(
                      value: false, // TODO: Implement mute functionality
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.locale.languageCode == 'de'
                                ? 'Stummschaltung kommt in einer späteren Version'
                                : 'Mute feature coming in a future version'),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.vibration),
                    title: Text(l10n.locale.languageCode == 'de'
                        ? 'Vibration'
                        : 'Vibration'),
                    subtitle: Text(l10n.locale.languageCode == 'de'
                        ? 'Vibrieren bei Benachrichtigungen'
                        : 'Vibrate on notifications'),
                    trailing: Switch(
                      value: true, // TODO: Implement vibration setting
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.locale.languageCode == 'de'
                                ? 'Vibrationseinstellung kommt in einer späteren Version'
                                : 'Vibration setting coming in a future version'),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: Text(l10n.locale.languageCode == 'de'
                        ? 'Benachrichtigungston'
                        : 'Notification Sound'),
                    subtitle: Text(l10n.locale.languageCode == 'de'
                        ? 'Standard'
                        : 'Default'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.locale.languageCode == 'de'
                              ? 'Tonauswahl kommt in einer späteren Version'
                              : 'Sound selection coming in a future version'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preview Card
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.preview, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          l10n.locale.languageCode == 'de'
                              ? 'Benachrichtigungsvorschau'
                              : 'Notification Preview',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.locale.languageCode == 'de'
                          ? 'Aktive Erinnerungen:'
                          : 'Active reminders:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (remind1Day || remind1Hour || remind30Min) ...[
                      if (remind1Day) 
                        Text('• ${l10n.locale.languageCode == 'de' ? '1 Tag vorher' : '1 day before'}'),
                      if (remind1Hour) 
                        Text('• ${l10n.locale.languageCode == 'de' ? '1 Stunde vorher' : '1 hour before'}'),
                      if (remind30Min) 
                        Text('• ${l10n.locale.languageCode == 'de' ? '30 Minuten vorher' : '30 minutes before'}'),
                    ] else
                      Text(
                        l10n.locale.languageCode == 'de'
                            ? 'Keine Erinnerungen aktiviert'
                            : 'No reminders enabled',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (_permissionsGranted) {
                            await _notificationService.sendTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.locale.languageCode == 'de'
                                    ? '🔔 Test-Benachrichtigung gesendet!'
                                    : '🔔 Test notification sent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.locale.languageCode == 'de'
                                    ? '❌ Benachrichtigungsberechtigungen wurden nicht erteilt'
                                    : '❌ Notification permissions not granted'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send),
                        label: Text(l10n.locale.languageCode == 'de'
                            ? 'Test-Benachrichtigung senden'
                            : 'Send Test Notification'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: Text(l10n.save), // LOKALISIERT
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Permission Status
            Card(
              color: _permissionsGranted 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _permissionsGranted ? Icons.check_circle : Icons.warning,
                      color: _permissionsGranted ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.locale.languageCode == 'de'
                            ? _permissionsGranted 
                                ? 'ℹ️ Benachrichtigungen sind aktiviert und funktionsfähig.'
                                : 'ℹ️ Benachrichtigungsberechtigungen sind erforderlich.'
                            : _permissionsGranted
                                ? 'ℹ️ Notifications are enabled and functional.'
                                : 'ℹ️ Notification permissions are required.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
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
    );
  }
}