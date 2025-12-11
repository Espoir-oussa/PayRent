// Fichier : lib/config/theme.dart

import 'package:flutter/material.dart';
import 'colors.dart'; // Importez votre classe de couleurs

final ThemeData appTheme = ThemeData(
  // 1. COULEURS PRINCIPALES
  primaryColor: AppColors.primaryDark,
  fontFamily: 'Poppins', // <-- Police par défaut

  // 2. COLOR SCHEME
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryDark,
    secondary: AppColors.accentRed,
    surface: AppColors.backgroundLight,
    background: AppColors.backgroundLight,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textLight,
  ),

  // 3. FOND D'ÉCRAN
  scaffoldBackgroundColor: AppColors.backgroundLight,

  // 4. THEME DES WIDGETS

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.textLight,
    elevation: 0,
  ),

  // Boutons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentRed,
      foregroundColor: AppColors.textLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    ),
  ),

  // TextTheme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark, fontFamily: 'Poppins'),
    bodyMedium: TextStyle(color: AppColors.textDark, fontFamily: 'Poppins'),
    headlineMedium: TextStyle(color: AppColors.textDark, fontFamily: 'Poppins'),
    titleLarge: TextStyle(color: AppColors.textDark, fontFamily: 'Poppins'),
    labelLarge: TextStyle(color: AppColors.textDark, fontFamily: 'Poppins'),
  ),

  // Icones
  iconTheme: const IconThemeData(
    color: AppColors.primaryDark,
  ),

  // Champs de texte
  inputDecorationTheme: InputDecorationTheme(
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryDark),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.accentRed, width: 2.0),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryDark, width: 1.0),
    ),
    labelStyle: TextStyle(
      color: AppColors.primaryDark.withOpacity(0.7),
      fontFamily: 'Poppins',
    ),
    hintStyle: TextStyle(
      color: AppColors.primaryDark.withOpacity(0.5),
      fontFamily: 'Poppins',
    ),
    prefixIconColor: AppColors.primaryDark,
  ),
);
