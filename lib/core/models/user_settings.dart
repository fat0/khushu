enum Fiqh {
  sunniStandard,
  sunniHanafi,
  jafari,
}

class UserSettings {
  final Fiqh fiqh;
  final int? methodId;
  final bool combinePrayers;
  final bool? darkMode;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool onboardingComplete;

  const UserSettings({
    this.fiqh = Fiqh.sunniStandard,
    this.methodId,
    this.combinePrayers = false,
    this.darkMode,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
  });

  int get apiSchool => fiqh == Fiqh.sunniHanafi ? 1 : 0;

  int get apiMethod {
    if (fiqh == Fiqh.jafari) return 0;
    return methodId ?? 3;
  }

  UserSettings copyWith({
    Fiqh? fiqh,
    int? methodId,
    bool? combinePrayers,
    bool? darkMode,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? onboardingComplete,
  }) {
    return UserSettings(
      fiqh: fiqh ?? this.fiqh,
      methodId: methodId ?? this.methodId,
      combinePrayers: combinePrayers ?? this.combinePrayers,
      darkMode: darkMode ?? this.darkMode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'fiqh': fiqh.index,
        'methodId': methodId,
        'combinePrayers': combinePrayers,
        'darkMode': darkMode,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        fiqh: Fiqh.values[json['fiqh'] as int? ?? 0],
        methodId: json['methodId'] as int?,
        combinePrayers: json['combinePrayers'] as bool? ?? false,
        darkMode: json['darkMode'] as bool?,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        locationName: json['locationName'] as String?,
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
}
