class RegionDetector {
  /// Maps GPS coordinates to the best AlAdhan calculation method ID.
  /// Uses bounding-box regions — not perfect, but good enough for auto-detection.
  /// Users can override in settings.
  static int detectMethod(double latitude, double longitude) {
    // Turkey
    if (_inBox(latitude, longitude, 36, 42, 26, 45)) return 13;

    // Iran
    if (_inBox(latitude, longitude, 25, 40, 44, 63)) return 7;

    // Saudi Arabia + Yemen + Oman
    if (_inBox(latitude, longitude, 12, 32, 34, 56)) return 4;

    // Gulf states (UAE, Qatar, Bahrain, Kuwait)
    if (_inBox(latitude, longitude, 22, 32, 45, 56)) return 8;

    // Egypt
    if (_inBox(latitude, longitude, 22, 32, 24, 37)) return 5;

    // North Africa (Morocco, Algeria, Tunisia, Libya)
    if (_inBox(latitude, longitude, 18, 38, -18, 25)) return 5;

    // Pakistan, India, Bangladesh
    if (_inBox(latitude, longitude, 5, 38, 60, 93)) return 1;

    // SE Asia (Malaysia, Indonesia)
    if (_inBox(latitude, longitude, -11, 8, 95, 141)) return 17;

    // North America
    if (_inBox(latitude, longitude, 15, 72, -170, -50)) return 2;

    // Europe
    if (_inBox(latitude, longitude, 35, 72, -25, 45)) return 3;

    // Default: Muslim World League
    return 3;
  }

  static bool _inBox(
    double lat,
    double lng,
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}
