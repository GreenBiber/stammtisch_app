import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyException implements Exception {
  final String message;
  ApiKeyException(this.message);
  @override
  String toString() => 'ApiKeyException: $message';
}

class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException(this.message);
  @override
  String toString() => 'QuotaExceededException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final double rating;
  final int userRatingsTotal;
  final String vicinity;
  final List<String> types;
  final bool isOpen;
  final String? photoReference;
  final double? lat;
  final double? lng;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.userRatingsTotal,
    required this.vicinity,
    required this.types,
    required this.isOpen,
    this.photoReference,
    this.lat,
    this.lng,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['place_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? json['editorial_summary']?['overview'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['user_ratings_total'] ?? json['userRatingsTotal'] ?? 0,
      vicinity: json['vicinity'] ?? json['formatted_address'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      isOpen: json['opening_hours']?['open_now'] ?? json['isOpen'] ?? true,
      photoReference: json['photos']?[0]?['photo_reference'],
      lat: json['geometry']?['location']?['lat']?.toDouble(),
      lng: json['geometry']?['location']?['lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'vicinity': vicinity,
      'types': types,
      'isOpen': isOpen,
      'photoReference': photoReference,
      'lat': lat,
      'lng': lng,
    };
  }
}

enum ApiKeyStatus {
  notConfigured,
  invalid,
  quotaExceeded,
  restricted,
  valid
}

class PlacesService {
  static const String _baseUrl = 'https://places.googleapis.com/v1/places';
  static const String _quotaKey = 'places_api_quota';
  static const String _lastResetKey = 'places_api_last_reset';
  static const String _apiKeyValidationKey = 'places_api_key_validation';
  static const String _apiKeyLastChecked = 'places_api_key_last_checked';
  static const int _dailyQuotaLimit = 1000;
  static const int _validationCacheHours = 24;

  String get _apiKey {
    try {
      final key = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
      if (key.isEmpty) return '';
      
      // Basic format validation for Google API keys
      if (!_isValidApiKeyFormat(key)) {
        print('Warning: API key has invalid format');
        return '';
      }
      
      return key;
    } catch (e) {
      print('Warning: dotenv not properly initialized - $e');
      return '';
    }
  }
  
  bool _isValidApiKeyFormat(String key) {
    // Google API keys typically start with AIza and are 39 characters long
    return key.startsWith('AIza') && key.length == 39 && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(key);
  }
  
  bool get hasValidApiKey => _apiKey.isNotEmpty;

  Future<ApiKeyStatus> validateApiKey() async {
    if (_apiKey.isEmpty) {
      return ApiKeyStatus.notConfigured;
    }

    // Check cache first
    final cachedStatus = await _getCachedValidationStatus();
    if (cachedStatus != null) {
      return cachedStatus;
    }

    // Perform actual validation with minimal quota usage
    return await _performApiKeyValidation();
  }

  Future<ApiKeyStatus?> _getCachedValidationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastChecked = prefs.getString(_apiKeyLastChecked);
    final cachedStatus = prefs.getString(_apiKeyValidationKey);
    
    if (lastChecked != null && cachedStatus != null) {
      final lastCheck = DateTime.parse(lastChecked);
      final now = DateTime.now();
      
      if (now.difference(lastCheck).inHours < _validationCacheHours) {
        return ApiKeyStatus.values.firstWhere(
          (status) => status.toString() == cachedStatus,
          orElse: () => ApiKeyStatus.invalid,
        );
      }
    }
    
