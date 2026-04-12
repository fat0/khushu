import 'notification_type.dart';

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
  final Map<String, NotificationType> notificationTypes;

  const UserSettings({
    this.fiqh = Fiqh.sunni,
    this.methodId,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
    this.notificationTypes = const {},
  });

  NotificationType notificationFor(String prayerName) {
    if (prayerName == 'Sunrise') return NotificationType.off;
    return notificationTypes[prayerName] ?? NotificationType.off;
  }

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
    Map<String, NotificationType>? notificationTypes,
  }) {
    return UserSettings(
      fiqh: fiqh ?? this.fiqh,
      methodId: methodId ?? this.methodId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      notificationTypes: notificationTypes ?? this.notificationTypes,
    );
  }

  Map<String, dynamic> toJson() => {
        'fiqh': fiqh.index,
        'methodId': methodId,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
        'notificationTypes': notificationTypes.map(
          (key, value) => MapEntry(key, value.index),
        ),
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final fiqhIndex = json['fiqh'] as int? ?? 0;
    final fiqh = fiqhIndex >= 2 ? Fiqh.jafari : Fiqh.sunni;

    final rawMap = json['notificationTypes'];
    final notificationTypesRaw = rawMap is Map
        ? Map<String, dynamic>.from(rawMap)
        : <String, dynamic>{};
    final notificationTypes = notificationTypesRaw.map(
      (key, value) {
        final index = value as int;
        if (index >= 0 && index < NotificationType.values.length) {
          return MapEntry(key, NotificationType.values[index]);
        }
        // Migration: old enum had 5 values, map to new 3-value enum
        if (index == 3) return MapEntry(key, NotificationType.sound);
        if (index == 4) return MapEntry(key, NotificationType.adhan);
        return MapEntry(key, NotificationType.sound);
      },
    );

    return UserSettings(
      fiqh: fiqh,
      methodId: json['methodId'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      notificationTypes: notificationTypes,
    );
  }
}
