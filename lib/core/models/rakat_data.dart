import 'user_settings.dart';

class RakatItem {
  final int count;
  final String label;
  final String? note;

  const RakatItem(this.count, this.label, [this.note]);

  String get display {
    final n = note != null ? ' $note' : '';
    return '$count $label$n';
  }
}

class RakatInfo {
  final List<RakatItem> items;
  final bool isSunrise;

  const RakatInfo(this.items, {this.isSunrise = false});

  static const sunrise = RakatInfo([], isSunrise: true);
  static const sunriseNote = 'Marks the end of Fajr time — no prayer';
}

class RakatData {
  static List<RakatItem> getRakat(String prayerName, Fiqh fiqh) {
    final info = getInfo(prayerName, fiqh);
    return info.items;
  }

  static RakatInfo getInfo(String prayerName, Fiqh fiqh) {
    final key = _normalizeKey(prayerName);
    if (key == 'sunrise') return RakatInfo.sunrise;

    final data = _data[fiqh]?[key];
    if (data == null) return const RakatInfo([]);
    return data;
  }

  static String _normalizeKey(String prayerName) {
    // Handle "Asr (Maliki, Hanbali, Shafi'i)" and "Asr (Hanafi)" -> "asr"
    final lower = prayerName.toLowerCase();
    if (lower.startsWith('asr')) return 'asr';
    return lower;
  }

  static const _sunni = {
    'fajr': RakatInfo([
      RakatItem(2, 'Sunnah'),
      RakatItem(2, 'Fard'),
    ]),
    'dhuhr': RakatInfo([
      RakatItem(2, 'Sunnah', '(4 for Hanafi)'),
      RakatItem(4, 'Fard'),
      RakatItem(2, 'Sunnah'),
    ]),
    'asr': RakatInfo([
      RakatItem(4, 'Fard'),
    ]),
    'maghrib': RakatInfo([
      RakatItem(3, 'Fard'),
      RakatItem(2, 'Sunnah'),
    ]),
    'isha': RakatInfo([
      RakatItem(4, 'Fard'),
      RakatItem(2, 'Sunnah'),
      RakatItem(3, 'Witr'),
    ]),
  };

  static const _jafari = {
    'fajr': RakatInfo([
      RakatItem(2, 'Nafilah'),
      RakatItem(2, 'Fard'),
    ]),
    'dhuhr': RakatInfo([
      RakatItem(8, 'Nafilah'),
      RakatItem(4, 'Fard'),
    ]),
    'asr': RakatInfo([
      RakatItem(8, 'Nafilah'),
      RakatItem(4, 'Fard'),
    ]),
    'maghrib': RakatInfo([
      RakatItem(3, 'Fard'),
      RakatItem(4, 'Nafilah'),
    ]),
    'isha': RakatInfo([
      RakatItem(4, 'Fard'),
      RakatItem(2, 'Nafilah'),
    ]),
  };

  static const _data = {
    Fiqh.sunni: _sunni,
    Fiqh.jafari: _jafari,
  };
}
