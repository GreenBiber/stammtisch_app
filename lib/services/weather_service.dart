import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }

  bool get isGoodWeatherForOutdoor {
    // Gutes Wetter für Outdoor-Locations (Biergarten, Terrasse)
    return temperature >= 15 && 
           !['Rain', 'Snow', 'Thunderstorm'].contains(condition);
  }

  bool get isSummerWeather {
    return temperature >= 20;
  }

  bool get isWinterWeather {
    return temperature < 10;
  }

  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  String get _apiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  
  bool get hasValidApiKey => _apiKey.isNotEmpty && _apiKey != 'your_weather_api_key_here';

  Future<WeatherData?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (!hasValidApiKey) {
      print('⚠️ Weather API key not configured');
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/weather').replace(queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': _apiKey,
        'units': 'metric', // Celsius
        'lang': 'de', // Deutsche Beschreibungen
      });

      print('🌤️ Calling Weather API: ${url.toString().replaceAll(_apiKey, 'XXX')}');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('❌ Weather API request failed: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body);
      return WeatherData.fromJson(data);

    } catch (e) {
      print('❌ Weather API Error: $e');
      return null;
    }
  }

  List<String> getWeatherBasedRestaurantTypes(WeatherData? weather) {
    if (weather == null) {
      return ['restaurant']; // Default fallback
    }

    List<String> types = ['restaurant'];

    if (weather.isGoodWeatherForOutdoor) {
      types.addAll(['bar', 'cafe']); // Biergarten, Terrassen
    }

    if (weather.isSummerWeather) {
      types.addAll(['bar']); // Rooftop bars, Strandlokale
    }

    if (weather.isWinterWeather || weather.condition == 'Rain') {
      // Bei schlechtem Wetter: gemütliche Indoor-Locations bevorzugen
      types.add('restaurant');
    }

    return types.toSet().toList(); // Duplikate entfernen
  }

  String getWeatherBasedRecommendation(WeatherData? weather) {
    if (weather == null) {
      return 'Wetter-Daten nicht verfügbar';
    }

    if (weather.isGoodWeatherForOutdoor) {
      return '${weather.weatherEmoji} ${weather.temperature.round()}°C - Perfekt für Biergarten oder Terrasse!';
    } else if (weather.condition == 'Rain') {
      return '${weather.weatherEmoji} ${weather.temperature.round()}°C - Gemütliches Indoor-Restaurant wäre ideal';
    } else if (weather.isWinterWeather) {
      return '${weather.weatherEmoji} ${weather.temperature.round()}°C - Warme Küche und gemütliche Atmosphäre';
    } else {
      return '${weather.weatherEmoji} ${weather.temperature.round()}°C - ${weather.description}';
    }
  }
}