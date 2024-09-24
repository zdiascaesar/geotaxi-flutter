import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'role_selection_screen.dart';
import 'code_confirmation_screen.dart';
import '../services/email_verification_service.dart';
import '../services/user_service.dart';

class RegistrationScreen extends StatefulWidget {
  final UserRole role;

  const RegistrationScreen({Key? key, required this.role}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(localizations.registration, style: TextStyle(color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                'lib/assets/registration-header.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: localizations.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseEnterEmail;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return localizations.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: localizations.password),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseEnterPassword;
                        }
                        if (value.length < 6) {
                          return localizations.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(labelText: localizations.confirmPassword),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseConfirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return localizations.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: AppTheme.elevatedButtonStyle,
                      onPressed: _isLoading ? null : _handleRegistration,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(localizations.next),
                    ),
                    SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTheme.richTextStyle,
                        children: [
                          TextSpan(text: localizations.alreadyHaveAccount),
                          TextSpan(text: ' '),
                          TextSpan(
                            text: localizations.login,
                            style: AppTheme.richTextLinkStyle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user account with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Create user document in Firestore
        await UserService.createUser(userCredential.user!.uid, {
          'email': _emailController.text,
          'role': widget.role == UserRole.driver ? 1 : 0,
        });

        print('Generating verification code');
        String verificationCode = EmailVerificationService.generateVerificationCode();
        print('Verification code generated: $verificationCode');

        print('Sending verification email');
        bool emailSent = await EmailVerificationService.sendVerificationEmail(
          _emailController.text,
          verificationCode,
        );

        if (emailSent) {
          print('Verification email sent successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CodeConfirmationScreen(
                email: _emailController.text,
                initialVerificationCode: verificationCode,
                userRole: widget.role == UserRole.driver ? 1 : 0,
              ),
            ),
          );
        } else {
          print('Failed to send verification email');
          _showErrorSnackBar('Failed to send verification email. Please try again.');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showErrorSnackBar('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showErrorSnackBar('The account already exists for that email.');
        } else {
          _showErrorSnackBar('Error: ${e.message}');
        }
      } catch (e) {
        print('Unexpected error: $e');
        _showErrorSnackBar('An unexpected error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}