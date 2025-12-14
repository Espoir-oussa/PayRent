// Fichier : lib/config/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Couleurs Principales
  static const Color primaryDark = Color(0xFF171810); // Noir Profond (Base/Fond)
  static const Color accentRed = Color(0xFF5F2525); // Rouge Foncé (Accent/Action)
  static const Color backgroundLight = Color(0xFFFFFFFF); // Blanc Pur (Arrière-plan, Texte principal)
  static const Color primaryLight = Color(0xFFF3F4F8); // Gris très clair (pour fonds et cartes)

  // Couleurs de Support (déduites et utiles)
  static const Color textLight = backgroundLight; // Texte sur fond sombre (primaire)
  static const Color textDark = primaryDark;     // Texte sur fond clair (primaire)

  // Couleurs de Statut (Basées sur votre analyse)
  // Utiliser l'Accent pour les actions importantes ou les statuts "En Cours".
  static const Color statusOpen = accentRed; 
  static const Color statusResolved = Color(0xFF4CAF50); // Vert standard pour succès
  static const Color statusClosed = Color(0xFF9E9E9E);  // Gris pour clôture/inactif
}