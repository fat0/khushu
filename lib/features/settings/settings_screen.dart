import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/location/location_service.dart';
import '../../core/location/region_detector.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/app_colors.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _cityController = TextEditingController();
  bool _showMethodOverride = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: theme.textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Fiqh
          const _SectionHeader('Fiqh'),
          const SizedBox(height: 8),
          ...Fiqh.values.map((t) => _FiqhTile(
                fiqh: t,
                isSelected: settings.fiqh == t,
                isDark: isDark,
                onTap: () => ref.read(settingsProvider.notifier).setFiqh(t),
              )),

          const SizedBox(height: 24),

          // Location
          const _SectionHeader('Location'),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Current',
            value: settings.locationName ?? 'Not set',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await LocationService.getCurrentLocation();
                    if (result != null) {
                      final method = RegionDetector.detectMethod(
                          result.latitude, result.longitude);
                      ref.read(settingsProvider.notifier).setLocation(
                          result.latitude, result.longitude, result.name);
                      ref.read(settingsProvider.notifier).setMethodId(method);
                    }
                  },
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Use GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    foregroundColor: AppColors.cream,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _searchCity(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _searchCity, icon: const Icon(Icons.search)),
            ],
          ),

          const SizedBox(height: 24),

          // Combine prayers
          const _SectionHeader('Display'),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Combine prayers',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.sage : AppColors.deepGreen)),
            subtitle: Text('Show Dhuhr+Asr and Maghrib+Isha together',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary)),
            value: settings.combinePrayers,
            activeColor: AppColors.sage,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setCombinePrayers(v),
          ),

          const SizedBox(height: 16),

          // Dark mode
          SwitchListTile(
            title: Text('Dark mode',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.sage : AppColors.deepGreen)),
            subtitle: Text('Follow system when off',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary)),
            value: settings.darkMode ?? false,
            activeColor: AppColors.sage,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setDarkMode(v ? true : null),
          ),

          const SizedBox(height: 24),

          // Advanced: method override
          TextButton(
            onPressed: () => setState(() => _showMethodOverride = !_showMethodOverride),
            child: Text(
              _showMethodOverride ? 'Hide advanced' : 'Advanced: Override calculation method',
              style: const TextStyle(fontSize: 12, color: AppColors.sage),
            ),
          ),
          if (_showMethodOverride) ...[
            const SizedBox(height: 8),
            ..._methods.entries.map((e) => RadioListTile<int>(
                  title: Text(e.value,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.sage : AppColors.deepGreen)),
                  value: e.key,
                  groupValue: settings.apiMethod,
                  activeColor: AppColors.sage,
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setMethodId(v);
                  },
                )),
          ],
        ],
      ),
    );
  }

  Future<void> _searchCity() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) return;
    final result = await LocationService.searchCity(query);
    if (result != null) {
      final method =
          RegionDetector.detectMethod(result.latitude, result.longitude);
      ref
          .read(settingsProvider.notifier)
          .setLocation(result.latitude, result.longitude, result.name);
      ref.read(settingsProvider.notifier).setMethodId(method);
      _cityController.clear();
    }
  }

  static const _methods = {
    0: 'Shia Ithna-Ashari (Qum)',
    1: 'University of Islamic Sciences, Karachi',
    2: 'ISNA (North America)',
    3: 'Muslim World League',
    4: 'Umm Al-Qura (Makkah)',
    5: 'Egyptian General Authority',
    7: 'Tehran (Univ. of Geophysics)',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Singapore (MUIS)',
    12: 'France (UOIF)',
    13: 'Turkey (Diyanet)',
    14: 'Russia',
    15: 'Moonsighting Committee',
  };
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.sage,
      ),
    );
  }
}

class _FiqhTile extends StatelessWidget {
  final Fiqh fiqh;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FiqhTile({
    required this.fiqh,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  String get _label => switch (fiqh) {
        Fiqh.sunniStandard => 'Sunni (Standard Asr)',
        Fiqh.sunniHanafi => 'Sunni (Hanafi Asr)',
        Fiqh.jafari => 'Shia (Jafari)',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected
            ? (isDark ? AppColors.highlightDark : AppColors.highlightLight)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isDark ? AppColors.sage : AppColors.deepGreen,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check, color: AppColors.sage, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.sage : AppColors.deepGreen)),
        ],
      ),
    );
  }
}
