import 'package:adhan/adhan.dart' as adhan;
import 'package:intl/intl.dart';
import '../debug_log.dart';
import '../models/prayer_times.dart';

/// Calculates prayer times locally using the adhan-dart library.
/// Used as a fallback when the AlAdhan API is unavailable.
class OfflineCalculator {
  /// Map AlAdhan API method IDs to adhan-dart CalculationMethod
  static adhan.CalculationParameters _getCalculationParams(int methodId) {
    final method = switch (methodId) {
      0 => adhan.CalculationMethod.tehran, // Jafari/Qum — closest Shia method
      1 => adhan.CalculationMethod.karachi,
      2 => adhan.CalculationMethod.north_america, // ISNA
      3 => adhan.CalculationMethod.muslim_world_league,
      4 => adhan.CalculationMethod.umm_al_qura,
      5 => adhan.CalculationMethod.egyptian,
      7 => adhan.CalculationMethod.tehran,
      8 => adhan.CalculationMethod.qatar,
      9 => adhan.CalculationMethod.kuwait,
      11 => adhan.CalculationMethod.singapore,
      13 => adhan.CalculationMethod.turkey,
      15 => adhan.CalculationMethod.moon_sighting_committee,
      _ => adhan.CalculationMethod.muslim_world_league, // Default
    };
    return method.getParameters();
  }

  /// Calculate prayer times for a given location, date, method, and fiqh.
  /// Returns a PrayerTimes model matching the API response format.
  static PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required int methodId,
    required bool isSunni,
    required DateTime date,
  }) {
    final coordinates = adhan.Coordinates(latitude, longitude);
    final dateComponents = adhan.DateComponents(date.year, date.month, date.day);
    final fmt = DateFormat('HH:mm');

    // Standard calculation (school=0, Madhab.shafi)
    final params = _getCalculationParams(methodId);
    params.madhab = adhan.Madhab.shafi;
    final times = adhan.PrayerTimes(coordinates, dateComponents, params);

    String? asrHanafi;
    if (isSunni) {
      // Hanafi Asr (school=1)
      final hanafiParams = _getCalculationParams(methodId);
      hanafiParams.madhab = adhan.Madhab.hanafi;
      final hanafiTimes = adhan.PrayerTimes(coordinates, dateComponents, hanafiParams);
      asrHanafi = fmt.format(hanafiTimes.asr);
    }

    final result = PrayerTimes(
      fajr: fmt.format(times.fajr),
      sunrise: fmt.format(times.sunrise),
      dhuhr: fmt.format(times.dhuhr),
      asr: fmt.format(times.asr),
      asrHanafi: asrHanafi,
      maghrib: fmt.format(times.maghrib),
      isha: fmt.format(times.isha),
      date: date,
      source: PrayerTimeSource.offline,
    );

    DebugLog.info('[OFFLINE] Calculated prayer times: Fajr=${result.fajr}, Dhuhr=${result.dhuhr}, Asr=${result.asr}, Maghrib=${result.maghrib}, Isha=${result.isha}');
    return result;
  }
}