    return null;
  }

  Future<ApiKeyStatus> _performApiKeyValidation() async {
    try {
      // Use a lightweight API call for validation (geocoding with minimal data)
      final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json');
      final testUrl = url.replace(queryParameters: {
        'address': 'test',
        'key': _apiKey,
      });

      final response = await http.get(testUrl);
      final ApiKeyStatus status;

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          if (data['status'] == 'REQUEST_DENIED') {
            status = ApiKeyStatus.restricted;
          } else if (data['status'] == 'OVER_QUERY_LIMIT') {
            status = ApiKeyStatus.quotaExceeded;
          } else {
            status = ApiKeyStatus.valid;
          }
          break;
        case 403:
          status = ApiKeyStatus.invalid;
          break;
        case 429:
          status = ApiKeyStatus.quotaExceeded;
          break;
        default:
          status = ApiKeyStatus.invalid;
      }

      // Cache the result
      await _cacheValidationStatus(status);
      return status;
      
    } catch (e) {
      print('API key validation failed: $e');
      return ApiKeyStatus.invalid;
    }
  }

  Future<void> _cacheValidationStatus(ApiKeyStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyValidationKey, status.toString());
    await prefs.setString(_apiKeyLastChecked, DateTime.now().toIso8601String());
  }

  Future<List<Restaurant>> searchRestaurants({
    required double latitude,
    required double longitude,
    String type = 'restaurant',
    int radius = 2000,
  }) async {
    // Validate API key first
    final apiKeyStatus = await validateApiKey();
    
    switch (apiKeyStatus) {
      case ApiKeyStatus.notConfigured:
        throw ApiKeyException('Google Places API key not configured. Please add GOOGLE_PLACES_API_KEY to your .env file.');
      case ApiKeyStatus.invalid:
        throw ApiKeyException('Google Places API key is invalid. Please check your API key in the .env file.');
      case ApiKeyStatus.restricted:
        throw ApiKeyException('Google Places API key access is restricted. Please check your API key permissions.');
      case ApiKeyStatus.quotaExceeded:
        throw ApiKeyException('Google Places API daily quota exceeded. Please try again tomorrow.');
      case ApiKeyStatus.valid:
        break;
    }

    if (!await _hasQuotaAvailable()) {
      throw QuotaExceededException('Daily API quota limit ($_dailyQuotaLimit requests) exceeded');
    }

    final url = Uri.parse('$_baseUrl:searchNearby');

    // Debug: Print actual coordinates being used
    print('🔍 Searching restaurants at coordinates: lat=$latitude, lng=$longitude, radius=${radius}m');
    
    final requestBody = {
      'includedTypes': [type],
      'maxResultCount': 3,
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'radius': radius.toDouble(),
        }
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'places.id,places.displayName,places.rating,places.userRatingCount,places.formattedAddress,places.photos,places.primaryType,places.currentOpeningHours,places.location',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        await _incrementQuotaUsage();
        
        final List<dynamic> places = data['places'] ?? [];
        return places
            .map((placeJson) => _convertNewApiResponse(placeJson))
            .toList();
      } else {
        await _handleApiError(response);
      }
    } on ApiKeyException {
      rethrow;
    } on QuotaExceededException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException')) {
        throw NetworkException('Network connection failed. Please check your internet connection.');
      }
      throw NetworkException('Unexpected error occurred: $e');
    }
    
    return [];
  }

  Future<void> _handleApiError(http.Response response) async {
    try {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['error']?['message'] ?? 'Unknown API error';
      
      switch (response.statusCode) {
        case 400:
          throw ApiKeyException('Bad request: $errorMessage');
        case 403:
          throw ApiKeyException('API key forbidden: $errorMessage');
        case 429:
          throw QuotaExceededException('Rate limit exceeded: $errorMessage');
        default:
          throw NetworkException('API Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      if (e is ApiKeyException || e is QuotaExceededException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Failed to parse API error response: ${response.statusCode}');
    }
  }

  Restaurant _convertNewApiResponse(Map<String, dynamic> place) {
    final photoRef = place['photos']?[0]?['name'];
    print('📸 Photo reference for ${place['displayName']?['text']}: $photoRef');
    
    return Restaurant(
      id: place['id'] ?? '',
      name: place['displayName']?['text'] ?? '',
      description: place['editorialSummary']?['text'] ?? '',
      rating: (place['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: place['userRatingCount'] ?? 0,
      vicinity: place['formattedAddress'] ?? '',
      types: [place['primaryType'] ?? 'restaurant'],
      isOpen: place['currentOpeningHours']?['openNow'] ?? true,
      photoReference: photoRef,
      lat: place['location']?['latitude']?.toDouble(),
      lng: place['location']?['longitude']?.toDouble(),
    );
  }

  String? getPhotoUrl(String? photoReference, {int maxWidth = 400}) {
    if (!hasValidApiKey || photoReference == null) return null;
    
    // New API uses photo name format: places/{place_id}/photos/{photo_id}
    // photoReference should be like "places/ChIJ.../photos/..."
    if (photoReference.startsWith('places/')) {
      return 'https://places.googleapis.com/v1/$photoReference/media?'
          'maxWidthPx=$maxWidth&'
          'key=$_apiKey';
    } else {
      // Legacy format fallback
      return 'https://places.googleapis.com/v1/places/photos/$photoReference/media?'
          'maxWidthPx=$maxWidth&'
          'key=$_apiKey';
    }
  }

  Future<int> getRemainingQuota() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkDailyReset();
    
    final used = prefs.getInt(_quotaKey) ?? 0;
    return _dailyQuotaLimit - used;
  }

  Future<bool> _hasQuotaAvailable() async {
    final remaining = await getRemainingQuota();
    return remaining > 0;
  }

  Future<void> _incrementQuotaUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUsage = prefs.getInt(_quotaKey) ?? 0;
    await prefs.setInt(_quotaKey, currentUsage + 1);
  }

  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString(_lastResetKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastReset != today) {
      await prefs.setInt(_quotaKey, 0);
      await prefs.setString(_lastResetKey, today);
    }
  }
}