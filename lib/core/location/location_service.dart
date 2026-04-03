import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String name;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}

class LocationService {
  static Future<LocationResult?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      // Try last known position first (instant)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final name = await _reverseGeocode(lastKnown.latitude, lastKnown.longitude);
        return LocationResult(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          name: name,
        );
      }

      // Fall back to current position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 15));

      final name = await _reverseGeocode(position.latitude, position.longitude);

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        name: name,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<LocationResult?> searchCity(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;

      final loc = locations.first;
      final name = await _reverseGeocode(loc.latitude, loc.longitude);

      return LocationResult(
        latitude: loc.latitude,
        longitude: loc.longitude,
        name: name,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.subAdministrativeArea ?? '';
        final country = p.isoCountryCode ?? '';
        if (city.isNotEmpty && country.isNotEmpty) return '$city, $country';
        if (city.isNotEmpty) return city;
        return country;
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';
  }
}
