import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Restaurant {
  final String id;
  final String name;
  final String? description;
  final double rating;
  final int userRatingsTotal;
  final String? photoReference;
  final String? vicinity;
  final List<String> types;
  final bool isOpen;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    required this.rating,
    required this.userRatingsTotal,
    this.photoReference,
    this.vicinity,
    required this.types,
    required this.isOpen,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['place_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? json['editorial_summary']?['overview'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['user_ratings_total'] ?? json['userRatingsTotal'] ?? 0,
      photoReference: json['photos']?.isNotEmpty == true 
          ? json['photos'][0]['photo_reference'] 
          : null,
      vicinity: json['vicinity'],
      types: List<String>.from(json['types'] ?? []),
      isOpen: json['opening_hours']?['open_now'] ?? json['isOpen'] ?? true,
    );
  }
}

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const int _dailyLimit = 1000;
  static const String _quotaKey = 'places_api_daily_requests';
  static const String _quotaDateKey = 'places_api_last_date';
  
  String get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  
  // Singleton pattern
  static PlacesService? _instance;
  PlacesService._();
  
  factory PlacesService() {
    _instance ??= PlacesService._();
    return _instance!;
  }
  
  // Getter für API-Status
  bool get hasValidApiKey => _apiKey.isNotEmpty && _apiKey != 'your_api_key_here';
  
  // Asynchrone Methoden für Quota-Management
  Future<bool> get hasApiQuotaRemaining async {
    final remaining = await getRemainingQuota();
    return remaining > 0;
  }
  
  Future<int> getRemainingQuota() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Prüfe ob neuer Tag
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_quotaDateKey) ?? '';
    
    if (lastDate != today) {
      // Neuer Tag - Reset Counter
      await prefs.setString(_quotaDateKey, today);
      await prefs.setInt(_quotaKey, 0);
      return _dailyLimit;
    }
    
    final used = prefs.getInt(_quotaKey) ?? 0;
    return _dailyLimit - used;
  }
  
  Future<void> _incrementQuota() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_quotaKey) ?? 0;
    await prefs.setInt(_quotaKey, used + 1);
  }

  Future<List<Restaurant>> searchRestaurants({
    required double latitude,
    required double longitude,
    int radius = 2000,
    String type = 'restaurant',
  }) async {
    // Prüfe Quota
    final remaining = await getRemainingQuota();
    if (remaining <= 0) {
      throw PlacesException('API quota exceeded for today');
    }

    if (!hasValidApiKey) {
      throw PlacesException('API key not configured or invalid');
    }

    try {
      final url = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'type': type,
        'key': _apiKey,
        'language': 'de', // Für deutsche Ergebnisse
      });

      print('🌐 Calling Google Places API: ${url.toString().replaceAll(_apiKey, 'XXX')}');

      final response = await http.get(url);
      
      // Incrementiere Quota NACH erfolgreichem Request
      await _incrementQuota();
      
      print('📍 API Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw PlacesException('API request failed: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      
      print('📍 API Status: ${data['status']}');
      
      if (data['status'] == 'ZERO_RESULTS') {
        return []; // Keine Ergebnisse, aber kein Fehler
      }
      
      if (data['status'] != 'OK') {
        throw PlacesException('Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
      }

      final results = data['results'] as List;
      
      print('📍 Found ${results.length} restaurants');
      
      // Filtere und sortiere Restaurants
      final restaurants = results
          .map((json) => Restaurant.fromJson(json))
          .where((restaurant) => restaurant.rating >= 3.5)
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating)); // Sortiere nach Rating
      
      // Nimm die besten 3
      return restaurants.take(3).toList();

    } catch (e) {
      print('❌ PlacesService Error: $e');
      if (e is PlacesException) rethrow;
      throw PlacesException('Network error: $e');
    }
  }

  String? getPhotoUrl(String? photoReference, {int maxWidth = 400}) {
    if (photoReference == null || !hasValidApiKey) {
      return null;
    }
    
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }
}

class PlacesException implements Exception {
  final String message;
  PlacesException(this.message);
  
  @override
  String toString() => 'PlacesException: $message';
}