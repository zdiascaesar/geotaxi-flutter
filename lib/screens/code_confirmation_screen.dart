import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/email_verification_service.dart';
import 'personal_information_screen.dart';
import 'dart:async';

class CodeConfirmationScreen extends StatefulWidget {
  final String email;
  final String initialVerificationCode;
  final int userRole;

  const CodeConfirmationScreen({
    Key? key,
    required this.email,
    required this.initialVerificationCode,
    required this.userRole,
  }) : super(key: key);

  @override
  _CodeConfirmationScreenState createState() => _CodeConfirmationScreenState();
}

class _CodeConfirmationScreenState extends State<CodeConfirmationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  int _timerSeconds = 30;
  Timer? _timer;
  bool _isLoading = false;
  late String _currentVerificationCode;

  @override
  void initState() {
    super.initState();
    _currentVerificationCode = widget.initialVerificationCode;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(localizations.codeConfirmation, style: TextStyle(color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.codeSentToEmail,
              style: AppTheme.codeConfirmationTitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              widget.email,
              style: AppTheme.codeConfirmationSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.none,
                    decoration: AppTheme.codeInputDecoration,
                    readOnly: true,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              '${localizations.enterCode} (00:${_timerSeconds.toString().padLeft(2, '0')})',
              style: AppTheme.codeConfirmationSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (_timerSeconds == 0)
              ElevatedButton(
                style: AppTheme.elevatedButtonStyle,
                onPressed: _isLoading ? null : _handleResendCode,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(localizations.resendCode),
              ),
            Spacer(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              children: [
                ...List.generate(9, (index) => _buildDigitButton(index + 1)),
                _buildActionButton(Icons.backspace, AppColors.textDark, _handleBackspace),
                _buildDigitButton(0),
                _buildActionButton(Icons.check_circle, AppColors.primary, _handleConfirm),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitButton(int digit) {
    return TextButton(
      child: Text(
        digit.toString(),
        style: AppTheme.codeConfirmationNumberStyle,
      ),
      onPressed: () => _handleDigitInput(digit),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }

  void _handleDigitInput(int digit) {
    for (int i = 0; i < 4; i++) {
      if (_controllers[i].text.isEmpty) {
        _controllers[i].text = digit.toString();
        break;
      }
    }
  }

  void _handleBackspace() {
    for (int i = 3; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        _controllers[i].clear();
        break;
      }
    }
  }

  Future<void> _handleConfirm() async {
    final localizations = AppLocalizations.of(context);
    String enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode == _currentVerificationCode) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Update email verification status in Firebase Authentication
          await user.sendEmailVerification();

          // Update user document in Firestore
          await UserService.updateUser(user.uid, {'emailVerified': true});

          // Navigate to PersonalInformationScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PersonalInformationScreen(userRole: widget.userRole),
            ),
          );
        } else {
          throw Exception('User not found');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying email: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.incorrectCode)),
      );
    }
  }

  Future<void> _handleResendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String newVerificationCode = EmailVerificationService.generateVerificationCode();
      bool emailSent = await EmailVerificationService.sendVerificationEmail(
        widget.email,
        newVerificationCode,
      );

      if (emailSent) {
        setState(() {
          _currentVerificationCode = newVerificationCode;
          _timerSeconds = 30;
          _startTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code resent successfully')),
        );
      } else {
        throw Exception('Failed to send verification email');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending verification code: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
