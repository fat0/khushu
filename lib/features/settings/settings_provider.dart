import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_settings.dart';
import '../../core/storage/hive_service.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(HiveService.loadSettings());

  Future<void> setFiqh(Fiqh fiqh) async {
    state = state.copyWith(fiqh: fiqh);
    await HiveService.saveSettings(state);
    await HiveService.clearPrayerCache();
  }

  Future<void> setMethodId(int methodId) async {
    state = state.copyWith(methodId: methodId);
    await HiveService.saveSettings(state);
    await HiveService.clearPrayerCache();
  }

  Future<void> setLocation(double lat, double lng, String name) async {
    state = state.copyWith(latitude: lat, longitude: lng, locationName: name);
    await HiveService.saveSettings(state);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await HiveService.saveSettings(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});
