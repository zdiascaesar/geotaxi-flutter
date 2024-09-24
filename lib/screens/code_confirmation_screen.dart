import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'personal_information_screen.dart';
import 'dart:async';

class CodeConfirmationScreen extends StatefulWidget {
  final String email;
  final String verificationCode;
  final int userRole;

  const CodeConfirmationScreen({
    Key? key,
    required this.email,
    required this.verificationCode,
    required this.userRole,
  }) : super(key: key);

  @override
  _CodeConfirmationScreenState createState() => _CodeConfirmationScreenState();
}

class _CodeConfirmationScreenState extends State<CodeConfirmationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
    final localizations = AppLocalizations.of(context)!;
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
                style: AppTheme.resendCodeButtonStyle,
                onPressed: () {
                  setState(() {
                    _timerSeconds = 30;
                    _startTimer();
                  });
                },
                child: Text(localizations.resendCode),
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

  void _handleConfirm() {
    String enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode == widget.verificationCode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PersonalInformationScreen(userRole: widget.userRole),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect code. Please try again.')),
      );
    }
  }
}
