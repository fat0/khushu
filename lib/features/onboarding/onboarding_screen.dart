import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_provider.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _locationName;
  bool _locationLoading = false;
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tryGps();
  }

  Future<void> _tryGps() async {
    setState(() => _locationLoading = true);
    final controller = ref.read(onboardingProvider);
    final success = await controller.setupLocation();
    if (mounted) {
      setState(() {
        _locationLoading = false;
        if (success) {
          _locationName = ref.read(settingsProvider).locationName;
        }
      });
    }
  }

  Future<void> _searchCity() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) return;

    setState(() => _locationLoading = true);
    final controller = ref.read(onboardingProvider);
    final result = await controller.searchCity(query);
    if (mounted) {
      setState(() {
        _locationLoading = false;
        if (result != null) {
          _locationName = result.name;
          _cityController.clear();
        }
      });
    }
  }

  Future<void> _selectTradition(Tradition tradition) async {
    if (_locationName == null) return;
    final controller = ref.read(onboardingProvider);
    await controller.selectTradition(tradition);
    if (mounted) context.go('/prayer-times');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
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
              const SizedBox(height: 32),

              // Location
              if (_locationLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_locationName != null)
                Text(
                  _locationName!,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Enter your city...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _searchCity(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _searchCity,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Tradition selection — always visible
              Text(
                'Which tradition do you follow?',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _TraditionButton(
                label: 'Sunni (Standard Asr)',
                subtitle: 'Maliki, Shafi\'i, Hanbali',
                isDark: isDark,
                enabled: _locationName != null,
                onTap: () => _selectTradition(Tradition.sunniStandard),
              ),
              const SizedBox(height: 10),
              _TraditionButton(
                label: 'Sunni (Hanafi Asr)',
                subtitle: 'Later Asr prayer time',
                isDark: isDark,
                enabled: _locationName != null,
                onTap: () => _selectTradition(Tradition.sunniHanafi),
              ),
              const SizedBox(height: 10),
              _TraditionButton(
                label: 'Shia (Jafari)',
                subtitle: 'Ithna-Ashari tradition',
                isDark: isDark,
                enabled: _locationName != null,
                onTap: () => _selectTradition(Tradition.jafari),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _TraditionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  const _TraditionButton({
    required this.label,
    required this.subtitle,
    required this.isDark,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.4;
    return Opacity(
      opacity: opacity,
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
                        color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
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
