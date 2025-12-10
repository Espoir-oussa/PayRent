import 'package:flutter/material.dart';

class AppColors {
  // Palette personnalisée
  static const Color primaryDark =
      Color(0xFF171810); // Couleur sombre principale
  static const Color accentRed = Color(0xFF5f2525); // Accent rouge/marron
  static const Color backgroundLight = Color(0xFFffffff); // Fond blanc

  // Statuts avec couleurs dérivées
  static const Color statusOpen = accentRed; // Ouverte - Accent rouge
  static const Color statusReceived = primaryDark; // Réception - Sombre
  static const Color statusInProgress =
      Color(0xFF8B3A3A); // En cours - Variation accent
  static const Color statusResolved =
      Color(0xFF2D2D26); // Résolue - Variation sombre
  static const Color statusClosed = Color(0xFF4A4A42); // Fermée - Gris sombre

  // Couleurs de texte
  static const Color textLight = Color(0xFFffffff); // Texte clair
  static const Color textDark = Color(0xFF171810); // Texte sombre
}
