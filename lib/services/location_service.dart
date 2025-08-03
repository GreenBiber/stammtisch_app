import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum LocationPermissionState {
  notAsked,
  userDenied, 
  userGranted,
  systemDenied,
  disabled,
  granted
}

class LocationPermissionResult {
  final LocationPermissionState state;
  final String? message;
  final LocationData? locationData;

  LocationPermissionResult({
    required this.state,
    this.message,
    this.locationData,
  });
}

class LocationService {
  static LocationService? _instance;
  LocationService._();
  
  factory LocationService() {
    _instance ??= LocationService._();
    return _instance!;
  }

  static const String _userConsentKey = 'location_user_consent';
  static const String _permissionAskedKey = 'location_permission_asked';

  /// Check if user has given consent for location usage
  Future<bool> hasUserConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userConsentKey) ?? false;
  }

  /// Save user's consent decision
  Future<void> setUserConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userConsentKey, consent);
    if (consent) {
      await prefs.setBool(_permissionAskedKey, true);
    }
  }

  /// Check if we've already asked for permission
  Future<bool> hasAskedForPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionAskedKey) ?? false;
  }

  /// Get current location with user consent flow
  Future<LocationPermissionResult> getCurrentLocationWithConsent() async {
    try {
      // First check if user has given consent
      if (!await hasUserConsent()) {
        return LocationPermissionResult(
          state: LocationPermissionState.notAsked,
          message: 'User consent required for location access',
        );
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult(
          state: LocationPermissionState.disabled,
          message: 'Location services are disabled on this device',
        );
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionResult(
            state: LocationPermissionState.systemDenied,
            message: 'Location permission denied by system',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult(
          state: LocationPermissionState.systemDenied,
          message: 'Location permission permanently denied. Please enable in device settings.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print('📍 GPS Position obtained: lat=${position.latitude}, lng=${position.longitude}');
      print('📍 Accuracy: ${position.accuracy}m, Timestamp: ${position.timestamp}');

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationPermissionResult(
        state: LocationPermissionState.granted,
        locationData: locationData,
        message: 'Location access granted',
      );
      
    } catch (e) {
      return LocationPermissionResult(
        state: LocationPermissionState.systemDenied,
        message: 'Failed to get location: ${e.toString()}',
      );
    }
  }

  /// Legacy method for backward compatibility
  Future<LocationData?> getCurrentLocation() async {
    final result = await getCurrentLocationWithConsent();
    return result.locationData;
  }

  /// Reset all location preferences (for testing/debugging)
  Future<void> resetLocationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userConsentKey);
    await prefs.remove(_permissionAskedKey);
  }

  /// Get current permission state for UI display
  Future<LocationPermissionState> getPermissionState() async {
    // Check user consent first
    if (!await hasUserConsent()) {
      // If we haven't asked yet, check if it's because user denied before
      if (await hasAskedForPermission()) {
        return LocationPermissionState.userDenied;
      }
      return LocationPermissionState.notAsked;
    }

    // Check system permissions
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionState.disabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      switch (permission) {
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return LocationPermissionState.granted;
        case LocationPermission.denied:
          return LocationPermissionState.systemDenied;
        case LocationPermission.deniedForever:
          return LocationPermissionState.systemDenied;
        case LocationPermission.unableToDetermine:
          return LocationPermissionState.systemDenied;
      }
    } catch (e) {
      return LocationPermissionState.systemDenied;
    }
  }

  /// Reset user consent to allow asking again
  Future<void> resetUserConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userConsentKey, false);
    await prefs.setBool(_permissionAskedKey, false);
  }

  /// Force request permission even if denied before
  Future<LocationPermissionResult> forceRequestPermission() async {
    await resetUserConsent();
    return await getCurrentLocationWithConsent();
  }
}