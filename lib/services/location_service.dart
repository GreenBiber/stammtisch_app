import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? cityName;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.cityName,
  });
}

class LocationService {
  static LocationService? _instance;
  LocationService._();
  
  factory LocationService() {
    _instance ??= LocationService._();
    return _instance!;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check permissions
      if (!await _hasLocationPermission()) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
    } catch (e) {
      return null; // Graceful fallback
    }
  }

  Future<bool> _hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }
}