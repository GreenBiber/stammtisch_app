import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncStatusIndicator extends StatefulWidget {
  final bool showLabel;
  final double? iconSize;
  
  const SyncStatusIndicator({
    super.key,
    this.showLabel = false,
    this.iconSize = 20,
  });

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  final SyncService _syncService = SyncService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _syncService.statusStream,
      initialData: _syncService.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.offline;
        
        // Control animation based on sync status
        if (status == SyncStatus.syncing) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(status),
            if (widget.showLabel) ...[
              const SizedBox(width: 4),
              Text(
                _getStatusLabel(status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    if (status == SyncStatus.syncing) {
      return RotationTransition(
        turns: _animation,
        child: Icon(
          icon,
          size: widget.iconSize,
          color: color,
        ),
      );
    }

    return Icon(
      icon,
      size: widget.iconSize,
      color: color,
    );
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.online:
        return Icons.cloud_done;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.error:
        return Icons.cloud_off;
    }
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.online:
        return Colors.green;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  String _getStatusLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.online:
        return 'Online';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Error';
    }
  }
}

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = SyncService();

    return StreamBuilder<SyncStatus>(
      stream: syncService.statusStream,
      initialData: syncService.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.offline;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SyncStatusIndicator(showLabel: false, iconSize: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Sync Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      _getStatusDescription(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusDetailText(status),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (status == SyncStatus.offline || status == SyncStatus.error) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await syncService.forceSyncToCloud();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sync completed successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sync failed: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.sync, size: 16),
                          label: const Text('Retry Sync'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await syncService.clearPendingOperations();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pending sync operations cleared'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.online:
        return Colors.green;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  String _getStatusDescription(SyncStatus status) {
    switch (status) {
      case SyncStatus.online:
        return 'Connected';
      case SyncStatus.offline:
        return 'Offline Mode';
      case SyncStatus.syncing:
        return 'Synchronizing';
      case SyncStatus.error:
        return 'Connection Error';
    }
  }

  String _getStatusDetailText(SyncStatus status) {
    switch (status) {
      case SyncStatus.online:
        return 'All data is synced with the cloud. Changes are automatically saved online.';
      case SyncStatus.offline:
        return 'Working offline. Your changes are saved locally and will sync when connection is restored.';
      case SyncStatus.syncing:
        return 'Synchronizing your local changes with the cloud...';
      case SyncStatus.error:
        return 'Unable to connect to cloud services. Check your internet connection.';
    }
  }
}