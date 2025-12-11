// Fichier : lib/config/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // Importez votre classe de couleurs

// Police pour le logo "PayRent" uniquement
const String logoFontFamily = 'MuseoModerno';

final ThemeData appTheme = ThemeData(
  // 1. COULEURS PRINCIPALES
  // La couleur primaire est la couleur la plus proéminente de votre UI.
  primaryColor: AppColors.primaryDark, // #171810 (Noir Profond)

  // Police par défaut: Poppins (via Google Fonts)
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    bodyLarge: GoogleFonts.poppins(color: AppColors.textDark),
    bodyMedium: GoogleFonts.poppins(color: AppColors.textDark),
    bodySmall: GoogleFonts.poppins(color: AppColors.textDark),
    headlineLarge: GoogleFonts.poppins(color: AppColors.textDark),
    headlineMedium: GoogleFonts.poppins(color: AppColors.textDark),
    headlineSmall: GoogleFonts.poppins(color: AppColors.textDark),
    titleLarge: GoogleFonts.poppins(color: AppColors.textDark),
    titleMedium: GoogleFonts.poppins(color: AppColors.textDark),
    titleSmall: GoogleFonts.poppins(color: AppColors.textDark),
    labelLarge: GoogleFonts.poppins(color: AppColors.textDark),
    labelMedium: GoogleFonts.poppins(color: AppColors.textDark),
    labelSmall: GoogleFonts.poppins(color: AppColors.textDark),
  ),

  // La couleur de l'accentuation (boutons, sélections)
  // Utilisation de la couleur accentuée pour les actions importantes.
  colorScheme: ColorScheme.light(
    primary: AppColors
        .primaryDark, // Généralement la couleur principale de l'app bar
    secondary: AppColors
        .accentRed, // Couleur d'accentuation (Floating Action Buttons, etc.)
    surface: AppColors.backgroundLight, // Couleur des cartes et surfaces
    background: AppColors.backgroundLight, // Couleur de fond des écrans
    onPrimary: AppColors.textLight, // Couleur du texte sur la couleur primaire
    onSecondary: AppColors.textLight, // Couleur du texte sur l'accentuation
  ),

  // 2. FOND D'ÉCRAN
  scaffoldBackgroundColor: AppColors.backgroundLight, // Arrière-plan des pages

  // 3. THÈMES SPÉCIFIQUES AUX WIDGETS

  // Thème de l'AppBar (Barre de navigation)
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.textLight, // Texte (titre) et icônes sont blancs
    elevation: 0, // Pas d'ombre pour un look plat
    titleTextStyle: GoogleFonts.poppins(
      color: AppColors.textLight,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  // Thème des Boutons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentRed, // Boutons primaires en Rouge Foncé
      foregroundColor: AppColors.textLight, // Texte du bouton en Blanc
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    ),
  ),

  // Thème des Icônes
  iconTheme: const IconThemeData(
    color: AppColors.primaryDark,
  ),

  // 🔥 CORRECTION : Thème des Champs de Texte (Look moderne/flat)
  inputDecorationTheme: InputDecorationTheme(
    // Retirer les bordures par défaut pour un look plus clean
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryDark),
    ),
    focusedBorder: UnderlineInputBorder(
      // Bordure quand l'utilisateur tape
      borderSide: BorderSide(color: AppColors.accentRed, width: 2.0),
    ),
    enabledBorder: const UnderlineInputBorder(
      // Bordure normale
      borderSide: BorderSide(color: AppColors.primaryDark, width: 1.0),
    ),
    labelStyle:
        GoogleFonts.poppins(color: AppColors.primaryDark.withOpacity(0.7)),
    hintStyle:
        GoogleFonts.poppins(color: AppColors.primaryDark.withOpacity(0.5)),
    prefixIconColor: AppColors.primaryDark,
  ),
);
