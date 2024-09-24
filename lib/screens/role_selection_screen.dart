import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'registration_screen.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

enum UserRole {
  passenger,
  driver,
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'lib/assets/header.svg',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.whoAreYou,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.defineYourRole,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: () => _navigateToRegistration(context, UserRole.driver),
                    style: AppTheme.outlinedButtonStyle,
                    child: Text(localizations.iAmDriver),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _navigateToRegistration(context, UserRole.passenger),
                    child: Text(localizations.iAmPassenger),
                  ),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => _navigateToLogin(context),
                    child: Text(localizations.alreadyHaveAccount),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegistration(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(role: role),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}