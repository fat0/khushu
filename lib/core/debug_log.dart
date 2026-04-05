import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: kDebugMode ? Level.debug : Level.off,
);

class DebugLog {
  static void gps(String message) => _logger.d('[GPS] $message');
  static void api(String message) => _logger.d('[API] $message');
  static void storage(String message) => _logger.d('[STORAGE] $message');
  static void nav(String message) => _logger.d('[NAV] $message');

  static void info(String message) => _logger.i(message);

  static void gpsWarning(String message) => _logger.w('[GPS] $message');
  static void apiWarning(String message) => _logger.w('[API] $message');

  static void gpsError(String message, [dynamic error]) =>
      _logger.e('[GPS] $message', error: error);
  static void apiError(String message, [dynamic error]) =>
      _logger.e('[API] $message', error: error);
}
