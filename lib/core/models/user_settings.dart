enum Tradition {
  sunniStandard,
  sunniHanafi,
  jafari,
}

class UserSettings {
  final Tradition tradition;
  final int? methodId;
  final bool combinePrayers;
  final bool? darkMode;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool onboardingComplete;

  const UserSettings({
    this.tradition = Tradition.sunniStandard,
    this.methodId,
    this.combinePrayers = false,
    this.darkMode,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
  });

  int get apiSchool => tradition == Tradition.sunniHanafi ? 1 : 0;

  int get apiMethod {
    if (tradition == Tradition.jafari) return 0;
    return methodId ?? 3;
  }

  UserSettings copyWith({
    Tradition? tradition,
    int? methodId,
    bool? combinePrayers,
    bool? darkMode,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? onboardingComplete,
  }) {
    return UserSettings(
      tradition: tradition ?? this.tradition,
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
        'tradition': tradition.index,
        'methodId': methodId,
        'combinePrayers': combinePrayers,
        'darkMode': darkMode,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        tradition: Tradition.values[json['tradition'] as int? ?? 0],
        methodId: json['methodId'] as int?,
        combinePrayers: json['combinePrayers'] as bool? ?? false,
        darkMode: json['darkMode'] as bool?,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        locationName: json['locationName'] as String?,
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
}
