class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const City(this.name, this.country, this.latitude, this.longitude);

  String get displayName => '$name, $country';
}

const cities = [
  // North America
  City('New York', 'US', 40.7128, -74.0060),
  City('Los Angeles', 'US', 34.0522, -118.2437),
  City('Chicago', 'US', 41.8781, -87.6298),
  City('Houston', 'US', 29.7604, -95.3698),
  City('San Francisco', 'US', 37.7749, -122.4194),
  City('Dallas', 'US', 32.7767, -96.7970),
  City('Detroit', 'US', 42.3314, -83.0458),
  City('Washington DC', 'US', 38.9072, -77.0369),
  City('Philadelphia', 'US', 39.9526, -75.1652),
  City('Atlanta', 'US', 39.9526, -75.1652),
  City('Toronto', 'CA', 43.6532, -79.3832),
  City('Montreal', 'CA', 45.5017, -73.5673),
  City('Vancouver', 'CA', 49.2827, -123.1207),
  City('Mexico City', 'MX', 19.4326, -99.1332),

  // Europe
  City('London', 'UK', 51.5074, -0.1278),
  City('Birmingham', 'UK', 52.4862, -1.8904),
  City('Manchester', 'UK', 53.4808, -2.2426),
  City('Paris', 'FR', 48.8566, 2.3522),
  City('Berlin', 'DE', 52.5200, 13.4050),
  City('Amsterdam', 'NL', 52.3676, 4.9041),
  City('Brussels', 'BE', 50.8503, 4.3517),
  City('Stockholm', 'SE', 59.3293, 18.0686),
  City('Oslo', 'NO', 59.9139, 10.7522),
  City('Copenhagen', 'DK', 55.6761, 12.5683),
  City('Rome', 'IT', 41.9028, 12.4964),
  City('Madrid', 'ES', 40.4168, -3.7038),
  City('Barcelona', 'ES', 41.3874, 2.1686),
  City('Vienna', 'AT', 48.2082, 16.3738),
  City('Zurich', 'CH', 47.3769, 8.5417),
  City('Athens', 'GR', 37.9838, 23.7275),
  City('Moscow', 'RU', 55.7558, 37.6173),

  // Middle East
  City('Makkah', 'SA', 21.3891, 39.8579),
  City('Madinah', 'SA', 24.5247, 39.5692),
  City('Riyadh', 'SA', 24.7136, 46.6753),
  City('Jeddah', 'SA', 21.5433, 39.1728),
  City('Dubai', 'AE', 25.2048, 55.2708),
  City('Abu Dhabi', 'AE', 24.4539, 54.3773),
  City('Doha', 'QA', 25.2854, 51.5310),
  City('Kuwait City', 'KW', 29.3759, 47.9774),
  City('Muscat', 'OM', 23.5880, 58.3829),
  City('Manama', 'BH', 26.2285, 50.5860),
  City('Amman', 'JO', 31.9454, 35.9284),
  City('Beirut', 'LB', 33.8938, 35.5018),
  City('Baghdad', 'IQ', 33.3152, 44.3661),
  City('Erbil', 'IQ', 36.1901, 44.0091),
  City('Sanaa', 'YE', 15.3694, 44.1910),

  // Iran
  City('Tehran', 'IR', 35.6892, 51.3890),
  City('Isfahan', 'IR', 32.6546, 51.6680),
  City('Mashhad', 'IR', 36.2605, 59.6168),
  City('Shiraz', 'IR', 29.5918, 52.5837),
  City('Tabriz', 'IR', 38.0800, 46.2919),
  City('Qom', 'IR', 34.6416, 50.8746),

  // South Asia
  City('Karachi', 'PK', 24.8607, 67.0011),
  City('Lahore', 'PK', 31.5204, 74.3587),
  City('Islamabad', 'PK', 33.6844, 73.0479),
  City('Peshawar', 'PK', 34.0151, 71.5249),
  City('Mumbai', 'IN', 19.0760, 72.8777),
  City('Delhi', 'IN', 28.7041, 77.1025),
  City('Hyderabad', 'IN', 17.3850, 78.4867),
  City('Lucknow', 'IN', 26.8467, 80.9462),
  City('Dhaka', 'BD', 23.8103, 90.4125),
  City('Colombo', 'LK', 6.9271, 79.8612),

  // Turkey
  City('Istanbul', 'TR', 41.0082, 28.9784),
  City('Ankara', 'TR', 39.9334, 32.8597),
  City('Izmir', 'TR', 38.4237, 27.1428),
  City('Bursa', 'TR', 40.1885, 29.0610),

  // Africa
  City('Cairo', 'EG', 30.0444, 31.2357),
  City('Alexandria', 'EG', 31.2001, 29.9187),
  City('Casablanca', 'MA', 33.5731, -7.5898),
  City('Rabat', 'MA', 34.0209, -6.8416),
  City('Tunis', 'TN', 36.8065, 10.1815),
  City('Algiers', 'DZ', 36.7538, 3.0588),
  City('Lagos', 'NG', 6.5244, 3.3792),
  City('Abuja', 'NG', 9.0579, 7.4951),
  City('Nairobi', 'KE', 1.2921, 36.8219),
  City('Johannesburg', 'ZA', -26.2041, 28.0473),
  City('Cape Town', 'ZA', -33.9249, 18.4241),

  // SE Asia
  City('Jakarta', 'ID', -6.2088, 106.8456),
  City('Kuala Lumpur', 'MY', 3.1390, 101.6869),
  City('Singapore', 'SG', 1.3521, 103.8198),
  City('Bangkok', 'TH', 13.7563, 100.5018),

  // East Asia
  City('Tokyo', 'JP', 35.6762, 139.6503),
  City('Beijing', 'CN', 39.9042, 116.4074),
  City('Shanghai', 'CN', 31.2304, 121.4737),
  City('Seoul', 'KR', 37.5665, 126.9780),
  City('Sydney', 'AU', -33.8688, 151.2093),
  City('Melbourne', 'AU', -37.8136, 144.9631),
];
