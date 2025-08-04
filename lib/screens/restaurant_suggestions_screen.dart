import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/points_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/restaurant_provider.dart';
import '../services/location_service.dart';
import '../widgets/xp_animation.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/location_permission_dialog.dart';
import '../l10n/l10n.dart';

class RestaurantSuggestionsScreen extends StatefulWidget {
  const RestaurantSuggestionsScreen({super.key});

  @override
  State<RestaurantSuggestionsScreen> createState() =>
      _RestaurantSuggestionsScreenState();
}

class _RestaurantSuggestionsScreenState
    extends State<RestaurantSuggestionsScreen> {
  final GlobalKey<XPAnimationOverlayState> _overlayKey = GlobalKey();
  final Set<String> _userVotes = {};

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final locationService = LocationService();

    // Check location permission state
    final permissionState = await locationService.getPermissionState();
    
    LocationData? location;
    
    if (permissionState == LocationPermissionState.notAsked ||
        permissionState == LocationPermissionState.userDenied) {
      // Show permission dialog if user hasn't been asked yet or denied before
      await _showLocationPermissionDialog();
      
      // Check if user granted permission and get location
      final hasConsent = await locationService.hasUserConsent();
      if (hasConsent) {
        final result = await locationService.getCurrentLocationWithConsent();
        if (result.state == LocationPermissionState.granted) {
          location = result.locationData;
        }
      }
    } else if (permissionState == LocationPermissionState.granted) {
      // User has granted permission, get location
      final result = await locationService.getCurrentLocationWithConsent();
      if (result.state == LocationPermissionState.granted) {
        location = result.locationData;
      }
    }

    // Load restaurants with location if available
    await restaurantProvider.loadRestaurantSuggestions(
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
  }

  Future<void> _showLocationPermissionDialog() async {
    final l10n = context.l10n;
    
    await LocationPermissionDialog.show(
      context,
      onPermissionGranted: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.allowLocation),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onPermissionDenied: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationPermissionDenied),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer4<PointsProvider, AuthProvider, GroupProvider,
        RestaurantProvider>(
      builder: (context, pointsProvider, authProvider, groupProvider,
          restaurantProvider, child) {
        final currentUserId = authProvider.currentUserId;
        final activeGroup = groupProvider.getActiveGroup(context);
        final userPoints =
            pointsProvider.getUserPoints(currentUserId, activeGroup?.id ?? '');

        return XPAnimationOverlay(
          key: _overlayKey,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.restaurantSuggestions),
              actions: [
                // API Quota Indicator
                if (!restaurantProvider.hasApiQuota)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning,
                                size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              context.isGerman
                                  ? 'Offline'
                                  : 'Offline',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Profile Card Header
                if (userPoints != null)
                  UserProfileCard(
                    groupId: activeGroup?.id ?? '',
                    showDetailed: false,
                    showProgress: true,
                    heroTagSuffix: 'restaurant-header',
                  ),

                // Weather Info Card
                if (restaurantProvider.weatherRecommendation != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            restaurantProvider.weatherRecommendation!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                // API Status Info
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(
                      16,
                      restaurantProvider.weatherRecommendation != null ? 8 : 16,
                      16,
                      16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: restaurantProvider.hasValidApiKey &&
                            restaurantProvider.hasApiQuota
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: restaurantProvider.hasValidApiKey &&
                              restaurantProvider.hasApiQuota
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        restaurantProvider.hasValidApiKey &&
                                restaurantProvider.hasApiQuota
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: restaurantProvider.hasValidApiKey &&
                                restaurantProvider.hasApiQuota
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              !restaurantProvider.hasValidApiKey
                                  ? (context.isGerman
                                      ? 'API-Key nicht konfiguriert'
                                      : 'API Key not configured')
                                  : restaurantProvider.hasApiQuota
                                      ? (context.isGerman
                                          ? 'Live Restaurant-Daten'
                                          : 'Live Restaurant Data')
                                      : (context.isGerman
                                          ? 'Offline-Modus aktiv'
                                          : 'Offline Mode Active'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: restaurantProvider.hasValidApiKey &&
                                        restaurantProvider.hasApiQuota
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            Text(
                              !restaurantProvider.hasValidApiKey
                                  ? (context.isGerman
                                      ? 'Setze deinen Google Places API-Key in places_service.dart'
                                      : 'Set your Google Places API key in places_service.dart')
                                  : restaurantProvider.hasApiQuota
                                      ? (context.isGerman
                                          ? 'Verbleibende API-Anfragen: ${restaurantProvider.remainingQuota}'
                                          : 'Remaining API requests: ${restaurantProvider.remainingQuota}')
                                      : (context.isGerman
                                          ? 'API-Limit erreicht - zeige Fallback-Restaurants'
                                          : 'API limit reached - showing fallback restaurants'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Debug-Button zum Quota Reset (nur für Development)
                if (!const bool.fromEnvironment('dart.vm.product'))
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('places_api_daily_requests');
                        await prefs.remove('places_api_last_date');

                        // Reload
                        await _loadRestaurants();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('🔧 Debug: API Quota zurückgesetzt'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Debug: Reset API Quota'),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                    ),
                  ),

                // Restaurant List
                Expanded(
                  child: restaurantProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : restaurantProvider.error != null
                          ? _buildErrorState(restaurantProvider.error!)
                          : _buildRestaurantList(
                              restaurantProvider.suggestions),
                ),
              ],
            ),
            floatingActionButton: FutureBuilder<LocationPermissionState>(
              future: LocationService().getPermissionState(),
              builder: (context, snapshot) {
                final state = snapshot.data ?? LocationPermissionState.notAsked;
                final color = _getLocationStateColor(state);
                
                return FloatingActionButton.extended(
                  onPressed: () => _showLocationSettingsDialog(),
                  icon: Icon(_getLocationStateIcon(state)),
                  label: Text(
                    context.isGerman ? 'Standort' : 'Location',
                  ),
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    final l10n = context.l10n;
    
    // Determine error type and provide user-friendly messages
    String title;
    String description;
    IconData icon;
    Color iconColor;
    
    if (error.toLowerCase().contains('location') || error.toLowerCase().contains('standort')) {
      // Location-related error
      title = context.isGerman
          ? 'Standortdienste erforderlich'
          : 'Location Services Required';
      description = context.isGerman
          ? 'Die Standortdienste sind nicht aktiviert. Um Restaurantvorschläge in Ihrer Nähe zu erhalten, aktivieren Sie bitte die Standortdienste auf Ihrem Gerät und erteilen Sie der App die Berechtigung.'
          : 'Location services are not enabled. To receive restaurant suggestions near you, please enable location services on your device and grant the app permission.';
      icon = Icons.location_off;
      iconColor = Colors.orange;
    } else if (error.toLowerCase().contains('api') || error.toLowerCase().contains('quota')) {
      // API-related error
      title = context.isGerman
          ? 'Service temporär nicht verfügbar'
          : 'Service Temporarily Unavailable';
      description = context.isGerman
          ? 'Die Restaurant-API ist momentan nicht verfügbar. Bitte versuchen Sie es später erneut.'
          : 'The restaurant API is currently unavailable. Please try again later.';
      icon = Icons.cloud_off;
      iconColor = Colors.orange;
    } else {
      // Generic error
      title = context.isGerman
          ? 'Fehler beim Laden der Restaurants'
          : 'Error Loading Restaurants';
      description = context.isGerman
          ? 'Es gab ein Problem beim Laden der Restaurantvorschläge. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.'
          : 'There was a problem loading restaurant suggestions. Please check your internet connection and try again.';
      icon = Icons.error_outline;
      iconColor = Colors.red;
    }
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadRestaurants,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.refresh),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              // Show technical error details in debug mode
              if (!const bool.fromEnvironment('dart.vm.product')) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text(
                    '🔧 Debug Info',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        error,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantList(List<dynamic> restaurants) {
    final l10n = context.l10n;
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

    if (restaurants.isEmpty) {
      // Check if it's due to missing location
      bool isLocationError = restaurantProvider.error?.contains('Location access required') ?? false;
      
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLocationError ? Icons.location_off : Icons.restaurant, 
                  size: 64, 
                  color: Colors.grey
                ),
                const SizedBox(height: 16),
                Text(
                  isLocationError
                      ? (context.isGerman
                          ? 'Standort benötigt'
                          : 'Location Required')
                      : (context.isGerman
                          ? 'Keine Restaurants gefunden'
                          : 'No restaurants found'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (isLocationError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.isGerman
                          ? 'Erlaube den Standortzugriff, um Restaurantvorschläge in deiner Nähe zu erhalten.'
                          : 'Allow location access to receive restaurant suggestions near you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _handleLocationRequest(),
                  icon: Icon(isLocationError ? Icons.location_on : Icons.refresh),
                  label: Text(isLocationError 
                      ? (context.isGerman ? 'Standort aktivieren' : 'Enable Location')
                      : l10n.refresh),
                ),
                if (isLocationError) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showLocationManualSetupDialog(),
                    icon: const Icon(Icons.settings, size: 16),
                    label: Text(
                      context.isGerman
                          ? 'Standort manuell aktivieren'
                          : 'Enable location manually',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        final hasVoted = _userVotes.contains(restaurant.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              _buildRestaurantImage(restaurant),

              // Restaurant Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildRatingChip(restaurant.rating),
                      ],
                    ),

                    if (restaurant.description != null) ...[
                      const SizedBox(height: 8),
                      Text(restaurant.description!,
                          style: const TextStyle(fontSize: 14)),
                    ],

                    if (restaurant.vicinity != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant.vicinity!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Voting Section
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: hasVoted
                              ? null
                              : () => _voteForRestaurant(restaurant.id),
                          icon: Icon(hasVoted
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined),
                          label: Text(hasVoted ? l10n.voted : l10n.vote),
                          style: hasVoted
                              ? ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.green.withOpacity(0.7)),
                                )
                              : null,
                        ),
                        const Spacer(),
                        Text(
                          '${restaurant.userRatingsTotal} ${context.isGerman ? 'Bewertungen' : 'reviews'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantImage(dynamic restaurant) {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    // Prüfe ob ein Photo Reference vorhanden ist
    if (restaurant.photoReference != null &&
        restaurantProvider.hasValidApiKey) {
      final imageUrl =
          restaurantProvider.getPhotoUrl(restaurant.photoReference);

      if (imageUrl != null) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
          ),
        );
      }
    }

    // Fallback: Platzhalter-Bild
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: Colors.white),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _voteForRestaurant(String restaurantId) {
    setState(() {
      _userVotes.add(restaurantId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.isGerman
            ? 'Du hast abgestimmt! 👍'
            : 'You voted! 👍'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleLocationRequest() async {
    final locationService = LocationService();
    final permissionState = await locationService.getPermissionState();
    
    if (permissionState == LocationPermissionState.systemDenied) {
      await _showLocationManualSetupDialog();
    } else {
      await _loadRestaurants();
    }
  }

  Future<void> _showLocationManualSetupDialog() async {
    final l10n = context.l10n;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.isGerman
                    ? 'Standort aktivieren'
                    : 'Enable Location',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isGerman
                  ? 'Um Restaurantvorschläge zu erhalten, musst du den Standortzugriff in den Geräteeinstellungen aktivieren:'
                  : 'To receive restaurant suggestions, you need to enable location access in your device settings:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepItem('1.', context.isGerman 
                      ? 'Öffne die Geräteeinstellungen'
                      : 'Open device settings'),
                  const SizedBox(height: 4),
                  _buildStepItem('2.', context.isGerman 
                      ? 'Gehe zu "Apps" oder "Anwendungen"'
                      : 'Go to "Apps" or "Applications"'),
                  const SizedBox(height: 4),
                  _buildStepItem('3.', context.isGerman 
                      ? 'Finde "Stammtisch App"'
                      : 'Find "Stammtisch App"'),
                  const SizedBox(height: 4),
                  _buildStepItem('4.', context.isGerman 
                      ? 'Aktiviere "Standort" Berechtigung'
                      : 'Enable "Location" permission'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadRestaurants();
            },
            child: Text(context.isGerman ? 'Erneut versuchen' : 'Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _showLocationSettingsDialog() async {
    final locationService = LocationService();
    final permissionState = await locationService.getPermissionState();
    
    if (!mounted) return;
    
    final l10n = context.l10n;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getLocationStateIcon(permissionState),
              color: _getLocationStateColor(permissionState),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.isGerman ? 'Standort-Einstellungen' : 'Location Settings',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getLocationStateColor(permissionState).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getLocationStateColor(permissionState).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocationStateTitle(permissionState),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getLocationStateColor(permissionState),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLocationStateDescription(permissionState),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (permissionState == LocationPermissionState.systemDenied) ...[
              const SizedBox(height: 16),
              Text(
                context.isGerman
                    ? 'Um die Standortberechtigung zu aktivieren:'
                    : 'To enable location permission:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    _buildStepItem('1.', context.isGerman ? 'Geräteeinstellungen öffnen' : 'Open device settings'),
                    _buildStepItem('2.', context.isGerman ? 'Apps → Stammtisch App' : 'Apps → Stammtisch App'),
                    _buildStepItem('3.', context.isGerman ? 'Berechtigung → Standort aktivieren' : 'Permissions → Enable Location'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          if (permissionState == LocationPermissionState.notAsked ||
              permissionState == LocationPermissionState.userDenied)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showLocationPermissionDialog();
                await _loadRestaurants();
              },
              child: Text(context.isGerman ? 'Aktivieren' : 'Enable'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadRestaurants();
              },
              child: Text(context.isGerman ? 'Erneut versuchen' : 'Try again'),
            ),
        ],
      ),
    );
  }

  IconData _getLocationStateIcon(LocationPermissionState state) {
    switch (state) {
      case LocationPermissionState.granted:
        return Icons.location_on;
      case LocationPermissionState.notAsked:
      case LocationPermissionState.userDenied:
        return Icons.location_off;
      case LocationPermissionState.systemDenied:
      case LocationPermissionState.disabled:
        return Icons.location_disabled;
      case LocationPermissionState.userGranted:
        return Icons.location_on;
    }
  }

  Color _getLocationStateColor(LocationPermissionState state) {
    switch (state) {
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

  String _getLocationStateTitle(LocationPermissionState state) {
    switch (state) {
      case LocationPermissionState.granted:
        return context.isGerman ? 'Standort aktiviert' : 'Location enabled';
      case LocationPermissionState.notAsked:
        return context.isGerman ? 'Standort nicht konfiguriert' : 'Location not configured';
      case LocationPermissionState.userDenied:
        return context.isGerman ? 'Standort abgelehnt' : 'Location denied';
      case LocationPermissionState.systemDenied:
        return context.isGerman ? 'Berechtigung verweigert' : 'Permission denied';
      case LocationPermissionState.disabled:
        return context.isGerman ? 'Standortdienste deaktiviert' : 'Location services disabled';
      case LocationPermissionState.userGranted:
        return context.isGerman ? 'Standort aktiviert' : 'Location enabled';
    }
  }

  String _getLocationStateDescription(LocationPermissionState state) {
    switch (state) {
      case LocationPermissionState.granted:
        return context.isGerman 
            ? 'Die App kann deinen Standort für Restaurantvorschläge nutzen.'
            : 'The app can use your location for restaurant suggestions.';
      case LocationPermissionState.notAsked:
        return context.isGerman 
            ? 'Du wurdest noch nicht nach der Standortberechtigung gefragt.'
            : 'You haven\'t been asked for location permission yet.';
      case LocationPermissionState.userDenied:
        return context.isGerman 
            ? 'Du hast die Standortberechtigung abgelehnt.'
            : 'You have denied location permission.';
      case LocationPermissionState.systemDenied:
        return context.isGerman 
            ? 'Die Standortberechtigung wurde in den Geräteeinstellungen verweigert.'
            : 'Location permission was denied in device settings.';
      case LocationPermissionState.disabled:
        return context.isGerman 
            ? 'Die Standortdienste sind auf diesem Gerät deaktiviert.'
            : 'Location services are disabled on this device.';
      case LocationPermissionState.userGranted:
        return context.isGerman 
            ? 'Die App kann deinen Standort für Restaurantvorschläge nutzen.'
            : 'The app can use your location for restaurant suggestions.';
    }
  }
}
