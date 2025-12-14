// Constantes de l'application
class AppConstants {
  AppConstants._();

  // Noms de l'application
  static const String appName = 'PayRent';
  static const String appVersion = '1.0.0';

  // Durées d'animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Tailles
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Limites
  static const int maxImageSizeMB = 10;
  static const int maxImagesPerBien = 10;
  static const int paginationLimit = 20;

  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencySymbol = 'FCFA';

  // Regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  static final RegExp phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
}

// Types de biens
class BienTypes {
  BienTypes._();

  static const String appartement = 'appartement';
  static const String maison = 'maison';
  static const String studio = 'studio';
  static const String villa = 'villa';
  static const String duplex = 'duplex';
  static const String localCommercial = 'local_commercial';
  static const String bureau = 'bureau';
  static const String terrain = 'terrain';

  static const List<String> all = [
    appartement,
    maison,
    studio,
    villa,
    duplex,
    localCommercial,
    bureau,
    terrain,
  ];

  static String getDisplayName(String type) {
    final map = {
      appartement: 'Appartement',
      maison: 'Maison',
      studio: 'Studio',
      villa: 'Villa',
      duplex: 'Duplex',
      localCommercial: 'Local commercial',
      bureau: 'Bureau',
      terrain: 'Terrain',
    };
    return map[type] ?? type;
  }
}

// Statuts des biens
class BienStatuts {
  BienStatuts._();

  static const String disponible = 'disponible';
  static const String occupe = 'occupe';
  static const String maintenance = 'maintenance';

  static const List<String> all = [disponible, occupe, maintenance];

  static String getDisplayName(String statut) {
    final map = {
      disponible: 'Disponible',
      occupe: 'Occupé',
      maintenance: 'En maintenance',
    };
    return map[statut] ?? statut;
  }
}

// Rôles utilisateur
class UserRoles {
  UserRoles._();

  static const String proprietaire = 'proprietaire';
  static const String locataire = 'locataire';

  static const List<String> all = [proprietaire, locataire];

  static String getDisplayName(String role) {
    final map = {
      proprietaire: 'Propriétaire',
      locataire: 'Locataire',
    };
    return map[role] ?? role;
  }
}

// Statuts des paiements
class PaiementStatuts {
  PaiementStatuts._();

  static const String enAttente = 'en_attente';
  static const String paye = 'paye';
  static const String retard = 'retard';
  static const String annule = 'annule';

  static const List<String> all = [enAttente, paye, retard, annule];

  static String getDisplayName(String statut) {
    final map = {
      enAttente: 'En attente',
      paye: 'Payé',
      retard: 'En retard',
      annule: 'Annulé',
    };
    return map[statut] ?? statut;
  }
}

// Statuts des plaintes
class PlainteStatuts {
  PlainteStatuts._();

  static const String ouverte = 'ouverte';
  static const String enCours = 'en_cours';
  static const String resolue = 'resolue';
  static const String fermee = 'fermee';

  static const List<String> all = [ouverte, enCours, resolue, fermee];

  static String getDisplayName(String statut) {
    final map = {
      ouverte: 'Ouverte',
      enCours: 'En cours',
      resolue: 'Résolue',
      fermee: 'Fermée',
    };
    return map[statut] ?? statut;
  }
}
