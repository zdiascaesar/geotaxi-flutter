import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.languageSelectionTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LanguageButton(
                        languageName: 'English',
                        locale: const Locale('en', ''),
                        isSelected: languageProvider.currentLocale.languageCode == 'en',
                        onSelected: (locale) => _updateLanguage(context, locale),
                      ),
                      const SizedBox(height: 20),
                      LanguageButton(
                        languageName: 'Русский',
                        locale: const Locale('ru', ''),
                        isSelected: languageProvider.currentLocale.languageCode == 'ru',
                        onSelected: (locale) => _updateLanguage(context, locale),
                      ),
                      const SizedBox(height: 20),
                      LanguageButton(
                        languageName: 'Türkçe',
                        locale: const Locale('tr', ''),
                        isSelected: languageProvider.currentLocale.languageCode == 'tr',
                        onSelected: (locale) => _updateLanguage(context, locale),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                style: AppTheme.elevatedButtonStyle,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                },
                child: Text(l10n.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateLanguage(BuildContext context, Locale locale) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.setLocale(locale);
  }
}

class LanguageButton extends StatelessWidget {
  final String languageName;
  final Locale locale;
  final bool isSelected;
  final Function(Locale) onSelected;

  const LanguageButton({
    Key? key,
    required this.languageName,
    required this.locale,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 42,
      child: ElevatedButton(
        style: isSelected
            ? AppTheme.elevatedButtonStyle
            : AppTheme.outlinedButtonStyle,
        onPressed: () => onSelected(locale),
        child: Text(
          languageName,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? AppColors.textLight : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
