import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geotaxi_flutter/screens/language_selection_screen.dart';
import 'package:geotaxi_flutter/screens/onboarding_screen.dart';
import 'package:geotaxi_flutter/screens/role_selection_screen.dart';
import 'package:geotaxi_flutter/screens/registration_screen.dart';
import 'package:geotaxi_flutter/screens/login_screen.dart';
import 'package:geotaxi_flutter/screens/code_confirmation_screen.dart';
import 'package:geotaxi_flutter/screens/personal_information_screen.dart';
import 'package:geotaxi_flutter/screens/car_information_screen.dart';
import 'package:geotaxi_flutter/screens/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:geotaxi_flutter/providers/language_provider.dart';
import 'package:geotaxi_flutter/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();
  
  runApp(
    ChangeNotifierProvider.value(
      value: languageProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'GeoTaxi',
          theme: AppTheme.themeData,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ru', ''),
            Locale('tr', ''),
          ],
          locale: languageProvider.currentLocale,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return const HomeScreen();
              } else {
                return const LanguageSelectionScreen();
              }
            },
          ),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/role_selection': (context) => const RoleSelectionScreen(),
            '/login': (context) => const LoginScreen(),
            '/car_information': (context) => const CarInformationScreen(),
            '/home': (context) => const HomeScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/registration') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => RegistrationScreen(
                  role: args?['role'] ?? UserRole.passenger,
                ),
              );
            }
            if (settings.name == '/code_confirmation') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => CodeConfirmationScreen(
                  email: args?['email'] ?? '',
                  initialVerificationCode: args?['initialVerificationCode'] ?? '',
                  userRole: args?['userRole'] ?? 0,
                ),
              );
            }
            if (settings.name == '/personal_information') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => PersonalInformationScreen(
                  userRole: args?['userRole'] ?? 0,
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
