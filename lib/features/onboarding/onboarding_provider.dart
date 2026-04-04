import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/location/location_service.dart';
import '../../core/location/region_detector.dart';
import '../../core/models/user_settings.dart';
import '../settings/settings_provider.dart';

final onboardingProvider = Provider((ref) => OnboardingController(ref));

class OnboardingController {
  final Ref _ref;

  OnboardingController(this._ref);

  Future<bool> setupLocation() async {
    final result = await LocationService.getCurrentLocation();
    if (result == null) return false;

    final methodId = RegionDetector.detectMethod(result.latitude, result.longitude);
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.setLocation(result.latitude, result.longitude, result.name);
    await notifier.setMethodId(methodId);
    return true;
  }

  Future<void> selectFiqh(Fiqh fiqh) async {
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.setFiqh(fiqh);
    await notifier.completeOnboarding();
  }

  Future<LocationResult?> searchCity(String query) async {
    final result = await LocationService.searchCity(query);
    if (result == null) return null;

    final methodId = RegionDetector.detectMethod(result.latitude, result.longitude);
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.setLocation(result.latitude, result.longitude, result.name);
    await notifier.setMethodId(methodId);
    return result;
  }
}
