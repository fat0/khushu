import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/api/aladhan_api.dart';

/// Interceptor that returns a fake response for testing
class _FakeInterceptor extends Interceptor {
  final List<int> statusCodes;
  final Map<String, dynamic>? responseData;
  final Map<String, List<String>>? headers;
  int _callCount = 0;

  _FakeInterceptor({
    required this.statusCodes,
    this.responseData,
    this.headers,
  });

  int get callCount => _callCount;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _callCount++;
    final statusIndex = _callCount <= statusCodes.length ? _callCount - 1 : statusCodes.length - 1;
    final statusCode = statusCodes[statusIndex];

    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: statusCode,
        data: statusCode == 200 ? (responseData ?? _validApiResponse()) : null,
        headers: Headers.fromMap(headers ?? {}),
      ),
    );
  }

  static Map<String, dynamic> _validApiResponse() => {
        'data': {
          'timings': {
            'Fajr': '05:00',
            'Sunrise': '06:30',
            'Dhuhr': '13:00',
            'Asr': '16:30',
            'Maghrib': '19:30',
            'Isha': '21:00',
          }
        }
      };
}

Dio _createMockDio(_FakeInterceptor interceptor) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 1),
    receiveTimeout: const Duration(seconds: 1),
  ));
  dio.interceptors.add(interceptor);
  return dio;
}

void main() {
  tearDown(() {
    // Reset to real Dio after each test
    AlAdhanApi.setDioForTesting(Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));
  });

  group('AlAdhanApi - API failure triggers PrayerTimesException', () {
    test('DioException throws PrayerTimesException', () async {
      final interceptor = _FakeInterceptor(statusCodes: [429]);
      AlAdhanApi.setDioForTesting(_createMockDio(interceptor));

      expect(
        () => AlAdhanApi.fetchPrayerTimes(
          latitude: 39.0,
          longitude: -77.0,
          method: 2,
          school: 0,
        ),
        throwsA(isA<PrayerTimesException>()),
      );
    });

    test('non-200 response throws PrayerTimesException', () async {
      final interceptor = _FakeInterceptor(statusCodes: [500]);
      AlAdhanApi.setDioForTesting(_createMockDio(interceptor));

      expect(
        () => AlAdhanApi.fetchPrayerTimes(
          latitude: 39.0,
          longitude: -77.0,
          method: 2,
          school: 0,
        ),
        throwsA(isA<PrayerTimesException>()),
      );
    });
  });

  group('AlAdhanApi - Rate limit (429) handling', () {
    test('429 triggers retry — retry succeeds', () async {
      // First call: 429, second call: 200
      final interceptor = _FakeInterceptor(statusCodes: [429, 200]);
      AlAdhanApi.setDioForTesting(_createMockDio(interceptor));

      final times = await AlAdhanApi.fetchPrayerTimes(
        latitude: 39.0,
        longitude: -77.0,
        method: 2,
        school: 0,
      );

      expect(times.fajr, '05:00');
      expect(interceptor.callCount, 2); // Initial + retry
    });

    test('429 twice throws PrayerTimesException', () async {
      // Both calls: 429
      final interceptor = _FakeInterceptor(statusCodes: [429, 429]);
      AlAdhanApi.setDioForTesting(_createMockDio(interceptor));

      expect(
        () => AlAdhanApi.fetchPrayerTimes(
          latitude: 39.0,
          longitude: -77.0,
          method: 2,
          school: 0,
        ),
        throwsA(isA<PrayerTimesException>()),
      );
    });

    test('429 with Retry-After header waits specified time', () async {
      // First call: 429 with Retry-After: 1, second call: 200
      final interceptor = _FakeInterceptor(
        statusCodes: [429, 200],
        headers: {'Retry-After': ['1']},
      );
      AlAdhanApi.setDioForTesting(_createMockDio(interceptor));

      final stopwatch = Stopwatch()..start();
      final times = await AlAdhanApi.fetchPrayerTimes(
        latitude: 39.0,
        longitude: -77.0,
        method: 2,
        school: 0,
      );
      stopwatch.stop();

      expect(times.fajr, '05:00');
      // Should have waited at least 1 second (the Retry-After value)
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(900));
    });
  });

  group('AlAdhanApi - Successful requests', () {
    test('200 response returns PrayerTimes', () async {
      final interceptor = _FakeInterceptor(statusCodes: [200]);
      AlAdhanApi.setDioForTesting(_createMockDio(interceptor));

      final times = await AlAdhanApi.fetchPrayerTimes(
        latitude: 39.0,
        longitude: -77.0,
        method: 2,
        school: 0,
      );

      expect(times.fajr, '05:00');
      expect(times.dhuhr, '13:00');
      expect(interceptor.callCount, 1); // Only one call
    });
  });
}
