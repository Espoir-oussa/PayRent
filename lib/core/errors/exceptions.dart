// Classe de base pour les erreurs de l'application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

// Erreur d'authentification
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});

  factory AuthException.invalidCredentials() =>
      const AuthException('Email ou mot de passe incorrect', code: 'INVALID_CREDENTIALS');

  factory AuthException.userNotFound() =>
      const AuthException('Utilisateur non trouvé', code: 'USER_NOT_FOUND');

  factory AuthException.emailAlreadyExists() =>
      const AuthException('Cet email est déjà utilisé', code: 'EMAIL_EXISTS');

  factory AuthException.weakPassword() =>
      const AuthException('Le mot de passe est trop faible', code: 'WEAK_PASSWORD');

  factory AuthException.sessionExpired() =>
      const AuthException('Session expirée, veuillez vous reconnecter', code: 'SESSION_EXPIRED');

  factory AuthException.notAuthenticated() =>
      const AuthException('Vous devez être connecté', code: 'NOT_AUTHENTICATED');
}

// Erreur réseau
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noConnection() =>
      const NetworkException('Pas de connexion internet', code: 'NO_CONNECTION');

  factory NetworkException.timeout() =>
      const NetworkException('La requête a expiré', code: 'TIMEOUT');

  factory NetworkException.serverError() =>
      const NetworkException('Erreur serveur', code: 'SERVER_ERROR');
}

// Erreur de validation
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.originalError,
  });

  factory ValidationException.requiredField(String fieldName) =>
      ValidationException('Le champ $fieldName est requis', code: 'REQUIRED_FIELD');

  factory ValidationException.invalidFormat(String fieldName) =>
      ValidationException('Format invalide pour $fieldName', code: 'INVALID_FORMAT');
}

// Erreur de stockage
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});

  factory StorageException.uploadFailed() =>
      const StorageException('Échec de l\'upload', code: 'UPLOAD_FAILED');

  factory StorageException.fileTooLarge() =>
      const StorageException('Fichier trop volumineux', code: 'FILE_TOO_LARGE');

  factory StorageException.invalidFileType() =>
      const StorageException('Type de fichier non supporté', code: 'INVALID_FILE_TYPE');
}

// Erreur de base de données
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.originalError});

  factory DatabaseException.notFound() =>
      const DatabaseException('Élément non trouvé', code: 'NOT_FOUND');

  factory DatabaseException.duplicateEntry() =>
      const DatabaseException('Cet élément existe déjà', code: 'DUPLICATE');

  factory DatabaseException.permissionDenied() =>
      const DatabaseException('Permission refusée', code: 'PERMISSION_DENIED');
}
