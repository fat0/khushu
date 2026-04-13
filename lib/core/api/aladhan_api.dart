import 'package:dio/dio.dart';
import '../debug_log.dart';
import '../models/prayer_times.dart';

class AlAdhanApi {
  static Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// For testing only — inject a mock Dio instance
  static void setDioForTesting(Dio dio) => _dio = dio;

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
      final response = await _makeRequestWithRetry(url);
      return parseResponse(response.data as Map<String, dynamic>, targetDate);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Rate limit already retried — let fallback handle it
        throw PrayerTimesException('Prayer times service is busy. Using offline calculation.');
      }
      throw PrayerTimesException('No internet connection. Please check your network.');
    }
  }

  /// Makes a request with one retry on HTTP 429 (rate limit).
  /// Reads Retry-After header if present, otherwise waits 2 seconds.
  static Future<Response> _makeRequestWithRetry(String url) async {
    final response = await _dio.get(url);

    if (response.statusCode == 429) {
      DebugLog.info('[API] Rate limited (429) — retrying...');

      // Read Retry-After header (seconds), default to 2
      final retryAfter = response.headers.value('Retry-After');
      final waitSeconds = int.tryParse(retryAfter ?? '') ?? 2;

      DebugLog.info('[API] Waiting $waitSeconds seconds before retry');
      await Future.delayed(Duration(seconds: waitSeconds));

      // Retry once
      final retryResponse = await _dio.get(url);
      if (retryResponse.statusCode == 429) {
        DebugLog.info('[API] Rate limited again after retry — falling back to offline');
        throw DioException(
          requestOptions: retryResponse.requestOptions,
          response: retryResponse,
          type: DioExceptionType.badResponse,
        );
      }
      return retryResponse;
    }

    if (response.statusCode != 200) {
      throw PrayerTimesException('Could not load prayer times');
    }

    return response;
  }
}

class PrayerTimesException implements Exception {
  final String message;
  const PrayerTimesException(this.message);

  @override
  String toString() => message;
}
