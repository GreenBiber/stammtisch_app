import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherData {
  final double temperature;
  final String description;
  final String mainCondition;
  final double humidity;
  final double windSpeed;
  final int visibility;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    
    return WeatherData(
      temperature: (main['temp'] ?? 20.0).toDouble(),
      description: weather['description'] ?? '',
      mainCondition: weather['main'] ?? '',
      humidity: (main['humidity'] ?? 0.0).toDouble(),
      windSpeed: (wind['speed'] ?? 0.0).toDouble(),
      visibility: (json['visibility'] ?? 10000) ~/ 1000, // Convert to km
      icon: weather['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'mainCondition': mainCondition,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'visibility': visibility,
      'icon': icon,
    };
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  String get _apiKey {
    try {
      return dotenv.env['WEATHER_API_KEY'] ?? '';
    } catch (e) {
      // dotenv not initialized or .env file not found
      debugPrint('Warning: dotenv not properly initialized - $e');
      return '';
    }
  }
  
  bool get hasValidApiKey => _apiKey.isNotEmpty;

  Future<WeatherData?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (!hasValidApiKey) {
      debugPrint('⚠️ OpenWeather API key not configured');
      return _getFallbackWeather();
    }

    final url = Uri.parse(
      '$_baseUrl/weather?'
      'lat=$latitude&'
      'lon=$longitude&'
      'appid=$_apiKey&'
      'units=metric&'
      'lang=de'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        debugPrint('⚠️ Weather API Error: ${response.statusCode}');
        return _getFallbackWeather();
      }
    } catch (e) {
      debugPrint('⚠️ Weather API Network Error: $e');
      return _getFallbackWeather();
    }
  }

  WeatherData _getFallbackWeather() {
    // Return realistic fallback weather data
    return WeatherData(
      temperature: 18.0,
      description: 'Teilweise bewölkt',
      mainCondition: 'Clouds',
      humidity: 65.0,
      windSpeed: 3.2,
      visibility: 8,
      icon: '02d',
    );
  }

  String? getWeatherBasedRecommendation(WeatherData? weather) {
    if (weather == null) return null;

    final temp = weather.temperature;
    final condition = weather.mainCondition.toLowerCase();
    final season = _getCurrentSeason();

    if (temp >= 25) {
      if (season == 'summer') {
        return "☀️ Perfektes Wetter für eine Terrasse oder den Beachclub!";
      }
      return "☀️ Warmer Tag - wie wär's mit einem Restaurant mit Außenbereich?";
    } else if (temp <= 5 || condition.contains('rain') || condition.contains('snow')) {
      return "🏠 Bei dem Wetter gemütlich drinnen - perfekt für ein Restaurant mit warmer Atmosphäre!";
    } else if (condition.contains('cloud')) {
      return "☁️ Ideales Wetter für jeden Restauranttyp - innen oder außen!";
    }

    return "🌤️ Schönes Wetter für euren Stammtisch!";
  }

  List<String> getWeatherBasedRestaurantTypes(WeatherData? weather) {
    if (weather == null) return ['restaurant'];

    final temp = weather.temperature;
    final condition = weather.mainCondition.toLowerCase();
    final season = _getCurrentSeason();

    List<String> types = ['restaurant'];

    if (temp >= 25 && season == 'summer') {
      types.addAll(['bar', 'cafe']);
    } else if (temp <= 5 || condition.contains('rain')) {
      types.addAll(['cafe', 'meal_takeaway']);
    }

    return types;
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    if (month >= 12 || month <= 2) return 'winter';
    return 'spring';
  }

  String getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': case '01n': return '☀️';
      case '02d': case '02n': return '⛅';
      case '03d': case '03n': case '04d': case '04n': return '☁️';
      case '09d': case '09n': case '10d': case '10n': return '🌧️';
      case '11d': case '11n': return '⛈️';
      case '13d': case '13n': return '❄️';
      case '50d': case '50n': return '🌫️';
      default: return '🌤️';
    }
  }
}