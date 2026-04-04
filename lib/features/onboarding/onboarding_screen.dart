import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/location/city_data.dart';
import '../../core/location/region_detector.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  City? _selectedCity;

  Future<void> _selectCity(City city) async {
    final methodId = RegionDetector.detectMethod(city.latitude, city.longitude);
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setLocation(city.latitude, city.longitude, city.displayName);
    await notifier.setMethodId(methodId);
    setState(() => _selectedCity = city);
  }

  Future<void> _selectFiqh(Fiqh fiqh) async {
    if (_selectedCity == null) return;
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setFiqh(fiqh);
    await notifier.completeOnboarding();
    if (mounted) context.go('/prayer-times');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'KHUSHU',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'One Ummah Serving Allah',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // City autocomplete
              if (_selectedCity != null) ...[
                Text(
                  _selectedCity!.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.sage : AppColors.deepGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedCity = null),
                  child: const Text(
                    'Change city',
                    style: TextStyle(fontSize: 12, color: AppColors.sage),
                  ),
                ),
              ] else
                Autocomplete<City>(
                  displayStringForOption: (city) => city.displayName,
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.length < 2) return const [];
                    final query = textEditingValue.text.toLowerCase();
                    return cities.where((city) =>
                        city.name.toLowerCase().contains(query) ||
                        city.country.toLowerCase().contains(query));
                  },
                  onSelected: _selectCity,
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search your city...',
                        prefixIcon: Icon(Icons.search, size: 20, color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => onSubmitted(),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final city = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(
                                  city.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.sage : AppColors.deepGreen,
                                  ),
                                ),
                                onTap: () => onSelected(city),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              // Fiqh selection
              Text(
                'Which fiqh do you follow?',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _FiqhButton(
                label: 'Sunni (Standard Asr)',
                subtitle: 'Maliki, Shafi\'i, Hanbali',
                isDark: isDark,
                enabled: _selectedCity != null,
                onTap: () => _selectFiqh(Fiqh.sunniStandard),
              ),
              const SizedBox(height: 10),
              _FiqhButton(
                label: 'Sunni (Hanafi Asr)',
                subtitle: 'Later Asr prayer time',
                isDark: isDark,
                enabled: _selectedCity != null,
                onTap: () => _selectFiqh(Fiqh.sunniHanafi),
              ),
              const SizedBox(height: 10),
              _FiqhButton(
                label: 'Shia (Jafari)',
                subtitle: 'Ithna-Ashari jurisprudence',
                isDark: isDark,
                enabled: _selectedCity != null,
                onTap: () => _selectFiqh(Fiqh.jafari),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiqhButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  const _FiqhButton({
    required this.label,
    required this.subtitle,
    required this.isDark,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.sage : AppColors.deepGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkSecondary
                              : AppColors.lightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.sage,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
