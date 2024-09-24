import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/language_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/personal_information_screen.dart';
import 'screens/car_information_screen.dart';
import 'theme/app_theme.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBtVnnwrnsblvpS27tU-i4CGncHh-5xNo0',
      appId: '1:237031142553:ios:4fb92c6f6115b35e2cb408',
      messagingSenderId: '237031142553',
      projectId: 'geo-taxi-zosi7j',
      storageBucket: 'geo-taxi-zosi7j.appspot.com',
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final String? savedLanguage = prefs.getString('language');
  runApp(MyApp(savedLanguage: savedLanguage));
}

class LanguageProvider extends ChangeNotifier {
  Locale _locale;

  LanguageProvider(String? savedLanguage)
      : _locale = savedLanguage != null
            ? Locale(savedLanguage)
            : WidgetsBinding.instance.platformDispatcher.locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }
}

class MyApp extends StatelessWidget {
  final String? savedLanguage;
  const MyApp({Key? key, this.savedLanguage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(savedLanguage),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'GeoTaxi',
            theme: AppTheme.themeData,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,
            initialRoute: '/',
            routes: {
              '/': (context) => const ProfileCheckScreen(),
              '/language': (context) => const LanguageSelectionScreen(),
              '/home': (context) => const HomeScreen(),
              '/personal_information': (context) => const PersonalInformationScreen(userRole: 0),
              '/car_information': (context) => const CarInformationScreen(),
            },
          );
        },
      ),
    );
  }
}

class ProfileCheckScreen extends StatelessWidget {
  const ProfileCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return FutureBuilder<String?>(
            future: UserService.getNextRequiredScreen(snapshot.data!.uid),
            builder: (context, screenSnapshot) {
              if (screenSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (screenSnapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/${screenSnapshot.data}');
                });
                return Container();
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/home');
                });
                return Container();
              }
            },
          );
        } else {
          // User is not signed in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/language');
          });
          return Container();
        }
      },
    );
  }
}
