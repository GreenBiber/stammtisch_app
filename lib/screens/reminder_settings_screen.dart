import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/notification_provider.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final List<int> _reminderTimeOptions = [1, 2, 6, 12, 24, 48]; // hours
  final List<int> _dailyTimeOptions = [8, 10, 12, 14, 16, 18, 20]; // hours

  @override
  void initState() {
    super.initState();
  }

  String _formatReminderTime(int hours) {
    final l10n = AppLocalizations.of(context)!;
    if (hours == 1) {
      return l10n.oneHourBefore;
    } else if (hours < 24) {
      return l10n.hoursBeforeEvent(hours);
    } else {
      final days = hours ~/ 24;
      return days == 1 ? l10n.oneDayBefore : l10n.daysBeforeEvent(days);
    }
  }

  String _formatDailyTime(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer3<AuthProvider, GroupProvider, NotificationProvider>(
      builder: (context, authProvider, groupProvider, notificationProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        final currentUser = authProvider.currentUser;
        
        if (activeGroup == null || currentUser == null) {
          return Center(
            child: Text(l10n.noGroupSelected),
          );
        }

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.reminderSettings,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.reminderDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Event Reminders Section
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.eventReminders),
                      subtitle: Text(l10n.eventRemindersDescription),
                      value: notificationProvider.eventReminders,
                      onChanged: (bool value) {
                        notificationProvider.toggleEventReminders(value);
                      },
                      secondary: const Icon(Icons.event),
                    ),
                    
                    if (notificationProvider.eventReminders) ...[
                      const Divider(height: 1),
                      ListTile(
                        title: Text(l10n.reminderTiming),
                        subtitle: Text(_formatReminderTime(notificationProvider.eventReminderTime)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _showReminderTimeDialog(notificationProvider),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Chat Notifications Section
              Card(
                child: SwitchListTile(
                  title: Text(l10n.chatNotifications),
                  subtitle: Text(l10n.chatNotificationsDescription),
                  value: notificationProvider.chatNotifications,
                  onChanged: (bool value) {
                    notificationProvider.toggleChatNotifications(value);
                  },
                  secondary: const Icon(Icons.chat),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Weekly Digest Section
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.weeklyDigest),
                      subtitle: Text(l10n.weeklyDigestDescription),
                      value: notificationProvider.weeklyDigest,
                      onChanged: (bool value) {
                        notificationProvider.toggleWeeklyDigest(value);
                      },
                      secondary: const Icon(Icons.email),
                    ),
                    
                    if (notificationProvider.weeklyDigest) ...[
                      const Divider(height: 1),
                      ListTile(
                        title: Text(l10n.digestTime),
                        subtitle: Text('${l10n.sundayAt} ${_formatDailyTime(notificationProvider.dailyReminderTime)}'),
                        trailing: const Icon(Icons.schedule),
                        onTap: () => _showDailyTimeDialog(notificationProvider),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Test Notification Button
              Card(
                child: ListTile(
                  title: Text(l10n.testNotification),
                  subtitle: Text(l10n.testNotificationDescription),
                  leading: const Icon(Icons.notifications_outlined),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => notificationProvider.sendTestNotification(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Section
              Card(
                color: Colors.blue.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.notificationInfo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.notificationInfoDescription,
                        style: TextStyle(
                          color: Colors.blue.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReminderTimeDialog(NotificationProvider notificationProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectReminderTime),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reminderTimeOptions.map((hours) {
            return RadioListTile<int>(
              title: Text(_formatReminderTime(hours)),
              value: hours,
              groupValue: notificationProvider.eventReminderTime,
              onChanged: (int? value) {
                if (value != null) {
                  notificationProvider.setEventReminderTime(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showDailyTimeDialog(NotificationProvider notificationProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectDigestTime),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _dailyTimeOptions.map((hour) {
            return RadioListTile<int>(
              title: Text(_formatDailyTime(hour)),
              value: hour,
              groupValue: notificationProvider.dailyReminderTime,
              onChanged: (int? value) {
                if (value != null) {
                  notificationProvider.setDailyReminderTime(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

}