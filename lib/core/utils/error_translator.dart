// Fichier : lib/core/utils/error_translator.dart
// Service de traduction des erreurs en français

/// Classe utilitaire pour traduire les messages d'erreur en français
class ErrorTranslator {
  /// Traduit un message d'erreur en français
  static String translate(dynamic error) {
    final message = error.toString().toLowerCase();

    // ============================================================
    // ERREURS D'AUTHENTIFICATION APPWRITE
    // ============================================================

    // Erreurs de connexion
    if (message.contains('invalid credentials') ||
        message.contains('invalid email or password') ||
        message.contains('user_invalid_credentials')) {
      return 'Email ou mot de passe incorrect';
    }

    if (message.contains('user not found') ||
        message.contains('user_not_found')) {
      return 'Aucun compte trouvé avec cet email';
    }

    if (message.contains('invalid email') ||
        message.contains('email is invalid')) {
      return 'L\'adresse email n\'est pas valide';
    }

    if (message.contains('password must be') ||
        message.contains('password is too short') ||
        message.contains('password_too_short')) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    if (message.contains('password is too weak')) {
      return 'Le mot de passe est trop faible. Utilisez des lettres, chiffres et caractères spéciaux';
    }

    // Erreurs d'inscription
    if (message.contains('user already exists') ||
        message.contains('user_already_exists') ||
        message.contains('email already exists') ||
        message.contains('account already exists')) {
      return 'Un compte existe déjà avec cet email';
    }

    if (message.contains('email is required')) {
      return 'L\'adresse email est obligatoire';
    }

    if (message.contains('password is required')) {
      return 'Le mot de passe est obligatoire';
    }

    if (message.contains('name is required')) {
      return 'Le nom est obligatoire';
    }

    // Erreurs de session
    if (message.contains('unauthorized') ||
        message.contains('session not found') ||
        message.contains('user_unauthorized')) {
      return 'Session expirée. Veuillez vous reconnecter';
    }

    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('general_rate_limit_exceeded')) {
      return 'Trop de tentatives. Veuillez patienter quelques minutes';
    }

    if (message.contains('blocked') || message.contains('user_blocked')) {
      return 'Votre compte a été temporairement bloqué';
    }

    // ============================================================
    // ERREURS RÉSEAU
    // ============================================================

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no internet')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet';
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'La connexion a pris trop de temps. Réessayez';
    }

    if (message.contains('server error') ||
        message.contains('500') ||
        message.contains('internal server')) {
      return 'Erreur serveur. Veuillez réessayer plus tard';
    }

    if (message.contains('503') || message.contains('service unavailable')) {
      return 'Service temporairement indisponible. Réessayez dans quelques instants';
    }

    if (message.contains('404') || message.contains('not found')) {
      return 'Ressource non trouvée';
    }

    // ============================================================
    // ERREURS DE VALIDATION (Laravel)
    // ============================================================

    if (message.contains('the email field is required')) {
      return 'L\'adresse email est obligatoire';
    }

    if (message.contains('the password field is required')) {
      return 'Le mot de passe est obligatoire';
    }

    if (message.contains('the email has already been taken')) {
      return 'Cette adresse email est déjà utilisée';
    }

    if (message.contains('the email must be a valid email')) {
      return 'L\'adresse email n\'est pas valide';
    }

    if (message.contains('the password must be at least')) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    if (message.contains('the password confirmation does not match')) {
      return 'Les mots de passe ne correspondent pas';
    }

    if (message.contains('these credentials do not match')) {
      return 'Email ou mot de passe incorrect';
    }

    // ============================================================
    // ERREURS GÉNÉRIQUES
    // ============================================================

    if (message.contains('exception:')) {
      // Nettoie le préfixe "Exception:" des messages
      final cleanMessage = error
          .toString()
          .replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'^Error:\s*', caseSensitive: false), '')
          .trim();

      // Retourne le message nettoyé s'il est déjà en français ou compréhensible
      if (_looksLikeFrench(cleanMessage)) {
        return cleanMessage;
      }
    }

    // Message par défaut
    return 'Une erreur est survenue. Veuillez réessayer';
  }

  /// Vérifie si le message semble être en français
  static bool _looksLikeFrench(String message) {
    final frenchIndicators = [
      'veuillez',
      'erreur',
      's\'il vous',
      'impossible',
      'échec',
      'invalide',
      'obligatoire',
      'connexion',
      'compte',
      'mot de passe',
      'adresse',
      'email',
      'utilisateur',
    ];

    final lowerMessage = message.toLowerCase();
    return frenchIndicators
        .any((indicator) => lowerMessage.contains(indicator));
  }

  /// Traduit les erreurs de validation de formulaire
  static String? translateValidation(
    String? value,
    String fieldName, {
    bool required = true,
    int? minLength,
    int? maxLength,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    if (required && (value == null || value.isEmpty)) {
      return 'Le champ $fieldName est obligatoire';
    }

    if (value != null && value.isNotEmpty) {
      if (minLength != null && value.length < minLength) {
        return '$fieldName doit contenir au moins $minLength caractères';
      }

      if (maxLength != null && value.length > maxLength) {
        return '$fieldName ne peut pas dépasser $maxLength caractères';
      }

      if (isEmail && !_isValidEmail(value)) {
        return 'Veuillez entrer une adresse email valide';
      }

      if (isPhone && !_isValidPhone(value)) {
        return 'Veuillez entrer un numéro de téléphone valide';
      }
    }

    return null;
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool _isValidPhone(String phone) {
    // Format français ou international basique
    return RegExp(
            r'^[\+]?[(]?[0-9]{1,3}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$')
        .hasMatch(phone);
  }
}
