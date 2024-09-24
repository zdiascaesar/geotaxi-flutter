import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData themeData = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textLight,
        backgroundColor: AppColors.primary,
        minimumSize: const Size(160, 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: outlinedButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ButtonStyle languageButtonStyle({required bool isSelected}) {
    return isSelected
        ? ElevatedButton.styleFrom(
            foregroundColor: AppColors.textLight,
            backgroundColor: AppColors.primary,
            minimumSize: const Size(160, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          )
        : outlinedButtonStyle;
  }

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textDark,
    backgroundColor: AppColors.background,
    minimumSize: const Size(160, 42),
    side: BorderSide(color: AppColors.border, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  );

  static final ButtonStyle confirmEmailButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.textLight,
    backgroundColor: AppColors.primary,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  );

  static const TextStyle richTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textGray,
  );

  static const TextStyle richTextLinkStyle = TextStyle(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  // Code Confirmation Screen Styles
  static final InputDecoration codeInputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 12),
  );

  static final TextStyle codeConfirmationTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static final TextStyle codeConfirmationSubtitleStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textGray,
  );

  static final TextStyle codeConfirmationNumberStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static final ButtonStyle resendCodeButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppColors.textLight,
    backgroundColor: AppColors.primary,
    minimumSize: const Size(160, 42),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  );
}