import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class PlacesService {
  static const String _baseUrl = 'https://places.googleapis.com/v1/places';
  static const String _quotaKey = 'places_api_quota';
  static const String _lastResetKey = 'places_api_last_reset';
  static const int _dailyQuotaLimit = 1000;

  String get _apiKey {
    try {
      return dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    } catch (e) {
      // dotenv not initialized or .env file not found
      print('Warning: dotenv not properly initialized - $e');
      return '';
    }
  }
  
  bool get hasValidApiKey => _apiKey.isNotEmpty;

  Future<List<Restaurant>> searchRestaurants({
    required double latitude,
    required double longitude,
    String type = 'restaurant',
    int radius = 2000,
  }) async {
    if (!hasValidApiKey) {
      throw Exception('Google Places API key not configured');
    }

    if (!await _hasQuotaAvailable()) {
      throw Exception('Daily API quota exceeded');
    }

    final url = Uri.parse('$_baseUrl:searchNearby');

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
          'X-Goog-FieldMask': 'places.id,places.displayName,places.rating,places.userRatingCount,places.formattedAddress,places.photos,places.primaryType,places.currentOpeningHours',
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
        final errorData = json.decode(response.body);
        throw Exception('Places API Error: ${response.statusCode} - ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Restaurant _convertNewApiResponse(Map<String, dynamic> place) {
    return Restaurant(
      id: place['id'] ?? '',
      name: place['displayName']?['text'] ?? '',
      description: place['editorialSummary']?['text'] ?? '',
      rating: (place['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: place['userRatingCount'] ?? 0,
      vicinity: place['formattedAddress'] ?? '',
      types: [place['primaryType'] ?? 'restaurant'],
      isOpen: place['currentOpeningHours']?['openNow'] ?? true,
      photoReference: place['photos']?[0]?['name'],
      lat: place['location']?['latitude']?.toDouble(),
      lng: place['location']?['longitude']?.toDouble(),
    );
  }

  String? getPhotoUrl(String? photoReference, {int maxWidth = 400}) {
    if (!hasValidApiKey || photoReference == null) return null;
    
    // New API uses photo name format: places/{place_id}/photos/{photo_id}
    return 'https://places.googleapis.com/v1/$photoReference/media?'
        'maxWidthPx=$maxWidth&'
        'key=$_apiKey';
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