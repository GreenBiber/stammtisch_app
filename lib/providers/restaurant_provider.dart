import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/places_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class RestaurantProvider with ChangeNotifier {
  PlacesService? _placesService;
  WeatherService? _weatherService;

  // Safe getters for services
  PlacesService get placesService {
    _placesService ??= PlacesService();
    return _placesService!;
  }

  WeatherService get weatherService {
    _weatherService ??= WeatherService();
    return _weatherService!;
  }

  List<Restaurant> _suggestions = [];
  bool _isLoading = false;
  String? _error;
  bool _hasApiQuota = true;
  int _remainingQuota = 1000;
  WeatherData? _currentWeather;
  String? _weatherRecommendation;

  // Fallback restaurants when API limit reached
  static const List<Map<String, dynamic>> _fallbackRestaurants = [
    {
      'id': 'fallback_1',
      'name': 'Trattoria da Luca',
      'description': 'Italienische Küche mit gemütlichem Innenhof',
      'rating': 4.5,
      'userRatingsTotal': 127,
      'vicinity': 'Stadtmitte',
      'types': ['restaurant', 'italian'],
      'isOpen': true,
    },
    {
      'id': 'fallback_2',
      'name': 'Burger Garage',
      'description': 'Handgemachte Burger & Craft Beer',
      'rating': 4.2,
      'userRatingsTotal': 89,
      'vicinity': 'Altstadt',
      'types': ['restaurant', 'american'],
      'isOpen': true,
    },
    {
      'id': 'fallback_3',
      'name': 'Sushiko',
      'description': 'Frisches Sushi in modernem Ambiente',
      'rating': 4.8,
      'userRatingsTotal': 156,
      'vicinity': 'Bahnhofsviertel',
      'types': ['restaurant', 'japanese'],
      'isOpen': true,
    },
  ];

  List<Restaurant> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiQuota => _hasApiQuota;
  int get remainingQuota => _remainingQuota;
  bool get hasValidApiKey {
    try {
      return placesService.hasValidApiKey;
    } catch (e) {
      debugPrint('⚠️ Error checking API key: $e');
      return false;
    }
  }

  Future<ApiKeyStatus> getApiKeyStatus() async {
    try {
      return await placesService.validateApiKey();
    } catch (e) {
      debugPrint('⚠️ Error validating API key: $e');
      return ApiKeyStatus.invalid;
    }
  }
  WeatherData? get currentWeather => _currentWeather;
  String? get weatherRecommendation => _weatherRecommendation;

  Future<void> loadRestaurantSuggestions({
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Update Quota Status (with error handling)
      try {
        await _updateQuotaStatus();
      } catch (quotaError) {
        debugPrint('⚠️ Error updating quota status: $quotaError');
        _hasApiQuota = false;
        _remainingQuota = 0;
      }

      // Try to get location if not provided
      LocationData? locationData;
      if (latitude == null || longitude == null) {
        try {
          final locationService = LocationService();
          final result = await locationService.getCurrentLocationWithConsent();
          
          if (result.state == LocationPermissionState.granted && result.locationData != null) {
            locationData = result.locationData!;
            latitude = locationData.latitude;
            longitude = locationData.longitude;
            
            // Validate coordinates but don't use fallback location
            if (latitude < 47.0 || latitude > 55.0 || longitude < 5.0 || longitude > 15.0) {
              debugPrint('⚠️ GPS coordinates seem incorrect: $latitude, $longitude');
              debugPrint('📍 Ignoring invalid coordinates - no location available');
              latitude = null;
              longitude = null;
            }
          } else {
            debugPrint('📍 Location not available: ${result.message}');
          }
        } catch (locationError) {
          debugPrint('⚠️ Location Error: $locationError');
        }
      }

      // Load weather data first
      if (latitude != null && longitude != null) {
        try {
          _currentWeather = await weatherService.getCurrentWeather(
            latitude: latitude,
            longitude: longitude,
          );
          _weatherRecommendation =
              weatherService.getWeatherBasedRecommendation(_currentWeather);
        } catch (weatherError) {
          debugPrint('⚠️ Weather API Error: $weatherError');
        }
      }

      if (hasValidApiKey &&
          _hasApiQuota &&
          latitude != null &&
          longitude != null) {
        try {
          // Use Google Places API with weather-based search

          // Get weather-based restaurant types
          final restaurantTypes =
              weatherService.getWeatherBasedRestaurantTypes(_currentWeather);

          _suggestions = await placesService.searchRestaurants(
            latitude: latitude,
            longitude: longitude,
            type: restaurantTypes.first, // Use primary type for API call
          );


          // Update quota after successful request
          await _updateQuotaStatus();
        } on ApiKeyException catch (e) {
          debugPrint('🔑 API Key Error: ${e.message}');
          _error = 'API configuration error: ${e.message}';
          _loadFallbackRestaurants();
        } on QuotaExceededException catch (e) {
          debugPrint('📊 Quota Error: ${e.message}');
          _error = 'Daily quota exceeded. Using saved locations.';
          _hasApiQuota = false;
          _remainingQuota = 0;
          _loadFallbackRestaurants();
        } on NetworkException catch (e) {
          debugPrint('🌐 Network Error: ${e.message}');
          _error = 'Network error. Using cached locations.';
          _loadFallbackRestaurants();
        } catch (apiError) {
          debugPrint('⚠️ Unexpected API Error, falling back to demo data: $apiError');
          _error = 'Service temporarily unavailable. Using saved locations.';
          _loadFallbackRestaurants();
        }
      } else {
        // No valid API or location available
        if (latitude == null || longitude == null) {
          debugPrint('📍 No location available - showing empty restaurant list');
          _suggestions = [];
          _error = 'Location access required to show restaurant suggestions';
        } else {
          // Use fallback data when API is not available but location exists
          debugPrint(
              '📱 Using fallback restaurants (API key: ${hasValidApiKey ? "valid" : "invalid"}, Quota: $_hasApiQuota)');
          _loadFallbackRestaurants();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading restaurants: $e');
      // Only use fallback if we have location data
      if (latitude != null && longitude != null) {
        _loadFallbackRestaurants();
      } else {
        _suggestions = [];
        _error = 'Location access required to show restaurant suggestions';
      }
    } finally {
      _setLoading(false);
    }
  }

  void _loadFallbackRestaurants() {
    // Load fallback restaurants with some randomization for variety
    final allFallbacks = List<Map<String, dynamic>>.from(_fallbackRestaurants);
    
    // Shuffle for variety if we have weather context
    if (_currentWeather != null) {
      allFallbacks.shuffle();
    }
    
    // Always provide at least 3 suggestions
    final selectedFallbacks = allFallbacks.take(3).toList();
    
    _suggestions = selectedFallbacks.map((data) => Restaurant.fromJson(data)).toList();
    
    debugPrint('📱 Loaded ${_suggestions.length} fallback restaurants');
  }

  Future<void> _updateQuotaStatus() async {
    try {
      _remainingQuota = await placesService.getRemainingQuota();
      // Debug: Remaining quota = $_remainingQuota
      _hasApiQuota = _remainingQuota > 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating quota status: $e');
      // Set safe fallback values
      _hasApiQuota = false;
      _remainingQuota = 0;
      rethrow; // Re-throw to be handled by caller
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String? getPhotoUrl(String? photoReference) {
    if (!hasValidApiKey) return null;
    try {
      return placesService.getPhotoUrl(photoReference);
    } catch (e) {
      debugPrint('⚠️ Error getting photo URL: $e');
      return null;
    }
  }
}
