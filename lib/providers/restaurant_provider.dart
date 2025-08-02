import 'package:flutter/material.dart';
import '../services/places_service.dart';
import '../services/weather_service.dart';

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
      print('⚠️ Error checking API key: $e');
      return false;
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
        print('⚠️ Error updating quota status: $quotaError');
        _hasApiQuota = false;
        _remainingQuota = 0;
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
          print('🌤️ Weather loaded: $_weatherRecommendation');
        } catch (weatherError) {
          print('⚠️ Weather API Error: $weatherError');
        }
      }

      if (hasValidApiKey &&
          _hasApiQuota &&
          latitude != null &&
          longitude != null) {
        try {
          // Use Google Places API with weather-based search
          print('🔍 Loading restaurants from Google Places API...');
          print('📍 Location: $latitude, $longitude');

          // Get weather-based restaurant types
          final restaurantTypes =
              weatherService.getWeatherBasedRestaurantTypes(_currentWeather);
          print('🌤️ Weather-based search types: $restaurantTypes');

          _suggestions = await placesService.searchRestaurants(
            latitude: latitude,
            longitude: longitude,
            type: restaurantTypes.first, // Use primary type for API call
          );

          print('✅ Loaded ${_suggestions.length} restaurants from API');

          // Update quota after successful request
          await _updateQuotaStatus();
        } catch (apiError) {
          print('⚠️ API Error, falling back to demo data: $apiError');
          _loadFallbackRestaurants();
        }
      } else {
        // Use fallback data
        print(
            '📱 Using fallback restaurants (API key: ${hasValidApiKey ? "valid" : "invalid"}, Quota: $_hasApiQuota, Location: ${latitude != null ? "available" : "missing"})');
        _loadFallbackRestaurants();
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading restaurants: $e');
      // Use fallback on error
      _loadFallbackRestaurants();
    } finally {
      _setLoading(false);
    }
  }

  void _loadFallbackRestaurants() {
    _suggestions =
        _fallbackRestaurants.map((data) => Restaurant.fromJson(data)).toList();
  }

  Future<void> _updateQuotaStatus() async {
    try {
      _remainingQuota = await placesService.getRemainingQuota();
      debugPrint("********************************");
      debugPrint(_remainingQuota.toString());
      debugPrint("********************************");
      _hasApiQuota = _remainingQuota > 0;
      notifyListeners();
    } catch (e) {
      print('Error updating quota status: $e');
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
      print('⚠️ Error getting photo URL: $e');
      return null;
    }
  }
}
