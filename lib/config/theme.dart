// Fichier : lib/config/theme.dart

import 'package:flutter/material.dart';
import 'colors.dart'; // Importez votre classe de couleurs

final ThemeData appTheme = ThemeData(
  // 1. COULEURS PRINCIPALES 
  // La couleur primaire est la couleur la plus proéminente de votre UI.
  primaryColor: AppColors.primaryDark, // #171810 (Noir Profond)
  
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
    bodyLarge: TextStyle(color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.textDark),
    headlineMedium: TextStyle(color: AppColors.textDark),
    titleLarge: TextStyle(color: AppColors.textDark),
    // Le texte par défaut sur fond blanc sera Noir Profond
  ),
  
  // Thème des Icônes
  iconTheme: const IconThemeData(
    color: AppColors.primaryDark, 
  ),
);