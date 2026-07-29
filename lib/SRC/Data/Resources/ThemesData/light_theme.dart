import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Application/Utils/Extensions/responsive_font.dart';

import '../colors/app_colors.dart';

mixin LightTheme {
  static ThemeData getTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.onPrimaryColor,
        secondary: AppColors.secondaryColor,
        onSecondary: AppColors.descriptionColors,
        surface: AppColors.onPrimaryColor,
        onSurface: AppColors.titlesColor,
        error: AppColors.errorColor,
        onError: AppColors.lightModeErrorColor,
        onErrorContainer: AppColors.darkErrorColor,
        errorContainer: AppColors.lightModeErrorColor,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: AppColors.primaryColor,
          fontFamily: 'ScheherazadeNew-Bold',
          fontSize: 42.sp(context),
        ),
        titleMedium: TextStyle(
          color: AppColors.primaryColor,
          fontFamily: 'ScheherazadeNew-Medium',
          fontSize: 32.sp(context),
        ),
        bodyLarge: TextStyle(
          color: AppColors.titlesColor,
          fontFamily: 'ScheherazadeNew-Regular',
          fontSize: 12.sp(context),
        ),
        bodyMedium: TextStyle(
          color: AppColors.titlesColor,
          fontFamily: 'ScheherazadeNew-Medium',
          fontSize: 32.sp(context),
        ),
        labelMedium: TextStyle(
          color: AppColors.titlesColor,
          fontFamily: 'ScheherazadeNew-Regular',
          fontSize: 14.sp(context),
        ),
        labelLarge: TextStyle(
          color: AppColors.titlesColor,
          fontFamily: 'ScheherazadeNew-Regular',
          fontSize: 22.sp(context),
        ),

        bodySmall: TextStyle(
          color: AppColors.descriptionColors,
          fontFamily: 'ScheherazadeNew-Regular',
          fontSize: 16.sp(context),
        ),
      ),
      iconTheme: IconThemeData(size: 20, color: ColorScheme.light().onPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        labelStyle: TextStyle(
          color: ColorScheme.light().onPrimary,
          fontFamily: 'ScheherazadeNew-Regular',
          fontSize: 16.sp(context),
        ),
        activeIndicatorBorder: BorderSide(
          color: ColorScheme.light().onPrimary,
          width: 1,
          style: BorderStyle.solid,
        ),
        fillColor: ColorScheme.light().surface,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorScheme.light().secondary),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'ScheherazadeNew-Regular',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }
}
