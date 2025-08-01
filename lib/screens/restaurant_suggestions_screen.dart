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

    // Debug: Location Status

    final location = await LocationService().getCurrentLocation();

    if (location == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Standort nicht verfügbar - verwende Demo-Daten'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {}

    await restaurantProvider.loadRestaurantSuggestions(
      latitude: location?.latitude,
      longitude: location?.longitude,
    );

    // Restaurant suggestions loaded successfully
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
                          color: Colors.orange.withValues(alpha: 0.2),
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
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: restaurantProvider.hasValidApiKey &&
                              restaurantProvider.hasApiQuota
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
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
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            context.isGerman
                ? 'Fehler beim Laden'
                : 'Loading Error',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRestaurants,
            child: Text(l10n.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList(List<dynamic> restaurants) {
    final l10n = context.l10n;

    if (restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              context.isGerman
                  ? 'Keine Restaurants gefunden'
                  : 'No restaurants found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRestaurants,
              child: Text(l10n.refresh),
            ),
          ],
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
                                      Colors.green.withValues(alpha: 0.7)),
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
        color: Colors.amber.withValues(alpha: 0.2),
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
}
