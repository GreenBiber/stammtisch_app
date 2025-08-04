import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';
import 'location_permission_dialog.dart';

class LocationSettingsTile extends StatefulWidget {
  final VoidCallback? onPermissionChanged;

  const LocationSettingsTile({
    super.key,
    this.onPermissionChanged,
  });

  @override
  State<LocationSettingsTile> createState() => _LocationSettingsTileState();
}

class _LocationSettingsTileState extends State<LocationSettingsTile> {
  LocationPermissionState _permissionState = LocationPermissionState.notAsked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionState();
  }

  Future<void> _checkPermissionState() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      final state = await LocationService().getPermissionState();
      if (mounted) {
        setState(() {
          _permissionState = state;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _permissionState = LocationPermissionState.systemDenied;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLocationPermission() async {
    final l10n = AppLocalizations.of(context)!;

    if (_permissionState == LocationPermissionState.notAsked ||
        _permissionState == LocationPermissionState.userDenied) {
      // Show permission dialog
      await LocationPermissionDialog.show(
        context,
        onPermissionGranted: () async {
          await _checkPermissionState();
          widget.onPermissionChanged?.call();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.allowLocation),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onPermissionDenied: () async {
          await _checkPermissionState();
          widget.onPermissionChanged?.call();
        },
      );
    } else if (_permissionState == LocationPermissionState.granted) {
      // Allow user to revoke consent
      await _showRevokeDialog();
    } else if (_permissionState == LocationPermissionState.systemDenied) {
      // Show settings dialog
      await _showSettingsDialog();
    }
  }

  Future<void> _showRevokeDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.locationPermissionTitle),
        content: Text(l10n.locationPermissionDenied),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(l10n.deny),
          ),
        ],
      ),
    );

    if (result == true) {
      await LocationService().setUserConsent(false);
      await _checkPermissionState();
      widget.onPermissionChanged?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationPermissionDenied),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _showSettingsDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.locationServicesDisabled),
        content: Text(l10n.locationPermissionPermanentlyDenied),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Note: Opening device settings is platform-specific
              // Would need platform-specific implementation
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  String _getPermissionStateText() {
    final l10n = AppLocalizations.of(context)!;
    
    switch (_permissionState) {
      case LocationPermissionState.granted:
        return l10n.allowLocation;
      case LocationPermissionState.notAsked:
      case LocationPermissionState.userDenied:
        return l10n.locationPermissionDenied;
      case LocationPermissionState.systemDenied:
        return l10n.locationPermissionPermanentlyDenied;
      case LocationPermissionState.disabled:
        return l10n.locationServicesDisabled;
      case LocationPermissionState.userGranted:
        return l10n.allowLocation;
    }
  }

  IconData _getPermissionStateIcon() {
    switch (_permissionState) {
      case LocationPermissionState.granted:
        return Icons.location_on;
      case LocationPermissionState.notAsked:
      case LocationPermissionState.userDenied:
        return Icons.location_off;
      case LocationPermissionState.systemDenied:
        return Icons.location_disabled;
      case LocationPermissionState.disabled:
        return Icons.location_disabled;
      case LocationPermissionState.userGranted:
        return Icons.location_on;
    }
  }

  Color _getPermissionStateColor() {
    switch (_permissionState) {
      case LocationPermissionState.granted:
        return Colors.green;
      case LocationPermissionState.notAsked:
      case LocationPermissionState.userDenied:
        return Colors.orange;
      case LocationPermissionState.systemDenied:
      case LocationPermissionState.disabled:
        return Colors.red;
      case LocationPermissionState.userGranted:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(l10n.useLocation),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      leading: Icon(
        _getPermissionStateIcon(),
        color: _getPermissionStateColor(),
      ),
      title: Text(l10n.useLocation),
      subtitle: Text(_getPermissionStateText()),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: _toggleLocationPermission,
    );
  }
}