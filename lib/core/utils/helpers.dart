// Fonctions utilitaires diverses
import 'package:flutter/material.dart';

/// Classe utilitaire pour les validations
class Validators {
  Validators._();

  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  /// Valide un mot de passe
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }
    return null;
  }

  /// Valide un champ requis
  static String? required(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  /// Valide un numéro de téléphone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Valide un nombre positif
  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Nombre invalide';
    }
    if (number <= 0) {
      return 'Le nombre doit être positif';
    }
    return null;
  }
}

/// Classe utilitaire pour les messages
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    if (isError) {
      backgroundColor = Colors.red;
    } else if (isSuccess) {
      backgroundColor = Colors.green.shade600;
    } else {
      backgroundColor = Colors.grey.shade800;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }
}

/// Classe utilitaire pour le debounce
class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  bool _isRunning = false;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _action = action;
    if (!_isRunning) {
      _isRunning = true;
      Future.delayed(delay, () {
        _isRunning = false;
        _action?.call();
      });
    }
  }

  void cancel() {
    _action = null;
  }
}
