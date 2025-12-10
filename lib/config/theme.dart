// Fichier : lib/config/theme.dart

import 'package:flutter/material.dart';
import 'colors.dart'; // Importez votre classe de couleurs

final ThemeData appTheme = ThemeData(
  // 1. COULEURS PRINCIPALES 
  // La couleur primaire est la couleur la plus proéminente de votre UI.
  primaryColor: AppColors.primaryDark, // #171810 (Noir Profond)
  fontFamily: 'MuseoModerno',

  // La couleur de l'accentuation (boutons, sélections)
  // Utilisation de la couleur accentuée pour les actions importantes.
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryDark,        // Généralement la couleur principale de l'app bar
    secondary: AppColors.accentRed,        // Couleur d'accentuation (Floating Action Buttons, etc.)
    surface: AppColors.backgroundLight,    // Couleur des cartes et surfaces
    background: AppColors.backgroundLight, // Couleur de fond des écrans
    onPrimary: AppColors.textLight,        // Couleur du texte sur la couleur primaire
    onSecondary: AppColors.textLight,      // Couleur du texte sur l'accentuation
  ),
  
  // 2. FOND D'ÉCRAN
  scaffoldBackgroundColor: AppColors.backgroundLight, // Arrière-plan des pages

  // 3. THÈMES SPÉCIFIQUES AUX WIDGETS

  // Thème de l'AppBar (Barre de navigation)
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.textLight, // Texte (titre) et icônes sont blancs
    elevation: 0, // Pas d'ombre pour un look plat
  ),

  // Thème des Boutons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentRed, // Boutons primaires en Rouge Foncé
      foregroundColor: AppColors.textLight, // Texte du bouton en Blanc
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    ),
  ),

  // Thème du Texte (Lisibilité)
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark, fontFamily: 'MuseoModerno'),
    bodyMedium: TextStyle(color: AppColors.textDark, fontFamily: 'MuseoModerno'),
    headlineMedium: TextStyle(color: AppColors.textDark, fontFamily: 'MuseoModerno'),
    titleLarge: TextStyle(color: AppColors.textDark, fontFamily: 'MuseoModerno'),
    // Le texte par défaut sur fond blanc sera Noir Profond
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
    focusedBorder: UnderlineInputBorder( // Bordure quand l'utilisateur tape
      borderSide: BorderSide(color: AppColors.accentRed, width: 2.0),
    ),
    enabledBorder: const UnderlineInputBorder( // Bordure normale
      borderSide: BorderSide(color: AppColors.primaryDark, width: 1.0),
    ),
    labelStyle: TextStyle(color: AppColors.primaryDark.withOpacity(0.7), fontFamily: 'MuseoModerno'),
    hintStyle: TextStyle(color: AppColors.primaryDark.withOpacity(0.5), fontFamily: 'MuseoModerno'),
    prefixIconColor: AppColors.primaryDark,
  ),
);