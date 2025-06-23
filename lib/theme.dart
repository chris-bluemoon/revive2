import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static Color primaryColor = const Color.fromARGB(255, 255, 255, 255);
  static Color primaryAccent = const Color.fromRGBO(120, 14, 14, 1);
  static Color secondaryColor = const Color.fromARGB(255, 255, 255, 255);
  static Color secondaryAccent = const Color.fromARGB(255, 255, 255, 255);
  static Color titleColor = const Color.fromARGB(255, 0, 0, 0);
  static Color textColor = const Color.fromARGB(255, 0, 0, 0);
  static Color successColor = const Color.fromRGBO(9, 149, 110, 1);
  static Color highlightColor = const Color.fromRGBO(212, 172, 13, 1);
}

ThemeData primaryTheme = ThemeData(
  splashColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
  ),
  scaffoldBackgroundColor: AppColors.secondaryAccent,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.secondaryColor,
    foregroundColor: AppColors.textColor,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  ),
  textTheme: GoogleFonts.ralewayTextTheme().copyWith(
    bodyMedium: GoogleFonts.raleway(
      color: AppColors.textColor,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 1,
    ),
    headlineMedium: GoogleFonts.raleway(
      color: AppColors.titleColor,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
    titleMedium: GoogleFonts.raleway(
      color: AppColors.titleColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    titleLarge: GoogleFonts.raleway(
      color: AppColors.titleColor,
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  ),
);