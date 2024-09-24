import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadInitialLanguage();
  }

  void _loadInitialLanguage() {
    final deviceLocale = ui.window.locale;
    if (['en', 'ru', 'tr'].contains(deviceLocale.languageCode)) {
      _currentLocale = Locale(deviceLocale.languageCode, '');
    }
  }

  void setLocale(Locale locale) async {
    if (!['en', 'ru', 'tr'].contains(locale.languageCode)) return;

    _currentLocale = locale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode, '');
      notifyListeners();
    } else {
      _loadInitialLanguage();
    }
  }
}