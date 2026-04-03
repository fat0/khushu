import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_settings.dart';
import '../../core/storage/hive_service.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(HiveService.loadSettings());

  Future<void> setTradition(Tradition tradition) async {
    state = state.copyWith(tradition: tradition);
    await HiveService.saveSettings(state);
  }

  Future<void> setMethodId(int methodId) async {
    state = state.copyWith(methodId: methodId);
    await HiveService.saveSettings(state);
  }

  Future<void> setLocation(double lat, double lng, String name) async {
    state = state.copyWith(latitude: lat, longitude: lng, locationName: name);
    await HiveService.saveSettings(state);
  }

  Future<void> setCombinePrayers(bool combine) async {
    state = state.copyWith(combinePrayers: combine);
    await HiveService.saveSettings(state);
  }

  Future<void> setDarkMode(bool? darkMode) async {
    state = state.copyWith(darkMode: darkMode);
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
