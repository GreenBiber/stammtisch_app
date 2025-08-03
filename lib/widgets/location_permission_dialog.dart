import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const LocationPermissionDialog({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.locationPermissionTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.locationPermissionMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  context,
                  Icons.restaurant_menu,
                  l10n.locationBenefitRestaurants,
                ),
                const SizedBox(height: 8),
                _buildBenefitItem(
                  context,
                  Icons.wb_sunny,
                  l10n.locationBenefitWeather,
                ),
                const SizedBox(height: 8),
                _buildBenefitItem(
                  context,
                  Icons.recommend,
                  l10n.locationBenefitRecommendations,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.locationPrivacyNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _handleDeny(context),
          child: Text(
            l10n.deny,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _handleAllow(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(l10n.allowLocation),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  void _handleAllow(BuildContext context) async {
    Navigator.of(context).pop();
    await LocationService().setUserConsent(true);
    onPermissionGranted?.call();
  }

  void _handleDeny(BuildContext context) async {
    Navigator.of(context).pop();
    await LocationService().setUserConsent(false);
    onPermissionDenied?.call();
  }

  /// Show the location permission dialog
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onPermissionGranted,
    VoidCallback? onPermissionDenied,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onPermissionGranted: onPermissionGranted,
        onPermissionDenied: onPermissionDenied,
      ),
    );
  }
}

/// Widget to handle location permission state and show appropriate UI
class LocationPermissionHandler extends StatefulWidget {
  final Widget Function(BuildContext context, LocationPermissionState state) builder;
  final VoidCallback? onPermissionGranted;
  final bool autoRequest;

  const LocationPermissionHandler({
    super.key,
    required this.builder,
    this.onPermissionGranted,
    this.autoRequest = false,
  });

  @override
  State<LocationPermissionHandler> createState() => _LocationPermissionHandlerState();
}

class _LocationPermissionHandlerState extends State<LocationPermissionHandler> {
  LocationPermissionState _permissionState = LocationPermissionState.notAsked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionState();
    
    if (widget.autoRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestLocationIfNeeded();
      });
    }
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

  Future<void> _requestLocationIfNeeded() async {
    if (_permissionState == LocationPermissionState.notAsked) {
      await _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!mounted) return;

    await LocationPermissionDialog.show(
      context,
      onPermissionGranted: () async {
        await _checkPermissionState();
        widget.onPermissionGranted?.call();
      },
      onPermissionDenied: () async {
        await _checkPermissionState();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return widget.builder(context, _permissionState);
  }
}