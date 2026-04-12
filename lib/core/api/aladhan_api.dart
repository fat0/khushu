import 'package:dio/dio.dart';
import '../models/prayer_times.dart';

class AlAdhanApi {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static String buildUrl({
    required double latitude,
    required double longitude,
    required int method,
    required int school,
    required DateTime date,
  }) {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    return 'https://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$method'
        '&school=$school';
  }

  static PrayerTimes parseResponse(Map<String, dynamic> json, DateTime date) {
    final data = json['data'];
    if (data == null) {
      throw PrayerTimesException('Prayer times service returned an invalid response');
    }
    final timings = data['timings'];
    if (timings == null) {
      throw PrayerTimesException('Prayer times not available for this location');
    }
    return PrayerTimes.fromAlAdhanJson(timings as Map<String, dynamic>, date);
  }

  static Future<PrayerTimes> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int school,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final url = buildUrl(
      latitude: latitude,
      longitude: longitude,
      method: method,
      school: school,
      date: targetDate,
    );

    try {
      final response = await _dio.get(url);
      if (response.statusCode != 200) {
        throw PrayerTimesException('Could not load prayer times');
      }
      return parseResponse(response.data as Map<String, dynamic>, targetDate);
    } on DioException {
      throw PrayerTimesException('No internet connection. Please check your network.');
    }
  }
}

class PrayerTimesException implements Exception {
  final String message;
  const PrayerTimesException(this.message);

  @override
  String toString() => message;
}
