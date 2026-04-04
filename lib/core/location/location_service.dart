import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../debug_log.dart';

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
      DebugLog.gps('Checking if location service is enabled...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      DebugLog.gps('serviceEnabled=$serviceEnabled');
      if (!serviceEnabled) {
        DebugLog.gpsWarning('Location service is disabled');
        return null;
      }

      DebugLog.gps('Checking permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      DebugLog.gps('permission=$permission');
      if (permission == LocationPermission.denied) {
        DebugLog.gps('Requesting permission...');
        permission = await Geolocator.requestPermission();
        DebugLog.gps('permission after request=$permission');
        if (permission == LocationPermission.denied) {
          DebugLog.gpsWarning('Permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        DebugLog.gpsWarning('Permission denied forever');
        return null;
      }

      DebugLog.gps('Trying getLastKnownPosition...');
      final lastKnown = await Geolocator.getLastKnownPosition();
      DebugLog.gps('lastKnown=${lastKnown != null ? "${lastKnown.latitude},${lastKnown.longitude}" : "null"}');
      if (lastKnown != null) {
        DebugLog.gps('Reverse geocoding last known position...');
        final name = await _reverseGeocode(lastKnown.latitude, lastKnown.longitude);
        DebugLog.gps('Resolved to: $name');
        return LocationResult(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          name: name,
        );
      }

      DebugLog.gps('Trying getCurrentPosition (15s timeout)...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 15));
      DebugLog.gps('position=${position.latitude},${position.longitude}');

      DebugLog.gps('Reverse geocoding current position...');
      final name = await _reverseGeocode(position.latitude, position.longitude);
      DebugLog.gps('Resolved to: $name');

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        name: name,
      );
    } catch (e) {
      DebugLog.gpsError('getCurrentLocation failed', e);
      return null;
    }
  }

  static Future<LocationResult?> searchCity(String query) async {
    try {
      DebugLog.gps('searchCity: query="$query"');
      final locations = await locationFromAddress(query);
      DebugLog.gps('searchCity: got ${locations.length} results');
      if (locations.isEmpty) return null;

      final loc = locations.first;
      DebugLog.gps('searchCity: first result=${loc.latitude},${loc.longitude}');
      final name = await _reverseGeocode(loc.latitude, loc.longitude);
      DebugLog.gps('searchCity: resolved to: $name');

      return LocationResult(
        latitude: loc.latitude,
        longitude: loc.longitude,
        name: name,
      );
    } catch (e) {
      DebugLog.gpsError('searchCity failed', e);
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
