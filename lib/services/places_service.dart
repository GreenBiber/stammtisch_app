import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _quotaKey = 'places_api_quota';
  static const String _lastResetKey = 'places_api_last_reset';
  static const int _dailyQuotaLimit = 1000;

  String get _apiKey => ''; // TODO: Add API key when flutter_dotenv is added
  
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

    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json?'
      'location=$latitude,$longitude&'
      'radius=$radius&'
      'type=$type&'
      'key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          await _incrementQuotaUsage();
          
          final List<dynamic> results = data['results'] ?? [];
          return results
              .map((json) => Restaurant.fromJson(json))
              .take(3) // Limit to 3 suggestions
              .toList();
        } else {
          throw Exception('Places API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  String? getPhotoUrl(String? photoReference, {int maxWidth = 400}) {
    if (!hasValidApiKey || photoReference == null) return null;
    
    return '$_baseUrl/photo?'
        'maxwidth=$maxWidth&'
        'photo_reference=$photoReference&'
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