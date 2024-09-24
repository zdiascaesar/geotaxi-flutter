import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.languageSelectionTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              _buildLanguageButton(context, localizations.englishLanguage, 'en'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, localizations.russianLanguage, 'ru'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, localizations.turkishLanguage, 'tr'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                },
                child: Text(localizations.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String languageName, String languageCode) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSelected = languageProvider.locale.languageCode == languageCode;

    return SizedBox(
      width: 160,
      height: 42,
      child: ElevatedButton(
        onPressed: () => _changeLanguage(context, languageCode),
        style: AppTheme.languageButtonStyle(isSelected: isSelected),
        child: Text(languageName),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.setLocale(Locale(languageCode));
    languageProvider.saveLanguage(languageCode);
  }
}