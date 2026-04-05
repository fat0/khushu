enum Fiqh {
  sunni,
  jafari,
}

class UserSettings {
  final Fiqh fiqh;
  final int? methodId;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool onboardingComplete;

  const UserSettings({
    this.fiqh = Fiqh.sunni,
    this.methodId,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
  });

  int get apiMethod {
    if (fiqh == Fiqh.jafari) return 0;
    return methodId ?? 3;
  }

  UserSettings copyWith({
    Fiqh? fiqh,
    int? methodId,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? onboardingComplete,
  }) {
    return UserSettings(
      fiqh: fiqh ?? this.fiqh,
      methodId: methodId ?? this.methodId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'fiqh': fiqh.index,
        'methodId': methodId,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    // Migration: old sunniStandard(0) and sunniHanafi(1) both map to sunni(0)
    final fiqhIndex = json['fiqh'] as int? ?? 0;
    final fiqh = fiqhIndex >= 2 ? Fiqh.jafari : Fiqh.sunni;

    return UserSettings(
      fiqh: fiqh,
      methodId: json['methodId'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }
}
