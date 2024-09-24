import 'dart:math';

class EmailVerificationService {
  static String generateVerificationCode() {
    Random random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  static Future<bool> sendVerificationEmail(String email, String code) async {
    // Simulate sending an email
    await Future.delayed(Duration(seconds: 2));
    print('Verification code $code sent to $email');
    return true;
  }
}